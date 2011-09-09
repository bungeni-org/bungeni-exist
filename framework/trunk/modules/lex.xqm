module namespace lex = "http://exist.bungeni.org/lex";
import module namespace lexcommon = "http://exist.bungeni.org/lexcommon" at "common.xqm";

declare namespace util="http://exist-db.org/xquery/util";

(:
Library for common lex functions
uses lexcommon
:)


(: Search for the doc matching the actid in the parameter :)
declare function lex:get-doc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};


(: Search for the doc matching the actid in the parameter :)
declare function lex:get-toc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};