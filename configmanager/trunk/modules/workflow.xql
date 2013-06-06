xquery version "3.0";

module namespace workflow="http://exist.bungeni.org/workflowfunctions";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace ce="http://bungeni.org/configeditor" ;

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
declare variable $workflow:REST-XML-RESOURCES :=  $workflow:CXT || $appconfig:REST-XML-RESOURCES;
declare variable $workflow:REST-CXT-MODELTMPL := $workflow:REST-CXT-APP || "/model_templates";

declare variable $workflow:TYPE := xs:string(request:get-parameter("type",""));
declare variable $workflow:DOCNAME := xs:string(request:get-parameter("doc",""));
declare variable $workflow:NODENAME := xs:string(request:get-parameter("node",""));
declare variable $workflow:FEATURE-FACET := xs:string(request:get-parameter("facet",""));
declare variable $workflow:ATTR-ID := xs:integer(request:get-parameter("attr",0));
declare variable $workflow:DOCPOS := xs:integer(request:get-parameter("pos",0));

declare function local:get-workflow($doctype) as node() * {
    let $workflow := doc($appconfig:WF-FOLDER || "/" || $doctype || ".xml")/workflow
    return $workflow
};

declare function local:external-facet($feature-name as xs:string) {

    let $doc := doc($appconfig:WF-FOLDER || "/" || $feature-name || ".xml")/workflow/facet
    for $facet in $doc
    return 
        <facet for="{$feature-name}" name="{$feature-name}.{$facet/@name}"/>
};

(: returns all the states nodes :)
declare function local:workflow-states($doctype) as node() * {
    let $states := local:get-workflow($doctype)/state
    for $state at $pos in $states
        return
            element state { 
                attribute id { data($state/@id) },
                attribute title { data($state/@title) }
            }
};

