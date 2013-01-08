xquery version "1.0";

import module namespace adm = "http://exist.bungeni.org/adm" at "admin.xqm";

(:
Route Editor container XForm
:)
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xhtml media-type=text/html indent=no";

<html xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:ev="http://www.w3.org/2001/xml-events" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:bf="http://betterform.sourceforge.net/xforms" 
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<head>
    <title>Route Preferences</title>
    <meta name="author" content="aowino at googlemail.com"/>
    <meta name="author" content="ashok at parliaments.info"/>
    <meta name="description" content="XForms with config options"/>
    <link rel="stylesheet" href="../../assets/admin/style.css"/>
</head>
<body>
 <div id="xforms">
    <div style="display:none">
       <!-- 
        "master" model used by the subform
        -->
        <xf:model id="master">
            
            <xf:instance xmlns="" 
                id="ui-config" 
                src="../ui-config.xml" />    
                
            <xf:instance id="tmpl-route" xmlns="">
                <route/>
            </xf:instance>         
                
             <xf:submission id="save-form" 
                replace="none" 
                resource="../ui-config.xml" 
                method="put">
             </xf:submission>
   
        </xf:model>       
    </div>
    <!-- MAIN MENU -->
    <div class="section" id="mainnav">{adm:main-menu('route')}</div>
    <div class="section" dojotype="dijit.layout.ContentPane">
        
        <xf:group appearance="compact" id="ui-config" class="uiConfigGroup" >
            <!-- 
                unload the subform, we may have to call this explicitly
                on switching rows in the repeater -->
            <xf:action ev:event="unload-subforms">
                <xf:load show="none" targetid="route"/>
            </xf:action>
            
            <div class="headline">Route Configurations</div>
            <div class="description">
                <p>Edit the route configurations</p>
            </div>
          
            
            <!--
            List all the routes 
            -->
            <xf:repeat id="routes" nodeset="/ui/routes/route" appearance="compact" class="configsRepeat">
                <xf:output ref="@href">
                    <xf:label class="configListHeader">Path</xf:label>
                </xf:output>
       
                <xf:output value="concat(title, ' [', navigation, '&#8594;', subnavigation, '] ')">
                    <xf:label class="configListHeader">Title [Navigation]</xf:label>
                </xf:output>
                
                <!--xf:trigger class="configsSubTrigger">
                    <xf:label>edit</xf:label>
                    <xf:hint>Edit the Selected row in a form.</xf:hint>
                    <xf:action>
                        <xf:message level="ephemeral">Loading Route Editor...</xf:message>
                        <xf:load show="embed" targetid="route" ref="index('routes')">
                            <xf:resource value="'./admin-route-subform.xml'"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger-->                
                
                <xf:trigger class="configsSubTrigger">
                    <xf:label>delete</xf:label>
                    <xf:hint>Delete the Selected row in a form.</xf:hint>
                    <xf:action>
                        <xf:message level="ephemeral">Deleting selected route...</xf:message>
                        <xf:delete nodeset="/ui/routes/route" at="index('routes')" ev:event="DOMActivate"/>
                    </xf:action>
                </xf:trigger>                 
            </xf:repeat>
            
        </xf:group>
        
        <xf:group appearance="minimal" model="master" class="configsTriggerGroup">
            <xf:trigger class="configsSubTrigger">
                <xf:label>add route</xf:label>
                <xf:hint>Add a new route for navigation.</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Loading Route Add Form...</xf:message>
                    <xf:insert nodeset="/ui/routes/route" at="last()" ev:event="DOMActivate" origin="instance('tmpl-route')"/>
                    <xf:load show="embed" targetid="route">
                        <xf:resource value="'./admin-route-add.xml'"/>
                    </xf:load>
                </xf:action>
            </xf:trigger>        
        
            <xf:trigger class="configsSubTrigger">
                <xf:label>edit selected</xf:label>
                <xf:hint>Edit the Selected row in a form.</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Loading Route Editor...</xf:message>
                    <xf:load show="embed" targetid="route">
                        <xf:resource value="'./admin-route-subform.xml'"/>
                    </xf:load>
                </xf:action>
            </xf:trigger>            
            
            <xf:trigger class="configsSubTrigger">
                <xf:label>save changes</xf:label>
                <xf:hint>Save all your changes back to the configuratiuon document</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Saving Document...</xf:message>
                    <xf:send submission="save-form" />
                </xf:action>
            </xf:trigger>
            
        </xf:group>
        <!-- 
            the subform is embedded here 
        -->
        <xf:group appearance="full" class="configsFullGroup">
            <div class="configsSubForm">
                <div id="route"/>
            </div>
        </xf:group>
        
    </div>
 </div>
    <script type="text/javascript" defer="defer">
        <![CDATA[
        dojo.addOnLoad(function(){
            dojo.subscribe("/xf/ready", function() {
                fluxProcessor.skipshutdown=true;
            });
        });
       ]]>
    </script>     
</body>
</html>
