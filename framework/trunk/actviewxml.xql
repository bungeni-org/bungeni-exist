xquery version "1.0";

import module namespace actview="http://exist.bungeni.org/actview" at "modules/actview.xqm";
import module namespace lex = "http://exist.bungeni.org/lex" at "modules/lex.xqm";
import module namespace xmltohtml = "http://exist.bungeni.org/xmltohtml" at "modules/xmltohtml.xqm";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace an="http://www.akomantoso.org/1.0";

declare option exist:serialize "method=xml media-type=text/html";

(: THis page and its module need to be rewritten in the lines of lexpage.xqm and index.xql :)

let $actid := xs:string(request:get-parameter("actid",""))
let $acttitle := xs:string(request:get-parameter("acttitle",""))
let $actno := xs:string(request:get-parameter("actno",""))
let $doc := xmltohtml:xmltohtml(lex:get-doc($actid), 1)

return
    <html>
        <head>
            <style>
           <!--
            /* Begin and end tag Delimiter */
            .t {color: blue;}
            /* Attribute Name and equal sign */
            .an {color: orange;}
            /* Attribute Values and equal sign */
            .av {color: orange;}
            /* Element Data Content */
            .d {color: black;}
            -->
            </style>
            <title>Act XML : {$acttitle}</title>
        </head>
        <body>
        <div id="xml-viewer-header">
            <h1>{$acttitle}&#160;({$actno})</h1>
        </div>
        <hr />
        <div id="xml-viewer-content">
            {$doc} 
        </div>
        </body>
    </html>

