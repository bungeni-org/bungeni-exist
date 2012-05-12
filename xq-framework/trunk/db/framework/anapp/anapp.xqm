module namespace akn = "http://exist.bungeni.org/akn";
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
declare variable $akn:SORT-BY := '//an:docDate';

declare variable $akn:OFF-SET := 0;
declare variable $akn:LIMIT := cmn:get-listings-config-limit();
declare variable $akn:VISIBLEPAGES := cmn:get-listings-config-visiblepages();
declare variable $akn:DOCNO := 1;

declare function akn:xqry-build-listing-by-type($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/an:akomaNtoso",
                "/an:",$type,"",
                "/ancestor::an:akomaNtoso")
};

declare function akn:xqry-build-listing-by-name($name as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/an:akomaNtoso",
                "/child::*[@name eq '",$name,"']",
                "/ancestor::an:akomaNtoso")
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
declare function akn:get-documentitems(
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
    let $coll := util:eval(akn:xqry-build-listing-by-type($type))
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
                count($coll)
         }</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count($coll) }">{data($listing/@name)}</tag>
         }
         </tags>         
        <documentType>{$type}</documentType>
        <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
        <fullQryStr/>
        <i18nlabel>{$type}</i18nlabel>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$akn:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
                for $match in subsequence($coll,$query-offset,$limit) 
                return 
                    akn:get-reference($match)          
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

declare function akn:get-reference($docitem as node()) {
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
declare function akn:get-acts(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "act", "act/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-bills(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "bill", "bill/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-debates(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "debate", "debate/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-reports(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "debateReport", "report/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-amendments(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
  akn:get-documentitems($acl, "amendment", "amendment/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-judgements(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "judgement", "judgement/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-gazettes(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "officialGazette", "gazette/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

declare function akn:get-misc(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
        
        akn:get-documentitems($acl, "doc", "misc/text", "listings.xsl", $offset, $limit, $querystr, $sortby)
};

(:~
:   Outputs the raw xml document with some omissions. Currently for legislative-items only
: 
: @param docid
:   The URI for the document
: @return
    Returns the fetched document as a XML document
:)
declare function akn:get-raw-xml($docid as xs:string) as element() {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    functx:remove-elements-deep(
        collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]],
        ('bu:versions', 'bu:permissions', 'bu:changes')
    )
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
declare function akn:get-akn-doc($acl as xs:string, 
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