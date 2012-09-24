xquery version "3.0";

import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "template.xqm";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni/bungeni.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace json="http://www.json.org";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace ex="http://exist-db.org/xquery/ex";
declare namespace bu="http://portal.bungeni.org/1.0/";

declare option exist:serialize "method=xml media-type=application/xml indent=yes";
(:declare option exist:serialize "method=json media-type=text/javascript";:)


(:
: Retrieving document types
:)
declare function local:legislative-docs(
            $type as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $sortby as xs:string,
            $search as xs:string) as element() {
    
    let $coll := collection(cmn:get-lex-db())/bu:ontology
    let $coll_rs := subsequence($coll,$offset,$limit)
    
    let $doc := 
        <docs> 
            <count>{count($coll)}</count>
            <documentType>{$type}</documentType>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            {$coll_rs}
        </docs>
        return
            $doc
};

local:legislative-docs("Question",1,5,"test txt")