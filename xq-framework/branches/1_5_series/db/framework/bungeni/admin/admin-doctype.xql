xquery version "1.0";

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
        <title>Navigation Preferences</title>
        <meta name="author" content="anthony at googlemail.com"/>
        <meta name="author" content="ashok at parliaments.info"/>
        <meta name="description" content="XForms with config options"/>
        <link rel="stylesheet" href="../assets/bungeni/css/boilerplate.css"/>
        <link rel="stylesheet" href="../assets/bungeni/css/bungeni.css"/>
        <link rel="stylesheet" href="../assets/bungeni/css/xforms.css"/>       
        
        
    </head>
    <body>
    
 
 <div id="xforms">
            <div style="display:none">
                <xf:model id="master">
                    <xf:instance xmlns="" id="ui-config" src="test-ui-config.xml" />
                    <xf:submission id="update-subform" resource="model:doctype#instance('default')/doctype" method="post" replace="none" ref="doctype[index('doctypes')]">
						<!--<xf:message ev:event="xforms-submit-done" level="ephemeral">Masterform has updated Subform.</xf:message>-->
                    </xf:submission>
                </xf:model>
            </div>
            <div class="Section" dojotype="dijit.layout.ContentPane">
                <xf:group appearance="full" id="ui-config" >
                    <xf:action ev:event="unload-subforms">
                        <xf:message level="ephemeral">unloading subform...</xf:message>
                        <xf:load show="none" targetid="doctype"/>
                    </xf:action>
                    <xf:repeat id="doctypes" nodeset="/ui/doctypes/doctype[@name='question']" appearance="compact" class="doctypesRepeat">
                       <xf:output ref="@name">
                            <xf:label class="orderListHeader">Doc Type</xf:label>
                        </xf:output>
                        <xf:repeat id="orderbys" nodeset="orderbys/orderby"  appearance="compact" class="orderbysRepeat" >
                             <xf:output ref="@value">
                              <xf:label class="orderListHeader">Orderby Value</xf:label>
                             </xf:output>
                             <xf:output ref="@order">
                              <xf:label class="orderListHeader">Order</xf:label>
                             </xf:output>
                             <xf:output ref=".">
                                <xf:label class="orderListHeader">Text</xf:label>
                             </xf:output>
          
                        </xf:repeat>
                     
                    </xf:repeat>
                </xf:group>
                
                <xf:group appearance="minimal" class="doctypesTriggerGroup">
                    <xf:trigger class="doctypesSubTrigger">
                        <xf:label>edit selected</xf:label>
                        <xf:hint>This button will push the selected data into the subform.</xf:hint>
                        <xf:action>
                            <xf:message level="ephemeral">loading subform...</xf:message>
                            <xf:load show="embed" targetid="doctype">
                                <xf:resource value="'./admin-doctype-subform.xml'"/>
                            </xf:load>
                        </xf:action>
                    </xf:trigger>
                </xf:group>
                
                <xf:group appearance="full" class="doctypesFullGroup">
                    <div class="doctypesSubForm">
                        <div id="doctype"/>
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
