xquery version "3.0";

(:~
    : Modify document by moving nodes FORM nodes up or down 
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:move-up($docname, $fieldname) as xs:string {

    let $path2resource := $appconfig:FORM-FOLDER || "/" || $docname || ".xml"
    let $doc := doc($path2resource)/descriptor[@name = $docname]
    return (
        update insert $doc/field[@name eq $fieldname] preceding $doc/field[@name eq $fieldname]/preceding-sibling::*[1],
        update delete $doc/field[@name eq $fieldname][2],
        $doc
    )
};

declare function local:move-down($docname, $fieldname) as xs:string {

    let $path2resource := $appconfig:FORM-FOLDER || "/" || $docname || ".xml"
    let $doc := doc($path2resource)/descriptor[@name = $docname]
    return (
        update insert $doc/field[@name eq $fieldname] following $doc/field[@name eq $fieldname]/following-sibling::*[1],
        update delete $doc/field[@name eq $fieldname][1],
        $doc
    )
};

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","none"))
let $FIELDNAME := xs:string(request:get-parameter("field","none"))
let $MOVE := request:get-parameter("move", "down")
let $MOVED := if ($move eq "up") then local:move-up($DOCNAME, $FIELDNAME) else local:move-down($DOCNAME, $FIELDNAME)
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
                dojo.publish('/form/view',['{$DOCNAME}','fields']);
            </script>
        </div>
    </body>
</html>
