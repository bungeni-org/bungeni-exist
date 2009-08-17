(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Bungeni Configuration settings
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.0
:)

module namespace db = "http://exist.bungeni.org/query/util/db";

declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace util = "http://exist-db.org/xquery/util";

import module namespace uri = "http://exist.bungeni.org/query/util/uri" at "uri.xqm";

(:~
:    Recursively creates collections to create a collection matching the provided path
:
:    @param collectionPath
:    @return The sequence of collection paths created
:)
declare function db:createCollectionsFromPath($collectionPath as xs:string) as xs:string*
{
    if(xmldb:collection-exists($collectionPath))then
    ()
    else
    (
        let $parentCollection := uri:collectionURIFromResourceURI($collectionPath),
        $collectionName : = uri:resourceNameFromResourceURI($collectionPath) return
        
            if(xmldb:collection-exists($parentCollection))then
            (
                (: creates the root collection :)
                xmldb:create-collection($parentCollection, $collectionName)
            )
            else
            (
                (: creates parent and self collection(s) :)
                db:createCollectionsFromPath($parentCollection),
                xmldb:create-collection($parentCollection, $collectionName)
            )
        )
};