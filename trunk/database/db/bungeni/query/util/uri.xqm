(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Bungeni URI Utilities
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.2
:)

module namespace uri = "http://exist.bungeni.org/query/util/uri";

import module namespace config = "http://exist.bungeni.org/query/config" at "../config.xqm";

(:~
:    Returns the db Collection URI from a db Resource URI
:
:    @param resourceURI The URI of the resource in the db
:    @return The Collection part of the Resource URI
:)
declare function uri:collectionURIFromResourceURI($resourceURI as xs:string) as xs:string
{
    replace($resourceURI, "(.*)/.*", "$1")
};

(:~
:    Returns the Resource filename from a db Resource URI
:
:    @param resourceURI The URI of the resource in the db
:    @return The filename part of the Resource URI
:)
declare function uri:resourceNameFromResourceURI($resourceURI as xs:string) as xs:string
{
    replace($resourceURI, ".*/", "")
};

(:~
:    Simple Manifestation URI Resolver
:    Given an Akoma Ntoso Manifestation URI the corresponding DB URI is returned
:
:    @param akomantosoURI The Akoma Ntoso Manifestation URI
:    @return the db URI of the Manifestation
:)
declare function uri:ANManifestationURIToDBURI($akomantosoURI as xs:string) as xs:string?
{
    let $uriComponents := tokenize($akomantosoURI, "/") return
        concat(
            $config:data_collection,
            "/",
            $uriComponents[2],
            "/",
            $uriComponents[3],
            "/",
            substring-before($uriComponents[4], "-"),
            "/",
            substring-after($uriComponents[4], "-"),
           
            if(count($uriComponents) gt 4)then
            (
                string-join(
                    for $i in (5 to count($uriComponents)) return
                        concat("_", $uriComponents[$i]),
                    ""
                )
            )else()
        )
};

declare function uri:parse-akn-entry-uri-to-db-uri($akn-entry-uri as xs:anyURI) as xs:string
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

declare function uri:parse-db-uri-to-akn-entry-uri($db-uri as xs:string) as xs:string
{
    (: TODO convert manifestation uri into akn entry uri :)
    let $uri-components := tokenize($db-uri, "/") return
        concat(
           $uri-components[5],
           "_",
           $uri-components[6],
           "_",
           $uri-components[7], "-", $uri-components[8]
        )
};

(:~
:    Adds a version to a Manifestation URI
:    if a version already exists then it is replaced with the value
:    of the version parameter
:    
:    @param manifestationURI The Akoma Ntoso Manifestation URI to add the version to
:    @param version The version to add
:    @return The manifestationURI with the specified version
:)
declare function uri:manifestationURI-with-version($manifestationURI as xs:string, $version as xs:string) as xs:string
{
    if(contains($manifestationURI, "@"))then
    (
        replace($manifestationURI, "(.*)@.*(\..*)", concat("$1@", $version, "$2"))
    )
    else
    (
        replace($manifestationURI, "(.*)(\..*)", concat("$1@", $version, "$2"))
    )
};

(:~
:    Returns an Expression URI given a Manifestation URI
:
:    @param Manifestation URI
:    @return Expression URI
:)
declare function uri:expressionURI-from-manifestationURI($manifestationURI as xs:string) as xs:string
{
    replace($manifestationURI, "(.*)(\.)(.*)", "$1")
};