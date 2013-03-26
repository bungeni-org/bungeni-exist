xquery version "3.0";

module namespace workflow="http://exist.bungeni.org/workflowfunctions";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace ev="http://www.w3.org/2001/xml-events" ;

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $workflow:CXT := request:get-context-path();
declare variable $workflow:RESTXQ := request:get-context-path() || "/restxq";
declare variable $workflow:REST-CXT-APP :=  $workflow:CXT || $appconfig:REST-APP-ROOT;
declare variable $workflow:REST-BC-LIVE :=  $workflow:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;
declare variable $workflow:REST-CXT-MODELTMPL := $workflow:REST-CXT-APP || "/model_templates";


declare function local:get-workflow($doctype) as node() * {
    let $workflow := doc($appconfig:WF-FOLDER || "/" || $doctype || ".xml")/workflow
    return $workflow
};

(: creates the output for all document facets :)
declare function local:facets($doctype) as node() * {
    let $facets := local:get-workflow($doctype)/facet
    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc",""))
    let $docpos := xs:integer(request:get-parameter("pos",""))
    let $count := count($facets)
    for $facet at $pos in $facets
        return
            <li>
                <a class="editlink" href="facet.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;attr={$pos}&amp;node={data($facet/@name)}">{data($facet/@name)}</a>
                &#160;<a class="edit" href="#" title="Edit facet"><i class="icon-edit add"></i></a>
                &#160;
                <a class="delete" href="/exist/restxq/workflow/{$docname}/facet/{$pos}" title="Delete facet"><i class="icon-cancel-circled"></i></a>
            </li>
};

(: creates the output for all document states :)
declare function local:states($doctype) as node() * {
    let $states := local:get-workflow($doctype)/state
    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc",""))
    let $docpos := xs:integer(request:get-parameter("pos",""))
    let $count := count($states)
    for $state at $pos in $states
        return
            <li>
                <a class="editlink" href="state.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;attr={$pos}&amp;node={data($state/@id)}">{data($state/@title)}</a>
                &#160;
                <a class="delete" href="/exist/restxq/workflow/{$docname}/state/{data($state/@id)}" title="Delete state"><i class="icon-cancel-circled"></i></a>
            </li>
};

declare function local:get-form($docname as xs:string) as node() * {
    doc($appconfig:FORM-FOLDER || '/' || $docname || '.xml')
};

