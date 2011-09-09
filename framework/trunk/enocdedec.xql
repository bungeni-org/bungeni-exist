xquery version "1.0";


declare namespace adx="http://exist.bungeni.org/adsearchx";

declare namespace util="http://exist-db.org/xquery/util";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "modules/common.xqm";
import module namespace lex="http://exist.bungeni.org/lex" at "modules/lex.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare namespace request="http://exist-db.org/xquery/request";
import module namespace kwic="http://exist-db.org/xquery/kwic";

(:
Performs a full text lucene search on the lex collection.

The full text search string is built in javascript and passed in.
(See lex.js:adsSearchBuild() )

This script is called from controller.xql and forwards to translate-adsearch.xql

The request pattern looks like this :
adsearch -> adsearch.xql -> translate-adsearch.xql 
:)

declare option exist:serialize "method=xml media-type=application/xml";

declare function adx:get-query() as element() {
    (:get the collection to search in :)
    let $query := xs:string(request:get-parameter("q",""))
    return <docs>{$query}</docs>
};




adx:get-query()


