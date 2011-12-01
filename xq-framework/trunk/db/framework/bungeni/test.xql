xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";




let $coll_rs := bun:list-documentitems-with-acl("public-view", "bill"),
    $coll := bun:ft-search($coll_rs,"Bill OR clerk AND P1_01")
return 
    <batch>
    {
        $coll
    }
    </batch>