(: creates the output for all document transitions sources :)
declare function local:transition-to-from($doctype, $nodename) as node() * {

    for $transition at $pos in local:get-workflow($doctype)/transition
    where $transition/sources/source[. = $nodename] | $transition/destinations/destination[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: reused to render the destination and source transition tables below :)
declare function local:render-row($doctype as xs:string, $nodename as xs:string, $pos as xs:integer, $transition as node()) as node() * {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("node",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    let $sources :=  for $src in $transition/sources/source
                    return 
                        if($src/text() = $nodename) then
                            <span class="xposeGreen">{$src/text()}</span>
                        else
                            <span>{$src}&#160;</span>
    let $destinations :=  for $dest in $transition/destinations/destination
                    return 
                        if($dest/text() = $nodename) then
                            <span class="xposeGreen">&#160;{$dest/text()}</span>
                        else
                            <span>{$dest}&#160;</span>                            
    return 
    <tr>
        <td>
            { 
                if(contains($transition/sources/source,$NODENAME)) then
                    <a class="editlink" href="transition-edit.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;from={$NODENAME}&amp;nodepos={$pos}">{data($transition/@title)}</a>
                else
                    <span>{data($transition/@title)}</span>             
            }
        </td>
        <td>{$sources}</td>
        <td>{$destinations}</td>
    </tr>
};

(: creates the output for all document transitions sources :)
declare function local:arrow-direction($doctype as xs:string, $nodepos as xs:integer, $nodename as xs:string) as node() * {

    let $workflow := local:get-workflow($doctype)
    let $state := data($workflow/transition[$nodepos]/@title)
    
    let $source-state-ids := $workflow/transition[$nodepos]/sources/source/text()
    let $source-state-titles := for $id in $source-state-ids return data($workflow/state[@id eq $id]/@title)
    
    let $title := data($workflow/state[@id eq $nodename]/@title)
    return
        if (empty($workflow/transition[$nodepos]/sources/source[. = $nodename])) then 
            (: <- :)
            <h4 title="Arrow points to the source(s)">{string-join($source-state-titles,", ")} &#8592; {$title}</h4>
        else 
            (: -> :)
            <h4 title="Arrow points to the destination">{$title} &#8594; {$state}</h4>
};

declare function local:mode() as xs:string {
    let $doc := request:get-parameter("doc", "nothing")

    let $mode := if($doc eq "undefined") then "new"
                 else "edit"

    return $mode
};

declare function local:get-permissions() {

    let $docname := xs:string(request:get-parameter("doc","none"))
    return
        doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")
    
};

declare function local:workflow() {

    let $docname := xs:string(request:get-parameter("doc","none"))
    let $doc := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")/workflow
    return 
        $doc
    
};

(:
    Wrapper function to retrieve the existing facest
:)
declare function local:get-facets() as node()* {

    let $attr := xs:integer(request:get-parameter("attr",0))
    return 
        local:existing-facets($attr)        
};

(:
    The functions generates <facet/>s based on the allowed roles in the workflow,
    It forms the basis when adding a new state and also used to incorporate new changes to existing 
    <facet/>s in subsequent renderings
:)
declare function local:generated-facets($roles as node()+, $perm-actions as node()+,$name as xs:string*) {

    for $role in $roles/role[./@name ne 'ALL' and data(./@name) ne '']
    group by $key := data($role/@name)
    return
        (:<roles keys="{$role/@key}" name="{$role[1]/@name}" state-id="{$name}" />:)
        <facet name="{$name}_{replace(data($role[1]/@name),'[.]','')}" role="{data($role[1]/@name)}">
            {
                for $perm at $pos in $perm-actions
                let $beshown := string-length(data($role[@key eq $perm]/@name))
                return
                    switch($perm)
            
                    case '.View' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role>{data($role[@key eq $perm]/@name)}</role>
                            </roles>
                        </allow>
                    case '.Edit' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role>{data($role[@key eq $perm]/@name)}</role>
                            </roles>
                        </allow>
                    case '.Add' return 
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role>{data($role[@key eq $perm]/@name)}</role>
                            </roles>
                        </allow>
                    case '.Delete' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role>{data($role[@key eq $perm]/@name)}</role>
                            </roles>
                        </allow>
                    default return
                        ()                   
            }
        </facet>

};
(:
    This method retrives all the existing facets in the current workflow
    that belong to the given state position. It tries to incorporate any new global 
    permission changes that might have been enabled or disabled since last modifications
:)
declare function local:existing-facets($stateid as xs:integer) {

    let $attr := xs:integer(request:get-parameter("attr",0))
    let $doc := local:workflow()
    
    let $name := data($doc/state[$attr]/@id)
    let $perm-actions := $doc/permActions/permAction
    let $roles :=   <roles> 
                    {
                        for $role in $doc/allow/roles/role
                        return 
                        <role key="{$role/ancestor::allow/@permission}" name="{$role}" />
                    }
                    </roles>    
    let $generated-facets := local:generated-facets($roles,$perm-actions,$name)
    
    for $facete in $doc/facet
    let $role : = data($facete/@role)    
    where starts-with($facete/@name, $name)
    return
        if (some $facetg in $generated-facets satisfies $facetg/@name = $facete/@name) then 
            element facet {
                attribute name { $facete/@name },
                attribute role { $facete/@role },
               
                for $allow in $facete/allow
                return 
                    switch($allow/@show)
                    case 'true' return
                        (: check if the permission has been rescinded to false() since last time because true() means it was there before :)
                        (:if ($generated-facets[@name = $facete/@name]/allow[@permission = $allow/@permission]/@show = 'false') then :)
                        if (some $allowrole in $doc/allow[@permission = $allow/@permission]/roles/role[. ne ''] satisfies $allowrole/text() = '') then 
                            <allow permission="{$allow/@permission}" show="false">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                        else 
                            $allow                               
                    case 'false' return
                        if ($generated-facets[@name = $facete/@name]/allow[@permission = $allow/@permission]/roles/role/text() != '' ) then 
                            <allow permission="{$allow/@permission}" show="true">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>                              
                        else 
                            <allow permission="{$allow/@permission}" show="{$allow/@show}">
                                <roles originAttr="roles">
                                    <role>{$allow/roles/role/text()}</role>
                                </roles>
                            </allow>                                
                    default return
                        ()
            }
        else 
        (: else it has been removed in global grants so it disappears also in the the states that had it :)
            ()        
};

(: This method does a diff between existing-facets and generated ones to return any
    new roles that have been added since last modifications to state facets were made 
:)
declare function local:new-facets($generated-facets as node()+) {

    let $attr := xs:integer(request:get-parameter("attr",0))
    for $facetg in $generated-facets
    return
    if (some $facete in local:existing-facets($attr) satisfies $facete/@name = $facetg/@name) then 
        ()
    else 
        $facetg

};

(:
    Generates <facet/>s the first time a state is created. Puts the all the 
    available options but as false i.e. not set but permissible
:)
declare function local:gen-facets() as node()* {

    let $docname := xs:string(request:get-parameter("doc","none"))
    let $attr := xs:integer(request:get-parameter("attr",0))
    let $state-pos := if($attr ne 0) then $attr else "last()"    
    let $doc := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")/workflow
    let $perm-actions := $doc/permActions/permAction
    let $global-actions := string-join($perm-actions,' ')    
    let $name := data($doc/state[$state-pos]/@id)
    let $roles :=   <roles> 
                    {
                        for $role in $doc/allow/roles/role
                        return 
                        <role key="{$role/ancestor::allow/@permission}" name="{$role}" />
                    }
                    </roles>
                    
    for $role in $roles/role[./@name ne 'ALL' and data(./@name) ne '']
    group by $key := data($role/@name)
    return 
        <facet name="{$name}_{replace(data($role[1]/@name),'[.]','')}" role="{data($role[1]/@name)}">
            {
                for $perm at $pos in $perm-actions
                let $beshown := string-length(data($role[@key eq $perm]/@name))
                return
                    switch($perm)
            
                    case '.View' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Edit' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Add' return 
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Delete' return
                        <allow permission="{$perm/text()}" show="{if($beshown gt 2) then 'true' else 'false'}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    default return
                        ()                   
            }
        </facet>        
};

declare function local:all-feature() {
    <features> 
    {
        let $type := xs:string(request:get-parameter("type","doc"))
        let $docname := xs:string(request:get-parameter("doc","none"))
        let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
        let $featurename :=if (doc-available($wf-doc) and $type ne 'doc') then $docname else $type
        let $feats-tmpl := doc($appconfig:CONFIGS-FOLDER || "/workflows/.auto/" || "_features.xml")//features[@for eq $featurename]
        let $feats-wf := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")//feature   
        for $feature in $feats-tmpl/feature    
        return 
            if($feats-wf[@name eq data($feature/@name)]) then 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute enabled { if(data($feats-wf[@name eq data($feature/@name)]/@enabled)) then xs:string(data($feats-wf[@name eq data($feature/@name)]/@enabled)) else "false" },
                    (: if there are parameters, show them :)
                    $feats-wf[@name eq data($feature/@name)]/child::* 

                }
            else 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute enabled { "false" }
                } 
    }
    </features>
};

