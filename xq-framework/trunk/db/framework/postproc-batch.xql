xquery version "3.0";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace pproc = "http://exist.bungeni.org/pproc" at "postproc.xqm";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $getqrystr := xs:string(request:get-query-string())
let $uri := xs:string(request:get-parameter("uri",'none'))
let $sigs := pproc:update-signatories()
let $members := pproc:update-groups()
(:let $events := pproc:update-events()
let $attachments := pproc:update-attachments() :)
let $sittings := pproc:update-sittings()

return 
    if ($sigs/node()) then 
        $sigs
    else if ($members/node()) then 
        $members        
    else if ($sittings/node()) then 
        $sittings        
    else 
        "Completed Repository updates on eXist-db"
