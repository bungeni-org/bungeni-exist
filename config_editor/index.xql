xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=application/xhtml+html";

import module namespace menu = "http://exist.bungeni.org/adm" at "menu.xqm";

let $contextPath := request:get-context-path()
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
    <body id="workflow" class="nihilo InlineRoundBordersAlert">
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
                                    resource="{$contextPath}/rest/db/config_editor/views/list-workflows.xql"
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
                            <currentDoc/>
                            <currentNode/>
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
                
                <xf:trigger id="editFORM">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-form.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;tab=',instance('i-vars')/showTab)"/>
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

                <xf:trigger id="deleteTask">
                    <xf:label>delete</xf:label>
                    <xf:send submission="s-delete-workflow"/>
                </xf:trigger>

                <xf:input id="currentTask" ref="instance('i-vars')/currentTask">
                    <xf:label>This is just a dummy used by JS</xf:label>
                </xf:input>
                <xf:input id="currentDoc" ref="instance('i-vars')/currentDoc">
                    <xf:label>This is just an ephemeral used by JS</xf:label>
                </xf:input>
                <xf:input id="currentNode" ref="instance('i-vars')/currentNode">
                    <xf:label>This is just a dummy placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="currentField" ref="instance('i-vars')/currentField">
                    <xf:label>This is just a random placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="showTab" ref="instance('i-vars')/showTab">
                    <xf:label>This is just a renderlook placeholder by JS</xf:label>
                </xf:input>                 
            </div>

            <div id="header">
                <div id="appName"><!--Bungeni Configuration Editor--></div>
            </div>
            <!-- ######################### Content here ################################## -->
            <img id="shadowTop" src="images/shad_top.jpg" alt=""/>
            <div id="content">
                <div id="left-content">
                    <div dojoType="dijit.Menu" id="navMenu">
                        {menu:get-types('search')}                
                        <!--div dojoType="dijit.MenuSeparator"/>
                        <div dojoType="dijit.MenuItem" onClick="alert('Roles!')">Roles</div>
                        <div dojoType="dijit.MenuItem" onClick="alert('Le DB!')">DB</div>
                        <div dojoType="dijit.MenuItem" onClick="alert('OpenOFFice!')">OpenOffice</div-->
                    </div>
                </div>
                <div id="right-content" >
                    <!-- ADADADA -->          
                    <div id="formsDialog" dojotype="dijit.Dialog" style="width:400px;overflow:auto;" title="Forms" autofocus="false">
                        <div id="embedDialogForms"></div>
                    </div>
    
                    <div id="dbDialog" dojotype="dijit.Dialog" style="width:480px;height:250px !important;overflow:overflow-y;" title="Database" autofocus="false">
                        <div id="embedDialogDB"></div>
                    </div>
    
                    <div id="taskDialog" dojotype="dijit.Dialog" style="width:600px;" title="Add / Edit field" autofocus="false">
                        <div id="embedDialog"></div>
                    </div>
    
                    <div id="embedInline"></div>
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
            
            var editSubscriber = dojo.subscribe("/form/view", function(doc,tab){
                fluxProcessor.setControlValue("currentDoc",doc);
                fluxProcessor.setControlValue("showTab",tab);
                embed('editFORM','embedInline');
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