xquery version "3.0";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace pproc = "http://exist.bungeni.org/pproc" at "postproc.xqm";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $getqrystr := xs:string(request:get-query-string())
let $sigs := pproc:update-signatories()
let $events := pproc:update-events()
let $sittings := pproc:update-sittings()

return 
    if ($sigs/node()) then 
        $sigs
    else if ($events/node()) then 
        $events
    else if ($sittings/node()) then 
        $sittings        
    else 
        "Completed Repository updates on eXist-db"