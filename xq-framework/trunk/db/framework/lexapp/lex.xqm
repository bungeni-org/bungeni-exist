module namespace lex = "http://exist.bungeni.org/lex";
import module namespace lexcommon = "http://exist.bungeni.org/lexcommon" at "common.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";

(:
Library for common lex functions
uses lexcommon
:)


(: Search for the doc matching the actid in the parameter and return the document :)
declare function lex:get-doc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};


(: Search for the doc matching the actid in the parameter and return the tabel of contents :)
declare function lex:get-toc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};


declare function lex:get-act($actid as xs:string, $pref as xs:string, $xslt as xs:string) as element() {
    (: First get the act document :)
    let $doc := lex:get-doc($actid)
    (: Next get the doc of the XSLT :)   
    let $doc-xslt := lexcommon:get-xslt($xslt)
    (: Now transform the doc with the XSLT :)
    let $doc-transformed := transform:transform($doc, 
		$doc-xslt,
        <parameters>
            <param name="pref" value="{$pref}" />
        </parameters>)
    return $doc-transformed
};