xquery version "3.0";

(:
 : Returns a form that have been transformed into
 : a validatable XML document
:)

declare namespace zope="http://namespaces.zope.org/zope";
declare namespace db="http://namespaces.objectrealms.net/rdb";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace bungeni="http://namespaces.bungeni.org";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $fname := "custom"
let $input_doc := doc(concat($appconfig:FORM-FOLDER,"/",$fname,".xml"))
(: !+FIX_THIS :)
let $step1 :=  appconfig:get-xslt("/xsl/forms_split_step1.xsl")
let $step2 := appconfig:get-xslt("/xsl/forms_split_step2.xsl")
let $step1_doc := transform:transform($input_doc, $step1,   
                <parameters>
                    <param name="fname" value="{$fname}" />
                </parameters>)
return 
    transform:transform($step1_doc, $step2,())