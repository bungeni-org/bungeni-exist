import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
module namespace vdex = 'http://www.imsglobal.org/xsd/imsvdex_v1p0';
(:~
    : Module for integration Vdex files exported from Bungeni
    
    : @author Anthony Oduor <aowino@googlemail.com>
    : @author Ashok Hariharan <ashok@parliaments.info>
:)


(:~
 : Get a Vdex vocabulary with given Identifier
 :
 : @param $vocabId Unique identifier for the vocabulary
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
        </erro>
    }    
};

(:~
 : Process a given id and return relevant term based on current language selection or default to default
 :
 : @param $selectedLang the prevailing language of the user
 : @param $termId the term identifier in the vdex file
 : @param $collDir the path to the collection of vdex files
 : @param $defaultLang the default language as set in the config.xml file
:)
declare function vdex:process($selectedLang as xs:string,
                            $termId as xs:string,
                            $collDir as xs:string, 
                            $defaultLang as xs:string) {        
    for $node in $nodes              
        let $selectedVocab := i18n:getVdexCollection($vocabularyId, $vocabularyCollPath)  
        return        
            vdex:getLocalizedTerm($termId, $selectedLang, $selectedVocab)
};


(: 
 : Get the localized term for a given term Id from the given vdex vocabulary 
 : if no localized term is available, the default value is used
 :
 : @param $termId the term identifier in the vdex file
 : @param $selectedVocab the vocab file returned from VocabId in vdex:getVdexCollection()
:)
declare function vdex:getLocalizedTerm($termId as xs:string, $selectedLang as xs:string, $selectedVocab as node()){
    if(exists($selectedVocab//termIdentifier[text() eq $termId])) then 
        $selectedVocab//termIdentifier[text() eq $termId]/following-sibling::caption/langstring[@language eq $selectedLang]/text() 
    else 
        ()
    
};