(:~
:    Copyright  Adam Retter 2008 <adam.retter@googlemail.com>
:    
:    Bungeni URI Utilities
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.0
:)

module namespace uri = "http://exist.bungeni.org/query/util/uri";

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