(: returns all the event types :)
declare function local:event-types() as node()* {
    for $event in doc($appconfig:TYPES-XML)/types/event
    return
        element eventType { 
            attribute name { data($event/@name) },        
            attribute workflow { data($event/@workflow) }
        }
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
                <a class="delete" href="/exist/restxq/workflow/{$docname}/facet/{data($facet/@name)}" title="Delete facet"><i class="icon-cancel-circled"></i></a>
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
declare function local:transition-src($doctype as xs:string, 
                                        $nodename as xs:string,
                                        $source as xs:boolean) as node() * {
    for $transition at $pos in local:get-workflow($doctype)/transition                 
    where $transition/sources/source[. = $nodename]
    order by $transition/@order ascending
    return
        <tr>
            <td><a class="editlink" title="edit transition" href="transition-edit.html?type={$workflow:TYPE}&amp;doc={$workflow:DOCNAME}&amp;pos={$workflow:DOCPOS}&amp;attr={$workflow:ATTR-ID}&amp;from={$workflow:NODENAME}&amp;nodepos={$pos}">{data($transition/@title)}</a></td>
            <td><span>{$transition/destinations/destination/text()}&#160;</span></td>
            <td title="{data($transition/@order)}">
                    <span style="float:right;">
                        <a class="up" href="{$workflow:RESTXQ}/workflow/{$workflow:DOCNAME}/{$workflow:NODENAME}/transition/up/"><i class="icon-up"/></a>
                        <a class="down" href="{$workflow:RESTXQ}/workflow/{$workflow:DOCNAME}/{$workflow:NODENAME}/transition/down/"><i class="icon-down"/></a>
                    </span>
            </td>
        </tr>        
};

declare function local:transition-dest($doctype as xs:string, 
                                        $nodename as xs:string,
                                        $source as xs:boolean) as node() * {
    for $transition at $pos in local:get-workflow($doctype)/transition
    
    let $sources :=  for $src in $transition/sources/source
                    return 
                        if($src/text() = $nodename) then
                            <span class="xposeGreen">{$src/text()}</span>
                        else
                            <span>{$src}&#160;</span>
                            
    where $transition/destinations/destination[. = $nodename]
    return
        <tr>
            <td><span>{data($transition/@title)}</span></td>
            <td>{$sources}</td>
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

declare function local:get-permissions() {

    let $docname := xs:string(request:get-parameter("doc","none"))
    return
        doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")
    
};

declare function local:workflow() {

    let $docname := xs:string(request:get-parameter("doc","none"))
    let $doc := doc($appconfig:WF-FOLDER || "/" || $docname || ".xml")/workflow
    return 
        $doc
};

declare function local:workflow-template() as node() * {
    let $workflow := doc($appconfig:MODEL-TEMPLATES || "/workflow.xml")/workflow
    return $workflow
};

(:
    Wrapper function to retrieve the existing facets
:)
declare function local:get-facets($docname as xs:string, $global as xs:boolean) as node()* {

        if ($global) then 
            local:existing-global-facets()
        else 
            local:existing-facets($docname)        
};

(:
    This method retrives all the existing facets in the current workflow
    that belong to the given state position. It tries to incorporate any new permission 
    changes that might have been enabled or disabled since last modifications
:)
declare function local:existing-facets($docname as xs:string) {

    (: feature-facets have a 'ext_' appended onto the workflow name :)
    let $new-docname := if(starts-with($docname,'ext_')) then 
                            substring-after($docname,'ext_') 
                        else 
                            $docname

    let $WF-DOC := local:get-workflow($new-docname)  
    (: for workflows proper either get the state facets by ID or the last 
        one in case of a newly injected ones. Have to test and and proof to eliminate the count()
        option since getting existing facets mean there isnt an option to get the last ones! :)
    let $ATTR := if($workflow:ATTR-ID != 0 and not(starts-with($docname,'ext_'))) then $workflow:ATTR-ID else count($WF-DOC/state)
    let $NAME := if(starts-with($docname,'ext_')) then $workflow:FEATURE-FACET else data($WF-DOC/state[$ATTR]/@id)
    
    for $facete in $WF-DOC/facet[@original-name eq $NAME]
    return
        element facet {
            attribute name { $facete/@name },
            attribute role { $facete/@role },
            attribute original-name { $NAME },
            $facete/allow
        }       
};

declare function local:existing-global-facets() {

    let $WF-DOC := local:workflow()
    let $NAME := "global"
    
    for $facete in $WF-DOC/facet   
    where starts-with($facete/@name, $NAME)
    return
        element facet {
            attribute name { $facete/@name },
            $facete/allow
        }       
};

(: This method does a diff between existing-facets and generated ones to return any
    new roles that have been added since last modifications to state facets were made 
:)
declare function local:new-facets($docname as xs:string?,$GENERATED-FACETS as node()+, $global as xs:boolean) {

    let $WF-DOC := local:get-workflow($docname)
    let $ATTR := if($workflow:ATTR-ID != 0) then $workflow:ATTR-ID else count($WF-DOC/state) 
    for $facetg in $GENERATED-FACETS
    return
        switch ($global)
        case true() return
            if (some $facete in local:existing-global-facets() satisfies ($facete/@name = $facetg/@name)) then 
                ()
            else 
                $facetg
        case false() return
            if (some $facete in local:existing-facets($docname) satisfies ($facete/@name = $facetg/@name)) then 
                ()
            else 
                $facetg
        default return
            ()
};

(:
    Generates <facet/>s the first time a state is created. Puts the all the 
    roles but as false i.e. not set but permissible
    @param global if the facent being made is for global-grant or state
:)
declare function local:gen-facets($docname as xs:string?,$global as xs:boolean) as node()* {

    (: feature-facets have a 'ext_' appended onto the workflow name:)
    let $new-docname := if(starts-with($docname,'ext_') and not($global)) then 
                            substring-after($docname,'ext_') 
                        else 
                            $docname
    let $WF-DOC := if($global) then local:workflow-template() else local:get-workflow($new-docname)
    let $ATTR := if($workflow:ATTR-ID != 0) then $workflow:ATTR-ID else count($WF-DOC/state)     
    
    let $perm-actions := $WF-DOC/permActions/permAction
    let $global-actions := string-join($perm-actions,' ')
    let $name :=if($global) then 
                    "global"
                else if(starts-with($docname,'ext_') and not($global)) then 
                    $new-docname
                else    
                    data($WF-DOC/state[$ATTR]/@id)
    let $log := util:log('debug',$new-docname)
    let $log := util:log('debug',"+++++++++++++++++++::::::::::::::::++++++++++++++++++")
                    
    let $original-name := if(starts-with($docname,'ext_')) then $workflow:FEATURE-FACET else $name
                    
    for $role in appconfig:roles()/role
    group by $key := data($role/@name)
    return 
        (:
            @original-name is added here because each facet is made of `stateid_roleid` and since 
            stateid also permit underscores, retrieving facets using that prefix brought problems 
            original-name allows all the local facets of a state while its in eXist-db be quickly 
            pulled and rendered on the grid.
        :)
        element facet         
            {
                attribute name { $name || "_" || data($role[1]/@name) },
                (: the `global_` facet does not need to have @original-name nor @role :)
                if($global) then () else attribute original-name { $original-name },
                if($global) then () else attribute role { data($role[1]/@name) },
                
                for $perm at $pos in $perm-actions
                let $beshown := string-length(data($role[@key eq $perm]/@name))
                return
                    switch($perm)
            
                    case '.View' return
                        <allow permission="{$perm/text()}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Edit' return
                        <allow permission="{$perm/text()}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Add' return 
                        <allow permission="{$perm/text()}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    case '.Delete' return
                        <allow permission="{$perm/text()}">
                            <roles originAttr="roles">
                                <role/>
                            </roles>
                        </allow>
                    default return
                        ()                   
            }     
};

declare function local:all-feature() {
    <features> 
    {
        let $type := xs:string(request:get-parameter("type","doc"))
        let $docname := xs:string(request:get-parameter("doc","none"))
        let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
        let $features-xml := $appconfig:XML-RESOURCES || "/features.xml" 
        let $features-schema := doc($features-xml)
        let $featurename :=if (doc-available($wf-doc) and $type ne 'doc') then $docname else $type
        let $feats-tmpl := doc($appconfig:CONFIGS-FOLDER || "/workflows/.auto/" || "_features.xml")//features[@for eq $featurename]
        let $feats-wf := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")//feature   
        for $feature in $feats-tmpl/feature 
        let $name := $features-schema/feature/@name
        let $params := if($features-schema/features/feature[@name eq $feature/@name]/parameter) then 'true' else 'false'
        return 
            if($feats-wf[@name eq data($feature/@name)]) then 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute params { $params },
                    attribute enabled { if(data($feats-wf[@name eq data($feature/@name)]/@enabled)) then xs:string(data($feats-wf[@name eq data($feature/@name)]/@enabled)) else "false" },
                    (: if there are parameters, show them :)
                    $feats-wf[@name eq data($feature/@name)]/child::* 
                }
            else 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute params { $params },
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
    
    let $no-existing-facets := count(local:get-facets($docname,true()))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model id="master">
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
                    
                    <xf:instance id="i-facets">
                        <data xmlns="">
                            { 
                                (: if <facet/>s exist, get them :)
                                if(not(empty(local:workflow()/facet[starts-with(./@name, "global")]))) then 
                                    (local:new-facets($docname,local:gen-facets((),true()),true()))
                                (: else generate them :)
                                else
                                    local:gen-facets((),true())
                            }
                        </data>
                    </xf:instance>                    
                                        
                    <xf:instance id="i-boolean" src="{$workflow:REST-CXT-MODELTMPL}/boolean.xml"/>                 
                    
                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>
                    
                    <xf:instance id="i-features" xmlns="">
                        {local:all-feature()}
                    </xf:instance>

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="feature/@enabled" type="xf:boolean" />
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp"  src="{$workflow:REST-CXT-MODELTMPL}/tmp.xml"/>

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
                        {
                            (: if facet references don't exist on the workflow, add them :)
                            if(empty(local:workflow()/facet[starts-with(./@name, "global")])) then 
                                for $facet at $pos in local:gen-facets((),true())
                                let $allow := $facet/allow
                                where starts-with($facet/@name, "global")
                                return
                                    <xf:insert nodeset="instance()/self::*" at="last()" position="after" origin="instance('i-facet')/facet" />
                            (: the new <facet/>s to be added now :)
                            else if (not(empty(local:new-facets($docname,local:gen-facets((),true()),true())))) then 
                                <xf:insert nodeset="instance()/self::*" at="last()" position="after" origin="instance('i-facet')/facet" />
                            else
                                ()
                        }                      
                        <xf:action if="'{$init}' eq 'true'">
                            <xf:setvalue ref="instance()/@name" value="'{$docname}'"/>
                        </xf:action>
                        
                        <!-- drop and add workflow features -->
                        <xf:message level="ephemeral">drop all &lt;xmp&gt;&lt;feature&gt;&lt;/xmp&gt; nodes on workflow</xf:message>
                        <xf:delete nodeset="instance()/feature"/>
                        <xf:insert nodeset="instance()/permActions" at="1" position="after" origin="instance('i-features')/feature" />   
                        {
                            (: if <facet/>s don't exist, add them :)
                            if(empty(local:workflow()/facet[starts-with(./@name, "global")])) then 
                                <xf:insert nodeset="instance()/permActions" at="last()" position="after" origin="instance('i-facets')/facet" />
                            (: if there are new <role/>s added, incorporate them :)
                            else if (not(empty(local:new-facets($docname,local:gen-facets((),true()),true())))) then 
                                <xf:insert nodeset="instance()/facet[starts-with(./@name, 'global')]" at="last()" position="after" origin="instance('i-facets')/facet" />                                
                            else
                                ()
                        }                        
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
                    <li id="tabgraphviz" data-type="/exist/restxq/workflow/graphviz/{$docname}" ><a href="#graphviz">Diagram</a></li>                    
                    <li id="tabfacets" ><a href="#facets">Facets</a></li>
                </ul>
            </div>
            
            <div id="tabs_content_container">          
                <div id="details" class="tab_content" style="display: block;">
                    <h2>Workflow Properties</h2>
                   
                    <xf:group ref="." appearance="bf:horizontalTable">
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
                        <xf:label>Features</xf:label>
                        <xf:group appearance="bf:verticalTable">
                            <xf:label>Workflowed</xf:label>  
                            {
                                for $feature at $pos in local:all-feature()/feature
                                return     
                                    if ($feature/@workflow eq 'True') then (
                                            if($feature/@params eq 'true') then 
                                                <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled" incremental="true">
                                                    <xf:label>
                                                        <xf:trigger appearance="minimal" class="{data($feature/@name)} feature-workflow">
                                                            <xf:label>{data($feature/@name)}&#160;</xf:label>
                                                            <xf:hint>click to go the feature workflow</xf:hint>
                                                            <xf:action ev:event="DOMActivate">
                                                                <!--xf:setvalue ref="instance('URL-container')" value="#"/>
                                                                <xf:load ref="instance('URL-container')"/-->
                                                                <xf:load show="embed" targetid="embeddedForm">
                                                                    <xf:resource value="'feature-subform.html?doc={$docname}&amp;index={$pos}&amp;feature={data($feature/@name)}'"/>
                                                                </xf:load>
                                                            </xf:action>
                                                            <xf:message level="ephemeral">Loading feature parameters. Hold on...</xf:message>
                                                        </xf:trigger>                                            
                                                    </xf:label>
                                                    <xf:hint>click to enable this feature</xf:hint>
                                                </xf:input>
                                            else
                                                <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled">
                                                    <xf:label>{data($feature/@name)} </xf:label>
                                                    <!-- !+NOTE (ao, June 6th 2013) Hardcoded enforcing of feature dependencies as it is not exported 
                                                        at the moment in order to determine all the known dependecies -->
                                                    <xf:action ev:event="xforms-value-changed" if="'{data($feature/@name)}' eq 'version'">
                                                        <xf:setvalue ref="instance()/feature[@name = 'attachment']/@enabled" value="instance()/feature[@name = 'version']/@enabled"/>
                                                        <xf:message level="ephemeral">Enabled dependent feature attachment</xf:message>
                                                    </xf:action> 
                                                    <xf:action ev:event="xforms-value-changed" if="'{data($feature/@name)}' eq 'attachment'">
                                                        <xf:setvalue ref="instance()/feature[@name = 'version']/@enabled" value="instance()/feature[@name = 'attachment']/@enabled"/>
                                                        <xf:message level="ephemeral">Enabled dependent feature version</xf:message>
                                                    </xf:action>                                                     
                                                </xf:input>                                    
                                    )
                                    else
                                        ()
                            }
                        </xf:group>
                        <xf:group appearance="bf:verticalTable">
                            <xf:label>Non-workflowed</xf:label>
                            {
                                for $feature at $pos in local:all-feature()/feature
                                return 
                                    if($feature/@workflow eq 'False') then
                                        (
                                            if($feature/@params eq 'true') then 
                                                <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled" incremental="true">
                                                    <xf:label>
                                                        <xf:trigger appearance="minimal" class="{data($feature/@name)} feature-workflow">
                                                            <xf:label>{data($feature/@name)}&#160;</xf:label>
                                                            <xf:hint>click to go the feature workflow</xf:hint>
                                                            <xf:action ev:event="DOMActivate">
                                                                <xf:load show="embed" targetid="embeddedForm">
                                                                    <xf:resource value="'feature-subform.html?doc={$docname}&amp;index={$pos}&amp;feature={data($feature/@name)}'"/>
                                                                </xf:load>
                                                            </xf:action>
                                                            <xf:message level="ephemeral">Loading feature parameters. Hold on...</xf:message>
                                                        </xf:trigger>                                            
                                                    </xf:label>
                                                    <xf:hint>click to enable this feature</xf:hint>                                                  
                                                </xf:input>
                                            else
                                                <xf:input ref="feature[@name eq '{$feature/@name}']/@enabled">
                                                    <xf:label>{data($feature/@name)} </xf:label>
                                                    <!-- !+NOTE (ao, June 6th 2013) Hardcoded enforcing of feature dependencies as it is not exported 
                                                        at the moment in order to determine all the known dependecies -->
                                                    <xf:action ev:event="xforms-value-changed" if="'{data($feature/@name)}' eq 'version'">
                                                        <xf:setvalue ref="instance()/feature[@name = 'attachment']/@enabled" value="instance()/feature[@name = 'version']/@enabled"/>
                                                        <xf:message level="ephemeral">Enabled dependent feature attachment</xf:message>
                                                    </xf:action> 
                                                    <xf:action ev:event="xforms-value-changed" if="'{data($feature/@name)}' eq 'attachment'">
                                                        <xf:setvalue ref="instance()/feature[@name = 'version']/@enabled" value="instance()/feature[@name = 'attachment']/@enabled"/>
                                                        <xf:message level="ephemeral">Enabled dependent feature version</xf:message>
                                                    </xf:action>                                                     
                                                </xf:input>
                                        )
                                    else
                                        ()
                            }                                
                        </xf:group>
                    </xf:group>                    
                    <hr/>
                    <div  style="width:50%;">
                        <h2>Global Grants</h2>
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
                                let $facets :=  if(not(empty(local:workflow()/facet[starts-with(./@name, "global")]))) then 
                                                    (local:get-facets($docname,true()),local:new-facets($docname,local:gen-facets((),true()),true()))
                                                else
                                                    local:gen-facets((),true())
                                for $facet at $pos in $facets
                                let $allow := $facet/allow
                                order by $facet/@name ascending
                                return
                                    <tr>
                                        <td id="foo" class="one">
                                            {substring-after($facet/@name,'_')}
                                        </td>
                                        <td class="permView">
                                            <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.View']/roles/role" appearance="full" incremental="true">
                                                <xf:item>
                                                    <xf:value>{substring-after($facet/@name,'_')}</xf:value>
                                                </xf:item>                                                            
                                            </xf:select>
                                        </td>
                                        <td>
                                            <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Edit']/roles/role" appearance="full" incremental="true">
                                                <xf:item>
                                                    <xf:value>{substring-after($facet/@name,'_')}</xf:value>
                                                </xf:item>                                                            
                                            </xf:select>
                                        </td>
                                        <td>
                                            <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Add']/roles/role" appearance="full" incremental="true">
                                                <xf:item>
                                                    <xf:value>{substring-after($facet/@name,'_')}</xf:value>
                                                </xf:item>                                                            
                                            </xf:select>
                                        </td>                                                        
                                        <td>
                                            <xf:select ref="instance()/facet[@name eq '{data($facet/@name)}']/allow[@permission eq '.Delete']/roles/role" appearance="full" incremental="true">
                                                <xf:item>
                                                    <xf:value>{substring-after($facet/@name,'_')}</xf:value>
                                                </xf:item>                                                            
                                            </xf:select>
                                        </td>
                                    </tr>                                                          
                            }                                                                                                                                             
                            </tbody> 
                        </table>                                                   
                    </div>
                    <hr/>
                    <xf:group appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>Update</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <!--xf:delete nodeset="instance()/allow/roles/role[string-length(.) lt 2]" /--> 
                                {
                                    let $facets :=  if(not(empty(local:workflow()/facet[starts-with(./@name, "global")]))) then 
                                                        (local:get-facets($docname,true()),local:new-facets($docname,local:gen-facets((),true()),true()))
                                                    else
                                                        local:gen-facets((),true())   
                                    for $facet at $pos in $facets                                   
                                    return
                                        <xf:setvalue ref="instance()/facet[@name eq {$facet/@name}]/@ref" value="concat('.',instance('i-facets')/facet[@name eq {$facet/@name}]/@name)"/>
                                }                                 
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
                <div id="graphviz" class="tab_content">
                    <h2>loading...</h2>
                </div>
                <div id="facets" class="tab_content">
                    <div class="ulisting">
                        <h2>Generated Facets</h2>
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
    
    let $WF-DOC := local:workflow()
    let $ATTR := if($workflow:ATTR-ID != 0) then $workflow:ATTR-ID else count($WF-DOC/state)    
    let $RETRIEVED-NAME := data($WF-DOC/state[$ATTR]/@id)
    
    let $NODENAME := if($NODE eq 'new') then $RETRIEVED-NAME else $NODE
    let $no-existing-facets := count(local:get-facets($DOCNAME,false()))
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
                        <xf:bind nodeset="@id" type="xf:string" required="true()" readonly="boolean-from-string('true')" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$')" />
                        <xf:bind nodeset="actions/action" type="xf:string" required="true()" constraint="count(instance()/state[{$ATTR}]/actions/action) eq count(distinct-values(instance()/state[{$ATTR}]/actions/action))" />                
                    </xf:bind>           
                    
                    <xf:instance xmlns="" id="i-permissions-manager">
                        <data>
                            <manager id="state"/>
                            <manager id="event"/>
                            <manager id="signatory"/>
                            <manager id="attachment"/>
                        </data> 
                    </xf:instance>
                    
                    <xf:instance id="i-vars">
                        <data xmlns="">
                            <value>state</value>
                        </data>
                    </xf:instance>                     
                    
                    <xf:instance id="i-facets">
                        <data xmlns="">
                            { 
                                (: if <facet/>s exist, get them :)
                                if(not(empty(local:workflow()/facet[@original-name eq $NODENAME]))) then 
                                    (local:get-facets($DOCNAME,false()),local:new-facets($DOCNAME,local:gen-facets($DOCNAME,false()),false()))
                                (: else generate them :)
                                else
                                    local:gen-facets($DOCNAME,false())
                            }
                        </data>
                    </xf:instance>                      
                    
                    <xf:instance id="i-facet" src="{$workflow:REST-CXT-MODELTMPL}/facet.xml"/>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp"  src="{$workflow:REST-CXT-MODELTMPL}/tmp.xml"/>                   

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
                        <xf:action if="not(exists(instance()/state[{$ATTR}]/actions))">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;actions&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" context="instance()/state[{$ATTR}]" at="last()" position="after" origin="instance('i-actions-node')/actions" />
                        </xf:action>                         
                        <xf:action if="instance()/state[{$ATTR}]/actions/action[last()] ne ''">
                            <xf:message level="ephemeral">inserted an &lt;xmp&gt;&lt;action&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/actions/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions/action" /> 
                        </xf:action>                       
                        {
                            (: if <facet/>s don't exist, add them :)
                            if(empty(local:workflow()/facet[@original-name eq $NODENAME])) then 
                                <xf:insert nodeset="instance()/feature" at="last()" position="after" origin="instance('i-facets')/facet" />
                            (: if <facet/>s exist on the current state, replace them :)
                            (:if(local:workflow()/facet[starts-with(./@name, $NODENAME)]) then (
                                <xf:delete nodeset="instance()/facet[starts-with(./@name, '{$NODENAME}')]" />,
                                <xf:insert nodeset="instance()/feature" at="last()" position="after" origin="instance('i-facets')/facet" />
                            ):) 
                            (: if there are new <role/>s added, incorporate them :)
                            else if (not(empty(local:new-facets($DOCNAME,local:gen-facets($DOCNAME,false()),false())))) then 
                                <xf:insert nodeset="instance()/facet[@original-name eq {$NODENAME}]" at="last()" position="after" origin="instance('i-facets')/facet" />                                 
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
                                                <xf:alert>invalid: emtpy or non-unique tags</xf:alert>
                                                <xf:hint>actions should be unique</xf:hint>   
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
                                        <h4 style="text-align:right;">&#8592;</h4>
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th style="width:40%">transition title</th>
                                                <th>source state</th>
                                            </tr>
                                            {local:transition-dest($DOCNAME, $NODENAME, true())}
                                        </table> 
                                        <div style="margin-top:15px;"/>
                                        <h4 style="text-align:right;">&#8594;</h4>   
                                        <table id="transitionSources" class="listingTable" style="width:100%;">
                                            <thead>
                                                <tr>                      			 
                                                    <th style="width:40%">transition title</th>
                                                    <th>destinations state</th>
                                                    <th style="width:8%">order</th>
                                                </tr>
                                            </thead>
                                            {local:transition-src($DOCNAME, $NODENAME, true())}
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
                                <h1>Manage Permissions
                                    <xf:select1 ref="instance('i-vars')/value" id="permissions-roller" class="inline-control xmediumWidth" incremental="true">
                                        <xf:hint>manage feature permissions</xf:hint>
                                        <xf:alert>invalid</xf:alert>
                                        <xf:itemset nodeset="instance('i-permissions-manager')/manager">
                                            <xf:label ref="@id"></xf:label>
                                            <xf:value ref="@id"></xf:value>
                                        </xf:itemset>                                      
                                    </xf:select1>   
                                    <xf:trigger appearance="compact" class="inline-control">
                                        <xf:label>LOAD&#160;</xf:label>
                                        <xf:hint>click to go the feature workflow</xf:hint>
                                        <!-- For this state permissions update -->
                                        <xf:action if="instance('i-vars')/value eq 'state'" ev:event="DOMActivate">
                                            <xf:load show="embed" targetid="permissions-grid">
                                                <xf:resource value="concat('permissions-subform.html?doc={$DOCNAME}&amp;state={$ATTR}&amp;facet={$NODENAME}&amp;attr={$ATTR}&amp;node={$NODENAME}&amp;feature=',instance('i-vars')/value)"/>
                                            </xf:load>
                                        </xf:action>         
                                        <!-- For feature permissions update -->
                                        <xf:action if="instance('i-vars')/value ne 'state'" ev:event="DOMActivate">
                                            <xf:load show="embed" targetid="permissions-grid">
                                                <xf:resource value="concat('permissions-subform.html?doc={$DOCNAME}&amp;state={$ATTR}&amp;facet={concat('ext_',$DOCNAME,'_',$NODE)}&amp;feature=ext_',instance('i-vars')/value)"/>
                                            </xf:load>
                                        </xf:action>
                                        <xf:message level="ephemeral">Loading this permissions. Hold on...</xf:message>
                                    </xf:trigger>                                     
                                </h1>
                                <div style="width:100%;" class="clearfix">
                                    <div style="float:left;width:50%;" id="permissions-grid">
                                        <xf:group>
                                            <xf:label>state</xf:label>
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
                                                    let $facets :=  if(not(empty(local:workflow()/facet[@original-name eq $NODENAME]))) then 
                                                                        (local:get-facets($DOCNAME,false()),local:new-facets($DOCNAME,local:gen-facets($DOCNAME,false()),false()))
                                                                    else
                                                                        local:gen-facets($DOCNAME,false())
                                                    for $facet at $pos in $facets
                                                    let $allow := $facet/allow
                                                    order by $facet/@name ascending
                                                    return
                                                        <tr>
                                                            <td class="one">
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
                                                <xf:label>Save state permissions</xf:label>
                                                <xf:action>
                                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                                    <xf:delete nodeset="instance()/state[{$ATTR}]/actions/action[last() > 1]" at="last()" />
                                                    <!-- remove the actions node if there is jus the template action we insert -->
                                                    <xf:delete nodeset="instance()/state[{$ATTR}]/actions[string-length(action/text()) &lt; 2]" />
                                                    <xf:send submission="s-add"/>
                                                    <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions" />
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
                    
                    <xf:instance id="i-transition" src="{$workflow:REST-CXT-MODELTMPL}/transition.xml" />

                    <xf:bind nodeset="instance()/state[last()]">
                        <xf:bind nodeset="@id" type="xf:string" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and not(starts-with(.,'global')) and count(instance()/state/@id) eq count(distinct-values(instance()/state/@id))" />
                        <xf:bind nodeset="actions/action" type="xf:string" constraint="count(instance()/state[last()]/actions/action) eq count(distinct-values(instance()/state[last()]/actions/action))" />
                    </xf:bind>                    

                    <xf:instance id="tmp"  src="{$workflow:REST-CXT-MODELTMPL}/tmp.xml"/>

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
                        <xf:action if="exists(instance()/state)">
                            <!-- subsequent states - this blank state routine is applied -->
                            <xf:insert nodeset="instance()/state" at="last()" position="after" origin="instance('i-state')/state" />
                        </xf:action>   
                        <xf:action if="not(exists(instance()/state))">
                            <!-- first state - this blank state routine is applied -->
                            <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-state')/state" />
                        </xf:action>   
                        
                        <!--    if there is no transition means that its the first state so add transition with 
                                transition with an empty source -->
                        <xf:action if="not(exists(instance()/transition))">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;transition&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-transition')/transition" />
                        </xf:action>                         
                        <xf:setfocus ev:event="DOMActivate" control="state-id" />
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
                                        <xf:action if="count(instance()/state) = 1">
                                            <xf:setvalue ref="instance()/transition/destinations/destination" value="instance()/state[last()]/@id"/>
                                            <xf:setvalue ref="instance()/transition/@trigger" value="'automatic'"/>
                                            <xf:setvalue ref="instance()/transition/@title" value="'Create {$DOCNAME}'"/>
                                            <xf:setvalue ref="instance()/transition/@note" value="'initial transition from none'"/>
                                            <xf:delete nodeset="instance()/transition/roles"/>
                                            <xf:delete nodeset="instance()/transition/@condition"/>
                                            <xf:delete nodeset="instance()/transition/@order"/>
                                            <xf:delete nodeset="instance()/transition/@require_confirmation"/>
                                            <!-- remove the actions node if there is jus the template action we insert -->
                                            <xf:delete nodeset="instance()/state[last()]/actions[string-length(action/text()) &lt; 2]" />                                            
                                        </xf:action>
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
    let $ORDER-NO := count(local:get-workflow($workflow:DOCNAME)/transition/sources/source[. = $NODENAME])+1
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

                    <xf:instance id="tmp"  src="{$workflow:REST-CXT-MODELTMPL}/tmp.xml"/>
                    
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
                        <xf:label><h1>{$NODENAME} &#8594; <xf:output value="destinations/destination" class="transition-inline"/></h1></xf:label>                    
                        <xf:label><h3>transition | <xf:output value="@title" class="transition-inline"/></h3></xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>                           
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                
                                <xf:itemset nodeset="instance()/state[xs:string(data(./@id)) ne '{$NODENAME}']/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>            
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>type transition title</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input>         
                            <xf:textarea id="transition-note" ref="@note" incremental="true">
                                <xf:label>Transition Note</xf:label>
                                <xf:hint>add a note...</xf:hint>
                                <xf:alert>invalid</xf:alert>
                            </xf:textarea>                              
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
                            <xf:setvalue ref="instance()/transition[last()]/@order" value="'{$ORDER-NO}'"/>
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

                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>                  
                    
                    <xf:bind nodeset="instance()/transition[{$NODEPOS}]">
                        <xf:bind id="b-title" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind id="b-order" nodeset="@order" type="xf:integer" required="true()" constraint="((. &lt; 100) and (. &gt; 0)) or (. = 0)" />
                        <xf:bind id="b-destination" nodeset="destinations/destination" type="xf:string" required="true()" constraint="xs:string(.) ne '{$NODENAME}'" />
                        <xf:bind nodeset="roles/role" type="xf:string" required="false()" constraint="count(instance()/transition[{$NODEPOS}]/roles/role[. ne '']) eq count(distinct-values(instance()/transition[{$NODEPOS}]/roles/role[. ne '']))" />
                        <xf:bind nodeset="@trigger" type="xf:string" required="true()" />
                        <xf:bind nodeset="@require_confirmation" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp"  src="{$workflow:REST-CXT-MODELTMPL}/tmp.xml"/>
                    
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
                        <xf:label><h1>{$NODENAME} &#8594; <xf:output value="destinations/destination" class="transition-inline"/></h1>
                        <xf:label><h3>transition | <xf:output value="@title" class="transition-inline"/></h3></xf:label>
                        </xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                   
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                              
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>transition name</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input>   
                            <xf:textarea id="transition-note" ref="@note" incremental="true">
                                <xf:label>Transition Note</xf:label>
                                <xf:hint>add a note...</xf:hint>
                                <xf:alert>invalid</xf:alert>
                            </xf:textarea>                             
                            <xf:output bind="b-order">
                                <xf:label>Order</xf:label>                                
                            </xf:output>                             
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

declare
function workflow:feature-subform($node as node(), $model as map(*)) {

    let $docname := xs:string(request:get-parameter("doc",""))
    let $index := xs:integer(request:get-parameter("index",6))
    let $feature-name := xs:string(request:get-parameter("feature",""))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model id="m-feature" ev:event="xforms-revalidate" ev:defaultAction="cancel">
                   <xf:instance xmlns="" id="i-feature-params">
                       <feature/>
                   </xf:instance>
                   
                    <xf:instance xmlns="" id="i-parameter-values">
                        <data>
                            <parameter name="" value=""/>
                        </data>
                    </xf:instance> 
                    
                    <xf:instance id="i-downtypes" src="{$workflow:REST-BC-LIVE}/workflows/.auto/_downtypes.xml"/>
                    
                    <xf:instance id="i-features-schema" src="{$workflow:REST-XML-RESOURCES}/features.xml"/>
                    
                    <xf:instance xmlns="" id="i-eventtypes">
                        <eventTypes>
                            <eventType name="event" workflow="event"/>
                            {local:event-types()}
                        </eventTypes>
                    </xf:instance>                    
                    
                    <xf:instance xmlns="" id="i-states">
                        <states>
                            {local:workflow-states($docname)}
                        </states>
                    </xf:instance>
                    
                   <xf:bind id="b-param-name" nodeset="@name" readonly="true()" type="xs:string"/>
                   <xf:bind id="b-param-values" nodeset="@value" type="xs:string"/>
                   <xf:bind id="b-min-signatories" nodeset="parameter[@name = 'min_signatories']/@value" type="xs:integer"/>
                   <xf:bind id="b-max-signatories" nodeset="parameter[@name = 'max_signatories']/@value" type="xs:integer"/>
                   
                   <xf:submission id="s-load-from-master" resource="model:master#instance('i-workflow')/workflow/feature[{$index}]" replace="instance" method="get">
                       <xf:message ev:event="xforms-submit-done" level="ephemeral">feature's parameters editor loaded</xf:message>
                   </xf:submission>
                   <xf:submission id="s-update-master" resource="model:master#instance('i-workflow')/workflow/feature[{$index}]" replace="none" method="post">
                       <xf:message ev:event="xforms-submit-done" level="ephemeral">feature's parameters saved</xf:message>
                       <xf:action ev:event="xforms-submit-done">
                            <script type="text/javascript">
                                deselect();
                            </script>
                       </xf:action>                       
                       <xf:message ev:event="xforms-submit-error" level="ephemeral">Sorry - your update failed.</xf:message>
                   </xf:submission>
                   <xf:send ev:event="xforms-ready" submission="s-load-from-master"/>
                   
                    <xf:action ev:event="xforms-ready" >                   
                        <xf:action if="not(instance()/parameter)">
                            <xf:insert nodeset="instance()/child::*" context="instance()" at="1" position="after" origin="instance('i-features-schema')/feature[@name = '{$feature-name}']/parameter" />
                        </xf:action>
                       <xf:action if="'{$feature-name}' = 'signatory'">
                           <xf:action if="not(contains(string-join(instance('i-feature-params')/parameter/@name,'\s'),'min_signatories'))">
                                <xf:insert nodeset="instance()/child::*" context="instance()" at="1" position="after" origin="instance('i-features-schema')/feature[@name = '{$feature-name}']/parameter[@name = 'min_signatories']" />
                            </xf:action>  
                           <xf:action if="not(contains(string-join(instance('i-feature-params')/parameter/@name,'\s'),'max_signatories'))">
                                <xf:insert nodeset="instance()/child::*" context="instance()" at="1" position="after" origin="instance('i-features-schema')/feature[@name = '{$feature-name}']/parameter[@name = 'max_signatories']" />
                            </xf:action>                            
                        </xf:action>                        
                    </xf:action>                   
                </xf:model>
            </div>
            <div>
                <xf:group appearance="minimal">
                   <xf:label id="editing-subform">Manage parameters: {$feature-name}</xf:label>
                   <xf:action ev:event="betterform-variable-changed" />
                   {
                    switch($feature-name)
                        case "signatory" return
                           <xf:group model="m-feature" ref="instance('i-feature-params')" appearance="bf:verticalTable">
                               <xf:output ref="parameter[@name = 'open_states']/@value"/>
                               <xf:group appearance="bf:verticalTable">
                                    <xf:select model="m-feature" ref="parameter[@name = 'open_states']/@value" appearance="minimal" incremental="true">
                                        <xf:label>select states:</xf:label>
                                        <xf:alert>invalid: emtpy or duplicate parameters</xf:alert>
                                        <xf:hint>parameters should be unique</xf:hint>   
                                        <xf:itemset nodeset="instance('i-states')/state">
                                            <xf:label ref="@title"/>                                       
                                            <xf:value ref="@id"/>
                                        </xf:itemset>
                                    </xf:select>
                                    <xf:input model="m-feature" id="min-signatories" bind="b-min-signatories" incremental="true">
                                        <xf:label>min signatories:</xf:label>
                                        <xf:alert>Invalid value. Between 1 &#8596; 100</xf:alert>
                                        <xf:help>Enter an integer between 1 and 100 </xf:help>
                                        <xf:hint>minimum no. of signatories required</xf:hint>
                                    </xf:input> 
                                    <xf:input model="m-feature" id="max-signatories" bind="b-max-signatories" incremental="true">
                                        <xf:label>max signatories:</xf:label>
                                        <xf:alert>Invalid value. Between 1 &#8596; 100</xf:alert>
                                        <xf:help>Enter an integer between 1 and 100 </xf:help>
                                        <xf:hint>maximum no. of signatories required</xf:hint>
                                    </xf:input>                                     
                                </xf:group>                         
                           </xf:group>  
                        case "event" return 
                           <xf:group model="m-feature" ref="instance('i-feature-params')/parameter" appearance="bf:verticalTable">
                               <xf:output bind="b-param-values"/>
                               <xf:group appearance="bf:horizontalTable">
                                    <xf:select model="m-feature" ref="@value" appearance="minimal" incremental="true">
                                        <xf:alert>invalid: emtpy or duplicate parameters</xf:alert>
                                        <xf:hint>parameters should be unique</xf:hint>   
                                        <xf:itemset nodeset="instance('i-eventtypes')/eventType">
                                            <xf:label ref="@name"/>                                       
                                            <xf:value ref="@name"/>
                                        </xf:itemset>
                                    </xf:select>
                                </xf:group>                         
                           </xf:group>                     
                        case "schedule" return
                           <xf:repeat id="r-parameters" model="m-feature" nodeset="instance('i-feature-params')/parameter">
                               <xf:group ref="." appearance="bf:verticalTable">
                                   <xf:output bind="b-param-name"/>
                                   <xf:output bind="b-param-values"/>
                                   <xf:group appearance="bf:horizontalTable">
                                        <xf:select model="m-feature" ref="@value" appearance="minimal" incremental="true">
                                            <xf:alert>invalid: emtpy or duplicate parameters</xf:alert>
                                            <xf:hint>parameters should be unique</xf:hint>   
                                            <xf:itemset nodeset="instance('i-states')/state">
                                                <xf:label ref="@title"/>                                       
                                                <xf:value ref="@id"/>
                                            </xf:itemset>
                                        </xf:select>
                                    </xf:group>                         
                               </xf:group>
                           </xf:repeat>
                        case "download" return 
                           <xf:group model="m-feature" ref="instance('i-feature-params')/parameter" appearance="bf:verticalTable">
                               <xf:output bind="b-param-values"/>
                               <xf:group appearance="bf:horizontalTable">
                                    <xf:select model="m-feature" ref="@value" appearance="minimal" incremental="true">
                                        <xf:alert>invalid: emtpy or duplicate parameters</xf:alert>
                                        <xf:hint>parameters should be unique</xf:hint>   
                                        <xf:itemset nodeset="instance('i-downtypes')/downloadType">
                                            <xf:label ref="@description"/>                                       
                                            <xf:value ref="@name"/>
                                        </xf:itemset>
                                    </xf:select>
                                </xf:group>                         
                           </xf:group>                     
                        default return
                            ()
                   }
                   <xf:group appearance="bf:horizontalTable">
                       <xf:trigger appearance="triggerMiddleColumn">
                           <xf:label>apply changes</xf:label>
                           <xf:hint>Click apply to update the parameters</xf:hint>
                           <xf:send submission="s-update-master"/>
                       </xf:trigger>
                       <xf:trigger appearance="compact" class="close">
                            <xf:label>Cancel&#160;</xf:label>
                            <xf:hint>click to go the feature workflow</xf:hint>
                            <xf:action ev:event="DOMActivate">
                                <!--xf:setvalue ref="instance('URL-container')" value="#"/-->
                                <xf:load ref="instance('URL-container')"/>
                            </xf:action>
                            <xf:message level="ephemeral">Loading feature parameters. Hold on...</xf:message>
                        </xf:trigger>                        
                   </xf:group>
                </xf:group>
            </div>                 
        </div>
};

declare
function workflow:permissions-subform($node as node(), $model as map(*)) {

    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    (: state passed in exclusively for purpose of injecting the <facet/> into the current state :)
    let $STATE := xs:integer(request:get-parameter("state",""))
    let $FACET-ORIGI-NAME := xs:string(request:get-parameter("facet",""))
    let $feature := xs:string(request:get-parameter("feature",""))
    let $feature-name := if(starts-with($feature,'ext_')) then xs:string(request:get-parameter("feature","")) else $DOCNAME
    let $feature-doc-name := if(starts-with($feature-name,'ext_')) then substring-after($feature-name,'ext_') else $DOCNAME
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model id="m-feature" ev:event="xforms-revalidate" ev:defaultAction="cancel">
                    {
                        (: if its a new workflow meaning its not saved as yet :)
                        if(doc-available($appconfig:CONFIGS-FOLDER || "/workflows/" || $DOCNAME || ".xml")) then
                            <xf:instance id="i-feature-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$feature-doc-name}.xml"/>
                        else
                            <xf:instance id="i-feature-workflow" src="{$workflow:REST-CXT-MODELTMPL}/workflow.xml"/>
                    }
                    
                    <xf:instance id="i-feature-facets">
                        <data xmlns="">
                            { 
                                (: if <facet/>s exist, get them :)
                                if(not(empty(local:get-workflow($feature-doc-name)/facet[@original-name eq $FACET-ORIGI-NAME]))) then 
                                    (local:get-facets($feature-name,false()),local:new-facets($feature-name,local:gen-facets($feature-name,false()),false()))
                                (: else generate them :)
                                else
                                    local:gen-facets($feature-name,false())                                
                            }
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add-feature-permissions"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$feature-doc-name}.xml'"/>
    
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
                            <xf:message level="ephemeral">Feature {$feature} permissions updated successfully</xf:message>
                        </xf:action>
                        
                        <xf:action if="'{$feature}' ne 'state'" ev:event="xforms-submit-done">
                            <xf:send submission="s-inject-feature-facet"/>
                        </xf:action>                         
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">Error saving permission changes</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:submission id="s-inject-feature-facet" resource="model:m-feature#instance('i-feature-workflow')/workflow" replace="none" method="post">
                       <xf:message ev:event="xforms-submit-done" level="ephemeral">{$feature} facet added</xf:message>
                        <xf:action ev:event="xforms-submit-done">
                            <xf:setvalue model="master" ref="instance('i-workflow')/state[{$STATE}]/facet[last()]/@ref" value="concat('{$feature-doc-name}','.{$FACET-ORIGI-NAME}')"/>
                            
                            <xf:delete model="master" nodeset="instance()/state[{$STATE}]/actions/action[last() > 1]" at="last()" />
                            <xf:delete model="master" nodeset="instance()/state[{$STATE}]/actions[string-length(action/text()) &lt; 2]" />
                            <xf:send model="master" submission="s-add"/>
                            <xf:insert model="master" nodeset="instance()/state[{$STATE}]/child::*" at="last()" position="after" origin="instance('i-actions-node')/actions" />
                        </xf:action>                       
                       <xf:message ev:event="xforms-submit-error" level="ephemeral">Sorry - your update failed.</xf:message>
                    </xf:submission>
                   
                    <xf:action ev:event="xforms-ready" >  
                        <!-- inject this facet only when dealing with features not state -->
                        <xf:action if="'{$feature}' ne 'state'">
                            <xf:delete model="master" nodeset="instance('i-workflow')/state[{$STATE}]/facet[@ref eq concat('{$feature-doc-name}','.{$FACET-ORIGI-NAME}')]" />
                            <xf:insert model="master" nodeset="instance('i-workflow')/state[{$STATE}]/child::*" at="last()" position="after" origin="instance('i-facet')/facet" />
                        </xf:action>                      
                        {
                            (: if <facet/>s don't exist, add them :)
                            if(empty(local:get-workflow($feature-doc-name)/facet[@original-name eq $FACET-ORIGI-NAME])) then 
                                <xf:insert nodeset="instance()/permActions" at="last()" position="after" origin="instance('i-feature-facets')/facet" />
                            (: if there are new <role/>s added, incorporate them :)
                            else if (not(empty(local:new-facets($feature-name,local:gen-facets($feature-name,false()),false())))) then 
                                <xf:insert nodeset="instance()/facet[@original-name eq {$FACET-ORIGI-NAME}]" at="last()" position="after" origin="instance('i-feature-facets')/facet" />                                 
                            else
                                ()
                        }                       
                    </xf:action>                   
                </xf:model>
            </div>
            <div>
                <xf:group>
                    <xf:label>{$feature}</xf:label>
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
                            let $facets :=  if(not(empty(local:get-workflow($feature-doc-name)/facet[@original-name eq $FACET-ORIGI-NAME]))) then 
                                                (local:get-facets($feature-name,false()),local:new-facets($feature-name,local:gen-facets($feature-name,false()),false()))
                                            else
                                                local:gen-facets($feature-name,false())
                            for $facet at $pos in $facets
                            let $allow := $facet/allow
                            order by $facet/@name ascending
                            return
                                <tr>
                                    <td class="one">
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
                        <xf:label>Save {$feature} permissions</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add-feature-permissions"/>
                        </xf:action>                                
                    </xf:trigger>
                </xf:group>                                 
            </div>                  
        </div>
};