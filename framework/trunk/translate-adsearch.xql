xquery version "1.0";


declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";

(:

Transforms an AkomaNtoso document into a HTML snapshot

This is invoked by controller.xql

inoput document for this file looks like :
<docs>
<doc actid="3">
    <p>
        <span class="previous">Law </span>
        <span class="hi">Reform</span>
        <span class="following"> Commission An Act of Parliament to provide for the establishment of a commission for the reform of the law May 21, 1982 Nov 11, 1111 3 3 ARRANGEMENT OF SECTIONS 1 Short title. 2 The Law Reform Commission ...</span>
    </p>
</doc>
<doc actid="28">

    <p>
        <span class="previous">Law </span>
        <span class="hi">Reform</span>
        <span class="following">An Act of Parliament to effect reforms in the law relating to civil actions and prerogative writs Dec 18, 1956 Nov 11, 1111 26 28 ARRANGEMENT OF SECTIONS I PRELIMINARY 1 Short title. II SURVIVAL OF CAUSES ...</span>
    </p>
</doc>
</docs>

:)

declare option exist:serialize "method=xml media-type=application/xml";

let $searchfor := xs:string(request:get-parameter("searchfor",""))
let $searchin := xs:string(request:get-parameter("searchin",""))
let $q := xs:string(request:get-parameter("q",""))
(: stylesheet to transform :)
let $stylesheet := xs:string("xslt/searchResult.xsl")
let $stylesheet_params := <parameters>
                                <param name="searchfor" value="{$searchfor}" />
                                <param name="searchin" value="{$searchin}" />
                                <param name="q" value="{$q}" />
                          </parameters>
(: input ANxml document in request :)
let $doc := request:get-attribute("results.doc")


return 
    transform:transform($doc, $stylesheet, $stylesheet_params)

