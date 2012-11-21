xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=application/xhtml+html";

let $contextPath := request:get-context-path()
return
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:xf="http://www.w3.org/2002/xforms"
      xmlns:ev="http://www.w3.org/2001/xml-events"
      xml:lang="en">
    <head>
        <title>Bungeni Configuration Editor</title>
        <link rel="stylesheet" type="text/css" href="./styles/configeditor.css"/>
    </head>
    <body id="workflow" class="tundra InlineRoundBordersAlert">
        <div class="page">

            <!-- ***** hidden triggers ***** -->
            <!-- ***** hidden triggers ***** -->
            <!-- ***** hidden triggers ***** -->
            <div style="display:none;">
                <xf:model id="modelone">
                    <xf:instance>
                        <data xmlns="">
                            <from>2000-01-01</from>
                            <to>2000-01-02</to>
                            <project/>
                            <billable/>
                            <billed/>
                        </data>
                    </xf:instance>
                    <xf:instance xmlns="" id="workflow-items" src="workflows.xql?return=docs"/>
                    <xf:bind nodeset="from" type="xf:date"/>
                    <xf:bind nodeset="to" type="xf:date" />

                    <xf:submission id="s-query-workflows"
                                    resource="{$contextPath}/rest/db/configeditor/views/list-workflows.xql"
                                    method="get"
                                    replace="embedHTML"
                                    targetid="embedInline"
                                    ref="instance()"
                                    validate="false">
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Submission for workflows succedded</xf:message>
                        </xf:action>                                    
                        <xf:action ev:event="xforms-submit-error">
                            <xf:message>Submission failed</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:submission id="s-query-workspaces"
                                    resource="{$contextPath}/rest/db/configeditor/views/list-workspace.xql"
                                    method="get"
                                    replace="embedHTML"
                                    targetid="embedInline"
                                    ref="instance()"
                                    validate="false">
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Submission for workspaces succedded</xf:message>
                        </xf:action>                                    
                        <xf:action ev:event="xforms-submit-error">
                            <xf:message>Submission failed</xf:message>
                        </xf:action>
                    </xf:submission>                    

                    <xf:submission id="s-delete-workflow"
                                    method="delete"
                                    replace="none"
                                    validate="false">
                        <xf:resource value="concat('{$contextPath}/rest/db/configeditor/configs/workflows/',instance('i-vars')/currentTask,'')"/>
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
                            <script type="text/javascript">
                                fluxProcessor.dispatchEvent("overviewTrigger");
                            </script>
                            <xf:message level="ephemeral">Entry has been removed</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:instance id="i-project" src="{$contextPath}/rest/db/configeditor/data/project.xml" />

                    <xf:instance id="i-vars">
                        <data xmlns="">
                            <default-duration>120</default-duration>
                            <currentTask/>
                            <selectedTasks/>
                        </data>
                    </xf:instance>
                    <xf:bind nodeset="instance('i-vars')/default-duration" type="xf:integer"/>

                    <xf:action ev:event="xforms-ready">
                        <xf:setvalue ref="to" value="substring(local-date(), 1, 10)"/>
                        <xf:recalculate/>
                        <!-- <xf:setvalue ref="from" value="days-to-date(number(days-from-date(instance()/to) - instance('i-vars')/default-duration))"/> -->
                        <xf:setvalue ref="from" value="'2010-01-01'"/>
                    </xf:action>
                </xf:model>

                <xf:trigger id="overviewTrigger">
                    <xf:label>Overview</xf:label>
                    <xf:send submission="s-query-workflows"/>
                </xf:trigger>
                
                <xf:trigger id="overviewWorkspaceTrigger">
                    <xf:label>Overview</xf:label>
                    <xf:send submission="s-query-workspaces"/>
                </xf:trigger>                

                <xf:trigger id="addTask">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="'{$contextPath}/rest/db/configeditor/edit/edit-item.xql#xforms'"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>

                <xf:trigger id="editTask">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/configeditor/edit/edit-item.xql#xforms?timestamp=',instance('i-vars')/currentTask)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>

                <xf:trigger id="deleteTask">
                    <xf:label>delete</xf:label>
                    <xf:send submission="s-delete-workflow"/>
                </xf:trigger>

                <xf:input id="currentTask" ref="instance('i-vars')/currentTask">
                    <xf:label>This is just a dummy used by JS</xf:label>
                </xf:input>
            </div>

            <!-- ######################### Content here ################################## -->
            <div id="content">
                <div id="header">
                    <div id="appName">Bungeni Configuration Editor</div>
                </div>           
 
                <div id="toolbar" dojoType="dijit.Toolbar">
                    
                	<div id="workflow" dojoType="dijit.form.DropDownButton" showLabel="true" onclick="fluxProcessor.dispatchEvent('overviewTrigger');">
                		<span>Workflows</span>
                		<div id="workflowsMenu" dojoType="dijit.TooltipDialog">              		
                			<div id="addworkflow" dojoType="dijit.form.Button" onclick="embed('addTask','embedDialog');">Add Workflow</div>                 			
                		</div>
                	</div>    
                	
                	<div id="workspace" dojoType="dijit.form.DropDownButton" showLabel="true" onclick="fluxProcessor.dispatchEvent('overviewWorkspaceTrigger');">
                		<span>Workspace</span>
                		<div id="workspaceMenu" dojoType="dijit.TooltipDialog">              		
                			<div id="addworkspace" dojoType="dijit.form.Button" onclick="embed('addTask','embedDialog');">Add Workspace</div>                 			
                		</div>
                	</div>                  	
                	
                    <div id="addBtn" dojoType="dijit.form.Button" showLabel="true"
                         onclick="embed('addTask','embedDialog');">
                        <span>Database</span>
                    </div>            
                    <div dojotype="dijit.form.Button" showLabel="true" onclick="dijit.byId('aboutDialog').show();">
                        <span>About</span>
                    </div>
                    <div id="overviewBtn" dojoType="dijit.form.DropDownButton" showLabel="true"
                         onclick="fluxProcessor.dispatchEvent('overviewTrigger');">
                        <span>Filter</span>
                        <div id="filterPopup" dojoType="dijit.TooltipDialog">
                            <table id="searchBar">
                                <tr>
                                    <td>
                                        <xf:input ref="from" incremental="true">
                                            <xf:label>from</xf:label>
                                            <xf:action ev:event="xforms-value-changed">
                                                <xf:dispatch name="DOMActivate" targetid="overviewTrigger"/>
                                            </xf:action>
                                        </xf:input>
                                    </td>
                                    <td>
                                        <xf:input ref="to" incremental="true">
                                            <xf:label>to</xf:label>
                                            <xf:action ev:event="xforms-value-changed">
                                                <xf:dispatch  name="DOMActivate" targetid="overviewTrigger"/>
                                            </xf:action>
                                        </xf:input>
                                    </td>
                                    <td>
                                        <xf:select1 ref="project" appearance="minimal" incremental="true">
                                            <xf:label>Project</xf:label>
                                            <xf:action ev:event="xforms-value-changed">
                                                <xf:dispatch  name="DOMActivate" targetid="overviewTrigger"/>
                                            </xf:action>
                                            <xf:itemset nodeset="instance('i-project')/*">
                                                <xf:label ref="."/>
                                                <xf:value ref="."/>
                                            </xf:itemset>
                                        </xf:select1>
                                    </td>
                                    <td>
                                        <xf:select1 ref="billable" appearance="minimal" incremental="true">
                                            <xf:label>Billable</xf:label>
                                            <xf:action ev:event="xforms-value-changed">
                                                <xf:dispatch  name="DOMActivate" targetid="overviewTrigger"/>
                                            </xf:action>
                                            <xf:item>
                                                <xf:label>yes</xf:label>
                                                <xf:value>true</xf:value>
                                            </xf:item>
                                            <xf:item>
                                                <xf:label>no</xf:label>
                                                <xf:value>false</xf:value>
                                            </xf:item>
                                        </xf:select1>
                                    </td>
                                    <td>
                                        <xf:select1 ref="billed" appearance="minimal" incremental="true">
                                            <xf:label>Billed</xf:label>
                                            <xf:action ev:event="xforms-value-changed">
                                                <xf:dispatch  name="DOMActivate" targetid="overviewTrigger"/>
                                            </xf:action>
                                            <xf:item>
                                                <xf:label>not billed yet</xf:label>
                                                <xf:value>false</xf:value>
                                            </xf:item>
                                            <xf:item>
                                                <xf:label>already billed</xf:label>
                                                <xf:value>true</xf:value>
                                            </xf:item>
                                        </xf:select1>
                                    </td>
                                    <td>
                                        <xf:trigger id="closeFilter">
                                            <xf:label/>
                                            <script type="text/javascript">
                                                dijit.byId("filterPopup").onCancel();
                                                fluxProcessor.dispatchEvent("overviewTrigger");
                                            </script>
                                        </xf:trigger>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>                    
                
                </div>

                <img id="shadowTop" src="{$contextPath}/rest/db/configeditor/images/shad_top.jpg" alt=""/>

                <div id="taskDialog" dojotype="dijit.Dialog" style="width:680px;height:680px !important;" title="Workflow" autofocus="false">
                    <div id="embedDialog"></div>
                </div>

                <div id="embedInline"></div>

                <div id="aboutDialog" dojotype="dijit.Dialog" href="about.html" title="About" style="width:500px;height:500px;"></div>

