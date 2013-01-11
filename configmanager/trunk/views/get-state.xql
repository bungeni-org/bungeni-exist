xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all document transitions sources :)
declare function local:transition-sources($doctype, $nodename) as node() * {
    (:let $form-id := request:get-parameter("doc", "workflow.xml")
    let $attrname := request:get-parameter("node", "nothing"):)

    for $transition at $pos in local:get-workflow($doctype)/workflow/transition
    where $transition/sources/source[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: creates the output for all document transitions destinations :)
declare function local:transition-destinations($doctype, $nodename) as node() * {
    (:let $form-id := request:get-parameter("doc", "workflow.xml")
    let $attrname := request:get-parameter("node", "nothing"):)
    (:form-id is same as doctype !:)
    for $transition at $pos in local:get-workflow($doctype)/workflow/transition
    where $transition/destinations/destination[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: reused to render the destination and source transition tables below :)
declare function local:render-row($doctype as xs:string, $nodename as xs:string, $pos as xs:integer, $transition as node()) as node() * {
    <tr>
        <td><a href="javascript:dojo.publish('/edit',['transition','{$doctype}','{$nodename}','{$pos}','none']);">{data($transition/@title)}</a></td>
        <td>{data($transition/@trigger)}</td>
        <td>{data($transition/@order)}</td>
    </tr>
};

declare function local:get-workflow($docname as xs:string) as node() * {
    doc($appconfig:WF-FOLDER || '/' || $docname)
};

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","workflow.xml"))
let $NODENAME := xs:string(request:get-parameter("node","nothing"))
let $ATTR := xs:string(request:get-parameter("attr","nothing"))
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
                 <xf:model>
                    <xf:instance id="i-workflowui" src="{$REST-CXT-CONFIGWF}/{$DOCNAME}"/>                   

                    <xf:bind nodeset="./state">
                        <xf:bind nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@version" type="xf:boolean" required="true()" />
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
                                dojo.publish('/workflow/view',['{$DOCNAME}','workflow','statesDiv']);  
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
                <h1>Types / {$DOCNAME} / workflow / state</h1>
                <br/>
                <a href="javascript:dojo.publish('/workflow/view',['{$DOCNAME}','workflow','statesDiv']);">
                    <img src="images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="float:left;width:60%;">
                                <xf:group ref="./state[{$attr}]" appearance="bf:verticalTable">   
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
                                        <a href="javascript:dojo.publish('/add',['transition','{$DOCNAME}','{$NODENAME}','{$attr}','none']);">add transition</a>                                 
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
                                            <td id="foo" class="one" style="color:steelblue;font-weight:bold;">
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
    </body>
</html>