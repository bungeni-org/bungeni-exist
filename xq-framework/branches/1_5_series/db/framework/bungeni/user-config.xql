xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xhtml media-type=text/html indent=no";

declare function local:get-real-name() {
    util:document-name(collection('/db/bungeni-xml')//bu:ontology/bu:legislativeItem[@uri='/ke/question/337:166-question/en'])
};


<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <head>
        <title>Config Param</title>
        <meta name="author" content="anthony at googlemail.com"/>
        <meta name="author" content="ashok at parliaments.info"/>
        <meta name="description" content="XForms with config options"/>
        <link rel="stylesheet" href="../assets/bungeni/css/boilerplate.css"/>
        <link rel="stylesheet" href="../assets/bungeni/css/bungeni.css"/>
        <link rel="stylesheet" href="../assets/bungeni/css/xforms.css"/>
        <xf:model id="m-user-config">
            <!--xf:instance id="pcount" xmlns="" >
                <data>
                    <range1 constraint="true">
                        <value>5</value>
                    </range1>
                </data>                                  
            </xf:instance-->
            <xf:instance xmlns="" id="uconfig" src="ui-user-config.xml"/>
            <xf:instance id="requests">
                <request xmlns="">
                    <host>{request:get-server-name()}</host>
                    <doc>{local:get-real-name()}</doc>
                    <remote-host>{request:get-remote-host()}</remote-host>
                    <remote-ip>{request:get-remote-addr()}</remote-ip>
                </request>                                      
            </xf:instance>                                    
            <xf:submission id="s-send" replace="none" resource="ui-user-config.xml" method="put">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message>Config Update failed. Please fill in valid values</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>You have updated successfully.</xf:message>
                </xf:action>
            </xf:submission>
            <!--<xf:setfocus control="first" ev:event="xforms-ready"/>-->
            <xf:bind id="pcount" nodeset="instance('uconfig')">
                <xf:bind nodeset="//limit" type="integer"/>
                <xf:bind constraint="boolean-from-string(../@constraint)" nodeset="//value" type="integer"/>
            </xf:bind>
        </xf:model>        
    </head>
    <body>
        <div id="container" style="background-color:#eeeeee;">
            <div id="header">
                <div id="header-banner"/>
                <div class="header-nav">
                    <div id="mainnav" class="menu">
                        <ul class="theme-lev-1" id="menu-level-mainnav">
                            <li><a href="javascript:history.back();">&#171; go back</a></li>
                            <li><a class="current" href="http://localhost:8080/exist/rest/db/framework/bungeni/user-config.xql">preferences</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div id="sub-header">
                <div class="header-nav">
                    <div id="subnav" class="submenu"/>
                </div>
            </div>
            <div id="main-wrapper">
                <div id="title-holder" class="theme-lev-1-only">
                    <h1 id="doc-title-blue">Edit UI Preferences</h1>
                </div>
                <div id="main-doc" class="rounded-eigh tab_container">
                    <div id="xforms" style="margin-left:0px;padding-left:10px;width:100%;">
                        <div id="ui-prefs" class="ui-prefs InlineRoundBordersAlert">
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
                            <xf:group id="itema-ui" ref="instance('uconfig')" appearance="bf:verticalTable">
                                <xf:label>Configure UI Parameters</xf:label>                                    
                                <xf:input ref="limit">
                                    <xf:label>Limit:</xf:label>
                                    <xf:hint>how many items to list per page</xf:hint>
                                    <xf:alert>Invalid non-numeric value entered</xf:alert>
                                </xf:input>
                                <xf:range class="ui-range-wdg" incremental="true" ref="visiblePages/value" start="1" step="1" end="10">
                                    <xf:label>Pagination Count:</xf:label>
                                    <xf:hint>a Hint for this control</xf:hint>
                                    <xf:help>help for visibalePages</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                </xf:range>
                                <xf:output value="visiblePages/value">
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
            </div>
        </div>
    </body>
</html>