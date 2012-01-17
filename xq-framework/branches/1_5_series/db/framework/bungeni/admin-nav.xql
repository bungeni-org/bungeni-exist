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
        <link rel="stylesheet" href="../assets/admin/style.css"/>
    </head>
    <body>
    
       <div id="xforms">
        
        <div style="display:none">
        <xf:model id="m-user-config">
            <xf:instance xmlns="" id="uconfig" src="test-ui-config.xml"/>
            
            <xf:submission id="s-send" replace="none" resource="test-ui-config.xml" method="put">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message level="ephemeral">Navigation Preferences Update failed. Please fill in valid values</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message level="ephemeral">You have updated Navigation Preferences successfully.</xf:message>
                </xf:action>
            </xf:submission>
            
            <xf:bind id="nav-bind" nodeset="instance('uconfig')">
                <xf:bind id="bind-limit" nodeset="/ui/listings/limit" type="xs:integer" />
                <xf:bind id="bind-visible-pages" nodeset="/ui/listings/visiblePages" type="xs:integer" />
            </xf:bind>

        </xf:model>
        </div>
        
    <div class="section">
        <a href="admin-nav.xql" title="Navigation Preferences">Navigation</a>
        <span class="sep">|</span>
        <a href="admin-route.xql" title="Route Configurations">Routes</a>
        <span class="sep">|</span>
        <a href="admin-order.xql" title="Order Configurations">Order</a>
    </div>
    <div class="section" dojotype="dijit.layout.ContentPane">
              <xf:group id="itema-ui" 
                    ref="instance('uconfig')" 
                    appearance="bf:verticalTable">

                <div class="headline">Navigation Preferences</div>
                <div class="description">
                    <p>Edit the Navigation Preferencs</p>
                </div>

                <xf:input bind="bind-limit">
                    <xf:label class="configListHeader">Limit:</xf:label>
                    <xf:hint>how many items to list per page</xf:hint>
                    <xf:alert>Invalid non-numeric value entered</xf:alert>
                </xf:input>
                            
                <xf:range  
                    bind="bind-visible-pages" 
                    start="1" step="1" end="10"
                    >
                    <xf:label class="configListHeader">Pagination Count:</xf:label>
                </xf:range>
                    
                <xf:output bind="bind-visible-pages">
                    <xf:label class="configListHeader">Set to: </xf:label>
                </xf:output>                                 
                <xf:trigger appearance="triggerMiddleColumn">
                    <xf:label class="configListHeader">Update preferences</xf:label>
                    <xf:send submission="s-send"/>
                </xf:trigger>
            </xf:group>
                      
        
        </div>
       
       </div>
        
     </body>
</html>
