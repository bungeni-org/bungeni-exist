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
declare variable $workflow:REST-CXT-APP :=  $workflow:CXT || "/rest" || $config:app-root;
declare variable $workflow:REST-CXT-CONFIGWF := $workflow:REST-CXT-APP || "/working/live/bungeni_custom/workflows";
declare variable $workflow:REST-CXT-MODELTMPL := $workflow:REST-CXT-APP || "/model_templates";


declare function local:get-workflow($doctype) as node() * {
    let $workflow := doc($appconfig:WF-FOLDER || "/" || $doctype || ".xml")/workflow
    return $workflow
};

(: creates the output for all document features :)
declare function local:features($doctype) as node() * {
    let $features := local:get-workflow($doctype)/feature
    let $count := count($features)
    for $feature at $pos in $features
        return
            <tr>
                <td><a href="javascript:dojo.publish('/view',['feature','{$doctype}','feature','{$pos}','none']);">{data($feature/@name)}</a></td>
                <td>{data($feature/@enabled)}</td>
                <td><a href="javascript:dojo.publish('/feature/delete',['{$doctype}','{data($feature/@name)}']);">delete</a></td>
            </tr>
};

(: creates the output for all document facets :)
declare function local:facets($doctype) as node() * {
    let $facets := local:get-workflow($doctype)/facet
    let $count := count($facets)
    for $facet at $pos in $facets
        return
            <tr>
                <td>{data($facet/@name)}</td>
                <td><a href="javascript:dojo.publish('/facet/edit',['{$doctype}','{data($facet/@name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/facet/delete',['{$doctype}','{data($facet/@name)}']);">delete</a></td>
            </tr>
};

(: creates the output for all document states :)
declare function local:states($doctype) as node() * {
    let $states := local:get-workflow($doctype)/state
    let $type := xs:string(request:get-parameter("type",""))
    let $docpos := xs:integer(request:get-parameter("pos",""))
    let $count := count($states)
    for $state at $pos in $states
        return
            <tr>
                <td><a class="editlink" href="state.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;attr={$pos}&amp;node={data($state/@id)}">{data($state/@id)}</a></td>
                <td>{data($state/@title)}</td>
                <td>{data($state/@version)}</td>
                <td>{data($state/@permissions_from_state)}</td>
                <td><a href="javascript:dojo.publish('/state/delete',['{$doctype}','{data($state/@id)}']);">delete</a></td>
            </tr>
};

(: creates the output for all document transitions :)
declare function local:transitions($doctype) as node() * {
    let $transitions := local:get-workflow($doctype)/transition
    let $count := count($transitions)
    for $transition at $pos in $transitions
        return
            <tr>
                <td>{data($transition/@title)}</td>
                <td>{data($transition/@condition)}</td>
                <td>{data($transition/@trigger)}</td>                
                <td>{data($transition/@order)}</td>
                <td><a href="javascript:dojo.publish('/transition/edit',['{$doctype}','{data($transition/@id)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/transition/delete',['{$doctype}','{data($transition/@id)}']);">delete</a></td>
            </tr>
};

declare function local:get-form($docname as xs:string) as node() * {
    doc($appconfig:FORM-FOLDER || '/' || $docname || '.xml')
};

