(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Expands and stores a .akn package in the database
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.1.1
:)
xquery version "1.0";

(: eXist function namespaces :)
declare namespace dbstore = "http://exist-db.org/xquery/db";
declare namespace compression = "http://exist-db.org/xquery/compression";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: user defined function modules :)
import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";
import module namespace db = "http://exist.bungeni.org/query/util/db" at "util/db.xqm";
import module namespace error = "http://exist.bungeni.org/query/error" at "error.xqm";
import module namespace uri = "http://exist.bungeni.org/query/util/uri" at "util/uri.xqm";


declare function local:parse-akn-entry-uri-to-db-uri($akn-entry-uri as xs:anyURI) as xs:string
{
    let $uri-components := tokenize($akn-entry-uri, "_") return
        concat(
            $config:data_collection,
            "/",
            $uri-components[1],
            "/",
            $uri-components[2],
            "/",
            substring-before($uri-components[3], "-"),
            "/",
            substring-after($uri-components[3], "-"),
            
            string-join(
                for $i in (4 to count($uri-components)) return
                    concat("_", $uri-components[$i]),
                ""
            )
    )
};

declare function local:akn-entry-data($entry-name as xs:anyURI, $entry-type as xs:string, $entry-data as item()?) as xs:string?
{
    if($entry-type eq "resource")then
    (
        let $db-uri := local:parse-akn-entry-uri-to-db-uri($entry-name) return
            let $new-collection-paths := db:createCollectionsFromPath(uri:collectionURIFromResourceURI($db-uri)) return
   
                let $collection-uri := uri:collectionURIFromResourceURI($db-uri),
                $resource-uri := uri:resourceNameFromResourceURI($db-uri),
                $resource-mime-type := xmldb:get-mime-type(xs:anyURI(concat("zip://", $entry-name))) return
   
                    ( util:log("debug", concat("db-uri=", $db-uri)),
                        xmldb:store($collection-uri, $resource-uri, $entry-data, $resource-mime-type)
                    )
    )else()
};

declare function local:is-valid-akn-entry-uri($akn-entry-uri as xs:anyURI) as xs:boolean
{
    (: e.g. ke_act_1980-01-01_1_eng@1989-12-15_main.xml :)
    
    let $akn-entry-regexp := concat(
        "^[a-z]{2}_",
        "(", string-join($config:document-types, "|"), ")",
        "_(", $config:date-regexp, ")",
        "(_[0-9999])?",
        "_[a-z]{3}",
        "(@", $config:date-regexp, ")?",
        "(_[a-z0-9]*)?",
        "\.", "[a-z0-9]{3,5}$"
    ) return
        
        (:( util:log("debug", concat("REGEXP=",$akn-entry-regexp)),
        matches($akn-entry-uri, $akn-entry-regexp)
        ):)
        let $result := matches($akn-entry-uri, $akn-entry-regexp),
            $null := util:log("debug", concat("MATCHES=", $result)) return
                $result
};

declare function local:akn-entry-filter($entry-name as xs:anyURI, $entry-type as xs:string) as xs:boolean
{
    let $null := util:log("debug", concat("entry-name=", $entry-name)) return

    if($entry-type eq "resource")then
    (
        local:is-valid-akn-entry-uri($entry-name)
    )
    else
    (
        false()
    )
};

declare function local:store-package($data as item()?) as element()
{
    (: check we have received a package! :)
    if(empty($data))then
    (
        error:response("MIPKST0001")
    )
    else if($data instance of xs:string and xs:string($data) eq "")then
    (
        error:response("IVPKST0001")
    )
    else if(not($data instance of xs:base64Binary))then
    (
        error:response("IVPKST0002")
    )
    else
    (
        
        (:
        (# dbstore:transaction #) {
        :)
        
            let $stored-entries := compression:unzip($data, util:function(xs:QName("local:akn-entry-filter"), 2), util:function(xs:QName("local:akn-entry-data"), 3)) return
        (:
        }
        :)
        
            (: check the stored paths eXist (due to hlt), then return desired result :)
            let $missing-entries := for $stored-entry in $stored-entries return
                if(doc-available($stored-entry))then
                ()
                else
                (
                    $stored-entry
                )
            return
                
                if(empty($missing-entries))then
                (
                    (: OK :)
                    <extracted>
                    {
                        for $stored-entry in $stored-entries return
                            <entry>{$stored-entry}</entry>
                    }
                    </extracted>
                )
                else
                (
                    (: FAIL :)
                    error:response("FAPKST0001")
                )
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