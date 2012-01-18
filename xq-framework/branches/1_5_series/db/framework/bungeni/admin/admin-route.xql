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
    <meta name="author" content="anthony at googlemail.com"/>
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
            <xf:instance xmlns="" id="ui-config" src="../test-ui-config.xml" />
            <xf:submission id="update-subform" 
                resource="model:route#instance('default')/route" 
                method="post" 
                replace="none" 
                ref="route[index('routes')]">
             </xf:submission>
        </xf:model>
    </div>
    <!-- MAIN MENU -->
    <div class="section">{adm:main-menu('route')}</div>
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
                <!--
               <xf:output ref="title">
                    <xf:label class="configListHeader">Title</xf:label>
                </xf:output>
                -->
               <xf:output value="concat(title, ' [', navigation, '&#8594;', subnavigation, '] ')">
                    <xf:label class="configListHeader">Title [Navigation]</xf:label>
                </xf:output>
                <!-- we show the navigation and subnavigation in the same cell -->
                <!--
               <xf:output ref="subnavigation">
                    <xf:label class="configListHeader">Sub-Navigation</xf:label>
                </xf:output>
                -->
            </xf:repeat>
            
        </xf:group>
        
        <xf:group appearance="minimal" class="configsTriggerGroup">
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
</body>
</html>
