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

(:
declare function bun:translate($node as node(), $params as element(parameters)?, $model as item()*) {
    let $selectedLang := $params/param[@name = "lang"]/@value
    let $catalogues := $params/param[@name = "catalogues"]/@value
    let $cpath :=
        (: if path to catalogues is relative, resolve it relative to the app root :)
        if (starts-with($catalogues, "/")) then
            $catalogues
        else
            concat($config:app-root, "/", $catalogues)
    let $translated :=
        i18n:process($node/*, $selectedLang, $cpath, ())
    return
        element { node-name($node) } {
            $node/@*,
            templates:process($translated, $model)
        }
};
:)

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
:  Renders PDF output for parliamentary document using xslfo module
: @param docid
:   The URI of the document
:
: @return
:   A PDF document for download
:)
declare function bun:gen-pdf-output($docid as xs:string)
{

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('parl-doc.fo') 
    
    let $doc := <doc>        
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]]
            }
        </doc>      
        
    let $transformed := transform:transform($doc,$stylesheet,())
     
    let $pdf := xslfo:render($transformed, "application/pdf", 
                                                            <parameters>
                                                                <param name="keywords" value="Parlimentary, ddocument"/>
                                                            </parameters>)
    (: 
    Set the content disposition header with the file name and the return type as attachment 
    For some odd reason return the response stream binary fails the request, i have to send
    a valid xml document as the last thing returned from the response
    :) 
    let $header := 
        response:set-header("Content-Disposition" , concat("attachment; filename=",  "output.pdf")) 
    let $out := response:stream-binary($pdf, "application/pdf")     
    return <xml />    
    
};

(:~
:  streams the attachment with the given id
: @param acl 
:   permissions scheme allowed for this file
: @param uri 
:   for thi document
: @param attid 
:   file id of the attachment as defined
: @return
:   A document for download with original name and extension and correct mimeType
:)
declare function bun:get-attachment($acl as xs:string, $uri as xs:string, $attid as xs:integer) {
    
    (: get the document through acl as validation :)
    let $doc-acl := document { util:eval(bun:xqy-docitem-acl-uri($acl, $uri)) } 
    let $acl-permissions := cmn:get-acl-permissions($acl)
    let $att-acl := bun:documentitem-attachments-with-acl($acl-permissions, $doc-acl/node())   

    (: get the attachment with the given file id :)
    for $attachedfile in $att-acl/bu:attached_files/bu:attached_file
    return
        if($attachedfile/bu:attachedFileId cast as xs:integer eq $attid) then (
            response:stream-binary(
                util:binary-doc(concat(cmn:get-att-db(),'/',$attachedfile/bu:attachedFileUuid)) cast as xs:base64Binary,
                $attachedfile/bu:fileMimetype,
                $attachedfile/bu:fileName),
            response:set-header("Content-Disposition" , concat("attachment; filename=",  $attachedfile/bu:fileName)),
            <xml/>
        )
        else () 
};

(:~
:  Renders PDF output for MP profile using xslfo module
: @param memberid
:   The URI of the parliamentary user
: @return
:   A PDF document for download
:)
declare function bun:gen-member-pdf($memberid as xs:string) {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('member-info.fo') 
    
    let $doc := <doc>        
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$memberid]/ancestor::bu:ontology
            }
        </doc>
        
    let $transformed := transform:transform($doc,$stylesheet,())
     
    let $pdf := xslfo:render($transformed, "application/pdf", ())
    
    let $header := 
        response:set-header("Content-Disposition" , concat("attachment; filename=",  "output.pdf"))  
    
    let $out := response:stream-binary($pdf, "application/pdf")     
    
    return <xml />     
};

(:~
:   Generates a xquery string with applied permissions
: @param acl
:   permission type
: @param type
:   document type 
: @return
:   A string with embedded permissions ready for evaluation.
:)
declare function bun:xqy-list-documentitems-with-acl($acl as xs:string, $type as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    
    (:~ !+FIX_THIS_WARNING - parameterized XPath queries are broken in eXist 1.5 dev, converted this to an EVAL-ed query to 
    make it work - not query on the parent axis i.e./bu:ontology[....] is also broken - so we have to use the ancestor axis :)
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='document']",
                "/bu:document[@type='",$type,"']",
                "/following-sibling::bu:legislativeItem",
                "/(bu:permissions except bu:versions)",
                "/bu:permission[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-list-documentitems-with-acl-n-tabs($acl as xs:string, $type as xs:string, $tag as xs:string) {
    let $acl-filter := cmn:get-acl-permission-as-attr($acl),
        $list-tabs :=  cmn:get-listings-config($type)[@id eq $tag]/text()
    
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='document']",
                "/bu:bungeni[",$list-tabs,"]",
                "/preceding-sibling::bu:document[@type='",$type,"']",
                "/following-sibling::bu:legislativeItem",
                "/(bu:permissions except bu:versions)",
                "/bu:permission[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-search-legis-with-acl($acl as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='document']",
                "/bu:legislativeItem",
                "/(bu:permissions except bu:versions)",
                "/bu:permission[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-list-groupitem($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='group']",
                "/bu:group[@type='",$type,"']",
                "/ancestor::bu:ontology")
};
declare function bun:xqy-search-group() {

    fn:concat("collection('",cmn:get-lex-db() ,"')","/bu:ontology[@type='group']")
};

declare function bun:xqy-list-membership($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='",$type,"']")
};
declare function bun:xqy-search-membership() {
    fn:concat("collection('",cmn:get-lex-db() ,"')",
            "/bu:ontology[@type='membership']")
};

(:~ !+FIXED(ah,05-01-2012) 

- the searchin/@field configuration must be relative to bu:ontology, it had field mappings 
as bu:shortName, bu:body etc. the collection context for the search is bu:ontology - so the full text search fails because 
there is no node context for bu:ontology/bu:shortName. This is fixed by setting the searchin/@field relative to bu:ontology.
from : bu:shortName to bu:legislativeItem/bu:shortName. 

- additionally the return context of the ft search was ancestor::bu:ontology this is not required because the ft:search is 
run in the context of bu:ontology (i.e. bu:ontology[ft:search()] ...) and not in a sub-context (i.e. bu:ontology/ft:search() )
:)
(:~ !+WAS_FIX_THIS (ao, 20 Dec 2011) - return bu:ontology begat a problem on eXist 1.5's Lucene where the ft:query() could
    not traverse up to and yielded nothing.
:)
(:
declare function bun:xqy-list-documentitems-with-acl-tmp($acl as xs:string, $type as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    

  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='document']",
                "/bu:document[@type='",$type,"']",
                "/following-sibling::bu:legislativeItem",
                "/(bu:permissions except bu:versions)",
                "/bu:permission[",$acl-filter,"]",
                "/ancestor::bu:legislativeItem")
};
:)

(:~
:   Implements xqy-list-documentitems-with-acl()
: @param acl
:   permission type
: @param type
:   document type
: @return
:   Evaluates xquery to return document(s) matching permission that was given
:)
declare function bun:list-documentitems-with-acl($acl as xs:string, $type as xs:string) {
    let $eval-query := bun:xqy-list-documentitems-with-acl($acl, $type)
    return
        util:eval($eval-query)
        (: collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type=$type]/following-sibling::bu:legislativeItem/(bu:permissions except bu:versions)/bu:permission[$acl-filter] :)
};

declare function bun:list-documentitems-with-acl-n-tabs($acl as xs:string, $type as xs:string, $tag as xs:string) {
    let $eval-query := bun:xqy-list-documentitems-with-acl-n-tabs($acl, $type, $tag)
    return
        util:eval($eval-query)
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
    let $coll := bun:list-documentitems-with-acl-n-tabs($acl, $type, $tab)
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
            if($tab) then 
                count(util:eval(bun:xqy-list-documentitems-with-acl-n-tabs($acl, $type, $tab)))
            else
                count($coll)
         }</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(util:eval(bun:xqy-list-documentitems-with-acl-n-tabs($acl, $type, $listing/@id))) }">{data($listing/@name)}</tag>
         }
         </tags>         
        <documentType>{$type}</documentType>
        <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
        <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
        <i18nlabel>{$type}</i18nlabel>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )  
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )                 
            else  (
                for $match in subsequence($coll,$query-offset,$limit) 
                (:where $coll/bu:bungeni/bu:tags[contains(bu:tag,'terminal')]:)
                order by $match/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)         
                )
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

declare function bun:get-motions(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "motion", "motion/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $sortby)
};

declare function bun:get-tableddocuments(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "tableddocument", "tableddocument/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $sortby)
};

declare function bun:get-agendaitems(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "agendaitem", "agendaitem/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $sortby)
};

declare function bun:search-criteria(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string,
        $typeofdoc as xs:string) as element() {
        
        if ($typeofdoc eq "committee" or $typeofdoc eq "political-group") then
            bun:search-groupitems($acl, $typeofdoc, "committee/text", "committees.xsl", $offset, $limit, $querystr, $sortby)
        else if ($typeofdoc eq "membership") then
            bun:search-membership($acl, $typeofdoc, "member/text", "members.xsl", $offset, $limit, $querystr, $sortby)
        else
            bun:search-documentitems($acl, $typeofdoc, "bill/text", "search-listing.xsl", $offset, $limit, $querystr, $sortby)
};

(:~
:   This filters out the search-centric parameters that need to be sustained with the corresponding paginator xslt
: @param querystr
: @return
:   xhtml query string that will be appended to paginator.
:)
declare function local:generate-qry-str($getqrystr) {
        let $rem-dups := if (matches($getqrystr,"offset")) then fn:substring-before($getqrystr, '&amp;offset') else $getqrystr,
            $tokened := tokenize($rem-dups,'&amp;')
         
        (: Remove constant params like limit,offset etc :)
        let $off := for $toks1 in $tokened 
            return
                if (contains($toks1,"offset")) then (
                    remove($tokened,index-of($tokened,$toks1))
                )
                else ($tokened)
                
        let $lim := for $toks2 in $tokened 
            return
                if (contains($toks2,"limit")) then (
                    remove($tokened,index-of($tokened,$toks2))
                )
                else ($tokened)

         return 
                string(string-join(distinct-values($off[.=$lim]),"&amp;"))
};

(:~
:   Similar to documents listings above and implements ft-search() to perform
:   full-text search on the sorted documents
: @param querystr
: @param type
: @param url-prefix
: @param stylesheet
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return
:   xhtml query string that will be appended to paginator.
: @stylesheet 
:   search-listing.xsl
:)
declare function bun:search-documentitems(
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
    let $coll_rs := bun:xqy-list-documentitems-with-acl($acl, $type)
    let $getqrystr := xs:string(request:get-query-string())

    (: check if search is there so as to proceed to search or not :)    
    let $coll := if ($querystr ne "") then bun:ft-search($coll_rs, $querystr, $type) else util:eval($coll_rs)
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count(
                    $coll
                  )
             }</count>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )                 
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)         
                )
                (:ft:score($m):)
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
            </parameters>
           )
};

(:~
:   
: @param qryall
: @param qryexact
: @param qryhas
: @param parent-types
: @param doc-types
: @param limit
: @param offset
: @param sortby
: @return
:   all documents that matched filters
: @stylesheet 
:   advanced-search.xsl
:)
declare function bun:advanced-search($qryall as xs:string,
            $qryexact as xs:string,
            $qryhas as xs:string, 
            $parent-types as xs:string,
            $doc-types as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $status as xs:string,
            $startdate as xs:string,
            $enddate as xs:string,            
            $sortby as xs:string) as element()* {
      
    let $stylesheet := "advanced-search.xsl"      
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    let $getqrystr := xs:string(request:get-query-string())    
    let $search-filter := cmn:get-doctypes()
    
    let $subset-parents-coll :=    if(not(empty($parent-types))) then (
                                        (: iterate through the all known (distinctly)categories from config :)
                                        for $category in distinct-values($search-filter/@category)
                                            (: iterate through the categories received from search form :)
                                            for $ptype in $parent-types
                                                return
                                                    if($ptype eq $category) then 
                                                        collection(cmn:get-lex-db())/bu:ontology[@type=$category]
                                                    else ()
                                    )
                                    else ()
                            
    let $subset-docs-coll :=    if(not(empty($doc-types))) then (
                                    (: iterate through the all known categories from config :)
                                    for $filter in $search-filter                                    
                                        (: iterate through the doctypes received :)
                                        for $dtype in $doc-types
                                        return
                                            (:  as per current structure, these types dont need summons to bu:ontology ancestor::
                                                this is determined when the (ontology type is the same as the document type) in 
                                                a child node 
                                            :)
                                            if(($filter/@name eq $filter/@category) and $dtype eq $filter/@name) then 
                                                collection(cmn:get-lex-db())/bu:ontology[@type=$filter/@name]
                                            (: check for ontology type only, which represents a category of a particular 
                                                type of documents 
                                            :)
                                            else if($dtype eq $filter/@name) then 
                                                collection(cmn:get-lex-db())/bu:ontology[@type=$filter/@category]/bu:document[@type=$filter/@name]/ancestor::bu:ontology                                       
                                            else ()
                                    )
                                    else ()    
       
    (: merge both sets :)
    let $coll_subset := ($subset-parents-coll, $subset-docs-coll)
    
    (: trim collection subset by bu:status :)
    let $subset_w_status := if ($status ne "none") then (
                                for $match in $coll_subset
                                (:  this is placed here and not with the order by sort 
                                    because it affects the <count/> if put after the search 
                                    of the total documents found 
                                :)
                                where $match/child::*/bu:status eq $status 
                                return 
                                    $match 
                            )
                            else 
                                $coll_subset
                                
    (: trim collection subset by bu:statusDate :)
    let $subset_w_st_date := if ($startdate ne "" and $enddate ne "") then (
                                for $match in $subset_w_status
                                return 
                                    $match/child::*[bu:statusDate gt xs:dateTime(concat($startdate,"T00:00:00"))]
                                    [bu:statusDate lt xs:dateTime(concat($enddate,"T23:59:59"))]/ancestor::bu:ontology
                                )
                                else 
                                    $subset_w_status                                
    
    (: check if search is there are search terms so as to proceed to search or not :)    
    let $subset_rs := if ($qryall ne "" or $qryexact ne "" or $qryhas ne "") then 
                        bun:adv-ft-search($subset_w_st_date, $qryall, $qryexact, $qryhas) 
                    else 
                        ()
    
    (: document node to be returned to transforming stylesheet :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents for display.  :)
            <count>{
                count(
                    $subset_rs
                  )
             }</count>
            <documentType>question</documentType>
            <qryAll>{$qryall}</qryAll>
            <qryExact>{$qryexact}</qryExact>
            <qryHas>{$qryhas}</qryHas>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$doc-types}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
                if ($sortby = 'std_oldest') then (
                    for $match in subsequence($subset_rs,$query-offset,$limit)              
                    order by $match/bu:ontology/child::*/bu:statusDate ascending 
                    return 
                        $match 
                )
                else  (
                    for $match in subsequence($subset_rs,$query-offset,$limit)              
                    order by $match/bu:ontology/child::*/bu:statusDate descending 
                    return 
                        $match     
                )        
        } 
        </alisting>
    </docs>
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sort" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Performs a lucene search using the XML syntax
: @param coll-subset
: @param qryall
: @param qryexact
: @param qryhas
: @return
:   search results in a <doc/> document
:)
declare function bun:adv-ft-search(
            $coll-subset as node()*, 
            $qryall as xs:string,
            $qryexact as xs:string,
            $qryhas as xs:string) as element()* {
        
        let $qryall-words := tokenize($qryall, '\s')
        let $qryhas-words := tokenize($qryhas, 'OR')
        let $query-node :=  <query>
                                <bool>
                                    <bool> {
                                        for $word in $qryall-words
                                            return
                                            <term occur="must">{$word}</term>
                                        }
                                    </bool>                                    
                                    <phrase>{$qryexact}</phrase>
                                    <bool> {
                                       for $word in $qryhas-words
                                           return
                                           <term occur="should">{$word}</term>
                                       }
                                    </bool>      
                                </bool>
                            </query>        
        
        for $search-rs in $coll-subset[ft:query(., $query-node)]
        let $expanded := kwic:expand($search-rs),
        $config := <config xmlns="" width="160"/>
        order by ft:score($search-rs) descending
        return
            (:  <doc>
                    <bu:ontology/>
                    <kwic/>
                </doc>
            :)
            <doc>
                {$search-rs}
                <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
            </doc>
};