declare
function workflow:edit($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc","none"))   
    let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
    let $featuregroupname :=if (doc-available($wf-doc)) then $docname else $type
    let $pos := xs:string(request:get-parameter("pos",""))
    let $init := xs:string(request:get-parameter("init",""))
    let $laststate := count(doc($wf-doc)/workflow/state)
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model>
                    {
                        (: if adding a new workflow is true :)
                        if($init eq "true") then 
                            <xf:instance id="i-workflow" src="{$workflow:REST-CXT-MODELTMPL}/workflow.xml"/>
                        else
                            <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$docname}.xml"/> 
                    }
                    
                    <xf:instance id="URL-container" xmlns="">
                       <URL/>
                    </xf:instance>                    
                    
                    <xf:instance id="i-grants">
                        <data>
                            <allow permission=".Add">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".Edit">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".View">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".Delete">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>                          
                        </data>
                    </xf:instance>
                    
                    <xf:instance id="i-boolean" src="{$workflow:REST-CXT-MODELTMPL}/boolean.xml"/>                 
                    
                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>
                    
                    <xf:instance id="i-features" xmlns="">
                        <data>
                            {local:all-feature()}                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-tmplrole" xmlns="">
                        <data>
                            <roles>
                               <role/>                               
                            </roles>
                        </data>
                    </xf:instance> 

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="feature/@enabled" type="xf:boolean" />
                     
                        <xf:bind id="view" nodeset="allow[@permission eq '.View']/roles/role" type="xs:string" constraint="(instance()/allow[@permission eq '.View']/roles[count(role) eq count(distinct-values(role)) and count(role[text() = '']) lt 2])"/>
                        <xf:bind id="view" nodeset="allow[@permission eq '.Edit']/roles/role" type="xs:string" constraint="(instance()/allow[@permission eq '.Edit']/roles[count(role) eq count(distinct-values(role)) and count(role[text() = '']) lt 2])"/>
                        <xf:bind id="view" nodeset="allow[@permission eq '.Add']/roles/role" type="xs:string" constraint="(instance()/allow[@permission eq '.Add']/roles[count(role) eq count(distinct-values(role)) and count(role[text() = '']) lt 2])"/>
                        <xf:bind id="view" nodeset="allow[@permission eq '.Delete']/roles/role" type="xs:string" constraint="(instance()/allow[@permission eq '.Delete']/roles[count(role) eq count(distinct-values(role)) and count(role[text() = '']) lt 2])"/>                     
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$docname}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:submission id="s-delete" method="delete" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$docname}.xml'"/>
                        
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
                        
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Type deleted successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'type.html?type={$type}&#38;amp;doc={$docname}&#38;amp;pos={$pos}';
                            </script> 
                        </xf:action>
                        
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
                        
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>                    
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:action if="'{$init}' eq 'true'">
                            <xf:setvalue ref="instance()/@name" value="'{$docname}'"/>
                        </xf:action>
                        
                        <!-- drop and add workflow features -->
                        <xf:message level="ephemeral">drop all &lt;xmp&gt;&lt;feature&gt;&lt;/xmp&gt; nodes on workflow</xf:message>
                        <xf:delete nodeset="instance()/feature"/>
                        <xf:insert nodeset="instance()/allow[last()]" at="1" position="after" origin="instance('i-features')/features/feature" />                       
                        
                        <!-- add workflow permissions -->
                        <xf:action if="empty(instance()/allow[@permission eq '.View'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".View"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.View']" />
                        </xf:action>
                        <xf:action if="empty(instance()/allow[@permission eq '.Add'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Add"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Add']" />
                        </xf:action>                        
                        <xf:action if="empty(instance()/allow[@permission eq '.Edit'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Edit"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Edit']" />
                        </xf:action>          
                        <xf:action if="empty(instance()/allow[@permission eq '.Delete'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Delete"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Delete']" />
                        </xf:action>                           
                    </xf:action>

            </xf:model>
            
            </div>
            
            <div class="commit-holder">
                <a href="type.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <a class="commit" href="/exist/restxq/workflow/commit/{$docname}" title="save this file back to the filesystem">commit workflow</a>
            </div>   
                
            <div id="tabs_container">
                <ul id="tabs">
                    <li id="tabdetails" class="active"><a href="#details">Properties</a></li>
                    <li id="tabstates" ><a href="#states">States</a></li>
                    <li id="tabfacets" ><a href="#facets">Facets</a></li>
                </ul>
            </div>
            
            <div id="tabs_content_container">          
                <div id="details" class="tab_content" style="display: block;">
                    <xf:group ref="." appearance="bf:horizontalTable">
                        <xf:label>Workflow Properties</xf:label>
                        <xf:input id="wf-title" ref="@title" incremental="true">
                            <xf:label>Title</xf:label>
                            <xf:hint>edit title of the workflow</xf:hint>
                            <xf:alert>enter more than 3 characters</xf:alert>
                        </xf:input>   
                        <xf:textarea id="wf-description" ref="@description" appearance="growing" class="xLongwidthMax" incremental="true">
                            <xf:label>Description</xf:label>
                            <xf:hint>lengthy description of the workflow</xf:hint>
                            <xf:alert>invalid</xf:alert>
                        </xf:textarea>
                    </xf:group>
                    <hr/>
                    <xf:group ref="." appearance="bf:horizontalTable" style="width:500px;">
                        <xf:label>Features &amp; Tags</xf:label>
                        <xf:group appearance="bf:horizontalTable" style="width:500px;">
                            <xf:label>features</xf:label>
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Workflowed</xf:label>  
                                {
                                    for $feature in local:all-feature()/feature[@workflow eq 'True']
                                    return document {                                       
                                            <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled" incremental="true">
                                                <xf:label>{data($feature/@name)} </xf:label>
                                                <xf:hint>click to enabled this feature</xf:hint>
                                            </xf:input>,
                                            <xf:trigger appearance="minimal" class="feature-workflow">
                                                <xf:label>{data($feature/@name)} workflow&#160;</xf:label>
                                                <xf:hint>click to go the feature workflow</xf:hint>
                                                <xf:action ev:event="DOMActivate">
                                                    <xf:setvalue ref="instance('URL-container')" value="index.html"/>
                                                    <xf:load ref="instance('URL-container')"/>
                                                </xf:action>
                                                <xf:message level="ephemeral">The link trigger was clicked</xf:message>
                                            </xf:trigger>                                        
                                    }
                                }
                            </xf:group>
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Non-workflowed</xf:label>
                                {
                                    for $feature in local:all-feature()/feature[@workflow eq 'False']
                                    return 
                                        <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled">
                                            <xf:label>{data($feature/@name)} </xf:label>
                                        </xf:input>
                                }                                
                            </xf:group>
                        </xf:group>  
                    </xf:group>                    
                    <hr/>
                    <xf:group ref=".">
                        <xf:group appearance="compact" class="modesWrapper">
                            <xf:label>Global Grants</xf:label>
                            
                            <!-- view mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>View</xf:label>    
                                <xf:repeat id="r-viewfieldattrs" nodeset="allow[@permission eq '.View']/roles/role[position() != last()]"  startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant view on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger src="resources/images/delete.png">
                                        <xf:label>X</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-viewfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.View']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- edit mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Edit</xf:label>    
                                <xf:repeat id="r-editfieldattrs" nodeset="allow[@permission eq '.Edit']/roles/role[position() != last()]" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant edit on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger src="resources/images/delete.png">
                                        <xf:label>X</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-editfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Edit']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- add -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Add</xf:label>    
                                <xf:repeat id="r-addwfieldattrs" nodeset="allow[@permission eq '.Add']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant add on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger src="resources/images/delete.png">
                                        <xf:label>X</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-addfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Add']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                 
                            <!-- delete -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Delete</xf:label>    
                                <xf:repeat id="r-deletewfieldattrs" nodeset="allow[@permission eq '.Delete']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant delete on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger src="resources/images/delete.png">
                                        <xf:label>X</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-deletefieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Delete']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                                                   
                        </xf:group>             
                    </xf:group>
                    <hr/>
                    <xf:group appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>Update</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:delete nodeset="instance()/allow[count(roles/role) = 1]" /> 
                                <!--xf:delete nodeset="instance()/allow/roles/role[string-length(.) lt 2]" /--> 
                                <xf:send submission="s-add"/>
                            </xf:action>                                
                        </xf:trigger>  
                        <xf:group appearance="bf:verticalTable">                      
                             <xf:switch>
                                <xf:case id="delete">
                                   <xf:trigger ref="instance()/child::*">
                                      <xf:label>delete</xf:label>
                                      <xf:action ev:event="DOMActivate">
                                         <xf:toggle case="confirm" />
                                      </xf:action>
                                   </xf:trigger>
                                </xf:case>
                                <xf:case id="confirm">
                                   <h2>Are you sure you want to delete this workflow?</h2>
                                   <xf:group appearance="bf:horizontalTable">
                                       <xf:trigger>
                                          <xf:label>Delete</xf:label>
                                          <xf:action ev:event="DOMActivate">
                                            <xf:send submission="s-delete"/>
                                            <xf:toggle case="delete" />
                                          </xf:action>
                                       </xf:trigger>
                                       <xf:trigger>
                                            <xf:label>Cancel</xf:label>
                                            <xf:toggle case="delete" ev:event="DOMActivate" />
                                       </xf:trigger>
                                    </xf:group>
                                </xf:case>
                             </xf:switch>   
                        </xf:group>                        
                    </xf:group>                    
                    
                </div>
                <div id="states" class="tab_content">
                    <div class="ulisting">
                        <h2>States</h2>
                        <ul class="clearfix">
                            {local:states($docname)}
                        </ul>
                        <a class="button-link" href="state-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;attr=0">add state</a>                 
                    </div> 
                 </div>
                <div id="facets" class="tab_content">
                    <div class="ulisting">
                        <h2>Facets</h2>
                        <ul class="clearfix">
                            {local:facets($docname)}
                        </ul>
                    </div>
                </div>               
            </div>                 
        </div>
};

