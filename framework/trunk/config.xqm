xquery version "1.0";

(: Adapted code from http://seewhatithink.sourceforge.net/ by Adam Retter :)

module namespace config = "http://bungeni.org/xquery/config";

declare variable $config:db-root-collection := "/db";
declare variable $config:xml-collection := fn:concat($config:db-root-collection, "/lex");
declare variable $config:xml-ontology-collection := fn:concat($config:xml-collection, "/ontology");


