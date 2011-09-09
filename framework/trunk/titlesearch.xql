xquery version "1.0";


declare namespace ts="http://exist.bungeni.org/titlesearch";

declare namespace util="http://exist-db.org/xquery/util";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "modules/common.xqm";
declare namespace request="http://exist-db.org/xquery/request";


(:

Returns a AkomaNtoso document from the requested act identifier ,
the document is set into a request parameter.

This script is called from controller.xql and forwards to translate-titlesearch.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

(: Search for the doc matching the actid in the request :)
declare function ts:get-doc() as element() {
    let $actid := xs:string(request:get-parameter("actid", ""))
    for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};

(: set a request attribute for the next script in the execution chain :)
request:set-attribute("titlesearch.doc", ts:get-doc())
