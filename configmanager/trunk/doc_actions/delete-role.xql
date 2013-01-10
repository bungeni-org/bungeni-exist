xquery version "3.0";

(:~
    : Modify document by delete a node FORM nodes up or down 
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:delete-role($docname, $fieldname) as xs:string {
    let $path2resource := concat($appconfig:FORM-FOLDER,"/custom.xml")
    let $doc := doc($path2resource)/ui
    return (
        update delete $doc/roles/role[. eq $fieldname],
        $doc
    )
};

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","none"))
let $FIELDNAME := xs:string(request:get-parameter("field","none"))
let $deleted := local:delete-role($DOCNAME, $FIELDNAME)
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
                dojo.publish('/view',['roles','roles','none','none','none']);
            </script>
        </div>
    </body>
</html>