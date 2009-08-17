(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Query Interface for Bungeni Documents
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.1
:)
xquery version "1.0";

(: eXist function namespaces :)
declare namespace request = "http://exist-db.org/xquery/request";

(: user defined namespaces :)
declare namespace query = "http://exist.bungeni.org/query/query";
declare namespace an = "http://www.akomantoso.org/1.0";

(: user defined function modules :)
import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";
import module namespace error = "http://exist.bungeni.org/query/error" at "error.xqm";
import module namespace uri = "http://exist.bungeni.org/query/util/uri" at "util/uri.xqm";

declare function local:list-components($uri as xs:string) as element(query:match)*
{
    let $components := collection($config:data_collection)/an:akomaNtoso/child::element()/an:meta/an:identification/(an:FRBRWork|an:FRBRExpression|an:FRBRManifestation)[an:FRBRuri/@value eq $uri]/an:components return
            
            for $doc-components in $components return
                <query:match an-manifestation-uri="{$doc-components/ancestor::an:identification/an:FRBRManifestation/an:FRBRthis/@value}" db-uri="{document-uri(root($doc-components))}">{ $doc-components }</query:match>
};


(: main entry point - choose a function based on the uri :)
if(request:get-parameter("action", ()) eq "list-components" and request:get-parameter("uri",()))then
(
    <query:query>
        <query:request>
            <query:action>{request:get-parameter("action",())}</query:action>
            <query:params>
                <an:uri>{request:get-parameter("uri",())}</an:uri>
            </query:params>
        </query:request>
        <query:start time="{current-dateTime()}"/>
        <query:results>
        {
            local:list-components(request:get-parameter("uri",()))
        }
        </query:results>
        <query:end time="{current-dateTime()}"/>
    </query:query>
)
else
(
    error:response("UNKNAC0001")
)