module namespace bun = "http://exist.bungeni.org/bun";
import module namespace bungenicommon = "http://bungeni.org/pis/common" at "common.xqm";
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
Local Constants
:)
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
     for $match in collection(bungenicommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};

declare function bun:paginator($offset as xs:integer) as element()+ {
    (: get total documents for pagination :)
    let $count := count(collection(bungenicommon:get-lex-db())//akomaNtoso)
    
    let $pageoutput := <span>{fn:concat("total: ", $count)}</span>
     
    (:for $match in collection(bungenicommon:get-lex-db())//akomaNtoso:)
    (:for $i in (1 to $count)[. mod 10 = 0]
    let $page := <a > </a> 
    
        element xh:a {
                attribute href { fn:concat("?offset=", $bun:DEFAULT-PAGE, "&amp;limit=",$bun:PER-PAGE) },
                $bun:DEFAULT-PAGE
            } return $page
      :)
    return $pageoutput
};

declare function bun:get-bills($offset as xs:integer, $limit as xs:integer) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := bungenicommon:get-xslt("bill-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of bills only :)
        <count>{count(collection(bungenicommon:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            (:
            for $match in subsequence(collection(bungenicommon:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
            return $match/ancestor::bu:ontology  
            :)
            
            for $match in subsequence(collection(bungenicommon:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'],$offset,$limit)
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
                            collection(bungenicommon:get-lex-db())/bu:ontology/bu:group[@uri eq $bill-ref]/../bu:ministry
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

declare function bun:get-questions($offset as xs:integer, $limit as xs:integer) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := bungenicommon:get-xslt("question-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(bungenicommon:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            for $match in subsequence(collection(bungenicommon:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
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
                            collection(bungenicommon:get-lex-db())/bu:ontology/bu:group[@uri eq $bill-ref]/../bu:ministry
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
     for $match in collection(bungenicommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};

declare function bun:get-parl-doc($docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := bungenicommon:get-xslt($_tmpl) 

    (: return AN document as singleton :)
    (: !#FIX_THIS (ao, 3rd Nov 2011, dynamically get any document e.g question, bill e.t.c instead of 'bu:*' :)
    let $doc := collection(bungenicommon:get-lex-db())/bu:ontology/bu:*[@uri=$docid]/ancestor::bu:ontology
    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-member($memberid as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := bungenicommon:get-xslt("member.xsl") 

    (: return AN Member document as singleton :)
    let $doc := collection(bungenicommon:get-lex-db())//bu:ontology//bu:user[@uri=$memberid]/ancestor::bu:ontology
    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-act($actid as xs:string, $pref as xs:string, $xslt as xs:string) {
    (: First get the act document :)
    let $doc := bun:get-doc($actid),
    (: Next get the doc of the XSLT :)   
     $doc-xslt := bungenicommon:get-xslt($xslt),
    (: Now transform the doc with the XSLT :)
     $doc-transformed := transform:transform($doc, 
		$doc-xslt,
        <parameters>
            <param name="pref" value="{$pref}" />
        </parameters>)
     return $doc-transformed
};