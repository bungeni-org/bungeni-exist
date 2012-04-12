module namespace bun = "http://exist.bungeni.org/bun";
(:import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";:)
import module namespace i18n = "http://exist-db.org/xquery/i18n" at "../i18n.xql";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace xps="http://www.w3.org/2005/xpath-functions";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";
import module namespace functx = "http://www.functx.com" at "../functx.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo="http://exist-db.org/xquery/xslfo"; 
import module namespace json="http://www.json.org";


declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace an="http://www.akomantoso.org/2.0";

(:
Library for common lex functions
uses bungenicommon
:)

(:~
Default Variables
:)
declare variable $bun:SORT-BY := 'bu:statusDate';

declare variable $bun:OFF-SET := 0;
declare variable $bun:LIMIT := cmn:get-listings-config-limit();
declare variable $bun:VISIBLEPAGES := cmn:get-listings-config-visiblepages();
declare variable $bun:DOCNO := 1;

(:~
    Service for checking status of file before update eXist repository
    @param uri
        Document URI
    @param statusdate
        The status date in the document
        
    @return <response>
                <status>overwrite|new|ignore</status>
            </response>
:)
declare function bun:check-update($uri as xs:string, $statusdate as xs:string) {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    let $docitem := collection(cmn:get-lex-db())/bu:ontology/child::*[@uri=$uri]/ancestor::bu:ontology
    let $doc := <response>        
        {
            if($docitem) then (
                if($statusdate eq "") then 
                    (:  Means no `bu:statusDate` node in the external document, default is to overwrite  
                        repository version 
                    :)
                    <status>overwrite</status>
                else if(xs:dateTime($docitem/child::*/bu:statusDate) lt $statusdate cast as xs:dateTime) then 
                    (: Means eXist version of the doc is old... do replace by all means :)
                    <status>overwrite</status>
                else
                    (: Ambiguous scenario, ignore :)
                    <status>ignore</status>
            )
            else
                (: Not found on eXist :)
                <status>new</status>
        }
        </response>   
        
    return $doc
};

(:~
:   Returns all documents requested and applying the appropriate sort order
: @param acl
:   permission type
: @param type
:   document type
: @param url-prefix
:   Default page-tab to link to if needed
: @param stylesheet
:   The stylesheet that transforms this xml output
: @param offset
:   The xquery subsequence offet utilised the paginator in the stylesheet defined above
: @param querystr
:   User's search terms to be passed to the lucene ft-search()
: @param sortby
:   The element to order-by, descending / ascending
: @return
:   Evaluates xquery to return document(s) matching permission that was given
:)
declare function bun:get-documentitems(
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)    
    let $tab := xs:string(request:get-parameter("tab",'uc'))    
    let $coll := collection(cmn:get-lex-db())/an:akomaNtoso/an:bill/ancestor::an:akomaNtoso
    let $listings-filter := cmn:get-listings-config($type)
    let $getqrystr := xs:string(request:get-query-string())    
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of documents | active-tab count if the view is tabbed :)
        <count>{
                count(collection(cmn:get-lex-db())/an:akomaNtoso/an:bill/ancestor::an:akomaNtoso)
         }</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(collection(cmn:get-lex-db())/an:akomaNtoso/an:bill/ancestor::an:akomaNtoso) }">{data($listing/@name)}</tag>
         }
         </tags>         
        <documentType>{$type}</documentType>
        <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
        <fullQryStr/>
        <i18nlabel>{$type}</i18nlabel>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
                for $match in subsequence($coll,$query-offset,$limit) 
                return 
                    bun:get-reference($match)          
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
                <param name="listing-tab" value="{$tab}" />
            </parameters>
           ) 
       
};

declare function bun:get-reference($docitem as node()) {
    <doc>
        {$docitem}
        <ref>
            {
                let $doc-ref := data($docitem/bu:*/bu:group/@href)
                return 
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../bu:ministry
            }
         </ref>
    </doc>     
};

(:~
:   This and similar functions implement get-documentitems() to request for parliamentary documents
: @param acl
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return
:   Documents based on filter parameters passed in.
:)
declare function bun:get-bills(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        bun:get-documentitems($acl, "bill", "bill/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $sortby)
};

declare function bun:get-questions(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "question", "question/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $sortby)
};

(:~
:   Outputs the raw xml document with some omissions. Currently for legislative-items only
: 
: @param docid
:   The URI for the document
: @return
    Returns the fetched document as a XML document
:)
declare function bun:get-raw-xml($docid as xs:string) as element() {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    functx:remove-elements-deep(
        collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]],
        ('bu:versions', 'bu:permissions', 'bu:changes')
    )
};
 
declare function bun:strip-namespace($e as node()) {
  element {QName((), local-name($e))} {
    for $child in $e/(@*,*)
    return
      if ($child instance of element())
      then bun:strip-namespace($child)
      else $child
  }
};

(:~
:   Used to retrieve a legislative-document
:
: @param acl
: @param docid
: @param _tmpl
: @param tab
:   The corresponding transform template passed by the calling funcction
:)
declare function bun:get-parl-doc($acl as xs:string, 
            $doc-uri as xs:string, 
            $parts as node()) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    (: !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    
    let $doc := document {
            let $match := collection(cmn:get-lex-db())/an:akomaNtoso/child::*/an:meta/an:identification/an:FRBRWork/an:FRBRuri[@value eq $doc-uri]/ancestor::an:akomaNtoso
            return
                $match
        }
    return
        transform:transform($doc, $stylesheet, ())
};