module namespace bun = "http://exist.bungeni.org/bun";
(:import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";:)
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace xps="http://www.w3.org/2005/xpath-functions";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";
import module namespace functx = "http://www.functx.com" at "../functx.xqm";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo="http://exist-db.org/xquery/xslfo";


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
    
    let $doc := <document>        
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]]
            }
        </document>      
        
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
:  Renders PDF output for MP profile using xslfo module
: @param memberid
:   The URI of the parliamentary user
: @return
:   A PDF document for download
:)
declare function bun:gen-member-pdf($memberid as xs:string) {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('member-info.fo') 
    
    let $doc := <document>        
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$memberid]/ancestor::bu:ontology
            }
        </document>
        
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

declare function bun:xqy-list-userdata($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='",$type,"']")
};
declare function bun:xqy-search-userdata() {
    fn:concat("collection('",cmn:get-lex-db() ,"')",
            "/bu:ontology[@type='userdata']",
            "/bu:metadata[@type='user']/ancestor::bu:ontology")
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
    let $coll := bun:list-documentitems-with-acl($acl, $type)
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to alter the $offset to 1 for the first page limit only.
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
        <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
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

declare function bun:search-criteria(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string,
        $typeofdoc as xs:string) as element() {
        
        if ($typeofdoc eq "committee" or $typeofdoc eq "political-group") then
            bun:search-groupitems($acl, $typeofdoc, "bill/text", "committees.xsl", $offset, $limit, $querystr, $sortby)
        else if ($typeofdoc eq "userdata") then
            bun:search-userdata($acl, $typeofdoc, "bill/text", "members.xsl", $offset, $limit, $querystr, $sortby)
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
                    <document>{$match}</document>      
                )             
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <document>{$match}</document>        
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
declare function bun:search-userdata(
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
    let $coll_rs := bun:xqy-list-userdata($type)
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
                    bun:get-reference($match)   
                )             
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
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
    
    (:let $coll_rs := bun:xqy-list-groupitem("userdata"):)
    let $getqrystr := xs:string(request:get-query-string())

    (: toggle summary and categorized :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    let $query-limit := if ($scope eq "global" ) then 3 else $limit
    
    let $coll-legis := bun:xqy-search-legis-with-acl($acl),
        $coll-groups := bun:xqy-search-group(),
        $coll-members := bun:xqy-search-userdata()
    
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
                        <document>{$search-rs}</document>
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
                        <document>{$search-rs}</document>
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
                        <document>{$search-rs}</document>
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
            attribute placeholder { concat("Search ",$type,"s...") },
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
            attribute placeholder { "Searched all Bungeni documents..." },
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
        <listingUrlPrefix>committee/profile</listingUrlPrefix>        
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
                    <document>{$match/ancestor::bu:ontology}</document>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>
                   
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
        <listingUrlPrefix>political-group/profile</listingUrlPrefix>        
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
                    <document>{$match/ancestor::bu:ontology}</document>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>                  
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
:   <document>
:       <output />          Main document
:       <referenceInfo/>    Referenced Documents
:   </document>
:)
declare function bun:get-reference($docitem as node()) {
    <document>
        <output> 
        {
            $docitem
        }
        </output>
        <referenceInfo>
            <ref>
            {
                let $doc-ref := data($docitem/bu:*/bu:group/@href)
                return 
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../bu:ministry
            }
            </ref>
        </referenceInfo>
    </document>     
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
    let $acl-permissions := cmn:get-acl-permissions($acl)
    
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
    return bun:documentitem-versions-with-acl($acl-permissions, $match/node())
    
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
:   Used to retrieve a legislative-document
:
: @param acl
: @param docid
: @param _tmpl
:   The corresponding transform template passed by the calling funcction
:)
declare function bun:get-parl-doc($acl as xs:string, $doc-uri as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    (: !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    
    let $doc := <parl-doc> 
        {
            (:Returs a AN Document :)
            (:  !+ACL_NEW_API - changed call to use new ACL API , 
            :   the root is an ontology document now not a legislativeItem
            :)
            let $match := bun:documentitem-with-acl($acl, $doc-uri),
                (: !+FIX_THIS (ao, Dec 19 2011)
                :   Decoding escaped html markup was painfully futile in XSLT, this is temporary fix since a better
                :   solution must eXist out there. This converts the markup and returns a node that is sneaked into the 
                :   presentation layer as <fringe/> node. See bun:get-ref-assigned-grps()
                :)
                $encodedbody := util:parse(fn:replace(fn:replace(util:serialize($match//bu:legislativeItem/bu:body/node(),"method=xhtml,media-type=text/xhtml"),'&amp;gt;','>'),'&amp;lt;','<'))
            
            return
                bun:get-ref-assigned-grps($match, $encodedbody)
        } 
    </parl-doc>    
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
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$docid]/ancestor::bu:ontology,
                $nullnode := <node/>
            (: !+ACL_NEW_API, !+FIX_THIS - add acl filter for groups
            [$acl-filter]
           :)
            return
                bun:get-ref-assigned-grps($match, $nullnode)   
        } 
    </parl-doc>    
    return
        transform:transform($doc, $stylesheet, ())
};

(:~
:   Retrives all the groups assigned to the MP in the input document-node.
:
: @param docitem
: @return 
:   Document node with main document as primary and any group documents assigned to that MP as secondary
:   <document>
:       <primary/>
:       <secondary/>
:   </document>
:)
declare function bun:get-ref-assigned-grps($docitem as node(), $parsedbody as node()) {
    <document>
        <serverport>{request:get-server-name()}:{request:get-server-port()}</serverport>
        <primary> 
            <documentType>{$docitem/bu:legislature/bu:type}</documentType>
        {
        (:!+ACL_NEW_API 
            $docitem/ancestor::bu:ontology :)
            $docitem
        }
        </primary>
        <secondary>
            {
                (:!+ACL_NEW_API - removed the ancestor axis reference here 
                !+FIXED - why use a bu:* kind of reference why a * ?!
                :)
                let $doc-ref := data($docitem/child::bu:group/@href)
                return 
                    (:!+FIX_THIS - ultimately this should be replaced by the acl based group access api :)
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/ancestor::bu:ontology
            }
        </secondary>
        <fringe>{$parsedbody}</fringe>
    </document>     
};

(:~
:   Get parliamentary document based on a version URI
:   +NOTES
:   Follows the same structure as get-parl-doc() in that it returns 
:   <document>
:       <version>id</version>
:       <primary/>
:       <secondary/>
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
    let $match := bun:documentitem-with-acl($acl, $doc-uri)
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl)
    
    let $doc := <parl-doc>
        <document>
            <serverport>{request:get-server-name()}:{request:get-server-port()}</serverport>
            <version>{$version-uri}</version>
            <primary>         
            {
                $match
            }
            </primary>
            <secondary>
            </secondary>
        </document>
    </parl-doc>   
    
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
    
    let $doc := <parl-doc>
        <document>
            <event>{$eventid}</event>
            <primary>         
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:wfevents/bu:wfevent[@href = $eventid]/ancestor::bu:ontology
            }
            </primary>
            <secondary>
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='event']/../bu:legislativeItem[@uri eq $eventid]/ancestor::bu:ontology
            }            
            </secondary>
        </document>
    </parl-doc>   
    
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
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'])}</count>
        <documentType>userdata</documentType>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'ln') then (
            
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)                
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='last_name'] descending
                return 
                    bun:get-reference($match/ancestor::bu:ontology)       
                )
            else if ($sortby = 'fn') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='first_name'] descending
                return 
                    bun:get-reference($match/ancestor::bu:ontology)         
                )                
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='last_name'] descending
                return 
                    bun:get-reference($match/ancestor::bu:ontology)         
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
    let $doc := collection(cmn:get-lex-db())//bu:ontology//bu:user[@uri=$memberid]/ancestor::bu:ontology
    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-parl-activities($memberid as xs:string, $_tmpl as xs:string) as element()* {

     (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    (: return AN Member document with his/her activities :)
    let $doc := <activities>
    <member>
    {
        collection(cmn:get-lex-db())/bu:ontology//bu:user[@uri=$memberid]/ancestor::bu:ontology
    }
    </member>
    {
    (: Get all parliamentary documents the user is either owner or signatory :)
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']
    where   bu:signatories/bu:signatory[@href=$memberid]/ancestor::bu:ontology or 
            bu:legislativeItem/bu:owner[@href=$memberid]/ancestor::bu:ontology
    return
        <docs>
            {
                $match
            }
        </docs>
    }
    </activities> 
    
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
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:*/bu:group[@href=$committeeid]
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
