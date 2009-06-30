(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Expands and stores a .akn package in the database
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.0
:)
xquery version "1.0";

(: eXist function namespaces :)
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace compression = "http://exist-db.org/xquery/compression";

(: user defined function modules :)
import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";
import module namespace error = "http://exist.bungeni.org/query/error" at "error.xqm";


declare function local:store-package($data as item()?) (: TODO what is the return type? :)
{
    (: check we have received a package! :)
    if(empty($data))then
    (
        error:response("MIPKST0001")
    )
    else if($data instance of xs:string and xs:string($data) eq "")then
    (
        error:response("INPKST0001")
    )
    else if(not($data instance of xs:base64Binary))then
    (
        error:response("INPKST0001")
    )
    else
    (
        (: TODO :)
    )
};

(: main entry point - choose a function based on the uri :)
if(request:get-parameter("action", ()) eq "store" and request:get-method() eq "POST")then
(
    local:store-package(request:get-data())
)
else
(
    error:response("UNKNAC0001")
)