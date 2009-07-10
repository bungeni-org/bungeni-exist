(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Bungeni Configuration settings
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.2.2
:)

module namespace config = "http://exist.bungeni.org/query/config";


(: user defined namespaces :)
declare namespace an = "http://www.akomantoso.org/1.0";

(: default language :)
declare variable $config:default_language as xs:string := "eng";

(: should we log errors to eXists log as well :)
declare variable $config:log-to-exist_log as xs:boolean := true();

(: standard regexps :)
declare variable $config:date-regexp as xs:string := "(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])";

(: collections in the database :)
declare variable $config:bungeni_collection as xs:string := "/db/bungeni";
declare variable $config:data_collection as xs:string  := concat($config:bungeni_collection, "/data");
declare variable $config:errors_collection as xs:string  := concat($config:bungeni_collection, "/errors");
declare variable $config:transformation_collection as xs:string  := concat($config:bungeni_collection, "/transformation");

(: transformations :)
declare variable $config:handler_results_xslt as xs:string := concat($config:transformation_collection, "/AkomaNtosoURIHandler_results.xslt");

(: file extension for the manifestation package file :)
declare variable $config:manifestation_package_extension as xs:string := "akn";
(: mime type for the manifestation package file :)
declare variable $config:manifestation_package_mimeType as xs:string := "applicatiopn/zip";

(: all document types :)
declare variable $config:document-types as xs:string+ := ("act","debate","report","judgement");

(: document types that are versioned, currently only acts :)
declare variable $config:versionedDocumentTypes as xs:QName+ := ( xs:QName("an:act"));