(: creates the output for all document transitions sources :)
declare function local:transition-sources($doctype, $nodename) as node() * {

    for $transition at $pos in local:get-workflow($doctype)/transition
    where $transition/sources/source[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: creates the output for all document transitions destinations :)
declare function local:transition-destinations($doctype, $nodename) as node() * {

    for $transition at $pos in local:get-workflow($doctype)/transition
    where $transition/destinations/destination[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: reused to render the destination and source transition tables below :)
declare function local:render-row($doctype as xs:string, $nodename as xs:string, $pos as xs:integer, $transition as node()) as node() * {
    <tr>
        <td><a class="editlink" href="javascript:dojo.publish('/edit',['transition','{$doctype}','{$nodename}','{$pos}','none']);">{data($transition/@title)}</a></td>
        <td>{data($transition/@trigger)}</td>
        <td>{data($transition/@order)}</td>
    </tr>
};

declare function local:mode() as xs:string {
    let $doc := request:get-parameter("doc", "nothing")

    let $mode := if($doc eq "undefined") then "new"
                 else "edit"

    return $mode
};

declare
function workflow:edit($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc","none"))    
    let $pos := xs:string(request:get-parameter("pos",""))
    let $lastfield := data(local:get-form($docname)/descriptor/field[last()]/@name)
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-form" src="{$workflow:REST-CXT-CONFIGWF}/{$docname}.xml"/>                      

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@name" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@title" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>
                    
                    <xf:submission id="s-get-form"
                        method="get"
                        resource="{$workflow:REST-CXT-APP}/working/live/bungeni_custom/forms/{$docname}.xml"
                        replace="instance"
                        serialization="none">
                    </xf:submission>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-CXT-CONFIGWF}/{$docname}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>admin</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value></xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dijit.byId("formsDialog").hide();
                                dojo.publish('/workflow/view',['{$docname}','workflow','documentDiv']);  
                            </script>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >

                    </xf:action>

            </xf:model>
            
            </div>
            
            <div id="tabs_container">
                <ul id="tabs">
                    <li id="tabdetails" class="active"><a href="#details">Workflow</a></li>
                    <li id="tabstates" ><a href="#states">States</a></li>
                    <li id="tabfeatures" ><a href="#features">Features</a></li>
                    <li id="tabfacets" ><a href="#facets">Facets</a></li>
                    <li id="tabtransitions" ><a href="#transitions">Transitions</a></li>
                </ul>
            </div>
            
            <div id="tabs_content_container">
                <div id="details" class="tab_content" style="display: block;">
                    <xf:group ref=".">                   
                        <h1><xf:output ref="@name"/></h1>
                        <xf:group appearance="bf:verticalTable">
                            <xf:input id="wf-title" ref="@title">
                                <xf:label>Title</xf:label>
                                <xf:hint>edit title of the workflow</xf:hint>
                                <xf:alert>enter more than 3 characters</xf:alert>
                            </xf:input>   
                            <xf:textarea id="wf-description" ref="@description" appearance="growing" incremental="true">
                                <xf:label>Description</xf:label>
                                <xf:hint>lengthy description for the workflow</xf:hint>
                                <xf:alert>invalid</xf:alert>
                            </xf:textarea>
                            <xf:trigger>
                                <xf:label>Save</xf:label>
                                <xf:action>
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                    <xf:send submission="s-add"/>
                                </xf:action>                                
                            </xf:trigger> 
                        </xf:group>
                    </xf:group>
                </div>
                <div id="states" class="tab_content">
                    <table class="listingTable" style="width:auto;">
                        <thead>
                            <tr>                      			 
                                <th>state id</th>
                                <th>title</th>
                                <th title="allows versioning">version</th>
                                <th>permissions_from_state</th>
                                <th>...</th>
                            </tr>
                        </thead>
                        <tbody>
                            {local:states($docname)}
                        </tbody>
                    </table> 
                    <div class="linkButtonWrap">
                        <a class="linkButton" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">+ add state</a>
                    </div>
                </div>
                <div id="features" class="tab_content">
                    <table class="listingTable" style="width:auto;">
                        <thead>
                            <tr>                      			 
                                <th>feature name</th>
                                <th>enabled</th>
                                <th>...</th>
                            </tr>
                        </thead>
                        <tbody>
                            {local:features($docname)}
                        </tbody>
                    </table> 
                    <div class="linkButtonWrap">
                        <a class="linkButton" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">+ add feature</a>
                    </div>
                </div>  
                <div id="facets" class="tab_content">
                    <table class="listingTable" style="width:auto;">
                        <thead>
                            <tr>                      			 
                                <th>facet name</th>
                                <th colspan="2">...</th>
                            </tr>
                        </thead>
                        <tbody>
                            {local:facets($docname)}
                        </tbody>
                    </table> 
                    <div class="linkButtonWrap">
                        <a class="linkButton" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">+ add facet</a>
                    </div>
                </div>      
                <div id="transitions" class="tab_content">
                    <table class="listingTable" style="width:auto;">
                        <thead>
                            <tr>                      			 
                                <th>title</th>
                                <th>condition</th>
                                <th>trigger</th>
                                <th>order</th>
                                <th colspan="2">...</th>
                            </tr>
                        </thead>
                        <tbody>
                            {local:transitions($docname)}
                        </tbody>
                    </table> 
                    <div class="linkButtonWrap">
                        <a class="linkButton" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">+ add facet</a>
                    </div>
                </div>                 
            </div>                 
        </div>
};

declare
function workflow:state($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("node",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="-workflow" src="{$workflow:REST-CXT-CONFIGWF}/{$DOCNAME}.xml"/>                   

                    <xf:bind nodeset="./state">
                        <xf:bind nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@version" type="xf:boolean" required="true()" />
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
                        <xf:resource value="'{$workflow:REST-CXT-CONFIGWF}/{$DOCNAME}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>admin</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value></xf:value>
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
                            <xf:message>The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >  
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <a href="workflow.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>
                <h1>state | {$NODENAME}</h1>
                <br/>                
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="float:left;width:60%;">
                                <xf:group ref="./state[{$ATTR}]" appearance="bf:verticalTable">   
                                    <xf:output ref="@id" incremental="true">
                                        <xf:label>state:</xf:label>
                                    </xf:output>                                
                                    <xf:input id="state-id" ref="@id">
                                        <xf:label>ID</xf:label>
                                        <xf:hint>edit id of the workflow</xf:hint>
                                        <xf:help>... and no spaces in between words</xf:help>
                                        <xf:alert>enter more than 3 characters...</xf:alert>
                                    </xf:input> 
                                    <xf:input id="state-title" ref="@title">
                                        <xf:label>Title</xf:label>
                                        <xf:hint>edit title of the workflow</xf:hint>
                                        <xf:help>... and no spaces in between words</xf:help>
                                        <xf:alert>enter more than 3 characters...</xf:alert>
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
                                    <xf:input id="state-version" ref="@version">
                                        <xf:label>Version</xf:label>
                                        <xf:hint>support versioning</xf:hint>
                                    </xf:input>                                    
                                </xf:group>
                                
                                <br/>
                                <h1>Manage Transitions</h1>
                                <div style="width:100%;height:200px">
                                    <div style="float:left;width:49%;">
                                        <h3>Sources</h3>
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th>transition name</th>
                                                <th>trigger</th>
                                                <th>order</th>
                                            </tr>
                                            {local:transition-sources($DOCNAME, $NODENAME)}
                                        </table> 
                                        <a href="transition-add.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;from={$NODENAME}">add transition</a>                                 
                                    </div>
                                    <div style="float:right;width:49%;">
                                        <h3>Destinations</h3>
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th>transition name</th>
                                                <th>trigger</th>
                                                <th>order</th>
                                            </tr>
                                            {local:transition-destinations($DOCNAME, $NODENAME)}
                                        </table>     
                                    </div>                                    
                                </div>
                                
                            </div>
                            <div style="float:right">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>add/delete tags</th>   
                                            <th>...</th> 
                                        </tr>
                                    </thead>
                                    <tbody id="r-attrs" xf:repeat-nodeset="./state[{$ATTR}]/tags/tag">
                                        <tr>
                                            <td id="state-tags" class="one" style="color:steelblue;font-weight:bold;">
                                                <xf:select1 ref="." appearance="minimal" incremental="true">
                                                    <xf:itemset nodeset="instance()/tags/tag">
                                                        <xf:label ref="."></xf:label>
                                                        <xf:value ref="."></xf:value>
                                                    </xf:itemset>
                                                </xf:select1> 
                                            </td>
                                            <td>
                                                <xf:trigger>
                                                    <xf:label>delete</xf:label>
                                                    <xf:delete ev:event="DOMActivate" nodeset="."></xf:delete>
                                                </xf:trigger>
                                            </td> 
                                        </tr>
                                    </tbody>
                                </table>
                                <xf:trigger>
                                    <xf:label>add</xf:label>
                                    <xf:action>
                                        <xf:insert nodeset="./state[{$ATTR}]/tags/tag"></xf:insert>
                                    </xf:action>
                                </xf:trigger> 
                            </div>
                            <xf:trigger>
                                <xf:label>Save</xf:label>
                                <xf:action>
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                    <xf:send submission="s-add"/>
                                </xf:action>                                
                            </xf:trigger>                           
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>        
};