declare
function workflow:state-edit($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODE := xs:string(request:get-parameter("node",""))
    let $ATTR-ID := xs:integer(request:get-parameter("attr",0)) 
    
    let $WF-DOC := $appconfig:CONFIGS-FOLDER || "/workflows/" || $DOCNAME || ".xml"
    let $ATTR := if($ATTR-ID != 0) then $ATTR-ID else count(doc($WF-DOC)/workflow/state)    
    let $RETRIEVED-NAME := data(doc($WF-DOC)/workflow/state[$ATTR]/@id)    
    
    let $NODENAME := if($NODE eq 'new') then $RETRIEVED-NAME else $NODE
    let $no-existing-facets := count(local:get-facets())
    return
    	<div>
            <div style="display:none">
                 <xf:model id="master">
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>

                    <xf:instance id="i-alltags" src="{$workflow:REST-CXT-MODELTMPL}/_tags.xml"/>
                    
                    <xf:instance id="i-actions" src="{$workflow:REST-BC-LIVE}/workflows/.auto/_actions.xml"/>

                    <xf:instance id="i-actions-node" src="{$workflow:REST-CXT-MODELTMPL}/actions.xml"/>
                    
                    <xf:bind nodeset="./state[{$ATTR}]">
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 2" />                    
                        <xf:bind nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$')" />
                        <xf:bind nodeset="actions/action" type="xf:string" required="true()" constraint="count(instance()/state[{$ATTR}]/actions/action) eq count(distinct-values(instance()/state[{$ATTR}]/actions/action))" />                
                    </xf:bind>
                    <xf:bind nodeset="./facet/allow[@permission eq '.View']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" />
                    <xf:bind nodeset="./facet/allow[@permission eq '.Edit']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" />                  
                    <xf:bind nodeset="./facet/allow[@permission eq '.Add']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" />
                    <xf:bind nodeset="./facet/allow[@permission eq '.Delete']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" />                  
                    
                    <xf:instance id="i-facets">
                        <data xmlns="">
                            { 
                                (: if <facet/>s exist, get them :)
                                if(not(empty(local:workflow()/facet[starts-with(./@name, $NODENAME)]))) then 
                                    (local:get-facets(),local:new-facets(local:gen-facets()))
                                (: else generate them :)
                                else
                                    local:gen-facets()
                            }
                        </data>
                    </xf:instance>   
                    
                    <xf:instance id="i-facet">
                        <data>
                            <facet ref=""/>
                        </data>
                    </xf:instance>                

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>                   

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >  
                        <!-- Add the facets for a new state -->
                        {
                            (: if these <facet/>s don't exist on the current state, add them :)
                            if(empty(local:workflow()/facet[starts-with(./@name, $NODENAME)])) then 
                                for $facet at $pos in local:gen-facets()
                                let $allow := $facet/allow
                                where starts-with($facet/@name, $NODENAME)
                                return
                                    <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" at="last()" position="after" origin="instance('i-facet')/facet" />
                            (: the new <facet/>s to be added now :)
                            else if (not(empty(local:new-facets(local:gen-facets())))) then 
                                <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" at="last()" position="after" origin="instance('i-facet')/facet[position() >= {$no-existing-facets}]" />
                            else
                                ()
                        }               
                        <xf:action if="instance()/state[{$ATTR}]/actions/action[last()] ne ''">
                            <xf:message level="ephemeral">inserted an &lt;xmp&gt;&lt;action&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/actions/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions/action" /> 
                        </xf:action>                       
                        <xf:action if="empty(instance()/state[{$ATTR}]/actions)">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;actions&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions" />
                        </xf:action> 
                        {
                            (: if <facet/>s don't exist, add them :)
                            if(empty(local:workflow()/facet[starts-with(./@name, $NODENAME)])) then 
                                <xf:insert nodeset="instance()/feature" at="last()" position="after" origin="instance('i-facets')/facet" />
                            (: if <facet/>s exist on the current state, replace them :)
                            else if(local:workflow()/facet[starts-with(./@name, $NODENAME)]) then (
                                <xf:delete nodeset="instance()/facet[starts-with(./@name, '{$NODENAME}')]" />,
                                <xf:insert nodeset="instance()/feature" at="last()" position="after" origin="instance('i-facets')/facet" />
                            )   
                            (: if there are new <role/>s added on the workflow, incorporate them :)
                            else if (not(empty(local:new-facets(local:gen-facets())))) then 
                                <xf:insert nodeset="instance()/facet[starts-with(./@name, {$NODENAME})]" at="last()" position="after" origin="instance('i-facets')/facet[position() >= {$no-existing-facets}]" />                                
                            else
                                ()
                        }
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <div class="commit-holder">
                    <a href="workflow.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}#tabstates">
                        <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                    </a>
                    <a class="commit" href="/exist/restxq/workflow/commit/{$DOCNAME}" title="save this file back to the filesystem">commit workflow</a>
                </div>                  
                <br/>              
                <h1>state | <xf:output value="./state[{$ATTR}]/@id" class="transition-inline"/></h1>
                <br/>                
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="width:100%;">
                                <xf:group ref="./state[{$ATTR}]" appearance="bf:horizontalTable"> 
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:label>properties</xf:label>
                                        <xf:input id="state-id" ref="@id" incremental="true">
                                            <xf:label>ID</xf:label>
                                            <xf:hint>edit id of the workflow</xf:hint>
                                            <xf:help>Use A-z with the underscore character to avoid spaces</xf:help>
                                            <xf:alert>invalid: must be 3+ characters and A-z and _ allowed</xf:alert>
                                        </xf:input>                                         
                                        <xf:input id="state-title" ref="@title" incremental="true">
                                            <xf:label>Title</xf:label>
                                            <xf:hint>edit title of the workflow</xf:hint>
                                            <xf:help>... and no spaces in between words</xf:help>
                                            <xf:alert>enter more than 3 characters...</xf:alert>
                                        </xf:input>                                                                         
                                        <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                            <xf:label>Permission from state</xf:label>
                                           <xf:hint>where to derive permissions for state</xf:hint>
                                           <xf:help>select one</xf:help>
                                            <xf:itemset nodeset="instance()/state[data(@id) ne '{$NODENAME}']/@id">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1> 
                                    </xf:group>
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:label>actions</xf:label>
                                        <xf:repeat id="r-stateactions" nodeset="./actions/action[position() != last()]" appearance="compact">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:hint>a Hint for this control</xf:hint>
                                                <xf:alert>invalid: emtpy or non-unique tags</xf:alert>
                                                <xf:hint>tags should be unique</xf:hint>   
                                                <xf:itemset nodeset="instance('i-actions')/action">
                                                    <xf:label ref="."></xf:label>                                       
                                                    <xf:value ref="@name"></xf:value>
                                                </xf:itemset>
                                            </xf:select1>
                                            &#160;
                                            <xf:trigger src="resources/images/delete.png">
                                                <xf:label>X</xf:label>
                                                <xf:action>
                                                    <xf:delete at="index('r-stateactions')[position()]"></xf:delete>                                 
                                                </xf:action>
                                            </xf:trigger>                                  
                                        </xf:repeat>                                       
                                        <xf:trigger>
                                            <xf:label>add action</xf:label>
                                            <xf:action>
                                                <xf:insert ev:event="DOMActivate" nodeset="./actions/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions/action"/>
                                            </xf:action>
                                        </xf:trigger>
                                    </xf:group>
                                    
                                </xf:group>
                                <hr/>
                                <br/>
                                <h1>Manage Transitions</h1>
                                <div style="width:100%;" class="clearfix">
                                    <div style="float:left;width:60%;">
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th>transition name</th>
                                                <th>source(s)</th>
                                                <th>destination</th>
                                            </tr>
                                            {local:transition-to-from($DOCNAME, $NODENAME)}
                                        </table> 
                                        <div id="popup" style="display:none;">
                                            <div id="popupcontent" class="popupcontent"></div>
                                        </div>                                           
                                        <div style="margin-top:15px;"/>                                           
                                        <a class="button-link popup" href="transition-add.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;from={$NODENAME}">add transition</a>                                 
                                    </div>                                   
                                </div>
                                <hr/>
                                <br/>
                                <h1>Manage Permissions</h1>
                                <div style="width:100%;" class="clearfix">
                                    <div style="float:left;width:60%;">
                                        <xf:group>
                                            <table class="listingTable">
                                                <thead>
                                                    <tr>
                                                        <th>Roles</th>        
                                                        <th>View</th>
                                                        <th>Edit</th>
                                                        <th>Add</th>
                                                        <th>Delete</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                {
                                                    let $facets :=  if(not(empty(local:workflow()/facet[starts-with(./@name, $NODENAME)]))) then 
                                                                        (local:get-facets(),local:new-facets(local:gen-facets()))
                                                                    else
                                                                        local:gen-facets()
                                                    for $facet at $pos in $facets
                                                    let $allow := $facet/allow
                                                    order by $facet/@role ascending
                                                    return
                                                        <tr>
                                                            <td id="foo" class="one">
                                                                {data($facet/@role)}
                                                            </td>
                                                            <td class="permView">
                                                                <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.View']/roles/role" appearance="full" incremental="true">
                                                                    <xf:item>
                                                                        <xf:value>{data($facet/@role)}</xf:value>
                                                                    </xf:item>                                                            
                                                                </xf:select>
                                                            </td>
                                                            <td>
                                                                <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Edit']/roles/role" appearance="full" incremental="true">
                                                                    <xf:item>
                                                                        <xf:value>{data($facet/@role)}</xf:value>
                                                                    </xf:item>                                                            
                                                                </xf:select>
                                                            </td>
                                                            <td>
                                                                <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Add']/roles/role" appearance="full" incremental="true">
                                                                    <xf:item>
                                                                        <xf:value>{data($facet/@role)}</xf:value>
                                                                    </xf:item>                                                            
                                                                </xf:select>
                                                            </td>                                                        
                                                            <td>
                                                                <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Delete']/roles/role" appearance="full" incremental="true">
                                                                    <xf:item>
                                                                        <xf:value>{data($facet/@role)}</xf:value>
                                                                    </xf:item>                                                            
                                                                </xf:select>
                                                            </td>
                                                        </tr>                                                          
                                                }                                                                                                                                             
                                                </tbody>
                                            
                                            </table> 
                                            <div style="margin-top:15px;"/>                                           
                                            <xf:trigger>
                                                <xf:label>Save</xf:label>
                                                <xf:action>
                                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                                    <xf:delete nodeset="instance()/state[{$ATTR}]/actions/action[last() > 1]" at="last()" />
                                                    <!-- remove the actions node if there is jus the template action we insert -->
                                                    <xf:delete nodeset="instance()/state[{$ATTR}]/actions[string-length(action/text()) &lt; 2]" />
                                                    <!--xf:delete nodeset="instance()/state[{$ATTR}]/facet[not(contains(instance()/facet/@name,@ref))]" /-->
                                                    {
                                                        let $facets :=  if(not(empty(local:workflow()/facet[starts-with(./@name, $NODENAME)]))) then 
                                                                            (local:get-facets(),local:new-facets(local:gen-facets()))
                                                                        else
                                                                            local:gen-facets()                                                
                                                        for $facet at $pos in $facets
                                                        let $allow := $facet/allow
                                                        return
                                                            <xf:setvalue ref="instance()/state[{$ATTR}]/facet[{$pos}]/@ref" value="concat('.',instance()/facet[{$pos}]/@name)"/>
                                                    }                                                
                                                    <xf:send submission="s-add"/>
                                                    <xf:insert nodeset="instance()/state[{$ATTR}]/actions/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions/action" />
                                                </xf:action>                                
                                            </xf:trigger>
                                        </xf:group>                                 
                                    </div>    
                                </div>                                                                
                            </div>                       
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>        
};

declare
function workflow:state-add($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $ATTR := xs:integer(request:get-parameter("attr",0))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model id="master">
                    {
                        (: if its a new workflow meaning its not saved as yet :)
                        if(doc-available($appconfig:CONFIGS-FOLDER || "/workflows/" || $DOCNAME || ".xml")) then
                            <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                        else
                            <xf:instance id="i-workflow" src="{$workflow:REST-CXT-MODELTMPL}/workflow.xml"/>
                    }
                    
                    <xf:instance id="i-actions" src="{$workflow:REST-BC-LIVE}/workflows/.auto/_actions.xml"/>

                    <xf:instance id="i-actions-node" src="{$workflow:REST-CXT-MODELTMPL}/actions.xml"/>

                    <xf:instance id="i-state" src="{$workflow:REST-CXT-MODELTMPL}/state.xml"/>

                    <xf:bind nodeset="instance()/state[last()]">
                        <xf:bind nodeset="@id" type="xf:string" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and count(instance()/state/@id) eq count(distinct-values(instance()/state/@id))" />
                        <xf:bind nodeset="actions/action" type="xf:string" constraint="count(instance()/state[last()]/actions/action) eq count(distinct-values(instance()/state[last()]/actions/action))" />
                    </xf:bind>
                    
                    <!--xf:bind nodeset="./facet/allow[@permission eq '.View']/roles/role" relevant="data(../../@show) = 'true'" readonly="not(matches(instance()/state[last()]/@id, '^[a-z_]+$') and string-length(instance()/state[last()]/@id) &gt; 2)"/>
                    <xf:bind nodeset="./facet/allow[@permission eq '.Edit']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" readonly="not(matches(instance()/state[last()]/@id, '^[a-z_]+$') and string-length(instance()/state[last()]/@id) &gt; 2)"/>                  
                    <xf:bind nodeset="./facet/allow[@permission eq '.Add']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" readonly="not(matches(instance()/state[last()]/@id, '^[a-z_]+$') and string-length(instance()/state[last()]/@id) &gt; 2)" />
                    <xf:bind nodeset="./facet/allow[@permission eq '.Delete']/roles/role" constraint="boolean-from-string('true')" relevant="data(../../@show) = 'true'" readonly="not(matches(instance()/state[last()]/@id, '^[a-z_]+$') and string-length(instance()/state[last()]/@id) &gt; 2)" />                  
                    
                    <xf:instance id="i-facets">
                        <data xmlns="">
                            {local:gen-facets()}
                        </data>
                    </xf:instance-->                     

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow state added successfully. Hold on, loading permissions...</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr=0&#38;amp;node=new';
                            </script>                             
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready">  
                        <!-- insert a blank template state -->                
                        <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-state')/state" />
                        <!--xf:insert nodeset="instance()/feature" at="last()" position="after" origin="instance('i-facets')/facet" /--> 
                        <xf:setfocus control="state-title" />
                    </xf:action>                
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <a href="workflow.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}#tabstates">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>              
                <h1>state | <xf:output value="instance()/state[last()]/@id" class="transition-inline"/></h1>
                <br/>                
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="width:100%;">
                                <xf:group ref="instance()/state[last()]" appearance="bf:horizontalTable"> 
                                    <xf:group appearance="bf:verticalTable">   
                                        <xf:input id="state-id" ref="@id" incremental="true">
                                            <xf:label>ID</xf:label>
                                            <xf:hint>enter id of the new state</xf:hint>
                                            <xf:help>... and no spaces in between words or non-alphabets other than _</xf:help>
                                            <xf:alert>unique / not too short / lower-case a-z / use underscore to avoid spaces</xf:alert>
                                        </xf:input>                                      
                                        <xf:input id="state-title" ref="@title" incremental="true">
                                            <xf:label>Title</xf:label>
                                            <xf:hint>enter title of the state</xf:hint>
                                            <xf:help>... and no spaces in between words</xf:help>
                                            <xf:alert>enter more than 3 characters...</xf:alert>
                                        </xf:input>                                                                        
                                        <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                            <xf:label>Permission from state</xf:label>
                                           <xf:hint>where to derive permissions for state</xf:hint>
                                           <xf:help>select one</xf:help>
                                            <xf:itemset nodeset="instance()/state[xs:string(data(./@id)) ne xs:string(data(instance()/state[last()]/@id))]/@id">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1>  
                                    </xf:group>
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:repeat id="r-stateactions" nodeset="./actions/action[position() != last()]" appearance="compact">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:label>tags</xf:label>
                                                <xf:hint>a Hint for this control</xf:hint>
                                                <xf:alert>invalid: empty or non-unique tags</xf:alert>
                                                <xf:hint>tags should be unique</xf:hint>   
                                                <xf:itemset nodeset="instance('i-actions')/action">
                                                    <xf:label ref="."></xf:label>                                       
                                                    <xf:value ref="@name"></xf:value>
                                                </xf:itemset>
                                            </xf:select1>
                                            &#160;
                                            <xf:trigger src="resources/images/delete.png">
                                                <xf:label>X</xf:label>
                                                <xf:action>
                                                    <xf:delete at="index('r-stateactions')[position()]"></xf:delete>                                 
                                                </xf:action>
                                            </xf:trigger>                                  
                                        </xf:repeat>                                       
                                        <xf:trigger>
                                            <xf:label>add action</xf:label>
                                            <xf:action>
                                                <xf:insert nodeset="./actions/action"></xf:insert>
                                            </xf:action>
                                        </xf:trigger>
                                    </xf:group>
                                                                   
                                </xf:group>
                                <xf:trigger>
                                    <xf:label>Save</xf:label>
                                    <xf:action>
                                        <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                        <xf:send submission="s-add"/>
                                    </xf:action>                                
                                </xf:trigger>   
                                <hr/>
                            </div>                       
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>        
};


declare
function workflow:transition-add($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("from",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none;">
                <xf:model>         
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                    
                    <xf:instance id="i-conditions" src="{$workflow:REST-BC-LIVE}/workflows/.auto/_conditions.xml"/>                     

                    <xf:instance id="i-transition" src="{$workflow:REST-CXT-MODELTMPL}/transition.xml"/> 

                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>

                    <xf:instance id="i-originrole" src="{$workflow:REST-CXT-MODELTMPL}/roles.xml"/>                    
                    
                    <xf:bind nodeset="instance()/transition[last()]">
                        <xf:bind id="b-title" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <!--xf:bind nodeset="roles/role" type="xf:string" required="true()" constraint="count(instance()/transition[last()]/roles/role) eq count(distinct-values(instance()/transition[last()]/roles/role))" /-->
                        <xf:bind nodeset="@trigger" type="xf:string" required="true()" />
                        <xf:bind nodeset="@require_confirmation" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
                        
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >
                        <xf:setvalue ref="instance('i-transition')/transition/sources/source" value="'{$NODENAME}'"/>
                        <xf:insert nodeset="instance()/child::*[last()]" at="last()" position="after" origin="instance('i-transition')/transition" />                    
                    </xf:action>
                </xf:model>
            </div>
            <div style="width: 100%; height: 100%;">
                <a href="state.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;node={$NODENAME}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>    
                <div style="width:100%;margin-top:10px;">               
                    <xf:group ref="instance()/transition[last()]" appearance="bf:horizontalTable">                    
                        <xf:label><h1>transition | <xf:output value="@title" class="transition-inline"/></h1></xf:label>
                        <xf:label><h3>{$NODENAME} &#8594; <xf:output value="destinations/destination" class="transition-inline"/></h3></xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>type transition title</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input>                           
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                
                                <xf:itemset nodeset="instance()/state[xs:string(data(./@id)) ne '{$NODENAME}']/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                              
                            <xf:select1 ref="@trigger" appearance="minimal" incremental="true">
                                <xf:label>Triggered</xf:label>
                                <xf:hint>how this transition is triggered</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:item>
                                    <xf:label>by system</xf:label>
                                    <xf:value>system</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>manually</xf:label>
                                    <xf:value>manual</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>automatically</xf:label>
                                    <xf:value>automatic</xf:value>
                                </xf:item>                                
                            </xf:select1>                            
                            <xf:select1 ref="@condition" appearance="minimal" incremental="true">
                                <xf:label>Condition</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance('i-conditions')/condition">
                                <xf:label ref="."></xf:label>
                                <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                                <xf:message ev:event="xforms-valid" level="ephemeral">condition is valid.</xf:message>                             
                            </xf:select1>                              
                            <xf:input id="transition-confirm" ref="@require_confirmation">
                                <xf:label>Require&#160;confirmation</xf:label>
                                <xf:hint>support confirmation when making a transition</xf:hint>
                            </xf:input>                                
                            <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                <xf:label>Permission from state</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1> 
                        </xf:group>
                        
                        <xf:group appearance="bf:verticalTable" style="width:20%">
                            <xf:label><h3>roles</h3></xf:label>  
                            <xf:repeat id="r-transitionattrs" nodeset="roles/role[position()!=last()]" startindex="1" appearance="compact">
                                <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                    <xf:label>select a role</xf:label>
                                    <xf:help>help for roles</xf:help>
                                    <xf:alert>invalid: cannot have duplicates</xf:alert>
                                    <xf:itemset nodeset="instance('i-allroles')/role">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@name"></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                                <xf:trigger src="resources/images/delete.png">
                                    <xf:label>X</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-transitionattrs')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                            <br/>
                            <xf:group appearance="minimal">
                                <xf:trigger>
                                   <xf:label>add role</xf:label>
                                   <xf:action>
                                       <xf:insert nodeset="roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                   </xf:action>
                                </xf:trigger>     
                            </xf:group>
                        </xf:group>                          
                    
                    </xf:group>
                    <hr/>
                    <xf:trigger>
                        <xf:label>add transition</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>                                
                    </xf:trigger>                    
                </div>
            </div>
        </div>
};

declare
function workflow:transition-edit($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("from",""))
    let $NODEPOS := xs:string(request:get-parameter("nodepos",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none;">
                <xf:model>         
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                    
                    <xf:instance id="i-conditions" src="{$workflow:REST-BC-LIVE}/workflows/.auto/_conditions.xml"/>                     

                    <xf:instance id="i-originrole" src="{$workflow:REST-CXT-MODELTMPL}/roles.xml"/>

                    <xf:instance id='i-transition' xmlns="">
                        <data>
                           <transition title="" condition="" require_confirmation="false" trigger="manual" order="0"  note="Add a note">
                              <sources originAttr="source">
                                 <source/>
                              </sources>
                              <destinations originAttr="destination">
                                 <destination/>
                              </destinations>
                              <roles originAttr="roles">
                                 <role/>
                              </roles>
                           </transition>                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>                  
                    
                    <xf:bind nodeset="instance()/transition[{$NODEPOS}]">
                        <xf:bind id="b-title" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind id="b-order" nodeset="@order" type="xf:integer" required="true()" constraint="((. &lt; 100) and (. &gt; 0)) or (. = 0)" />
                        <xf:bind id="b-destination" nodeset="destinations/destination" type="xf:string" required="true()" constraint="xs:string(.) ne '{$NODENAME}'" />
                        <xf:bind nodeset="roles/role" type="xf:string" required="true()" constraint="count(instance()/transition[{$NODEPOS}]/roles/role) eq count(distinct-values(instance()/transition[{$NODEPOS}]/roles/role))" />
                        <xf:bind nodeset="@trigger" type="xf:string" required="true()" />
                        <xf:bind nodeset="@require_confirmation" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
                        
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Transition changes updated successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:submission id="s-delete" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
                        
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Transition deleted successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>                    

                    <xf:action ev:event="xforms-ready" >    
                        <xf:action if="empty(instance()/transition[{$NODEPOS}]/roles)">
                            <xf:message level="ephemeral">appended a template &lt;role/&gt; node</xf:message>
                            <xf:insert nodeset="instance()/transition[{$NODEPOS}]/roles/child::*" at="last()" position="after" origin="instance('i-originrole')/roles/role" /> 
                        </xf:action>                       
                        <!--xf:action if="empty(instance()/transition[{$NODEPOS}]/tags)">
                            <xf:message level="ephemeral">added &lt;roles/&gt; node</xf:message>
                            <xf:insert nodeset="instance()/transition[{$NODEPOS}]/child::*" at="last()" position="after" origin="instance('i-originrole')/roles" />
                        </xf:action-->                      
                    </xf:action>
                </xf:model>
            </div>
            <div style="width: 100%; height: 100%;">
                <div class="commit-holder">
                    <a href="state.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;node={$NODENAME}">
                        <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                    </a>
                    <a class="commit" href="/exist/restxq/workflow/commit/{$DOCNAME}" title="save this file back to the filesystem">commit workflow</a>
                </div>
                <br/>    
                <div style="width:100%;margin-top:10px;">               
                    <xf:group ref="instance()/transition[{$NODEPOS}]" appearance="bf:horizontalTable">                    
                        <xf:label><h1>transition | <xf:output value="@title" class="transition-inline"/></h1></xf:label>
                        <xf:label><h3>{$NODENAME} &#8594; <xf:output value="destinations/destination" class="transition-inline"/></h3>
                        </xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>transition name</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input>                       
                            <xf:output bind="b-order">
                                <xf:label>Order</xf:label>                                
                            </xf:output>     
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                   
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                               
                            <xf:select1 ref="@trigger" appearance="minimal" incremental="true">
                                <xf:label>Triggered</xf:label>
                                <xf:hint>how this transition is triggered</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:item>
                                    <xf:label>by system</xf:label>
                                    <xf:value>system</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>manually</xf:label>
                                    <xf:value>manual</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>automatically</xf:label>
                                    <xf:value>automatic</xf:value>
                                </xf:item>                                
                            </xf:select1>                            
                            <xf:select1 ref="@condition" appearance="minimal" incremental="true">
                                <xf:label>Condition</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance('i-conditions')/condition">
                                <xf:label ref="."></xf:label>
                                <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                                <xf:message ev:event="xforms-valid" level="ephemeral">condition is valid.</xf:message>                             
                            </xf:select1>                              
                            <xf:input id="transition-confirm" ref="@require_confirmation">
                                <xf:label>Require&#160;confirmation</xf:label>
                                <xf:hint>support confirmation when making a transition</xf:hint>
                            </xf:input>                                
                            <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                <xf:label>Permission from state</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1> 
                        </xf:group>    

                        <xf:group appearance="bf:verticalTable" style="width:20%">
                            <xf:label><h3>roles</h3></xf:label>  
                            <xf:repeat id="r-transitionattrs" nodeset="roles/role[position()!=last()]" startindex="1" appearance="compact">
                                <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                    <xf:label>select a role</xf:label>
                                    <xf:help>help for roles</xf:help>
                                    <xf:alert>invalid: cannot have duplicates</xf:alert>
                                    <xf:itemset nodeset="instance('i-allroles')/role">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@name"></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                                <xf:trigger src="resources/images/delete.png">
                                    <xf:label>X</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-transitionattrs')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                            <br/>
                            <xf:group appearance="minimal">
                                <xf:trigger>
                                   <xf:label>add role</xf:label>
                                   <xf:action>
                                       <xf:insert nodeset="roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                   </xf:action>
                                </xf:trigger>     
                            </xf:group>
                        </xf:group>                                                
                    </xf:group>
                     
                    <hr/>
                    <xf:group appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>update transition</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                                
                        </xf:trigger>
                        <xf:group appearance="bf:verticalTable">                      
                             <xf:switch>
                                <xf:case id="delete">
                                   <!-- don't display the delete trigger unless we have at lease one person -->
                                   <xf:trigger ref="instance()/transition[{$NODEPOS}]">
                                      <xf:label>remove transition</xf:label>
                                      <xf:action ev:event="DOMActivate">
                                         <xf:toggle case="confirm" />
                                      </xf:action>
                                   </xf:trigger>
                                </xf:case>
                                <xf:case id="confirm">
                                   <h2>Are you sure you want to remove this transition?</h2>
                                   <!--div id="content-for-deletion">
                                      <p>transition name: <xf:output ref="instance()/transition[{$NODEPOS}]/@title" /></p>
                                   </div-->
                                   <xf:group appearance="bf:horizontalTable">
                                       <xf:trigger>
                                          <xf:label>Delete</xf:label>
                                          <xf:action ev:event="DOMActivate">
                                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                            <xf:delete nodeset="instance()/transition[{$NODEPOS}]"/>
                                            <xf:send submission="s-delete"/>
                                            <xf:toggle case="delete" />
                                          </xf:action>
                                       </xf:trigger>
                                       <xf:trigger>
                                            <xf:label>Cancel</xf:label>
                                            <xf:toggle case="delete" ev:event="DOMActivate" />
                                       </xf:trigger>
                                    </xf:group>
                                </xf:case>
                             </xf:switch>   
                        </xf:group>
                    </xf:group>
                </div>
            </div>
        </div>
};
