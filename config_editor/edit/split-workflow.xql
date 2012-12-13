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

let $doctype := xs:string(request:get-parameter("doc","workflow.xml"))
let $path2resource := concat("/db/config_editor/bungeni_custom/workflows/",$doctype)
let $xsl := doc('/db/config_editor/xsl/wf_split_attrs.xsl')
let $doc := doc($path2resource)
return transform:transform($doc, $xsl, <parameters>
                                            <param name="docname" value="{util:document-name($doc)}" />
                                       </parameters>)