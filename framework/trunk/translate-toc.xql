xquery version "1.0";


declare namespace va="http://exist.bungeni.org/viewact";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";

(:

Transforms an AkomaNtoso document into a HTML Docuemnt

This is invoked by controller.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

(: stylesheet to transform :)
let $stylesheet := xs:string("xslt/acttoc.xsl")

(: input ANxml document in request :)
let $doc := request:get-attribute("xml.doc")
let $prefval := xs:string(request:get-parameter("pref","ts"))
let $actid := xs:string(request:get-parameter("actid", ""))
let $pref := <parameters>   
                <param name="pref" value="{$prefval}" />
                <param name="actid" value="{$actid}" />
             </parameters>

return 
    transform:transform($doc, $stylesheet, $pref)