(:~
:   Similar to bun:search-documentitems()
:)
declare function bun:search-groupitems(
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
    let $coll_rs := bun:xqy-list-groupitem($type)
    let $getqrystr := xs:string(request:get-query-string())

    (: check if search is there so as to proceed to search or not :)    
    let $coll := if ($querystr ne "") then bun:ft-search($coll_rs, $querystr, $type) else util:eval($coll_rs)
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count(
                    $coll
                  )
             }</count>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislature/bu:statusDate ascending
                return 
                    <doc>{$match}</doc>      
                )             
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match}</doc>        
                )
                (:ft:score($m):)
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
            </parameters>
           )
};

(:~
:   Similar to bun:search-documentitems()
:)
declare function bun:search-membership(
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
    let $coll_rs := bun:xqy-list-membership($type)
    let $getqrystr := xs:string(request:get-query-string())

    (: check if search is there so as to proceed to search or not :)    
    let $coll := if ($querystr ne "") then bun:ft-search($coll_rs, $querystr, $type) else util:eval($coll_rs)
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count(
                    $coll
                  )
             }</count>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence($coll,$offset,$limit)
                order by $match/child::*/bu:statusDate ascending
                return 
                    bun:get-reference($match)   
                )             
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/child::*/bu:statusDate descending
                return 
                    bun:get-reference($match)          
                )
                (:ft:score($m):)
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
            </parameters>
           )
};

