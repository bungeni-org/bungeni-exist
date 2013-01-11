xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:get-workflow($doctype) as node() * {
    let $workflow := doc($appconfig:WF-FOLDER || "/" || $doctype)/workflow
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
    let $count := count($states)
    for $state at $pos in $states
        return
            <tr>
                <td><a href="javascript:dojo.publish('/view',['state','{$doctype}','{data($state/@id)}','{$pos}','none']);">{data($state/@id)}</a></td>
                <td>{data($state/@title)}</td>
                <td>{data($state/@version)}</td>
                <td>{data($state/@permissions_from_state)}</td>
                <td><a href="javascript:dojo.publish('/state/delete',['{$doctype}','{data($state/@id)}']);">delete</a></td>
            </tr>
};

(: creates the output for all document transitions :)
declare function local:transitions($doctype) as node() * {
    let $transitions := local:get-workflow()/transition
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

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","nothing"))
let $SHOWING := xs:string(request:get-parameter("tab","fields"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Database</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                 <xf:model id="m-workflow">
                    <xf:instance id="i-workflowui" src="{$REST-CXT-CONFIGWF}/{$DOCNAME}"/>                   

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@name" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@title" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$REST-CXT-CONFIGWF}/{$DOCNAME}'"/>
    
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
                                dojo.publish('/workflow/view',['{$DOCNAME}','workflow','documentDiv']);  
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
                        <script type="text/javascript" if="'{$SHOWING}' != 'none'">
                            dijit.byId("switchDiv").selectChild("{$SHOWING}");                        
                        </script>   
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <div dojoType="dijit.layout.TabContainer" id="switchDiv" style="width: 100%; height: 100%;">             
                    <div dojoType="dijit.layout.ContentPane" title="Document" id="documentDiv" selected="true">
                        <div>
                            <h1>Types / {$DOCNAME} / workflow </h1>
                            <br/>                           
                            <xf:group ref="." appearance="bf:verticalTable">       
                                <xf:input id="wf-name" ref="@name">
                                    <xf:label>Name</xf:label>
                                    <xf:hint>edit name of the workflow</xf:hint>
                                    <xf:alert>enter more than 3 characters</xf:alert>
                                </xf:input>      
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
                        </div>
                    </div>
                    <div dojoType="dijit.layout.ContentPane" title="Edit States" id="statesDiv" selected="true">
                        <div>
                            <h1>Types / {$DOCNAME} / workflow / states</h1>
                            <br/>                       
                            <table class="listingTable" style="width:auto;">
                                <tr>                      			 
                                    <th>state id</th>
                                    <th>title</th>
                                    <th>version</th>
                                    <th>permissions_from_state</th>
                                    <th>...</th>
                                </tr>
                                {local:states($DOCNAME)}
                            </table>
                        </div>
                    </div>                    
                    <div dojoType="dijit.layout.ContentPane" title="Workflow Features" id="featuresDiv" selected="true">
                        <div>
                            <h1>Types / {$DOCNAME} / workflow / features </h1>
                            <br/>   
                            <table class="listingTable" style="width:auto;">
                                <tr>                      			 
                                    <th>feature name</th>
                                    <th>enabled</th>
                                    <th>...</th>
                                </tr>
                                {local:features($DOCNAME)}
                            </table>  
                         </div>
                    </div>
                    <div dojoType="dijit.layout.ContentPane" title="Workflow Facets" id="facetsDiv" selected="true">
                        <div>
                            <h1>Types / {$DOCNAME} / workflow / facets</h1>
                            <br/>   
                            <table class="listingTable" style="width:auto;">
                                <tr>                      			 
                                    <th>facet name</th>
                                    <th colspan="2">...</th>
                                </tr>
                                {local:facets($DOCNAME)}
                            </table>
                        </div>
                    </div>
                    <div dojoType="dijit.layout.ContentPane" title="Edit Transitions" id="detailsDiv" selected="true">
                        <div>
                            <h1>Types / {$DOCNAME} / workflow / transitions</h1>
                            <br/>                       
                            <table class="listingTable" style="width:auto;">
                                <tr>                      			 
                                    <th>title</th>
                                    <th>condition</th>
                                    <th>trigger</th>
                                    <th>order</th>
                                    <th colspan="2">...</th>
                                </tr>
                                {local:transitions($DOCNAME)}
                            </table>
                        </div>                        
                    </div>
                </div>                
            </div>                    
        </div>
    </body>
</html>