xquery version "1.0";


declare namespace fts="http://exist.bungeni.org/ftsearch";
declare namespace kl = "http://kenyalaw.org/metadata" ;
  
declare namespace util="http://exist-db.org/xquery/util";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "modules/common.xqm";
import module namespace lex="http://exist.bungeni.org/lex" at "modules/lex.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare namespace request="http://exist-db.org/xquery/request";
import module namespace kwic="http://exist-db.org/xquery/kwic";

(:
Performs a full text lucene search on the lex collection.

The full text search string is built in javascript and passed in.
(See lex.js:adsSearchBuild() )

This script is called from controller.xql and forwards to translate-adsearch.xql

The request pattern looks like this :
adsearch -> adsearch.xql -> translate-adsearch.xql 
:)

declare option exist:serialize "method=xml media-type=application/xml";

declare function fts:get-query() as element() {
    (:get the collection to search in :)
    let $collection := concat("collection('" , lexcommon:get-lex-db(), "')")
     
    let $filteryy := xs:string(request:get-parameter("restrictyy",""))
    let $filtermm := xs:string(request:get-parameter("restrictmm", ""))
    
    (: if there are FT filters first we build up a collection with just that set of documents :)
    let $restrictyy := if (string-length($filteryy) eq 0 ) then
                            ()
                       else
                            (: Here we do a range filter on meta/lexyy/@num and build a collection out of that :)
                            let $query_yy := concat(xs:string("//kl:meta[@name='lexyy']"),xs:string("[@num='"), $filteryy, xs:string("']"))
                            let $xq_by_yy := concat($collection, $query_yy)
                            return util:eval($xq_by_yy)
    (: restrictyy is a collection of documents :)                       
    let $restrictmm := if (empty($restrictyy)) then 
                            ()
                       else if (string-length($filtermm) eq 0 ) then
                            ()
                       else
                            (: Do the same here for the month filter :)
                            let $query_mm :=  concat(xs:string("/following-sibling::kl:meta[@name='lexmm'][@num='"), $filtermm, xs:string("']"))
                            let $xq_by_mm := concat('$restrictyy', $query_mm)
                            return util:eval($xq_by_mm)
                            
        
    (: conditional ancesstor reference ... for the condition see below :)
    let $returnResult := xs:string('/ancestor::akomaNtoso')
    let $query := xs:string(request:get-parameter("q",""))
    (: return the ancestor only for field level searches -- for document level searches we are already returning
    the whole document :)
    let $concatReturnResult := if (starts-with($query, "//akomaNtoso")) then 
                                    xs:string("") 
                               else 
                                    $returnResult
    (: Now concat all three to generate the full  XQuery ft search string :)      
    
    let $run := if (empty($restrictyy) and empty($restrictmm)) then
                    concat($collection, $query, $concatReturnResult)
                else 
                if ( (empty($restrictyy) = false ) and empty($restrictmm)) then 
                    concat('$restrictyy', '/ancestor::akomaNtoso', $query, $concatReturnResult)
                else
                if ( (empty($restrictmm) = false)) then
                    concat('$restrictmm','/ancestor::akomaNtoso', $query, $concatReturnResult)
                else
                    ()
                
    (: Now run the built XQuery :)
    let $results := for $hit in util:eval($run)
                    order by ft:score($hit) descending
                    return 
                        <doc actid="{$hit//docNumber[@id eq 'ActIdentifier']}">
                            <date><full>{$hit//docDate[@refersTo eq '#CommencementDate']/@date/string()}</full>
                            <year>{$hit//kl:meta[@name eq 'lexyy']/@num/string()}</year>
                            <month>{$hit//kl:meta[@name eq 'lexmm']/@num/string()}</month>
                            <day>{$hit//kl:meta[@name eq 'lexdd']/@num/string()}</day>
                            </date>
                            <category id="{$hit//kl:meta[@name eq 'gokcatid']/@num/string()}" name="{$hit//kl:meta[@name eq 'gokcatname']}" />
                            <title>{$hit//docTitle[@id eq 'ActTitle']/text()}</title>
                            <number>{$hit//docNumber[@id eq 'ActNumber']/text()}</number>
                            {kwic:summarize($hit, <config width="100"/>)}
                        </doc>

    return <docs>{$results}</docs>
};


(:"collection('/db/kenyalex')//docTitle[@id eq 'ActTitle'][ft:query(., 'reform')]/ancestor::akomaNtoso" :)

(:
let $results := for $hit in util:eval($run)
                let $expanded := kwic:expand($hit)
                return <searchResult>{$expanded}</searchResult>

let $fullsearchresults := <searchResults>{$results}</searchResults>


import module namespace kwic="http://exist-db.org/xquery/kwic";

  for $match in collection('/db/kenyalex')//docTitle[@id='ActTitle'][ft:query(.,'Law')]/ancestor::akomaNtoso//docNumber[@id='ActIdentifier'][text()='3']
   return $match/ancestor::akomaNtoso

:)


(: set a request attribute for the next script in the execution chain :)
request:set-attribute("results.doc",  fts:get-query())
