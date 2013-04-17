xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmwfrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
(: external dependency to be installed :)
import module namespace gv = "http://kitwallace.co.uk/ns/graphviz" at "xmldb:exist:///db/apps/graphviz/lib/graphviz.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
declare variable $ce:data := $config:app-root || "/config_editor/bungeni_custom/workflows";
:)

(: List all workflows and return them as XML. :)
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

(: COMMIT a workflow to the filesystem. Every workflow is committed in company of types.xml :)
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
    let $types := doc($appconfig:TYPES-XML)/types
    (: workflow XSLT:)
    let $xslworkflow := appconfig:get-xslt("wf_merge_attrs.xsl")   
    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status := file:serialize(transform:transform($doc, $xslworkflow, ()),
                                                $appconfig:FS-PATH || "/workflows/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};