xquery version "1.0";

import module namespace adm = "http://exist.bungeni.org/adm" at "admin.xqm";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;

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
    <link rel="stylesheet" href="../assets/css/admin.css"/>
</head>
<body>
 <div id="xforms">
    <!-- MAIN MENU -->
    <div class="section" id="mainnav">{adm:main-menu('search')}</div>
    <div class="section" dojotype="dijit.layout.ContentPane">
        
            <div class="headline">Admin Section</div>
            <div class="description desc-center">
                <p>
                    Welcome to administrator panel for Bungeni XML Repository portal 
                </p>
                <p>
                    <b>MISC NOTES</b>
                </p>
                <ul>
                    <li>Click on the blue toast messages at the bottom of page to dismiss; At times they can accumulate.</li>
                </ul>
            </div>              

    </div>
 </div>
</body>
</html>
