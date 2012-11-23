xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";


declare function local:timestamp() as xs:string {
      let $timestamp := request:get-parameter("timestamp", "")
      let $contextPath := request:get-context-path()
      let $path2resource := concat($contextPath,"/apps/configeditor/edit/split-item.xql?item=",$timestamp)
      let $doc := doc($path2resource)
      let $xsl := doc('/db/configeditor/xsl/wf_split_attrs.xsl')
      let $splitted := transform:transform($doc, $xsl, <parameters>
                                                          <param name="docname" value="{util:document-name($path2resource)}" />
                                                       </parameters>)
      return $path2resource
};

declare function local:mode() as xs:string {
    let $timestamp := request:get-parameter("timestamp", "undefined")

    let $mode := if($timestamp = "undefined") then "new"
                 else "edit"

    return $mode
};

let $contextPath := request:get-context-path()
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
                    <xf:instance id="i-workflow" src="{$contextPath}/rest/db/configeditor/data/workflow.xml"/>                  

                    <xf:bind id="documentname" nodeset="@document-name" type="xs:string" required="true()"/>
                    <xf:bind nodeset="transition/@title" type="xs:string" required="true()"/>
                    <xf:bind id="feature" nodeset="feature/@enabled" type="xs:boolean" required="true()"/>
                    <!--xf:bind nodeset="project" required="true()" />
                    <xf:bind nodeset="duration/@hours" type="integer" />
                    <xf:bind nodeset="duration/@minutes" type="integer" constraint=". != 0 or ../@hours != 0"/>
                    <xf:bind nodeset="who" required="true()"/>
                    <xf:bind nodeset="what" required="true()"/>
                    <xf:bind nodeset="created" required="true()"/-->

                  <xf:submission id="s-get-workflow"
                                 method="get"
                                 resource="{local:timestamp()}"
                                 replace="instance"
                                 serialization="none">
                                 <!--
                                     <xf:resource value="concat('{$contextPath}/rest/db/configeditor/configs/workflows/', '{local:timestamp()}')"/>
                                 -->
                 </xf:submission>

                 <xf:instance id="i-project"     src="{$contextPath}/rest/db/configeditor/data/project.xml"/>
                 <xf:instance id="i-worker"  	 src="{$contextPath}/rest/db/configeditor/data/worker.xml"/>
                 <xf:instance id="i-workflowtype"  	 src="{$contextPath}/rest/db/configeditor/data/tasktype.xml"/>
                 <xf:instance id="i-controller"  src="{$contextPath}/rest/db/configeditor/data/controller.xml"/>
                 <xf:instance id="labels">
                    <data>
                        <item1>Label 1</item1>
                        <item2>Label 2</item2>
                        <item3>Label 3</item3>
                        <item4>Label 4</item4>
                        <item5>Label 5</item5>
                    </data>
                 </xf:instance>  

                 <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                 </xf:instance>

                <xf:submission id="s-add"
                               method="put"
                               replace="none"
                               ref="instance()">
                    <xf:resource value="concat('{$contextPath}/rest/db/configeditor/configs/workflows/', instance('i-workflow')/@document-name)"/>

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
                        <!--xf:setvalue ref="instance('i-workflow')/@document-name" value="now()" /-->
                    </xf:action>

                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">Workflow saved successfully</xf:message>
                        <script type="text/javascript" if="instance('tmp')/wantsToClose">
                            dijit.byId("taskDialog").hide();
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
                               ref="instance('i-workflow')"
                               resource="{$contextPath}/rest/db/configeditor/data/workflow.xml"
                               method="get"
                               replace="instance"
                               instance="i-workflow">
                </xf:submission>
            <xf:action ev:event="xforms-ready" >
                <xf:send submission="s-get-workflow" if="'{local:mode()}' = 'edit'"/>
                <!--xf:setfocus control="date"/-->
            </xf:action>

            </xf:model>
        </div>

        <xf:group ref="." class="{if(local:mode()='edit') then 'suppressInfo' else ''}">
            <xf:group id="add-task-table" appearance="default">         

                <xf:output ref="@title">
                    <xf:label>States:</xf:label>
                </xf:output>                               
                
                <xf:group>
                    <xf:trigger>
                        <xf:label>insert</xf:label>
                        <xf:action>
                            <xf:insert nodeset="transition" at="1" position="before"></xf:insert>
                        </xf:action>
                    </xf:trigger>  
                </xf:group>                
                <table>
                    <thead>
                        <tr>
                            <th>
                                state id
                            </th>
                            <th>
                                title
                            </th>                                  
                            <th>
                                view
                            </th>    
                            <th>
                                edit
                            </th>                              
                            <th colspan="2">
                                actions
                            </th>                               
                        </tr>
                    </thead>
                    <tbody id="r-stateattrs" xf:repeat-nodeset="state">
                        <tr> 
                            <td style="color:steelblue;font-weight:bold;">
                                <xf:input ref="@id" incremental="true">
                                    <xf:label/>
                                    <xf:hint>State for this transition</xf:hint>
                                    <xf:help>Type a title</xf:help>
                                    <xf:alert>invalid title</xf:alert>
                                </xf:input>
                            </td>                             
                            <td>
                                <xf:textarea ref="@title" appearance="growing" incremental="true">
                                    <xf:label>Title for this state</xf:label>
                                    <xf:hint>This is a short description about this state</xf:hint>
                                    <xf:help>Type the title information</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                </xf:textarea>
                            </td>                                
                            <td>
                                <xf:output ref="@trigger"></xf:output>
                            </td>   
                            <td>
                                <xf:output ref="@trigger"></xf:output>
                            </td>                               
                            <td style="color:blue;">
                                <xf:trigger>
                                    <xf:label>insert</xf:label>
                                    <xf:action>
                                        <xf:insert nodeset="." at="index('r-stateattrs')" position="before"></xf:insert>
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
                            dijit.byId("taskDialog").hide();
                        </script>
                    </xf:trigger>                    
                </xf:group>

            </xf:group>

			<xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>

        </xf:group>
        </div>
    </body>
</html>
