xquery version "1.0";


declare namespace ts="http://exist.bungeni.org/titlesearch";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";

(:

Transforms an AkomaNtoso document into a HTML snapshot

This is invoked by controller.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

(: stylesheet to transform :)
let $stylesheet := xs:string("xslt/actsnapshot.xsl")

(: input ANxml document in request :)
let $doc := request:get-attribute("capsearch.doc")

return 
    transform:transform($doc, $stylesheet, ())

