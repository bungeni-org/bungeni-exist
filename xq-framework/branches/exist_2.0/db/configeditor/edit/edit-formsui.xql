xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";


declare function local:fn-formsui() as xs:string {

    let $contextPath := request:get-context-path()
    let $docname := xs:string(request:get-parameter("doc","nothing"))
    let $path2resource := concat($contextPath,"/apps/configeditor/edit/split-forms.xql?doc=",$docname)
    let $xsl := doc('/db/configeditor/xsl/forms_split_attrs.xsl')
    let $doc := doc($path2resource)
    let $fname := substring-before($docname,'.xml')
    let $splitted := transform:transform($doc, $xsl, <parameters>
                                                            <param name="fname" value="{$fname}" />
                                                     </parameters>)
    return $path2resource
};

declare function local:mode() as xs:string {
    let $timestamp := request:get-parameter("doc", "undefined")
    let $node := request:get-parameter("node", "undefined")

    let $mode := if($timestamp = "undefined") then "new"
                 else "edit"

    return $mode
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","nothing"))
let $nodeattr := xs:string(request:get-parameter("node","nothing"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>Edit Workflow</title>
       <link rel="stylesheet" type="text/css" href="./styles/configeditor.css"/>
    </head>
    <body class="tundra InlineRoundBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-formsui" src="{$contextPath}/rest/db/configeditor/data/forms.xml"/>   
                    
                    <xf:instance id="i-modes" xmlns="">
                        <data>
                            <modes>
                               <mode>add</mode>
                               <mode>edit</mode>                                 
                               <mode>view</mode>                                                            
                               <mode>listing</mode>
                            </modes>
                        </data>
                    </xf:instance>

                    <xf:bind nodeset="@name" type="xf:string" required="true()" />
                    <xf:bind id="modes" nodeset="show/modes/mode" type="xs:string" />

                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{local:fn-formsui()}"
                        ref="descriptor[@name eq 'attachment']"
                        replace="instance"
                        serialization="none">
                    </xf:submission>

                    <xf:instance id="i-project" src="{$contextPath}/rest/db/configeditor/data/project.xml"/>
                    <xf:instance id="i-worker" src="{$contextPath}/rest/db/configeditor/data/worker.xml"/>
                    <xf:instance id="i-formsuitype" src="{$contextPath}/rest/db/configeditor/data/tasktype.xml"/>
                    <xf:instance id="i-controller" src="{$contextPath}/rest/db/configeditor/data/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                <xf:submission id="s-add"
                               method="put"
                               replace="none"
                               ref="instance()">
                    <xf:resource value="concat('{$contextPath}/rest/db/configeditor/configs/forms/',$docname)"/>

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

                    <xf:action ev:event="xforms-submit" if="'{local:mode()}' = 'new'">
                        <xf:message level="ephemeral">Creating timestamp as name</xf:message>
                        <!--xf:setvalue ref="instance('i-formsui')/@document-name" value="now()" /-->
                    </xf:action>

                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">Workflow saved successfully</xf:message>
                        <script type="text/javascript" if="instance('tmp')/wantsToClose">
                            dijit.byId("formsDialog").hide();
                            dojo.publish("/wf/refresh");
                        </script>
                        <xf:send submission="s-clean" if="'{local:mode()}' = 'new'"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The form has not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>

                <xf:submission id="s-clean"
                               ref="instance('i-formsui')"
                               resource="{$contextPath}/rest/db/configeditor/data/workflow.xml"
                               method="get"
                               replace="instance"
                               instance="i-formsui">
                </xf:submission>
            <xf:action ev:event="xforms-ready" >
                <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                <!--xf:setfocus control="date"/-->
            </xf:action>

            </xf:model>
        </div>

        <xf:group ref="descriptor[@name eq '{$nodeattr}']" class="{if(local:mode()='edit') then 'suppressInfo' else ''}">
            <xf:group id="add-task-table" appearance="default">
            
                <xf:output ref="@name">
                    <xf:label>Editing ID, Labels and Modes:</xf:label>
                </xf:output>               
            
                <xf:input id="document-name" ref="@document-name">
                    <xf:label>Document ID</xf:label>
                    <xf:alert>The convention current is file name = Document ID</xf:alert>
                    <xf:hint>You cannot change this once set e.g. address.xml is immutable</xf:hint>
                    <xf:alert>invalid file name</xf:alert>
                </xf:input>            

                <xf:input id="title" ref="@title">
                    <xf:label>Title</xf:label>
                    <xf:alert>a Title is required</xf:alert>
                    <xf:hint>senter Title for this workflow items</xf:hint>
                </xf:input>
                
                <xf:textarea id="description" ref="@description" appearance="growing" incremental="true">
                    <xf:label>Description</xf:label>
                    <xf:hint>You may enter a description</xf:hint>
                    <xf:help>short description about this workflow</xf:help>
                    <xf:alert>invalid</xf:alert>
                </xf:textarea>                  
                
                <table>
                    <thead>
                        <tr>
                            <th>
                                name
                            </th>
                            <th>
                                label
                            </th>    
                            <th>
                                modes
                            </th>                                 
                            <th colspan="2">
                                actions
                            </th>                               
                        </tr>
                    </thead>
                    <tbody id="r-fieldattrs" xf:repeat-nodeset="field">
                        <tr> 
                            <td style="color:steelblue;font-weight:bold;">
                                <xf:input ref="@name" incremental="true">
                                    <xf:label/>
                                    <xf:hint>State for this transition</xf:hint>
                                    <xf:help>Type a title</xf:help>
                                    <xf:alert>invalid title</xf:alert>
                                </xf:input>
                            </td>                             
                            <td>
                                <xf:textarea ref="@label" appearance="growing" incremental="true">
                                    <xf:label>Title for this state</xf:label>
                                    <xf:hint>This is a short description about this state</xf:hint>
                                    <xf:help>Type the title information</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                </xf:textarea>
                            </td>                              
                            <td>
                                <xf:select ref="show/modes/mode" selection="closed" appearance="full" incremental="true" >  
                                    <xf:itemset nodeset="instance('i-modes')/modes/mode">
                                        <xf:label ref="."></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select>
                            </td>                               
                            <td style="color:blue;">
                                <xf:trigger>
                                    <xf:label>insert</xf:label>
                                    <xf:action>
                                        <xf:insert nodeset="." at="index('r-fieldattrs')" position="before"></xf:insert>
                                    </xf:action>
                                </xf:trigger> 
                            </td>                                            
                            <td style="color:red;">                                           
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete nodeset="." ev:event="DOMActivate"></xf:delete>
                                    </xf:action>
                                </xf:trigger>   
                            </td>                            
                        </tr>
                    </tbody>
                </table>   

                <br/>
                <xf:group id="dialogButtons" appearance="bf:horizontalTable">
                    <xf:label/>
                    <xf:trigger>
                        <xf:label>Save</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Close</xf:label>
                        <script type="text/javascript">
                            dijit.byId("formsDialog").hide();
                        </script>
                    </xf:trigger>                    
                </xf:group>

            </xf:group>

			<xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>

        </xf:group>
        </div>
    </body>
</html>
