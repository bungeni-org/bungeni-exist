module namespace bun = "http://exist.bungeni.org/bun";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";


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
declare variable $bun:LIMIT := 15;
declare variable $bun:DOCNO := 1;

(:~
Load navigation menu on every page 
:)
declare function bun:get-menu($request-rel-path as xs:string, $element as element(), $content as node()*) {
  element {node-name($element)} {
     for $attr in $element/@* return
        template:adjust-relative-paths($request-rel-path, $attr)
     ,
     for $child in $element/node() return
        if($child instance of element()) then
            
            if($content/node-name(.) = node-name($child) and $child/@id = $content/@id)then
            (: if(node-name($child) = (xs:QName("xh:div"), xs:QName("xh:ul")) and $child/@id = $content/@id)then :)
                template:copy-and-replace($request-rel-path, $content[@id eq $child/@id], ())
            else
                template:copy-and-replace($request-rel-path, $child, $content)
        else
            $child
    }
};

(: Search for the doc matching the actid in the parameter and return the document :)
declare function bun:get-doc($actid as xs:string) as element() {
     for $match in collection(cmn:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};

declare function bun:paginator($offset as xs:integer) as element()+ {
    (: get total documents for pagination :)
    let $count := count(collection(cmn:get-lex-db())//akomaNtoso)
    
    let $pageoutput := <span>{fn:concat("total: ", $count)}</span>
     
    (:for $match in collection(cmn:get-lex-db())//akomaNtoso:)
    (:for $i in (1 to $count)[. mod 10 = 0]
    let $page := <a > </a> 
    
        element xh:a {
                attribute href { fn:concat("?offset=", $bun:DEFAULT-PAGE, "&amp;limit=",$bun:PER-PAGE) },
                $bun:DEFAULT-PAGE
            } return $page
      :)
    return $pageoutput
};

declare function bun:get-bills($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("bill-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of bills only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'pub_date') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:field[@type='publication_date'] descending
                return 
                    bun:get-reference($match)         
                )                
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:registryNumber descending
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
            </parameters>
           ) 
       
};

(:~
    This function runs a sub-query to get ministry information
    It takes in primary results of main query as input to search
    for group documents with matching URI
:)
declare function bun:get-reference($docitem as node()) {
            <document>
                <output> 
                {
                    $docitem/ancestor::bu:ontology
                }
                </output>
                <referenceInfo>
                    <ref>
                    {
                        let $doc-ref := data($docitem/ancestor::bu:ontology/bu:*/bu:group/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../bu:ministry
                    }
                    </ref>
                </referenceInfo>
            </document>     
};

declare function bun:get-questions($offset as xs:integer, $limit as xs:integer) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("question-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
            return 
            <document>
                <output> 
                {
                    $match/ancestor::bu:ontology
                }
                </output>
                <referenceInfo>
                    <ref>
                    {
                        let $bill-ref := data($match/ancestor::bu:ontology/bu:bill/bu:ministry/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $bill-ref]/../bu:ministry
                    }
                    </ref>
                </referenceInfo>
            </document>            
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, $stylesheet, ()) 
       
}; 

declare function bun:get-motions($offset as xs:integer, $limit as xs:integer) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("motion-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
            return 
            <document>
                <output> 
                {
                    $match/ancestor::bu:ontology
                }
                </output>
                <referenceInfo>
                    <ref>
                    {
                        let $bill-ref := data($match/ancestor::bu:ontology/bu:bill/bu:ministry/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $bill-ref]/../bu:ministry
                    }
                    </ref>
                </referenceInfo>
            </document>            
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, $stylesheet, ()) 
       
};

declare function bun:get-tableddocs($offset as xs:integer, $limit as xs:integer) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("td-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
            return 
            <document>
                <output> 
                {
                    $match/ancestor::bu:ontology
                }
                </output>
                <referenceInfo>
                    <ref>
                    {
                        let $bill-ref := data($match/ancestor::bu:ontology/bu:bill/bu:ministry/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $bill-ref]/../bu:ministry
                    }
                    </ref>
                </referenceInfo>
            </document>            
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, $stylesheet, ()) 
       
};

(: Search for the doc matching the actid in the parameter and return the tabel of contents :)
declare function bun:get-toc($actid as xs:string) as element() {
     for $match in collection(cmn:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};

declare function bun:get-parl-doc($docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
 
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            (: !#FIX_THIS (ao, 3rd Nov 2011, dynamically get any document e.g question, bill e.t.c instead of 'bu:*' :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:*[@uri=$docid]
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
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-members($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("members.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of bills only :)
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
                    bun:get-reference($match)       
                )
            else if ($sortby = 'fn') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='first_name'] descending
                return 
                    bun:get-reference($match)         
                )                
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='last_name'] descending
                return 
                    bun:get-reference($match)         
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
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:owner[@href=$memberid]
    return
        <docs>
            {
                $match/ancestor::bu:ontology
             }
        </docs>
    }
    </activities> 
    
    return
        transform:transform($doc, $stylesheet, ())    
};