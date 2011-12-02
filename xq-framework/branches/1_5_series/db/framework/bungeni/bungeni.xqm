module namespace bun = "http://exist.bungeni.org/bun";
(:import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";:)
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
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
declare variable $bun:WHERE := 'body_text';

declare variable $bun:OFF-SET := 0;
declare variable $bun:LIMIT :=10;
declare variable $bun:DOCNO := 1;

(:
    Renders PDF documents using xslfo module
:)
declare function bun:gen-pdf-output($docid as xs:string) {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('parl-doc.fo') 
    
    let $doc := <document>        
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]]
            }
        </document>      
        
    let $transformed := transform:transform($doc,$stylesheet,())
     
    let $pdf := xslfo:render($transformed, "application/pdf", ())
     
    return response:stream-binary($pdf, "application/pdf", "output.pdf")     
    
};

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
     
    return response:stream-binary($pdf, "application/pdf", "output.pdf")     
    
};


declare function bun:list-documentitems-with-acl($acl as xs:string, $type as xs:string) {
    let $eval-query := bun:xqy-list-documentitems-with-acl($acl, $type)
    return
        util:eval($eval-query)
        (: collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type=$type]/following-sibling::bu:legislativeItem/(bu:permissions except bu:versions)/bu:permission[$acl-filter] :)
};

declare function bun:xqy-list-documentitems-with-acl($acl as xs:string, $type as xs:string) {
  let $acl-filter := cmn:get-acl-filter($acl)
    
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

declare function bun:get-documentitems(
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $where as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)    
    let $coll := bun:list-documentitems-with-acl($acl, $type)
    
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
        <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
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

declare function bun:get-bills(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $where as xs:string, 
        $sortby as xs:string) as element() {
        
        bun:get-documentitems($acl, "bill", "bill/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $where, $sortby)
};

declare function bun:get-questions(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $where as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "question", "question/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $where, $sortby)
};

declare function bun:get-motions(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $where as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "motion", "motion/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $where, $sortby)
};

declare function bun:get-tableddocuments(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $where as xs:string, 
        $sortby as xs:string) as element() {
  bun:get-documentitems($acl, "tableddocument", "tableddocument/text", "legislativeitem-listing.xsl", $offset, $limit, $querystr, $where, $sortby)
};

declare function bun:search-legislative-items(
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $where as xs:string, 
        $sortby as xs:string,
        $typeofdoc as xs:string) as element() {
        
        bun:search-documentitems($acl, $typeofdoc, "bill/text", "search-listing.xsl", $offset, $limit, $querystr, $where, $sortby)
};

declare function local:generate-qry-str($getqrystr) {
        let $tokened := tokenize($getqrystr,'&amp;'),
            $loop := 0
            
        for $toks in $tokened 
            return
                if (contains($toks,"offset") or contains($toks,"limit")) then (
                    remove($tokened,index-of($tokened,$toks))
                )
                else ()
};

declare function bun:search-documentitems(
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $where as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)    
    let $coll_rs := bun:xqy-list-documentitems-with-acl($acl, $type)
    let $getqrystr := xs:string(request:get-query-string())

    (: check if search is there so as to proceed to search or not :)    
    let $coll := if ($querystr ne "") then bun:ft-search($coll_rs, $querystr, $type) else $coll_rs
    
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
            <searchString>{$querystr}</searchString>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <sortBy>{$sortby}</sortBy>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
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
        (:$doc:)
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           )
};
declare function bun:ft-search(
            $sort-rs as xs:string, 
            $querystr as xs:string,
            $type as xs:string) as element()* {
        (: 
            There are special characters for Lucene that we have to escape 
            incase they form part of the user's search input. More on this...
           
            http://sewm.pku.edu.cn/src/other/clucene/doc/queryparsersyntax.html
            http://www.addedbytes.com/cheat-sheets/regular-expressions-cheat-sheet/
        :)
        
        let $escaped := replace($querystr,'(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`'),
            $ultimate-path := local:build-search-objects($type),
            $eval-query := concat($sort-rs,"//bu:legislativeItem[ft:query((",$ultimate-path,"), '",$escaped,"')]")
            
        for $search-rs in util:eval($eval-query)
        order by ft:score($search-rs) descending
            
        return
            (:<params>{$ultimate-path}</params> !+DEBUG_WITH_test.xql:)
            $search-rs/ancestor::bu:ontology        
};