(:~
:   Performs a full-text on a set of documents, based on Lucene
:
: @param collection query
:   A xquery to return the collection of documents we want to search in 
: @param querystr
:   The raw search terms / parameters by the user
: @param type
:   The document type to filter the search scope to particular type e.g. bill, question, motion
: @return
:   Results matching the search terms and returned in search index/indices field(s) that was 
:   specified in the filter options e.g. bu:shortName, bu:registryNumber
:)
declare function bun:ft-search(
            $coll-query as xs:string, 
            $querystr as xs:string,
            $type as xs:string) as element()* {
        (: 
            There are special characters for Lucene that we have to escape 
            incase they form part of the user's search input. More on this...
           
            http://sewm.pku.edu.cn/src/other/clucene/doc/queryparsersyntax.html
            http://www.addedbytes.com/cheat-sheets/regular-expressions-cheat-sheet/
        :)

        let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`'),
            $ultimate-path := local:build-search-objects($type),
            $eval-query := concat($coll-query,"[ft:query((",$ultimate-path,"), '",$escaped,"')]")
            
        for $search-rs in util:eval($eval-query)
        order by ft:score($search-rs) descending      
            
        return
            (:<params>{$ultimate-path}</params> !+DEBUG_WITH_test.xql:)
            $search-rs        
};

(:~
:   Searches the entire document for matching text/strings within the lucene-indexed fields
:   in the Bungeni collection.
: @param acl
: @param offset
: @param limit
: @param querystr
: @param scope
: @param sortby
: @return
:   A <doc/> with paginator items where applicable and also found results wrapped in respective
:   category. Three categories define at the moment <legis/>, <groups/> and <members/>.
: @stylesheet 
:   global-search-summary.xsl OR global-search-results.xsl
:)
declare function bun:search-global(
            $acl as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $scope as xs:string,
            $sortby as xs:string) as element() {
            
    (: convinience variables :)
    let $qry-available := if($querystr ne "") then true() else false() 
    
    (: stylesheet to transform: ephemeral or paginated :)
    let $stylesheet := if ($scope eq "global" ) then 
                            cmn:get-xslt("global-search-summary.xsl") 
                       else cmn:get-xslt("global-search-results.xsl")
    
    (:let $coll_rs := bun:xqy-list-groupitem("membership"):)
    let $getqrystr := xs:string(request:get-query-string())

    (: toggle summary and categorized :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    let $query-limit := if ($scope eq "global" ) then 3 else $limit
    
    let $coll-legis := bun:xqy-search-legis-with-acl($acl),
        $coll-groups := bun:xqy-search-group(),
        $coll-members := bun:xqy-search-membership()
    
    (: Escape all invalid characters :)
    let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`')       
      
    let $count :=   if($scope eq "legis") then (
                        count(util:eval(concat($coll-legis,"[ft:query(., '",$escaped,"')]")))
                    )
                    else if($scope eq "groups") then (
                        count(util:eval(concat($coll-groups,"[ft:query(., '",$escaped,"')]")))
                    )
                    else if($scope eq "members") then (
                        count(util:eval(concat($coll-members,"[ft:query(., '",$escaped,"')]")))
                    )   
                    else()
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{ $count }</count>
            <documentType>global</documentType>
            <qryStr>{$querystr}</qryStr>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <legis>
            {
                (: check if search is there so as to proceed to search or not :) 
                if(($querystr ne "" and $scope eq "global") or
                    ($querystr ne "" and $scope eq "legis")) then (
                    element count { count(util:eval(concat($coll-legis,"[ft:query(., '",$escaped,"')]"))) }, 
                    
                    let $eval-query := concat("subsequence(",$coll-legis,"[ft:query(., '",$escaped,"')]",",$query-offset,$query-limit)")
                    
                    for $search-rs in util:eval($eval-query)
                    order by ft:score($search-rs) descending
                    return 
                        <doc>{$search-rs}</doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </legis>
        <groups>
            {
                attribute having { "ola"},
                if(($querystr ne "" and $scope eq "global") or
                    ($querystr ne "" and $scope eq "groups")) then (
                    element count { count(util:eval(concat($coll-groups,"[ft:query(., '",$escaped,"')]"))) },
                    
                    let $eval-query := concat("subsequence(",$coll-groups,"[ft:query(., '",$escaped,"')]",",$query-offset,$query-limit)")
                    
                    for $search-rs in util:eval($eval-query)
                    order by ft:score($search-rs) descending
                    return 
                        <doc>{$search-rs}</doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </groups>     
        <members>
            {
                if(($querystr ne "" and $scope eq "global") or
                    ($querystr ne "" and $scope eq "members")) then (
                    element count { count(util:eval(concat($coll-members,"[ft:query(., '",$escaped,"')]"))) },
                    
                    let $eval-query := concat("subsequence(",$coll-members,"[ft:query(., '",$escaped,"')]",",$query-offset,$query-limit)")
                    
                    for $search-rs in util:eval($eval-query)
                    order by ft:score($search-rs) descending
                    return 
                        <doc>{$search-rs}</doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </members>            

    </docs>
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Generates list of indexed items selected by user and match the ui-config option for that type of document.
:   +NOTES: The items in the ui-config must also be indexed in the /db/system/db/config/bungeni-xml/collection.xconf
:
: @param type
: @return 
:   Comma seperated list of indexed nodes as set in the ui-config.
:)
declare function local:build-search-objects($type as xs:string) {
    
  let 
    $search-filter := cmn:get-searchins-config($type),
    $filter_names := request:get-parameter-names()
    (:$filter_names := fn:tokenize('f_t f_b s q','\s+') !+DEBUG_WITH_test.xql:)
  
    (: Loop the number of items checked by the user :)
    let $list := 
        for $token in $filter_names 
            (: Loop the number of times we have <searchins> in ui-config :)
            for $searchins in $search-filter
                return
                    if ($token eq $searchins/@name) then $searchins/@field else ()
    return 
        (: Recurvice appends the matched indexed items :)
        string-join($list, ",")
};

(:~
:   Re-writes the search-form used in legislative-items listing using input from <searchins>
:   and <orderbys> in ui-config. 
:
: @param tmpl
:   A xml template that has the skeleton form
: @param type
:   The document type
: @return 
:   Returns re-written nodes and elements in the form listing-search-form.xml
:)
declare function local:rewrite-listing-search-form($EXIST-PATH as xs:string, $tmpl as element(), $type as xs:string)  {

    (: get the current doc-types search conf:)
    let $search-filter := cmn:get-searchins-config($type),
        $search-orderby := cmn:get-orderby-config($type),
        $qry := xs:string(request:get-parameter("q",'')),          
        $allparams := request:get-parameter-names()       

    return
      (: [Re]writing the doc_type with the one gotten from rou:listing-documentitem() :)    
      if ($tmpl/self::xh:input[@id eq "doc_type"]) then 
        element input {
            attribute type { "hidden" },
            attribute name { "type" },
            attribute value { $type }
        }   
      else if($tmpl/self::xh:input[@id eq "exist_path"]) then
        element input {
            attribute type { "hidden" },
            attribute name { "exist_path" },
            attribute value { $EXIST-PATH }
        }       
      (: [Re]writing the search-field with search text :)    
      else if ($tmpl/self::xh:input[@id eq "search_for"]) then 
        element input {
            attribute id { "search_for" },
            attribute name { "q" },
            attribute class { "search_for" },
            attribute type { "text" },
            attribute placeholder { "i18n(ph-searchlisting,search...)" },
            attribute value { $qry }
        }
       
      (: [Re]Writing the filter_by options from ui-config :)
      else if ($tmpl/self::xh:ul[@id eq 'filter_by']) then 
          element ul 
          {
            attribute id {$tmpl/@id},
            attribute class {$tmpl/@class},      
            (: The filter title :)
            element li {
                attribute class { "sb_filter" },
                "Filter your search"
            },  
            (: End of filter title :)
            
            (: initialize form-filter to field set in ui-config.xml :)
            if ($qry eq '') 
               then 
                for $searchins in $search-filter
                    return 
                        element li {
                            element input {
                                if ($searchins/@default eq "true")
                                  then
                                   attribute checked { "checked" }
                                else
                                   ()
                            ,
                            attribute type { "checkbox" },
                            attribute name { $searchins/@name },
                            $searchins/@value
                        },
                        local:filter-labels($searchins)
                    }
            else
               for $searchins in $search-filter
                return
                    element li {
                        element input {
                             for $param in $allparams 
                                return
                                    if($param eq $searchins/@name) 
                                      then
                                        attribute checked { "checked" }
                                    else 
                                        () 
                            ,                    
                            attribute type { "checkbox" },
                            attribute name { $searchins/@name },
                            $searchins/@value
                        },
                        local:filter-labels($searchins)
                    }
          }
        (: [Re]Writing the sort_by options from ui-config :)
        else if ($tmpl/self::xh:select[@id eq 'sort_by']) then 
          element select 
          {
            attribute id {$tmpl/@id},
            attribute name {$tmpl/@name},
            
            for $orderbys in $search-orderby
            return
                element option {
                    attribute value { $orderbys/@value },
                    $orderbys/text()
                }
          }        
        else
  		element { node-name($tmpl)}
		  		 {$tmpl/@*, 
			         for $child in $tmpl/node()
				        return if ($child instance of element())
					       then local:rewrite-listing-search-form($EXIST-PATH, $child, $type)
					       else $child
				 }

};

declare function local:filter-labels($searchins as element()) {
    element label { 
        attribute for { $searchins/@value},
         if($searchins/@name eq 'all') then 
            element b {
                $searchins/text()
            }
         else
            $searchins/text()    
    }
};

(:~
:   Re-writes the search-form-global that does a full-text search across all documents.
:
: @param tmpl
:   A xml template that has the skeleton form
: @param type
:   The document type
: @return 
:   Returns re-written nodes and elements in the form global-search-form.xml
:)
declare function local:rewrite-global-search-form($EXIST-PATH as xs:string, $tmpl as element(), $qry as xs:string)  {
   
    (: [Re]writing the search-field with search text :)    
    if ($tmpl/self::xh:input[@id eq "global-search"]) then 
        element input {
            attribute id { "global-search" },
            attribute name { "q" },
            attribute class { "search_for" },
            attribute type { "text" },
            attribute value { "BOOHOO" }
    } 
    else
      element { node-name($tmpl)}
      		 {$tmpl/@*,
    	         for $child in $tmpl/node()
    		        return if ($child instance of element())
    			       then local:rewrite-global-search-form($EXIST-PATH, $child, $qry)
    			       else $child
    		 }

};

(:~
:   The main search API in appcontroller that accepts all requests routed to /search
:  
: @param embed_tmpl
:   XML skeleton global/listing-search-form.xml that is merged into the main layout template.
: @param scope
:   Can either be known 'doctype' or '"global"'
: @param doctype
:   The document type
: @return
:   A Re-written search-form with relevant sort-by field and filter-options
:)
declare function bun:get-listing-search-context(
                        $EXIST-PATH as xs:string, 
                        $embed_tmpl as xs:string,
                        $doctype as xs:string) {

    (: get the template to be embedded :)
    let $tmpl := fw:app-tmpl($embed_tmpl) 
    
    return
        document {
                local:rewrite-listing-search-form($EXIST-PATH, $tmpl/xh:div, $doctype)
        }
};
declare function bun:get-global-search-context(
                        $EXIST-PATH as xs:string, 
                        $embed_tmpl as xs:string, 
                        $scope as xs:string) {

    (: get the template to be embedded :)
    let $tmpl := fw:app-tmpl($embed_tmpl), 
        $qry := xs:string(request:get-parameter("q",'')) 
    
    return
        document {
                local:rewrite-global-search-form($EXIST-PATH, $tmpl/xh:div, $qry)
        }
};

declare function bun:get-advanced-search-context($EXIST-PATH as xs:string, $embed_tmpl as xs:string) {

    (: get the template to be embedded :)
    let $tmpl := fw:app-tmpl($embed_tmpl)
    
    return
        document {
                local:rewrite-advanced-search-form($EXIST-PATH, $tmpl/xh:div)
        }
};

(:~
:   The advanced search API 
:  
: @param EXIST-PATH
:   default path
: @param tmpl
:   The advanced search template
: @return
:   A Re-written advanced search form
:)
declare function local:rewrite-advanced-search-form($EXIST-PATH as xs:string, $tmpl as element())  {
   
    let $search-filter := cmn:get-doctypes(),
        $statuses := cmn:get-statuses()
    
    return
    (: writing the search categories and doctypes :)    
    if ($tmpl/self::xh:div[@id eq "search-groups"]) then 
    element div {
        attribute id { "search-groups" },
        attribute class { "b-left" },
        (: loops through categories filtering duplicates :)
        for $category in distinct-values($search-filter/@category) 
            return 
                element div {
                    attribute class {"category-block"},
                    element span {
                        attribute class {"ul-list-header"},
                        <i18n:text key="{concat('cate-',$category)}">{$category}(nt)</i18n:text>,
                        element br {},
                        element span {
                            attribute class {"checkall"},
                            <i18n:text key="select-all">check all(nt)</i18n:text>
                        },
                        element input {
                            attribute type {"checkbox"},
                            attribute name {"types"},
                            attribute value {$category}
                        }
                    },
                    element ul {
                        for $doctype in $search-filter
                            return  
                                if($doctype/@category eq $category) then (
                                    element li {
                                        <i18n:text key="{concat('doc-',$doctype/@name)}">{lower-case($doctype/@name)}(nt)</i18n:text>,
                                        element input {
                                            attribute type {"checkbox"},
                                            attribute name {"docs"},
                                            attribute value {$doctype/@name}
                                        }
                                    }
                                )
                                else ()
                    }
                }
    }   
    (: render the status dropdown :)
    else if ($tmpl/self::xh:select[@id eq "status"]) then 
    element select {
        attribute id { "status" },
        attribute name { "std" },
        element option {
            attribute value {"none"},
            attribute selected {"selected"},
            <i18n:text key="status-default">select one(nt)</i18n:text>
        },
        for $status in $statuses
            return 
            element option {
                attribute value {$status},
                $status
            }
    } 
    else
      element { node-name($tmpl)}
      		 {$tmpl/@*,
    	         for $child in $tmpl/node()
    		        return if ($child instance of element())
    			       then local:rewrite-advanced-search-form($EXIST-PATH, $child)
    			       else $child
    		 }

};

(:~
:   Generates Atom FEED for Bungeni Documents Bills, Questions, TabledDocuments and Motions.
:    
: @param acl
:   permissions setting
: @param doctype
:   The document type
: @param outputtype
:   Can either be a "user" or "service" request.
: @return
:   A qualified atom feed limited to 10 items
:)
declare function bun:get-atom-feed(
            $acl as xs:string, 
            $doctype as xs:string, 
            $outputtype as xs:string
            ) as element() {
    util:declare-option("exist:serialize", "media-type=application/atom+xml method=xml"),
    
    let $server-path := "http://localhost:8180/exist/apps/framework"
    
    let $feed := <feed xmlns="http://www.w3.org/2005/Atom" xmlns:atom="http://www.w3.org/2005/Atom">
        <title>{concat(upper-case(substring($doctype, 1, 1)), substring($doctype, 2))}s Atom</title>
        <id>http://portal.bungeni.org/1.0/</id>
        <updated>{current-dateTime()}</updated>
        <generator uri="http://exist.sourceforge.net/" version="1.4.5">eXist XML Database</generator>      
        <id>urn:uuid:31337-4n70n9-w00t-l33t-5p3364</id>
        <link rel="self" href="/bills/rss" />
       {
            for $i in subsequence(bun:list-documentitems-with-acl($acl, $doctype),0,10)
            order by $i/bu:legislativeItem/bu:statusDate descending
            (:let $path :=  substring-after(substring-before(base-uri($i),'/.feed.atom'),'/db/bungeni-xml'):)
            return 
            (   <entry>
                    <id>{data($i/bu:legislativeItem/@uri)}</id>
                    <title>{$i/bu:legislativeItem/bu:shortName/node()}</title>
                    {
                       <summary> 
                       {
                           $i/bu:document/@type,
                           $i/bu:legislativeItem/bu:shortName/node()
                       }
                       </summary>,
                       if ($outputtype = 'user')  then (
                            <link rel="alternate" type="application/xhtml" href="{$server-path}/bill/text?uri={$i/bu:legislativeItem/@uri}"/>
                        )  (: "service" output :)
                        else (
                            <link rel="alternate" type="application/xml" href="{$server-path}/bill/xml?uri={$i/bu:legislativeItem/@uri}"/>
                        )  
                    }
                    <content type='html'>{$i/bu:legislativeItem/bu:body/node()}</content>
                    <published>{$i/bu:legislativeItem/bu:publicationDate/node()}</published>
                    <updated>{$i/bu:legislativeItem/bu:statusDate/node()}</updated>                           
                </entry>
            )
       }
    </feed>
    
    return 
        $feed
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

(:~
:   Retieves all group documents of type committee
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type committee
:)
declare function bun:get-committees(
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("committees.xsl")    
    
    (: 
        The line below is documented in bun:get-documentitems()
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'])}</count>
        <documentType>committee</documentType>
        <listingUrlPrefix>committee/text</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>        
        </paginator>
        <alisting>
        {
            if ($sortby = 'start_dt_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>
                   
                )

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
            </parameters>
           ) 
       
};

(:~
:   Retieves all group documents of type sittings
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type sittings
:)
declare function bun:get-sittings(
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("sittings.xsl")    
    
    (: 
        The line below is documented in bun:get-documentitems()
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='groupsitting'])}</count>
        <documentType>groupsitting</documentType>
        <listingUrlPrefix>sittings/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>        
        </paginator>
        <alisting>
        {
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='groupsitting'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    local:get-sitting-items($match)
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
            </parameters>
           ) 
       
};

(:~
:   Retieves all group documents of type sittings
: @param acl
: @param doc-uri
: @param _tmpl
: @return 
:   A listing of documents of group type sittings
:)
declare function bun:get-sitting($acl as xs:string, 
            $doc-uri as xs:string, 
            $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    let $doc := 
            (:Returs a Sittings Document :)
            let $match := util:eval(concat( "collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology[@type='groupsitting']/",
                                            "bu:groupsitting[@uri eq '",$doc-uri,"']/",
                                            bun:xqy-docitem-perms($acl)))
            
            return
                local:get-sitting-items($match/ancestor::bu:ontology)   
    return
        transform:transform($doc, $stylesheet, ())
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

declare function bun:get-sittings-json($acl as xs:string) as element()* {
    util:declare-option("exist:serialize", "method=json media-type=text/javascript"),

    let $match := util:eval(concat( "collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology[@type='groupsitting']/",
                                            bun:xqy-generic-perms($acl),"/",
                                            "ancestor::bu:ontology")),
        $json_ready := functx:remove-elements-deep($match,('bu:bungeni', 'bu:permissions'))
    
     return
        <json>
        {
         $json_ready
        }
        </json>
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

declare function local:get-sitting-items($sittingdoc as node()) {
    <doc>
        {$sittingdoc}
        <ref>
            {
                for $eachitem in $sittingdoc/bu:groupsitting/bu:item_schedule/bu:item_schedule
                return 
                    collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem/bu:legislativeItemId[text() eq $eachitem/bu:itemId/text()]/ancestor::bu:ontology
            }
        </ref>
    </doc>     
};

(:~
:   Retieves all group documents of type politicalgroups
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type policicalgroups
:)
declare function bun:get-politicalgroups(
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("politicalgroups.xsl")    
    
    (: 
        The line below is documented in bun:get-documentitems()
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset      
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'])}</count>
        <documentType>political-group</documentType>
        <listingUrlPrefix>political-group/text</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'start_dt_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>                  
                )
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
            </parameters>
           )     
};

(:~
:   This function runs a sub-query to get related information of type="group" and has
:   has matching URI of the input document-docitem
: 
: @param docitem
:   A document-node
: @return
:   docitem together with any reference group documents found... simplistic structure below
:   <doc>
:       <bu:ontology/> Main document
:       <ref/> Referenced Documents
:   </doc>
:)
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
:
: The following are query builder functions for generating the document access query
: It supports applying of ACLs
:
:)
declare function bun:xqy-docitem-uri($uri as xs:string) as xs:string{
    fn:concat(
        "collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem[@uri='", 
        $uri, 
        "']")
};        

declare function bun:xqy-docitem-perms($acl as xs:string) as xs:string{
    let $acl-permissions := cmn:get-acl-permissions($acl)
    (:
    : Regarding (bu:permissions except bu:versions) 
    : see : 
    : "XQuery wrong xpath resolution bug"
    : <http://sourceforge.net/mailarchive/forum.php?thread_name=CAPoZz4TDjD1B1JqJOKF9z%3DWFGO%3D1xVVg5xo_ksc8y5H66hGNag%40mail.gmail.com&forum_name=exist-open>
    :)
    return fn:concat(
        "(bu:permissions except bu:versions)/bu:permission[", 
        cmn:get-acl-permission-attr($acl-permissions), 
        "]")
};

declare function bun:xqy-generic-perms($acl as xs:string) as xs:string{
    let $acl-permissions := cmn:get-acl-permissions($acl)
    (:
    : !+NOTES(ao, 16 Mar 2012) After moving permissions into main ontological document 
    : containing the uri of a document, the bun:xqy-docitem-perms() applies in less instances 
    : if any and will be deprecated.
    :)
    return fn:concat(
        "bu:permissions/bu:permission[", 
        cmn:get-acl-permission-attr($acl-permissions), 
        "]")
};

declare function bun:xqy-docitem-ancestor-root() as xs:string{
    xs:string("ancestor::bu:ontology")
};

declare function bun:xqy-docitem-acl-uri($acl as xs:string, $uri as xs:string) as xs:string {
    fn:concat(
        bun:xqy-docitem-uri($uri), 
        "/", 
        bun:xqy-docitem-perms($acl),
        "/",
        bun:xqy-docitem-ancestor-root()
        )
};


(:~
Get document with ACL filter
!+ACL_NEW_API - this is the new ACL API for retrieving documents
:)
declare function bun:documentitem-with-acl($acl as xs:string, $uri as xs:string) {
    let $acl-permissions := cmn:get-acl-permissions($acl),
        $tab-context := functx:substring-after-last(request:get-effective-uri(), '/')
        (:$permit := <permission name="zope.View" role="bungeni.Anonymous" setting="Deny"/>:)
    
    (: WARNING-- because of odd behavior in eXist 1.5 branch we have to wrap the return value of the 
    eval in a document {} object otherwise things dont work. Search in the exist mailing list for 'xpath resolution
    bug' :)
    let $match := 
        document {
            util:eval(bun:xqy-docitem-acl-uri($acl, $uri))
        }
    (:
    let $match :=  collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem[@uri=$uri]/
            (bu:permissions except bu:versions)/bu:permission[@name=$acl-permissions/@name and 
                                                              @role=$acl-permissions/@role and 
                                                              @setting=$acl-permissions/@setting]/ancestor::bu:ontology
    :)
    
    (: WARNING -- we pass the node() of the document since the API expects a node, so we send the root node :)
    return 
        if($tab-context eq 'timeline') then
            bun:documentitem-changes-with-acl($acl-permissions,$match/node())
        (:else if($tab-context eq 'documents') then 
            bun:documentitem-eventdocs-with-acl($permit, $match/node()):)           
        else if($tab-context eq 'documents') then 
            bun:documentitem-versions-with-acl($acl-permissions, $match/node())
        else
            $match
    
};

(:~
    Remove Events to which we dont have access. This API filters a document for ONLY the versions
    the acl user has access to !+ACL_NEW_API
:)
declare function bun:documentitem-eventdocs-with-acl($acl-permissions as node(), $docitem as node() ) {

    (:for $anevent in $docitem/bu:legislativeItem/bu:wfevents/bu:wfevent
    let $gotevent := collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem[@uri eq data($anevent/@href)]/ancestor::bu:ontology
    
    return 
    if ($gotevent/bu:legislativeItem/bu:permissions/bu:permission[
          @name=data($acl-permissions/@name) and 
          @role=data($acl-permissions/@role) and 
          @setting=data($acl-permissions/@setting)]) then
          <ola>{data($anevent/@href)}</ola>
    else
          <ola>{data($anevent/@href)}</ola>:)
          
    for $thisone in $docitem/bu:legislativeItem/bu:wfevents/bu:wfevent 
    
        return <test/>
};

(:~
Remove Versions to which we dont have access. This API filters a document for ONLY the versions
the acl user has access to
!+ACL_NEW_API
:)
declare function bun:documentitem-versions-with-acl($acl-permissions as node(), $docitem as node() ) {
  if ($docitem/self::bu:version) then
        if ($docitem/bu:permissions/bu:permission[
                @name=data($acl-permissions/@name) and 
                @role=data($acl-permissions/@role) and 
                @setting=data($acl-permissions/@setting)
                (: 
                @name='zope.View' and 
                @role='bungeni.Anonymous' and 
                @setting='Allow'
                :)
                ]) then
            $docitem
        else
            ()
  else 
    (:~
     return the default 
     :)
  		element { node-name($docitem)}
		  		 {$docitem/@*, 
					for $child in $docitem/node()
						return if ($child instance of element())
							   then bun:documentitem-versions-with-acl($acl-permissions, $child)
							   else $child
				 }
};
(:~ 
    Similar to Versions... removes changes that don't fit the permissions given.
:)
declare function bun:documentitem-changes-with-acl($acl-permissions as node(), $docitem as node() ) {
  if ($docitem/self::bu:change) then
        if ($docitem/bu:permissions/bu:permission[
                @name=data($acl-permissions/@name) and 
                @role=data($acl-permissions/@role) and 
                @setting=data($acl-permissions/@setting)
                ]) then
            $docitem
        else
            ()
  else 
    (:~
     return the default 
     :)
  		element { node-name($docitem)}
		  		 {$docitem/@*, 
					for $child in $docitem/node()
						return if ($child instance of element())
							   then bun:documentitem-changes-with-acl($acl-permissions, $child)
							   else $child
				 }
};
(:~ 
    Similar to Versions... removes attached_files that don't fit the permissions given.
:)
declare function bun:documentitem-attachments-with-acl($acl-permissions as node(), $docitem as node() ) {
  if ($docitem/self::bu:attached_file) then
        if ($docitem/bu:permissions/bu:permission[
                @name=data($acl-permissions/@name) and 
                @role=data($acl-permissions/@role) and 
                @setting=data($acl-permissions/@setting)
                ]) then
            $docitem
        else
            ()
  else 
    (:~
     return the default 
     :)
  		element { node-name($docitem)}
		  		 {$docitem/@*, 
					for $child in $docitem/node()
						return if ($child instance of element())
							   then bun:documentitem-attachments-with-acl($acl-permissions, $child)
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
            $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    (: !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    
    let $doc := document {
            (:Returs a AN Document :)
            (:  !+ACL_NEW_API - changed call to use new ACL API , 
            :   the root is an ontology document now not a legislativeItem
            :)
            let $match := bun:documentitem-with-acl($acl, $doc-uri)
            return
                bun:get-ref-assigned-grps($match)
        }
    return
        transform:transform($doc, $stylesheet, ())
};

(:~ 
:   Used to retrieve a group document with a given URI
:
: @param acl
: @param docid
: @param _tmpl
: @return
:   A document-node of type group
: @stylesheet 
:   committee.xsl, comm-*.xsl
:)
declare function bun:get-parl-group($acl as xs:string, $docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    (: !+FIX_THIS , !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    let $doc := document {
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$docid]/ancestor::bu:ontology
                    return
                        bun:get-ref-assigned-grps($match)   
                }     
    return
        transform:transform($doc, $stylesheet, ())
};

(:~
:   Retrives all the groups assigned to the MP in the input document-node.
:
: @param docitem
: @return 
:   Document node with main document as primary and any group documents assigned to that MP as secondary
:   <doc>
:       <bu:ontology/>
:       <ref/>
:   </doc>
:)
declare function bun:get-ref-assigned-grps($docitem as node()) {
    <doc>
        {$docitem}
        <ref>
            {
                (:!+ACL_NEW_API - removed the ancestor axis reference here 
                !+FIXED - why use a bu:* kind of reference why a * ?!
                :)
                let $doc-ref := data($docitem/child::bu:group/@href)
                return 
                    (:!+FIX_THIS - ultimately this should be replaced by the acl based group access api :)
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/ancestor::bu:ontology
            }
        </ref>
        <exlude>
            {
                if(not($docitem//bu:item_assignments)) then 
                    <tab>assigned</tab>
                else ()
            }
        </exlude>
    </doc>     
};

(:~
:   Retrives contacts for member/group eith particular id.
:
: @param focal - the focal-point, group/user who(s) addresses we want to get
: @param acl - access control list
: @return 
:   Document node with main document as primary and any group documents assigned to that MP as secondary
:   <doc>
:       <bu:ontology/>
:       <ref/>
:   </doc>
:)
declare function bun:get-contacts-by-uri($acl as xs:string, 
                    $address-type as xs:string, 
                    $focal as xs:string,
                    $_tmpl as xs:string) {
    let $stylesheet := cmn:get-xslt($_tmpl), 
        $acl-filter := cmn:get-acl-permission-as-attr($acl),
        $user-uri := if ($address-type eq 'group') then 
                        $focal 
                     else 
                        data(collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$focal]/bu:referenceToUser/@uri),
        $build-qry  := fn:concat("collection('",cmn:get-lex-db() ,"')",
                            "/bu:ontology[@type='address']",
                            "/bu:address/bu:assignedTo[@uri eq '",$user-uri,"']",
                            (: !+NOTE (ao, 16 Mar 2012) Commented permissions check below since currently
                             : we only have public permissions which dont apply in this case 
                             :)
                            (:"/following-sibling::bu:permissions/bu:permission[",$acl-filter,"]",:)
                            "/ancestor::bu:ontology")
    let $doc := <doc>
                    document {
                            if($address-type eq 'group') then 
                                collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$focal]/ancestor::bu:ontology
                            else
                                collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$focal]/ancestor::bu:ontology
                        }
                    <ref>
                        {
                            util:eval($build-qry)
                        }
                    </ref>
                </doc>     
    return
        transform:transform($doc, $stylesheet, <parameters>
                                                 <param name="address_type" value="{$address-type}" />
                                               </parameters>)        
};

(:~
:   Get parliamentary document based on a version URI
:   +NOTES
:   Follows the same structure as get-parl-doc() in that it returns 
:   <doc>
:       <bu:ontology/>
:       <ref/>
:       <version>id</version>
:   </document>
:
: @param versionid
:   Unique ID for the document version
: @param _tmpl
:   The .xsl template that will handle the return output
: @return 
:   Documennt node similar to get-ref-assigned-grps() above
:
: @stylesheet [document-type]/version/text e.g question/version/text
:)
declare function bun:get-doc-ver($acl as xs:string, $version-uri as xs:string, $_tmpl as xs:string) as element()* {
    
    let $doc-uri := xps:substring-before($version-uri, "@")
    let $match := document { util:eval(bun:xqy-docitem-acl-uri($acl, $doc-uri)) }
    let $acl-permissions := cmn:get-acl-permissions($acl)
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl)
    
    let $doc := <doc>
                    {bun:documentitem-versions-with-acl($acl-permissions, $match/node())}
                    <ref/>
                    <version>{$version-uri}</version>
                </doc>   
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                            </parameters>)
};



declare function bun:get-doc-event($eventid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    let $doc := <doc>       
            { collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:wfevents/bu:wfevent[@href = $eventid]/ancestor::bu:ontology }
            <ref>
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='event']/following-sibling::bu:legislativeItem[@uri eq $eventid]/ancestor::bu:ontology
            }            
            </ref>
            <event>{$eventid}</event>
        </doc>  
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                            </parameters>)
};

declare function bun:get-members($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("members.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of members :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='membership'])}</count>
        <documentType>membership</documentType>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'ln') then (
            
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='membership'],$offset,$limit)                
                order by $match/ancestor::bu:ontology/bu:membership/bu:lastName descending
                return 
                    <doc>
                    {
                        $match      
                    }
                    </doc>
                )
            else if ($sortby = 'fn') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='membership'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:membership/bu:firstName descending
                return 
                    <doc>
                    {
                        $match      
                    }
                    </doc>         
                )                
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='membership'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:membership/bu:lastName descending
                return 
                    <doc>
                    {
                        $match      
                    }
                    </doc>        
                )

        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, $stylesheet, ()) 
       
};

