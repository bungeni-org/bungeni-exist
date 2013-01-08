xquery version "3.0";

import module namespace cmn = "http://exist.bungeni.org/cmn" at "../../common.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace bun = "http://exist.bungeni.org/bun" at "../bungeni.xqm";
import module namespace vdex = "http://www.imsglobal.org/xsd/imsvdex_v1p0" at "../vdex.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../../template.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace ex="http://exist-db.org/xquery/ex";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xml media-type=application/xml indent=yes";

(: return a deep copy of  the element and all sub elements :)
declare function local:add-vocabularies(
   $node as node(),
   $element as xs:string,
   $vdexid as xs:string
   ) as element() {
    element
        {node-name($node)}
            {if (string(node-name($node))=$element and $node[@vdex eq $vdexid]) then ( 

                        for $att in $node/@*
                            return
                                attribute {name($att)} {$att}
                            ,
                            attribute name {vdex:getVocabName($vdexid,cmn:get-vdex-db(),template:set-lang())},
                            attribute term {vdex:getCaptionByTermId($node/text(),$vdexid,cmn:get-vdex-db(),template:set-lang())}
                   )
            else
                $node/@*
               ,
               for $child in $node/node()
                    return if ($child instance of element())
                        then local:add-vocabularies($child, $element, $vdexid)
                        else $child 
             }
};
let $doc := collection("/db/bungeni-xml")/bu:ontology/bu:membership/bu:referenceToUser[@uri='/ontology/Person/ke.P1_08.minister.1900-02-02.68']/ancestor::bu:ontology
return
    local:add-vocabularies($doc,"bu:gender","org.bungeni.metadata.vocabularies.gender")