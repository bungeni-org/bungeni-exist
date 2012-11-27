xquery version "3.0";

declare namespace zope="http://namespaces.zope.org/zope";
declare namespace db="http://namespaces.objectrealms.net/rdb";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";

declare namespace request = "http://exist-db.org/xquery/request";

(:let $sortord := xs:string(request:get-parameter("type","none")):)

for $doc in doc('/db/configeditor/configs/sys/db.xml')
return $doc