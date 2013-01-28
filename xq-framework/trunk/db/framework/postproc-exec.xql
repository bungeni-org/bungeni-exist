xquery version "3.0";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace pproc = "http://exist.bungeni.org/pproc" at "postproc.xqm";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $uri := xs:string(request:get-parameter("uri",'none'))

return 
    if ($uri ne 'none') then (
         pproc:update-document($uri),
         "Completed PostTransform on eXist-db"
    )
    else 
        "URI missing"