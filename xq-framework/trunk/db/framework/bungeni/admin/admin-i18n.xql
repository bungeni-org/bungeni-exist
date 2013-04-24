xquery version "3.0";

import module namespace adm = "http://exist.bungeni.org/adm" at "admin.xqm";

(:
Order Editor container XForm
:)
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xhtml media-type=text/html indent=no";

<html xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:ev="http://www.w3.org/2001/xml-events" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:bf="http://betterform.sourceforge.net/xforms" 
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <head>
        <title>i18n Catalogues</title>
        <meta name="author" content="anthony at googlemail.com"/>
        <meta name="author" content="ashok at parliaments.info"/>
        <meta name="description" content="XForms with config options"/>
        <link rel="stylesheet" href="../assets/css/admin.css"/>
    </head>
<body>
 <div id="xforms">
    <div style="display:none">
       <!-- 
        "master" model used by the subform
        -->
        <xf:model id="master">
            <xf:instance xmlns="" id="ui-config" src="{$adm:UI-CONFIG}" />
            
            <!-- catalogues listed here -->
            <xf:instance xmlns="" id="messages">
                {adm:catalogues()}
            </xf:instance>
             
        </xf:model>
    </div>
    <!-- MAIN MENU -->
    <div class="section" id="mainnav">{adm:main-menu('order')}</div>
    <div class="section" dojotype="dijit.layout.ContentPane">
        <!-- 
            unload the subform, we may have to call this explicitly
            on switching rows in the repeater -->
        <xf:action ev:event="unload-subforms">
            <xf:load show="none" targetid="orderby"/>
        </xf:action>
        
        <div class="headline">i18n Catalogues</div>
        <div class="description">
            <p>Edit language message strings</p>
        </div>
       
        <div class="section" dojotype="dijit.layout.ContentPane">
            <xf:group appearance="compact" id="ui-config" class="uiConfigGroup" >
                <!--
                List all the catalogue documents
                -->
                <div class="itemgroups"> 
                    <xf:group appearance="minimal" class="configsTriggerGroup">
                          <xf:trigger class="configsSubTrigger">
                              <xf:label>load selected catalogue</xf:label>
                              <xf:hint>Edit the Selected row in a form.</xf:hint>
                              <xf:action>
                                  <xf:message level="ephemeral">Loading Language catalogue...</xf:message>
                                  <xf:load show="embed" targetid="docwrapper">
                                      <xf:resource value="concat('./admin-i18n-subform.xql?cat=',instance('messages')/lang[index('catalogues')]/text())"/>
                                  </xf:load>
                              </xf:action>
                          </xf:trigger>
                    </xf:group>                 
                
                    <xf:repeat id="catalogues" nodeset="instance('messages')/lang" appearance="full" class="itemgroups">
                        <xf:output ref="@label"/>
                    </xf:repeat>
                    
                    <xf:group appearance="minimal" class="configsTriggerGroup">            
                        <xf:trigger class="configsSubTrigger">
                            <xf:label>add new catalogue</xf:label>
                            <xf:hint>Add a blank catalogue</xf:hint>
                              <xf:action>
                                  <xf:message level="ephemeral">Loading catalogue template...</xf:message>
                                  <xf:load show="embed" targetid="docwrapper">
                                      <xf:resource value="'./admin-i18n-subform.xql'"/>
                                  </xf:load>
                              </xf:action>
                        </xf:trigger>
                        
                    </xf:group>
                 </div>
            </xf:group>
            
            <!-- 
                the subform is embedded here 
            -->
            <xf:group appearance="full" class="configsFullGroup">
                <div class="configsSubForm">
                    <div id="docwrapper" class="editpane"/>
                </div>
            </xf:group>             
         </div> 
        
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
