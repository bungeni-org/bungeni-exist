xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";




let $actinfo := cmn:get-menu-from-route('/bill/text')
return $actinfo
