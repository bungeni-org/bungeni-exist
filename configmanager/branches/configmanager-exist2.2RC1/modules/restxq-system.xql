xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmwfrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
(: external dependency to be installed :)
import module namespace gv = "http://kitwallace.co.uk/ns/graphviz" at "xmldb:exist:///db/apps/graphviz/lib/graphviz.xqm";
import module namespace sysmanager = "http://exist.bungeni.org/systemfunctions" at "xmldb:exist:///db/apps/configmanager/modules/system.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
declare variable $ce:data := $config:app-root || "/config_editor/bungeni_custom/workflows";
:)

(: COMMIT either types/roles.xml files which are at the root on the bungeni_custom folder to the filesystem :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/system/commit/{$name}")
function cmwfrest:commit-single-root($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $node := doc($appconfig:CONFIGS-FOLDER || "/" || $name || ".xml")/child::node()
    
    let $status := file:serialize($node,$appconfig:FS-PATH || "/" || $name || ".xml" ,
                                                "media-type=application/xml method=xml")
    return 
        $status
};

(: ACTIVATE a configuration in bungeni-configuration collections :)
declare 
    %rest:GET
    %rest:path("/system/activate/{$name}")
function cmwfrest:activate-single($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    (: copy import_... to live :)
    let $copy-to-live := xmldb:copy($appconfig:CONFIGS-COLLECTION || "/" || $name || "/" || $appconfig:CONFIGS-FOLDER-NAME, $appconfig:CONFIGS-ROOT-LIVE)
    (: now transform the live folder files :)
    let $storing := for $item in collection($appconfig:CONFIGS-ROOT-LIVE || "/" || $appconfig:CONFIGS-FOLDER-NAME) return fn:base-uri($item)
    let $transform-working-copy := sysmanager:transform-configs($storing)    
    (: update the config.xml with the new active import_... :)
    let $update-fs-live := update replace $appconfig:doc/ce-config/configs/fs-live/text() with $name

    return 
        <done>{$name}</done>
};

(: DELETE imported configuration in bungeni-configuration collections :)
declare 
    %rest:DELETE
    %rest:path("/system/delete/{$name}")
function cmwfrest:delete-single($name as xs:string) {

    let $active-name := $appconfig:doc/ce-config/configs/fs-live/text()
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    return 
        if($active-name ne $name) then 
            xmldb:remove($appconfig:CONFIGS-COLLECTION || "/" || $name)
        else
            "could not delete"
};

(:~
 : List all workflows and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/workflows")
    %rest:produces("application/xml", "text/xml")
function cmwfrest:workflows() {
    <workflows>
    {
        for $workflow in collection($appconfig:WF-FOLDER)/workflow
        return
            $workflow
    }
    </workflows>
};

(: DELETE a state in a workflow: subsequently transitions where it occurs... there is an attempt to remove it also :)
declare 
    %rest:DELETE
    %rest:path("/workflow/{$doc}/state/{$id}")
function cmwfrest:delete-state($doc as xs:string,$id as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
    return (
        update delete $doc/state[@id eq $id],
        update delete $doc/facet[starts-with(@name,$id)],
        (:update delete $doc/transition[destinations/destination eq $id],:)
        update delete $doc/transition[(count(destinations/destination) = 1) and destinations/destination eq $id],
        update delete $doc/transition/destinations/destination[(count(.) gt 1) and . eq $id],        
        update delete $doc/transition[(count(sources/source) = 1) and sources/source eq $id],
        update delete $doc/transition/sources/source[(count(.) gt 1) and . eq $id],
        $doc
    )
};

(: DELETE a facet in a workflow :)
declare 
    %rest:DELETE
    %rest:path("/workflow/{$doc}/facet/{$name}")
function cmwfrest:delete-facet($doc as xs:string,$name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
    let $facet-name := data($doc/facet[@name eq $name]/@name)
    return (
        update delete $doc/facet[@name eq $name],
        update delete $doc/state/facet[@ref eq "." || $facet-name],
        $doc
    )
};

(: Retrieve a workflow identified by a name. :)
declare 
    %rest:GET
    %rest:path("/workflow/{$name}")
function cmwfrest:get-workflow($name as xs:string) {
    collection($appconfig:FORM-FOLDER)/descriptor[@name = $name]
};

(: Delete a workflow identified by its name. :)
declare
    %rest:DELETE
    %rest:path("/workflow/{$name}")
function cmwfrest:delete-workflow($name as xs:string) {
    xmldb:remove($appconfig:WF-FOLDER, $name || ".xml"),
    cmwfrest:workflows()
};

(: Change transition order in the workflow's state :)
declare 
    %rest:GET
    %rest:path("/workflow/{$doc}/{$state}/transition/{$dir}/{$order}")
function cmwfrest:move-transition($doc as xs:string,
                                $state as xs:string,
                                $order as xs:integer,
                                $dir as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    return
        switch ($dir)
        
            case 'up' return 
                let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
                let $relegate := $doc/transition[sources/source eq $state and @order = xs:integer($order)]
                let $promote := $doc/transition[sources/source eq $state and @order = (xs:integer($order)-1)]
                return (
                    update replace $relegate/@order with (xs:integer($order)-1),                
                    update replace $promote/@order with xs:integer($order),
                    $doc
                )
                    
            case 'down' return 
                let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
                let $promote := $doc/transition[sources/source eq $state and @order = (xs:integer($order)+1)]                
                let $relegate := $doc/transition[sources/source eq $state and @order = xs:integer($order)]
                return (
                    update replace $promote/@order with xs:integer($order),                
                    update replace $relegate/@order with (xs:integer($order)+1),                
                    $doc
                )        
                    
            default return           
                () 
};

(: GRAPHVIZ generate workflow diagram :)
declare 
    %rest:GET
    %rest:path("/workflow/graphviz/{$name}")
function cmwfrest:graphviz-workflow($name as xs:string) {

    util:declare-option("exist:serialize", "method=xhtml media-type=application/xhtml+xml"),

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $name || ".xml")
    let $xsl := doc($appconfig:XSL || "/wf_to_dotml.xsl")
    let $dotml := transform:transform($doc, $xsl, ())
    let $svg :=  let $graph := gv:dotml-to-dot($dotml)
                 return  
                    gv:dot-to-svg($graph)
    return
        $svg
};

(: COMMIT a workflow to the filesystem. Every workflow is committed in company of types.xml and roles.xml :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/workflow/commit/{$name}")
function cmwfrest:commit-workflow($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $name || ".xml")/workflow
    let $roles := doc($appconfig:ROLES-XML)/roles
    let $types := doc($appconfig:TYPES-XML)/types
    (: workflow XSLT:)
    let $xslworkflow := appconfig:get-xslt("wf_merge_attrs.xsl")   
    
    let $null := file:serialize($roles,$appconfig:FS-PATH || "/roles.xml" ,
                                                "media-type=application/xml method=xml")    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status := file:serialize(transform:transform($doc, $xslworkflow, ()),
                                                $appconfig:FS-PATH || "/workflows/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};

(:~
 : Move a field in a form descriptor
 :)
declare 
    %rest:GET
    %rest:path("/form/{$doc}/{$field}/{$dir}")
function cmwfrest:move-field($doc as xs:string,
    $field as xs:string,
    $dir as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    return
        switch ($dir)
        
            case 'up' return 
                let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
                return (
                    update insert $doc/field[@name eq $field] preceding $doc/field[@name eq $field]/preceding-sibling::*[1],
                    update delete $doc/field[@name eq $field][2],
                    $doc
                )
                    
            case 'down' return 
                let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
                return (
                    update insert $doc/field[@name eq $field] following $doc/field[@name eq $field]/following-sibling::*[1],
                    update delete $doc/field[@name eq $field][1],
                    $doc
                )           
                    
            default return           
                () 
};

(:~
 : DELETE a field in a form descriptor
 :)
declare 
    %rest:DELETE
    %rest:path("/form/{$doc}/{$field}")
function cmwfrest:delete-field($doc as xs:string,$field as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
    return (
        update delete $doc/field[@name eq $field],
        $doc
    )
};

(:~
 : COMMIT a form to the filesystem. Every form is committed in the company of types.xml and roles.xml
 :)
declare 
    %rest:GET
    %rest:path("/form/commit/{$name}")
function cmwfrest:commit-form($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:FORM-FOLDER || "/" || $name || ".xml")/descriptor
    let $roles := doc($appconfig:ROLES-XML)/roles    
    let $types := doc($appconfig:TYPES-XML)/types
    (: form XSLTs:)
    let $step1forms := appconfig:get-xslt("forms_merge_step1.xsl")
    let $step2forms := appconfig:get-xslt("forms_merge_step2.xsl")  
    
    let $null := file:serialize($roles,$appconfig:FS-PATH || "/roles.xml" ,
                                                "media-type=application/xml method=xml")    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status :=  file:serialize(transform:transform(
                                                transform:transform($doc, $step1forms,()), $step2forms,()), 
                                                $appconfig:FS-PATH || "/forms/" || $name || ".xml",
                                                "media-type=application/xml method=xml")  
    return 
        $status
};

(: COMMIT a notification to the filesystem. :)
declare 
    %rest:GET
    %rest:path("/notification/commit/{$name}")
function cmwfrest:commit-notification($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:NOTIF-FOLDER || "/" || $name || ".xml")/notifications
    (: notification XSLT:)
    let $xslnotif := appconfig:get-xslt("notif_merge.xsl")
    let $status := file:serialize(transform:transform($doc, $xslnotif, ()),
                                                $appconfig:FS-PATH || "/notifications/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};

(: List all workspaces and return them as XML. :)
declare
    %rest:GET
    %rest:path("/workspace")
    %rest:produces("application/xml", "text/xml")
function cmwfrest:workspace() {
    <workspaces>
    {
        for $workspace in collection($appconfig:WS-FOLDER)/workspace
        return
            $workspace
    }
    </workspaces>
};

(: Delete a workspace identified by its name. :)
declare
    %rest:DELETE
    %rest:path("/workspace/{$name}")
function cmwfrest:delete-workspace($name as xs:string) {
    xmldb:remove($appconfig:WS-FOLDER, $name || ".xml"),
    cmwfrest:workspace()
};

(: COMMIT a workspace to the filesystem. Every workpspace is committed in company of types.xml :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/workspace/commit/{$name}")
function cmwfrest:commit-workspace($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WS-FOLDER || "/" || $name || ".xml")/workspace
    let $types := doc($appconfig:TYPES-XML)/types
    (: workspace XSLT:)
    let $xslworkspace := appconfig:get-xslt("ws_merge_attrs.xsl")   
    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status := file:serialize(transform:transform($doc, $xslworkspace, ()),
                                                $appconfig:FS-PATH || "/workspace/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};
