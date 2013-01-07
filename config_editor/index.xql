xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=application/xhtml+html";

import module namespace menu = "http://exist.bungeni.org/adm" at "menu.xqm";

let $contextPath := request:get-context-path()
let $fs-bungeni-custom-path := doc('config.xml')//bungeni-custom-fs-path/text()
return
<html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb"
      xml:lang="en">
    <head>
        <title>Bungeni Configuration Editor</title>
        <link rel="stylesheet" type="text/css" href="./css/main.css"/>
    </head>
    <body class="nihilo InlineRoundBordersAlert">
        <div class="page">

            <!-- ***** hidden triggers ***** -->
            <div style="display:none;">
                <xf:model id="modelone">
                    <xf:instance>
                        <data xmlns="">
                            <lastupdate>2000-01-01</lastupdate>
                            <user>admin</user>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-query-workflows"
                                    resource="{$contextPath}/rest/db/config_editor/views/about.html"
                                    method="get"
                                    replace="embedHTML"
                                    targetid="embedInline"
                                    ref="instance()"
                                    validate="false">
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Request for about page successful</xf:message>
                        </xf:action>                                    
                        <xf:action ev:event="xforms-submit-error">
                            <xf:message>Submission failed</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:instance id="i-vars">
                        <data xmlns="">
                            <default-duration>120</default-duration>
                            <currentTask/>
                            <currentView/>
                            <currentDoc/>
                            <currentNode/>
                            <currentAttr/>
                            <currentField/>
                            <showTab/>
                            <selectedTasks/>
                        </data>
                    </xf:instance>
                    <xf:bind nodeset="instance('i-vars')/default-duration" type="xf:integer"/>

                    <xf:action ev:event="xforms-ready">
                        <xf:message level="ephemeral">Default: show about</xf:message>
                        <xf:action ev:event="xforms-value-changed">
                            <xf:dispatch name="DOMActivate" targetid="overviewTrigger"/>
                        </xf:action>
                    </xf:action>
                </xf:model>

                <xf:trigger id="overviewTrigger">
                    <xf:label>Overview</xf:label>
                    <xf:send submission="s-query-workflows"/>
                </xf:trigger>
                
                <xf:trigger id="storeSys">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/sys-store-custom.xql#xforms?fs_path=',instance('i-vars')/currentDoc)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger> 
                
                <xf:trigger id="writeSys">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/sys-sync-custom.xql#xforms?fs_path=',instance('i-vars')/currentDoc)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                
                
                <xf:trigger id="viewForm">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-form.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>   
                
                <xf:trigger id="viewWorkflow">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-workflow.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>         
                
                <xf:trigger id="addPopup">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/add-',instance('i-vars')/currentView,'.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;node=',instance('i-vars')/currentNode,'&amp;attr=',instance('i-vars')/currentAttr,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                 
                
                <xf:trigger id="editPopup">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/edit-',instance('i-vars')/currentView,'.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;node=',instance('i-vars')/currentNode,'&amp;attr=',instance('i-vars')/currentAttr,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>     
                
                <xf:trigger id="view">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-',instance('i-vars')/currentView,'.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;node=',instance('i-vars')/currentNode,'&amp;attr=',instance('i-vars')/currentAttr,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                  
                
                <xf:trigger id="addField">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/add-field.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField,'&amp;mode=new')"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                

                <xf:trigger id="editField">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-field.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>
                
                <xf:trigger id="editRole">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/edit-role.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;role=',instance('i-vars')/currentNode)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                
                
                <xf:trigger id="moveFieldUp">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/move-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;move=up&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger> 
                
                <xf:trigger id="moveFieldDown">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/move-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;move=down&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>  
                
                <xf:trigger id="deleteField">
                    <xf:label>delete</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/delete-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>   
                
                <xf:trigger id="deleteRole">
                    <xf:label>delete</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/delete-role.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
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
                <xf:input id="currentView" ref="instance('i-vars')/currentView">
                    <xf:label>This is just a hidden used by JS</xf:label>
                </xf:input>                
                <xf:input id="currentDoc" ref="instance('i-vars')/currentDoc">
                    <xf:label>This is just an ephemeral used by JS</xf:label>
                </xf:input>
                <xf:input id="currentNode" ref="instance('i-vars')/currentNode">
                    <xf:label>This is just a dummy placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="currentAttr" ref="instance('i-vars')/currentAttr">
                    <xf:label>This is just a value placeholder by JS</xf:label>
                </xf:input>                
                <xf:input id="currentField" ref="instance('i-vars')/currentField">
                    <xf:label>This is just a random placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="showTab" ref="instance('i-vars')/showTab">
                    <xf:label>This is just a renderlook placeholder by JS</xf:label>
                </xf:input>                 
            </div>

            <div id="header">
                <div id="appName">Bungeni Configuration Editor</div>
            </div>
            <!-- ######################### Content here ################################## -->
            <img id="shadowTop" src="images/shad_top.jpg" alt=""/>
            <div id="content">
                <div id="left-content">
                    <div dojoType="dijit.Menu" id="navMenu">
                        {menu:get-types('search')} 
                        <div dojoType="dijit.MenuItem" onclick="javascript:dojo.publish('/view',['roles','custom.xml','roles','none','none']);">Roles</div>                          
                        <xhtml:div dojoType="dijit.MenuSeparator"/> 
                        <div dojoType="dijit.PopupMenuItem"> 
                            <span>
                                System            
                            </span>                        
                            <div dojoType="dijit.Menu" id="submenusys">
                                <div dojoType="dijit.MenuItem" onClick="showDialogAb();document.getElementById('fs_path').focus();">store from file-system</div>
                                <!--div dojoType="dijit.MenuItem" onClick="alert('A To-Do')">create a working copy</div-->
                                <div dojoType="dijit.MenuItem" onclick="javascript:dojo.publish('/sys/write');">sync back to filesystem</div>           
                            </div>
                        </div>
                        <!--div dojoType="dijit.MenuSeparator"/>
                        <div dojoType="dijit.MenuItem" onClick="alert('DB : To Do')">DB</div>
                        <div dojoType="dijit.MenuItem" onClick="alert('OpenOFFice - To Do')">OpenOffice</div-->
                    </div>
                </div>
                <div id="right-content">
                    <!-- ######################### Views start ################################## -->    
                    <div id="sysDialog" dojotype="dijit.Dialog" style="width:500px;overflow:auto;" title="Dialog for Bungeni Custom" autofocus="false">
                        <div id="embedDialogSys">
                    		<table>
                    			<tr>
                    				<td style="width: 90px;"><label for="name">Absolute Path: </label></td>
                    				<td><input dojoType="dijit.form.TextBox" type="text" style="width:120%;" id="fs_path" name="fs_path" value="{$fs-bungeni-custom-path}" /></td>
                    			</tr>                    			
                    			<tr>
                    				<td colspan="2">
                    				    e.g. <i>/home/undesa/bungeni_apps/bungeni/src/bungeni_custom</i>
                    				    <br />
                    				    <br />
                    				    NOTE: This action will overwrite existing bungeni_custom. Unless the<br/>
                    				    structure of the configuration files has changed, this process is prefererably<br />
                    				    done once.<br/>
                    				</td>
                    			</tr>
                    		</table>
                        	<div class="dijitDialogPaneActionBar">
                        		<button dojoType="dijit.form.Button" type="submit" onClick="javascript:dojo.publish('/sys');" id="ABdialog1button1">Load</button>
                        	</div> 
                        </div>
                    </div>                    
                    
                    <div id="formsDialog" dojotype="dijit.Dialog" style="width:400px;overflow:auto;" title="Forms" autofocus="false">
                        <div id="embedDialogForms"></div>
                    </div>
    
                    <div id="dbDialog" dojotype="dijit.Dialog" style="width:480px;height:250px !important;overflow:overflow-y;" title="Database" autofocus="false">
                        <div id="embedDialogDB"></div>
                    </div>
    
                    <div id="taskDialog" dojotype="dijit.Dialog" style="width:860px;" title="Add / Edit Dialog" autofocus="false">
                        <div id="embedDialog"></div>
                    </div>
    
                    <div id="embedInline" style="width:100%;height:760px;overflow: auto;"></div>
                    <!-- ######################### Views end ################################## --> 
                </div>
            </div>            
            <div id="scontent">

                <!-- ######################### Content end ################################## -->
            </div>
        
        </div>
        <!-- ######################### Content end ################################## -->

        <script type="text/javascript" src="{$contextPath}/bfResources/scripts/betterform/betterform-TimeTracker.js" defer="defer"> </script>

        <script type="text/javascript" defer="defer">
            <!--
            var xfReadySubscribers;
            
            
			showDialogAb = function(){
				var dlg = dijit.byId('sysDialog');
				dlg.show();
			};              

            function embed(targetTrigger,targetMount){
                console.debug("embed",targetTrigger,targetMount);
                if(targetMount == "embedDialog"){
                    dijit.byId("taskDialog").show();
                } else if(targetMount == "embedDialogDB") {
                    dijit.byId("dbDialog").show();
                } else if(targetMount == "embedDialogForms") {
                    dijit.byId("formsDialog").show();
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
            
            var viewSubscriber = dojo.subscribe("/sys", function(){
                
                var fsPath = dijit.byId("fs_path");
                if (fsPath.get("value") == "" || fsPath.get("value").length < 10) {
                    alert("Invalid: Empty path or path less than 10 characters");
                    location.reload();
                }else{
                    validatedFsPath = fsPath.get("value").replace(/^\s+|\s+$/g, '');
                    console.log(validatedFsPath);
                    fluxProcessor.setControlValue("currentDoc",validatedFsPath); 
                    embed('storeSys','embedInline');
                }                 
            });     
            
            var writeSubscriber = dojo.subscribe("/sys/write", function(){
                var check = confirm("This will overwrite contents of your existing bungeni_custom folder");
                if (check == true){
                    embed('writeSys','embedInline');
                }                 
            });               
            
            var editSubscriber = dojo.subscribe("/form/view", function(doc,tab){
                fluxProcessor.setControlValue("currentDoc",doc);                
                fluxProcessor.setControlValue("showTab",tab);
                embed('viewForm','embedInline');
            }); 
            
            var editSubscriber = dojo.subscribe("/workflow/view", function(doc,node,tab){
                fluxProcessor.setControlValue("currentDoc",doc);       
                fluxProcessor.setControlValue("currentNode",node);  
                fluxProcessor.setControlValue("showTab",tab);
                embed('viewWorkflow','embedInline');
            });             
            
            var editSubscriber = dojo.subscribe("/view", function(view,doc,node,attr,tab){
                fluxProcessor.setControlValue("currentView",view);  // ~/views/get-{view}.xql  
                fluxProcessor.setControlValue("currentDoc",doc);    // document in the query                
                fluxProcessor.setControlValue("currentNode",node);  // parent node in the query
                fluxProcessor.setControlValue("currentAttr",attr);  // attribute selector for node in the query                
                fluxProcessor.setControlValue("showTab",tab);       // tab to switch to, if any, in the view
                embed('view','embedInline');
            });   
            
            var editSubscriber = dojo.subscribe("/add", function(view,doc,node,attr,tab){
                fluxProcessor.setControlValue("currentView",view);  // ~/views/get-{view}.xql  
                fluxProcessor.setControlValue("currentDoc",doc);    // document in the query                
                fluxProcessor.setControlValue("currentNode",node);  // parent node in the query
                fluxProcessor.setControlValue("currentAttr",attr);  // attribute selector for node in the query                
                fluxProcessor.setControlValue("showTab",tab);       // tab to switch to, if any, in the view
                embed('addPopup','embedDialog');
            });              
            
            var editSubscriber = dojo.subscribe("/edit", function(view,doc,node,attr,tab){
                fluxProcessor.setControlValue("currentView",view);  // ~/views/get-{view}.xql  
                fluxProcessor.setControlValue("currentDoc",doc);    // document in the query                
                fluxProcessor.setControlValue("currentNode",node);  // parent node in the query
                fluxProcessor.setControlValue("currentAttr",attr);  // attribute selector for node in the query                
                fluxProcessor.setControlValue("showTab",tab);       // tab to switch to, if any, in the view
                embed('editPopup','embedDialog');
            });             
            
            var addSubscriber = dojo.subscribe("/field/add", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                embed('addField','embedDialog');
            });
            
            var editSubscriber = dojo.subscribe("/field/edit", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                embed('editField','embedDialog');
            });            
            
            var moveUpSubscriber = dojo.subscribe("/field/up", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                fluxProcessor.dispatchEvent('moveFieldUp');
            });
            
            var moveDownSubscriber = dojo.subscribe("/field/down", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                fluxProcessor.dispatchEvent('moveFieldDown');
            });   
            
            var deleteSubscriber = dojo.subscribe("/field/delete", function(form,field){
                var check = confirm("Really delete this field?");
                if (check == true){
                    fluxProcessor.setControlValue("currentDoc",form);
                    fluxProcessor.setControlValue("currentField",field);
                    fluxProcessor.dispatchEvent('deleteField');
                }            
            }); 
            
            var deleteSubscriber = dojo.subscribe("/role/delete", function(form,field){
                var check = confirm("Really delete this role?");
                if (check == true){
                    fluxProcessor.setControlValue("currentDoc",form);
                    fluxProcessor.setControlValue("currentField",field);
                    fluxProcessor.dispatchEvent('deleteRole');
                }            
            });            

            var editSubscriber = dojo.subscribe("/role/edit", function(form,node){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentNode",node);
                embed('editRole','embedDialog');
            }); 

            var refreshSubcriber = dojo.subscribe("/wf/refresh", function(){
                fluxProcessor.dispatchEvent("overviewTrigger");
            });           

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
            
            dojo.addOnLoad(function(){
                dojo.subscribe("/xf/ready", function() {
                    fluxProcessor.skipshutdown=true;
                });
            });            

            // -->
        </script>
    </body>
</html>