<!--
                <xf:output ref="instance('i-vars')/selectedTasks">
                    <xf:label>all selected tasks</xf:label>
                </xf:output>
-->

                <div id="report"></div>

                <!-- ######################### Content end ################################## -->
            </div>
        </div>
        <!-- ######################### Content end ################################## -->

        <script type="text/javascript" src="{$contextPath}/bfResources/scripts/betterform/betterform-TimeTracker.js" defer="defer"> </script>

        <script type="text/javascript" defer="defer">
            <!--
            var xfReadySubscribers;

            function embed(targetTrigger,targetMount){
                console.debug("embed",targetTrigger,targetMount);
                if(targetMount == "embedDialog"){
                    dijit.byId("taskDialog").show();
                }

                var targetMount =  dojo.byId(targetMount);

                fluxProcessor.dispatchEvent(targetTrigger);

                if(xfReadySubscribers != undefined) {
                    dojo.unsubscribe(xfReadySubscribers);
                    xfReadySubscribers = null;
                }

                xfReadySubscribers = dojo.subscribe("/xf/ready", function(data) {
                    dojo.fadeIn({
                        node: targetMount,
                        duration:100
                    }).play();
                });
                dojo.fadeOut({
                    node: targetMount,
                    duration:100,
                    onBegin: function() {
                        fluxProcessor.dispatchEvent(targetTrigger);
                    }
                }).play();

            }

            var editSubcriber = dojo.subscribe("/task/edit", function(data){
                fluxProcessor.setControlValue("currentTask",data);
                embed('editTask','embedDialog');

            });

            var deleteSubscriber = dojo.subscribe("/task/delete", function(data){
                var check = confirm("Really delete this entry?");
                if (check == true){
                    fluxProcessor.setControlValue("currentTask",data);
                    fluxProcessor.dispatchEvent("deleteTask");
                }
            });

            var refreshSubcriber = dojo.subscribe("/task/refresh", function(){
                fluxProcessor.dispatchEvent("overviewTrigger");
            });

            function selectAll(){
                dojo.query("input",dojo.byId("listingTable")).forEach(
                function (node){
                    dijit.byId(node.id).setChecked(true);
                });
            }

            function selectNone(){
                dojo.query("input",dojo.byId("listingTable")).forEach(
                function (node){
                    dijit.byId(node.id).setChecked(false);
                });
            }

            function passValuesToXForms(){
                var result="";
                dojo.query("input",dojo.byId("listingTable")).forEach(
                function (node){
                    if(dijit.byId(node.id).checked && node.value != undefined){
                        result = result + " " + node.value;
                    }
                });
                fluxProcessor.setControlValue("selectedTaskIds",result);
            }

            // -->
        </script>
        <script type="text/javascript" defer="defer">
        <![CDATA[
        dojo.addOnLoad(function(){
            dojo.subscribe("/xf/ready", function() {
                fluxProcessor.skipshutdown=true;
            });
        });
       ]]></script>        
    </body>
</html>
