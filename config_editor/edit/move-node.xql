xquery version "3.0";

(:~
    : Modify document by moving nodes FORM nodes up or down 
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:move-up() as xs:string {

    let $docname := request:get-parameter("doc", "none")
    let $fieldname := request:get-parameter("field", "none")
    let $path2resource := concat($cfg:FORMS-COLLECTION,"/custom.xml")
    let $doc := doc($path2resource)/ui/descriptor[@name = $docname]
    return (
        update insert $doc/field[@name eq $fieldname] preceding $doc/field[@name eq $fieldname]/preceding-sibling::*[1],
        update delete $doc/field[@name eq $fieldname][2],
        $doc
    )
};

declare function local:move-down() as xs:string {

    let $docname := request:get-parameter("doc", "none")
    let $fieldname := request:get-parameter("field", "none")
    let $path2resource := concat($cfg:FORMS-COLLECTION,"/custom.xml")
    let $doc := doc($path2resource)/ui/descriptor[@name = $docname]
    return (
        update insert $doc/field[@name eq $fieldname] following $doc/field[@name eq $fieldname]/following-sibling::*[1],
        update delete $doc/field[@name eq $fieldname][1],
        $doc
    )
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","none"))
let $move := request:get-parameter("move", "down")
let $moved := if ($move eq "up") then local:move-up() else local:move-down()
let $fieldname := xs:string(request:get-parameter("field","none"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>Move Field</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <script type="text/javascript">
                dojo.publish('/form/view',['{$docname}','fields']);
            </script>
        </div>
    </body>
</html>