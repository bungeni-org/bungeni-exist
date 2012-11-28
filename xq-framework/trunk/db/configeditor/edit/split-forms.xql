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

let $doctype := xs:string(request:get-parameter("doc","nothing"))
let $path2resource := concat("/db/configeditor/configs/forms/",$doctype)
let $xsl := doc('/db/configeditor/xsl/forms_split_attrs.xsl')
let $doc := doc($path2resource)
let $fname := substring-before(util:document-name($doc),'.xml')
return transform:transform($doc, $xsl, <parameters>
                                            <param name="fname" value="{$fname}" />
                                       </parameters>)