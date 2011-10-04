xquery version "1.0";

(: 
Adapted code from http://seewhatithink.sourceforge.net/ by Adam Retter 
:)

module namespace config = "http://bungeni.org/xquery/config";

(: The db root :)
declare variable $config:db-root-collection := "/db";
(: Which xml collection to query ? :)
declare variable $config:xml-collection := fn:concat($config:db-root-collection, "/kenyalex");
(: Framework files :)
declare variable $config:fw-root := fn:concat($config:db-root-collection, "/framework");
(: Application files :)
declare variable $config:app-prefix := "bungeni/";
(: Application root :)
declare variable $config:fw-app-root := fn:concat($config:fw-root, "/", $config:app-prefix);
(: Ontology files :)
declare variable $config:xml-ontology-collection := fn:concat($config:xml-collection, "/ontology");


