xquery version "3.0";

(:~
    : Modify document by delete a node FORM nodes up or down 
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:delete-role() as xs:string {

    let $docname := request:get-parameter("doc", "none")
    let $fieldname := request:get-parameter("field", "none")
    let $path2resource := concat($cfg:FORMS-COLLECTION,"/custom.xml")
    let $doc := doc($path2resource)/ui
    return (
        update delete $doc/roles/role[. eq $fieldname],
        $doc
    )
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","none"))
let $fieldname := xs:string(request:get-parameter("field","none"))
let $deleted := local:delete-role()
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>Delete Role</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <script type="text/javascript">
                dojo.publish('/view',['roles','roles','none']);
            </script>
        </div>
    </body>
</html>