xquery version "3.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace cmn = "http://exist.bungeni.org/cmn" at "../../common.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace bun = "http://exist.bungeni.org/bun" at "../bungeni.xqm";
declare namespace ex="http://exist-db.org/xquery/ex";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xml media-type=application/xml indent=yes";

(: return a deep copy of  the element and all sub elements :)
declare function local:change-attribute-name-for-element(
   $node as node(),
   $element as xs:string,
   $vdexid as xs:string,
   $vocab as xs:string
   ) as element() {
    element
        {node-name($node)}
            {if (string(node-name($node))=$element and $node[@vdex eq $vdexid]) then ( 

                        for $att in $node/@*
                            return
                                attribute {name($att)} {$att}
                        ,
                        $vocab
                   )
                else
                    $node/@*
                   ,
                   for $child in $node/node()
                        return if ($child instance of element())
                            then local:change-attribute-name-for-element($child, $element, $vdexid, $vocab)
                            else $child 
                 }
};
let $doc := collection("/db/bungeni-xml")/bu:ontology/bu:membership/bu:referenceToUser[@uri='/ontology/Person/ke.P1_06.business.1900-02-02.50']/ancestor::bu:ontology
return
    local:change-attribute-name-for-element($doc,"bu:gender","org.bungeni.metadata.vocabularies.gender","wala")