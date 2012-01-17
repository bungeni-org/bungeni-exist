xquery version "1.0";

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
    <title>Ordering Preferences</title>
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
                resource="model:orderby#instance('default')/orderby" 
                method="post" 
                replace="none" 
                ref="orderby[index('orderbys')]">
             </xf:submission>
        </xf:model>
    </div>
    <div class="section">
        <a href="admin-nav.xql" title="Navigation Preferences">Navigation</a>
        <span class="sep">|</span>
        <a href="admin-route.xql" title="Route Configurations">Routes</a>
        <span class="sep">|</span>
        <a href="admin-order.xql" title="Order Configurations">Order</a>
        <span class="sep">|</span>
        <a href="admin-search.xql" title="Search Configurations">Search</a>         
    </div>
    <div class="section" dojotype="dijit.layout.ContentPane">
        
        <xf:group appearance="compact" id="ui-config" class="uiConfigGroup" >
            <!-- 
                unload the subform, we may have to call this explicitly
                on switching rows in the repeater -->
            <xf:action ev:event="unload-subforms">
                <xf:load show="none" targetid="orderby"/>
            </xf:action>
            
            <div class="headline">Search Configurations</div>
            <div class="description">
                <p>Edit the Search configurations</p>
            </div>
           
            <!--
            List all the orderby per content type
            -->
            <xf:repeat id="doctypes" nodeset="/ui/doctypes/doctype" appearance="full" class="sortorders">
                <xf:output ref="@name"/>
            </xf:repeat>
        </xf:group>
        
        <xf:group appearance="minimal" class="configsTriggerGroup">
        
            <xf:trigger class="configsSubTrigger">
                <xf:label>load selected configuration</xf:label>
                <xf:hint>Edit the Selected row in a form.</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Loading Order By Editor...</xf:message>
                    <xf:load show="embed" targetid="doctype">
                        <xf:resource value="'./admin-search-subform.xml'"/>
                    </xf:load>
                </xf:action>
            </xf:trigger>
        </xf:group>
        
        <!-- 
            the subform is embedded here 
        -->
        <xf:group appearance="full" class="configsFullGroup">
            <div class="configsSubForm">
                <div id="doctype"/>
            </div>
            
        </xf:group> 
        
    </div>
 </div>
</body>
</html>
