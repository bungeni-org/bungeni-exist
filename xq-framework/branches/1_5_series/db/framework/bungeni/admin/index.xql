xquery version "1.0";

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
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:ev="http://www.w3.org/2001/xml-events" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:bf="http://betterform.sourceforge.net/xforms" 
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<head>
    <title>Admin Section</title>
    <meta name="author" content="aowino at googlemail.com"/>
    <meta name="author" content="ashok at parliaments.info"/>
    <meta name="description" content="Landing page for admin panel."/>
    <link rel="stylesheet" href="../../assets/admin/style.css"/>
</head>
<body>
 <div id="xforms">
    <!-- MAIN MENU -->
    <div class="section">{adm:main-menu('search')}</div>
    <div class="section" dojotype="dijit.layout.ContentPane">
        
        <xf:group appearance="compact" id="ui-config" class="uiConfigGroup" >
            <!-- 
                unload the subform, we may have to call this explicitly
                on switching rows in the repeater -->
            <xf:action ev:event="unload-subforms">
                <xf:load show="none" targetid="orderby"/>
            </xf:action>
            
            <div class="headline">Admin Section</div>
            <div class="description desc-center">
                <p>
                    <![CDATA[ (: Welcome to administrator panel for Bungeni eXist portal :) ]]>
                </p>
            </div>

        </xf:group>
        
    </div>
 </div>
</body>
</html>
