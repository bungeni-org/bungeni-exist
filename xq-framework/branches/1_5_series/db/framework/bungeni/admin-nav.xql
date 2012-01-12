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
        
        
        <xf:model id="m-user-config">
            <xf:instance xmlns="" id="uconfig" src="test-ui-config.xml"/>
            
            <xf:submission id="s-send" replace="none" resource="test-ui-config.xml" method="put">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message>Navigation Preferences Update failed. Please fill in valid values</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>You have updated Navigation Preferences successfully.</xf:message>
                </xf:action>
            </xf:submission>
            
            <xf:bind id="nav-bind" nodeset="instance('uconfig')">
                <xf:bind id="bind-limit" nodeset="/ui/listings/limit" type="xs:integer" />
                <xf:bind id="bind-visible-pages" nodeset="/ui/listings/visiblePages" type="xs:integer" />
            </xf:bind>

        </xf:model>

    </head>
    <body>
    
 
       
            <div id="main-wrapper">
                <div id="title-holder" class="theme-lev-1-only">
                    <h1 id="doc-title-blue">Navigation Preferences</h1>
                </div>
                    <div id="xforms" style="margin-left:0px;padding-left:10px;width:100%;">
                        
                        <div id="ui-prefs" class="ui-prefs InlineRoundBordersAlert">
                            <!--
                            <div class="info-div">
                                <xf:label>
                                    <xf:output class="svr-params" value="instance('requests')//host">
                                        <xf:label>For server on hostname: </xf:label>
                                    </xf:output> 
                                    <xf:output value="instance('requests')/remote-ip">
                                        <xf:label>Your IP: </xf:label>
                                    </xf:output>                                    
                                </xf:label>
                            </div>        
                            -->
                            <xf:group id="itema-ui" ref="instance('uconfig')" appearance="bf:verticalTable">
                                <xf:label>Configure UI Parameters</xf:label>                                    
                                <xf:input bind="bind-limit">
                                    <xf:label>Limit:</xf:label>
                                    <xf:hint>how many items to list per page</xf:hint>
                                    <xf:alert>Invalid non-numeric value entered</xf:alert>
                                </xf:input>
                                
                                <xf:range  
                                    bind="bind-visible-pages" 
                                    start="1" step="1" end="10"
                                    >
                                    <xf:label>Pagination Count:</xf:label>
                                    <xf:hint>a Hint for this control</xf:hint>
                                    <xf:help>help for visibalePages</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    
                                </xf:range>
                                
                                <xf:output bind="bind-visible-pages">
                                    <xf:label>Set to: </xf:label>
                                </xf:output>                                 
                                <xf:trigger appearance="triggerMiddleColumn">
                                    <xf:label>Update preferences</xf:label>
                                    <xf:hint>Be calm - this is jus a tinker! ;)</xf:hint>
                                    <xf:send submission="s-send"/>
                                </xf:trigger>
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
