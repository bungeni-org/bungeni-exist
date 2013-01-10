xquery version "3.0";

(:
 : Returns workflows that have been transformed into
 : a validatable XML document
:)

import module namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace request = "http://exist-db.org/xquery/request";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";


declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $DOCTYPE := xs:string(request:get-parameter("doc","workflow.xml"))
let $PATH2RESOURCE := $appconfig:WF-FOLDER || $doctype
let $DOC_WF := doc($PATH2RESOURCE)
let $XSL := $appconfig:get-xslt("wf_split_attrs.xsl")
return transform:transform($DOC_WF, 
        $XSL, 
        <parameters>
            <param name="docname" value="{util:document-name($DOC_WF)}" />
       </parameters>)