declare function local:build-search-objects($type as xs:string) {
    
  let 
    $search-filter := cmn:get-searchins-config($type),
    $filter_names := request:get-parameter-names()
    (:$filter_names := fn:tokenize('f_t f_b s q','\s+') !+DEBUG_WITH_test.xql:)
  
    let $list := 
        for $token in $filter_names 
            (: Loop the number of times we have <searchins> in ui-config :)
            for $searchins in $search-filter
                return
                    if ($token eq $searchins/@name) then $searchins/@field else ()
    return 
      string-join($list, ",")
};

declare function local:rewrite-search-form($tmpl as element(), $type as xs:string)  {

    (: get the current doc-types search conf:)
    let $search-filter := cmn:get-searchins-config($type),
        $search-orderby := cmn:get-orderby-config($type),
        $qry := xs:string(request:get-parameter("q",'')),        
        $f_all := xs:string(request:get-parameter("all",'null')),
        $f_body := xs:string(request:get-parameter("f_b",'null')),
        $f_docno := xs:string(request:get-parameter("f_d",'null')),
        $f_title := xs:string(request:get-parameter("f_t",'null'))        

    return
      (: Re-writing the doc_type with the one we got from legi-listing :)    
      if ($tmpl/self::xh:input[@id eq "doc_type"]) then 
        element input {
            attribute type { "hidden" },
            attribute name { "type" },
            attribute value { $type }
        }   
      (: Re-writing the search-field with search text :)    
      else if ($tmpl/self::xh:input[@id eq "search_for"]) then 
        element input {
            attribute id { "search_for" },
            attribute name { "q" },
            attribute class { "search_for" },
            attribute type { "text" },
            attribute value { $qry }
        }
      (: [Re]Writing the filter_by options from ui-config :)
      else if ($tmpl/self::xh:ul[@id eq 'filter_by']) then 
          element ul 
          {
            attribute id {$tmpl/@id},
            attribute class {$tmpl/@class},      
            (: Default items on all search options :)
            element li {
                attribute class { "sb_filter" },
                "Filter your search"
            },  
            (: End of Default items :)
            for $searchins in $search-filter
            return
                element li {
                    element input {
                        (: Check if first time hence using default or custom filter and maintain filter options :)
                        if($searchins/@default eq "true" and $qry eq '') then 
                            attribute checked { "checked" }                    
                        else if($f_title eq $searchins/@value or 
                                $f_docno eq $searchins/@value or 
                                $f_body eq $searchins/@value) then 
                            attribute checked { "checked" }
                        else (),
                        attribute type { "checkbox" },
                        attribute name { $searchins/@name },
                        $searchins/@value
                    },
                    element label { 
                        attribute for { $searchins/@value},
                         if($searchins/@name eq 'all') then 
                            element b {
                                $searchins/text()
                            }
                         else
                            $searchins/text()    
                    }
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
					       then local:rewrite-search-form($child, $type)
					       else $child
				 }

};

(:~
    Expected parameters
    This currently uses search-form.xml
:)

declare function bun:get-search-context($embed_tmpl as xs:string, $doctype as xs:string) {

    let $tmpl := fw:app-tmpl($embed_tmpl) (: get the template to be embedded :)
        
    return
        document {
            local:rewrite-search-form($tmpl/xh:div, $doctype)
        }
};

(:~
    Generates Atom FEED for Bungeni Documents
    Bills, Questions, TabledDocuments and Motions.
    
    @category type of document e.g. bill
    
    Ordered by `bu:statusDate` and limited to 10 items.
    !+FIX_THIS - FOR ACL BASED ACCESS
:)
declare function bun:get-atom-feed($acl as xs:string, $doctype as xs:string, $outputtype as xs:string) as element() {
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
                  return ( <entry>
                            <id>{data($i/bu:legislativeItem/@uri)}</id>
                            <title>{$i/bu:legislativeItem/bu:shortName/node()}</title>
                            {
                               <summary> {
                                   $i/bu:document/@type,
                                   $i/bu:legislativeItem/bu:shortName/node()
                               }</summary>,
                               
                               
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
    Returns the fetched document as XML document
    @works-with Bills, Questions, TabledDocuments and Motions.
    @category   type of document e.g. bill
    
    Ordered by `bu:statusDate` and limited to 10 items.
:)
declare function bun:get-raw-xml($docid as xs:string) as element() {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    functx:remove-elements-deep(
    collection(cmn:get-lex-db())/bu:ontology[@type='document'][child::bu:legislativeItem[@uri eq $docid]],
    ('bu:versions', 'bu:permissions', 'bu:changes')
    )
};

declare function bun:get-committees($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("committees.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'])}</count>
        <documentType>group</documentType>
        <listingUrlPrefix>committee/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
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

declare function bun:get-politicalgroups($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("politicalgroups.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'])}</count>
        <documentType>group</documentType>
        <listingUrlPrefix>committee/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
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
    This function runs a sub-query to get related information
    It takes in primary results of main query as input to search
    for group documents with matching URI
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
(:
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
:)
declare function bun:documentitem-with-acl($acl as xs:string, $uri as xs:string) {
    let $acl-permissions := cmn:get-acl-permissions($acl)
    let $match := util:eval(bun:xqy-docitem-acl-uri($acl, $uri))
    (:
    let $match :=  collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem[@uri=$docid]/
            (bu:permissions except bu:versions)/bu:permission[@name=$acl-permissions/@name and 
                                                              @role=$acl-permissions/@role and 
                                                              @setting=$acl-permissions/@setting]/ancestor::bu:ontology
    :)
    return bun:documentitem-versions-with-acl($acl-permissions, $match)
    
};

(:~
Remove Versions to which we dont have access
:)
declare function bun:documentitem-versions-with-acl($acl-permissions as node(), $docitem as node() ) {
  if ($docitem/self::bu:version) then
        if ($docitem/bu:permissions/bu:permission[
            (:
                @name=data($acl-permissions/@name) and 
                @role=data($acl-permissions/@role) and 
                @setting=data($acl-permissions/@setting)
             :)
                @name='zope.View' and 
                @role='bungeni.Anonymous' and 
                @setting='Allow'
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
:)
declare function bun:get-parl-doc($acl as xs:string, $docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    let $acl-filter := cmn:get-acl-filter($acl)
 
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem[@uri=$docid][$acl-filter]
            return
                bun:get-ref-assigned-grps($match)   
        } 
    </parl-doc>    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-parl-group($acl as xs:string, $docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    let $acl-filter := cmn:get-acl-filter($acl)
 
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$docid][$acl-filter]
            return
                bun:get-ref-assigned-grps($match)   
        } 
    </parl-doc>    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-ref-assigned-grps($docitem as node()) {
            <document>
                <primary> 
                {
                    $docitem/ancestor::bu:ontology
                }
                </primary>
                <secondary>
                    {
                        let $doc-ref := data($docitem/ancestor::bu:ontology/bu:*/bu:ministry/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../../bu:ontology
                    }
                </secondary>
            </document>     
};

(:~
    Get parliamentary document based on a version URI
    +NOTES
    Follows the same structure as get-parl-doc() in that it returns 
    <document>
        <version>id</version>
        <primary/>
        <secondary/>
    </document>
:)
declare function bun:get-doc-ver($versionid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    let $doc := <parl-doc>
        <document>
            <version>{$versionid}</version>
            <primary>         
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:versions/bu:version[@uri=$versionid]/ancestor::bu:ontology
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

declare function bun:get-members($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("members.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of members :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
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
