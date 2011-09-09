xquery version "1.0";


declare namespace va="http://exist.bungeni.org/viewact";


import module namespace lex="http://exist.bungeni.org/lex" at "modules/lex.xqm";
declare namespace request="http://exist-db.org/xquery/request";


(:

Returns a AkomaNtoso document from the requested act identifier ,
the document is set into a request parameter.

This script is called from controller.xql and forwards to translate-titlesearch.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

declare function va:get-doc() as element() {
    let $actid := xs:string(request:get-parameter("actid", ""))
    return lex:get-doc($actid)    
  };

(: set a request attribute for the next script in the execution chain :)
request:set-attribute("xml.doc", va:get-doc())



