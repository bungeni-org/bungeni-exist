xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace bungenicommon = "http://exist.bungeni.org/cmn" at "common.xqm";




let $actinfo := bungenicommon:get-route('/business')
return $actinfo