declare function bun:get-member($memberid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    (: return AN Member document as singleton :)
    let $doc := <doc>{collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$memberid]/ancestor::bu:ontology}</doc>
    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-parl-activities($acl as xs:string, $memberid as xs:string, $_tmpl as xs:string) as element()* {
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl)
   
    (: return AN Member document with his/her activities :)
    let $doc := <doc>
        { collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$memberid]/ancestor::bu:ontology }
        <ref>    
            {
            (: Get all parliamentary documents the user is either owner or signatory :)
            for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']
            where bu:signatories/bu:signatory[@href=$memberid]/ancestor::bu:ontology or 
                  bu:legislativeItem/bu:owner[@href=$memberid]/ancestor::bu:ontology
            return
                    $match
            }
        </ref>
    </doc> 
    
    return
        transform:transform($doc, $stylesheet, ())    
};

declare function bun:get-assigned-items($committeeid as xs:string, $_tmpl as xs:string) as element()* {

     (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl)

    (: return AN Committee document with all items assigned to it :)
    let $doc := <assigned-items>
    <group>
    {
        collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@uri=$committeeid]/ancestor::bu:ontology
    }
    </group>
    {
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']/child::*/bu:group[@href=$committeeid]
    return
        <items>
            {
                $match/ancestor::bu:ontology
             }
        </items>
    }
    </assigned-items> 
    
    return
        transform:transform($doc, $stylesheet, ())  
};
