xquery version "3.0";

(:
 : Returns workflows that have been transformed into
 : a validatable XML document
:)

declare namespace zope="http://namespaces.zope.org/zope";
declare namespace db="http://namespaces.objectrealms.net/rdb";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace bungeni="http://namespaces.bungeni.org";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $doc := <data>{collection("/db/configeditor/configs/workflows")}</data>
let $view := xs:string(request:get-parameter("return","none"))
let $xsl := doc('xsl/split_attrs.xsl')
return 
    if ($view eq 'docs') then 
        transform:transform($doc, $xsl, ()) 
    else
       <data>
       {
           for $doc in collection("/db/configeditor/configs/workflows")
           return <name>{util:document-name($doc)}</name>
       }
       </data>
