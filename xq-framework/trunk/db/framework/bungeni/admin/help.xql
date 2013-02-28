xquery version "1.0";

import module namespace adm = "http://exist.bungeni.org/adm" at "admin.xqm";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;

(:
Admin panel usage documentation
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
        
            <div class="headline">Admin Section - User Documentation</div>
            <div class="description desc-center">
                <p>
                    Welcome to administrator panel - User Documentation 
                </p>
            </div>
            <div class="description desc-center">
                <p>
                    <b>Introduction</b> - The Admin panel is based on <a href="http://www.betterform.de" target="_new">betterFORM</a>'s implementation 
                    of <a href="http://www.w3.org/TR/xforms/" target="_new">XForms</a>. The Configuration document is 
                    loaded on the browser for manipulation. On this arrangement, changes made 
                    and applied need to be saved in order for the changes to take effect.
                </p>      
                <p>
                    <b>apply changes</b> - saves any alterations made on the input fields unto loaded copy
                    <br />
                    <b>save document</b> - saves changes applied back to original document. clicking this
                    ensures the all changes made and applied will now take effect on the application.
                </p>  
                <p>
                    <b>Simplified sequence of actions</b> - [addition/alteration/edit/updates] &#8594; <i>apply changes</i> &#8594; <i>save changes</i>
                </p>
                
                <p>
                    <b>MISC NOTES</b>
                </p>
                <ul>
                    <li>Click on the blue notifications at the bottom of page to dismiss; At times they can accumulate</li>
                    <li></li>
                </ul>
            </div>            

    </div>
 </div>
</body>
</html>
