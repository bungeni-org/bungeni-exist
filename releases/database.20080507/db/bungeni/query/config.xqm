(:~
:    Copyright  Adam Retter 2008 <adam.retter@googlemail.com>
:    
:    Bungeni Configuration settings
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.0
:)

module namespace config = "http://exist.bungeni.org/query/config";


(: user defined namespaces :)
declare namespace an = "http://www.akomantoso.org/1.0";

(: collections in the database :)
declare variable $config:bungeni_collection as xs:string := "/db/bungeni";
declare variable $config:data_collection as xs:string  := concat($config:bungeni_collection, "/data");
declare variable $config:transformation_collection as xs:string  := concat($config:bungeni_collection, "/transformation");

(: transformations :)
declare variable $config:handler_results_xslt as xs:string := concat($config:transformation_collection, "/AkomaNtosoURIHandler_results.xslt");

(: file extension for the manifestation package file :)
declare variable $config:manifestation_package_extension as xs:string := "akn";
(: mime type for the manifestation package file :)
declare variable $config:manifestation_package_mimeType as xs:string := "applicatiopn/zip";

(: document types that are versioned, currently only acts :)
declare variable $config:versionedDocumentTypes as xs:QName+ := ( xs:QName("an:act"));