xquery version "3.0";

declare namespace zope="http://namespaces.zope.org/zope";
declare namespace db="http://namespaces.objectrealms.net/rdb";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace bungeni="http://namespaces.bungeni.org";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

<data>{collection("/db/configeditor/configs/workspace")}</data>
