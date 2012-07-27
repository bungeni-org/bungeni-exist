xquery version "3.0";

module namespace vdex = 'http://www.imsglobal.org/xsd/imsvdex_v1p0';

import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
declare default element namespace "http://www.imsglobal.org/xsd/imsvdex_v1p0";
(:~
    : Module for integration Vdex files exported from Bungeni
    
    : @author Anthony Oduor <aowino@googlemail.com>
    : @author Ashok Hariharan <ashok@parliaments.info>
:)


(:~
 : Get a Vdex vocabulary with given Identifier
 :
 : @param $vocabId Unique identifier for the vocabulary
 : @param $collPath absolute path to the vocabularies collection
 :
 : @return <vdex/> node
:)
declare function vdex:getVdexCollection($vocabId as xs:string, $collPath as xs:string) {
    try {
        collection($collPath)/vdex/vocabIdentifier[text() eq $vocabId]/ancestor::vdex
    } catch * {
        <error>
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </error>
    }     
};

declare function vdex:getVocabName($vocabId as xs:string,
                                $collPath as xs:string,
                                $getLang as xs:string) {
    let $selectedVocab := vdex:getVdexCollection($vocabId, $collPath)
    return 
        if(exists($selectedVocab/vocabName/langstring[@language eq $getLang])) then 
            $selectedVocab/vocabName/langstring[@language eq $getLang]/text() 
        else 
            $selectedVocab/vocabName/langstring[1]/text() 
};

(: 
 : Get the caption for a given term Id from the given vdex vocabulary 
 : if no caption is available, the term id is returned as default
 :
 : @param $termId the term identifier in the vdex file
 : @param $vocabId unique identifier for the vocabulary
 : @param $collPath absolute path to the vocabularies collection
 : @param $getLang the selected/default language given to 'vocabularize'
:)
declare function vdex:getCaptionByTermId($termId as xs:string, 
                                $vocabId as xs:string,
                                $collPath as xs:string,
                                $getLang as xs:string) {
    let $selectedVocab := vdex:getVdexCollection($vocabId, $collPath)
    return 
        if( exists($selectedVocab//termIdentifier[text() eq $termId]) and 
            exists($selectedVocab//langstring[@language eq $getLang])) then 
            $selectedVocab//termIdentifier[text() eq $termId]/following-sibling::caption/langstring[@language eq $getLang]/text() 
        else 
            $termId
};

(: 
 : Identify-transform to embed any known vocalublaries
 :
 : @param $node a document node
 :
 : @return a deep copy of the document with additional vocabulatioes 
 :)
declare function vdex:set-vocabularies($node as node()) as element() {
    element
        {node-name($node)}
            {
            if (name($node/@vdex) eq 'vdex') then ( 

                        for $att in $node/@*
                            return
                                attribute {name($att)} {$att}
                            ,
                            attribute name {vdex:getVocabName(data($node/@vdex),cmn:get-vdex-db(),template:set-lang())},
                            attribute term {vdex:getCaptionByTermId($node/text(),data($node/@vdex),cmn:get-vdex-db(),template:set-lang())}
                   )
            else
                $node/@*
               ,
               for $child in $node/node()
                    return if ($child instance of element())
                        then vdex:set-vocabularies($child)
                        else $child 
             }
};