(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Document Version Editor
:    
:    Designed to work as the server side component
:    for client editing with Open Office
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.2.3
:)
xquery version "1.0";

(: eXist function namespaces :)
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: user defined namespaces :)
declare namespace an = "http://www.akomantoso.org/1.0";

(: user defined function modules :)
import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";
import module namespace db = "http://exist.bungeni.org/query/util/db" at "util/db.xqm";
import module namespace error = "http://exist.bungeni.org/query/error" at "error.xqm";
import module namespace uri = "http://exist.bungeni.org/query/util/uri" at "util/uri.xqm";



(:~
:    Determines whether the document type is versioned
:
:    @param akomantoso The akomantoso node from the xml document, for a binary document use the corresponding xml document
:    @return xs:boolean true() if the documentType is versioned
:)
declare function local:isVersionedDocumentType($akomantoso as element(an:akomaNtoso)+) as xs:boolean
{
    (: node-name($akomantoso/child::node()) = $config:versionedDocumentTypes :)
    $akomantoso/child::node()/node-name(.) = $config:versionedDocumentTypes
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
declare function local:manifestationURIWithVersion($manifestationURI as xs:string, $version as xs:string) as xs:string
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
declare function local:expressionURIFromManifestationURI($manifestationURI as xs:string) as xs:string
{
    replace($manifestationURI, "(.*)(\.)(.*)", "$1")
};

(:~
:    Retreives a document for editing
:
:    Binary documents are returned directly to the user
:    XML documents if they are not versioned are returned directly to the user,
:    if the XML doument is of a versioned type (such as an Act) then the
:    document is adjusted to reflect details of the new version before it is returned to the user.
:
:    @param originalURI The Akoma Ntoso URI of the document to retreive for editing
:    @param versionDate The new version date for the document (only used for XML documents that are a versioned type)
:    @return The XML un-versioned document or otherwise the XML or binary document is streamed directly to the HTTP Response, otherwise an error element
:)
declare function local:edit($originalURI as xs:string, $versionDate as xs:string?) as element()?
{
    (: are we editing a xml or binary document? :)
    if(ends-with($originalURI, ".xml"))then
    (
        (: XML Document :)
        
        (: get the document to edit :)
        let $xmlDoc := collection($config:data_collection)/an:akomaNtoso[child::node()/an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value eq $originalURI] return
        
        (: is the document a versioned type? :)
        if(local:isVersionedDocumentType($xmlDoc))then
        (
            if($versionDate)then
            (
                 (: prepare a new version of the XML document and stream it to the http response :)
                 transform:stream-transform(
                     $xmlDoc,
                     doc(concat($config:transformation_collection, "/editVersionedDocumentType.xslt")),
                     <parameters>
                         <param name="versionDate" value="{$versionDate}"/>
                         <param name="originalURI" value="{$originalURI}"/>
                     </parameters>
                 )
            )
            else
            (
                (: versioned document, but no version provided :)
                error:response("MIVEED0001")
            )
        )
        else
        (
            (: return the un-versioned XML document :)
            $xmlDoc
        )
    )
    else
    (
        (: Binary Document :)
        
        (: stream the binary document to the response :)
        let $dbBinaryDocURI := uri:ANManifestationURIToDBURI($originalURI) return
            response:stream-binary(util:binary-doc($dbBinaryDocURI), xmldb:get-mime-type(xs:anyURI($dbBinaryDocURI)), ())
    )
};

(:~
:    Determines if a document is a valid version
:
:    @param $akomantoso The akomantoso node of the document
:    @param $originalURI The Manifestation URI of the original document of which this is a version
:    @param $versionDate The date of this version
:    @return returns <error>errorCode</error> is its not a valid version
:)
declare function local:isValidVersion($akomantoso as node(), $originalURI, $versionDate as xs:string) as element(error)?
{
    let $originalVersion := doc(uri:ANManifestationURIToDBURI($originalURI)) return

        (:
            2) the <act> container of the new version has a "contains" attribute, this must be set to "SingleVersion"
            <act contains="SingleVersion">
        :)
        if($akomantoso/an:act/@contains eq "singleVersion")then
        (
            (:
                3.1) the Work URI must be the same in the original and new versions 
            :)
            if($akomantoso/an:act/an:meta/an:identification/an:FRBRWork/an:FRBRuri/@value eq $originalVersion/an:akomaNtoso/an:act/an:meta/an:identification/an:FRBRWork/an:FRBRuri/@value)then
            ( 
                (:
                    3.2) the Expression URI must be different in the original and new versions
                :)
                if($akomantoso/an:act/an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value ne $originalVersion/an:akomaNtoso/an:act/an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value)then
                (
                    (:
                    3.3) the Manifestation uri must be different in the original and new versions
                    :)
                    if($akomantoso/an:act/an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value ne $originalVersion/an:akomaNtoso/an:act/an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value)then
                    (
                        (: 
                            3.4 the expression uri must match the new expression uri
                        :)
                        let $newURI := local:manifestationURIWithVersion($originalURI, $versionDate) return
                            if($akomantoso/an:act/an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value eq local:expressionURIFromManifestationURI($newURI))then
                            (
                                (:
                                    3.5 ) the Manifestation uri must match the new uri 
                                :)
                                if($akomantoso/an:act/an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value eq $newURI)then
                                (
                                    (:
                                         4) A reference to the original document must be added in the <references> section of the document...
                                         <references source="#au1">
                                            <Original id="ro1" href="ken/act/1997-08-22/3/en/main" showAs="original"/>
                                        </references>
                                    :)
                                    if($akomantoso/an:act/an:meta/an:references/an:original/@href eq $originalURI)then
                                    (
                                        () (: sucess :)
                                    )
                                    else
                                    (
                                        (: Act documents reference to the original document is invalid :)
                                        <error>IVDORE0001</error>
                                    )
                                )
                                else
                                (
                                    (: Act documents Manifestation uri is invalid :)
                                    <error>IVVMAU0001</error>
                                )
                            )
                        else
                        (
                            (: Act documents Expression uri is invalid :)
                            <error>IVVEXU0001</error>
                        )
                    )
                    else
                    (
                        (: Act documents Manifestation uri is invalid :)
                        <error>IVVMAU0001</error>
                    )
                )
                else
                (
                    (: Act documents Expression uri is invalid :)
                    <error>IVVEXU0001</error>
                )
            )
            else
            (
                (:Act documents Work uri is invalid:)
                <error>IVVWOU0001</error>
            )
        )
        else
        (
            (: Act document is not a single version :)
            <error>IVVESV0001</error>
        )
};

(:~
:    Stores an edited document
:
:    Binary documents are stored and returned to the user
:    XML documents if they are not versioned are stored and returned to the user
:    If the XML doument is of a versioned type (such as an Act) then the
:    document is checked to make sure it is a valid version before it is stored and returned to the user
:
:    @param originalURI The Akoma Ntoso URI of the original document that was edited
:    @param versionDate The new version date of this document (only used for XML documents that are a versioned type or versioned Binary documents)
:    @param data The HTTP POST data, i.e. the document to Save
:    @return The stored XML document or otherwise if a Binary document it is streamed directly to the HTTP Response, otherwise an error element
:)
declare function local:save($originalURI as xs:string, $versionDate as xs:string?, $data as item()?) as node()?
{
    (: check we have a document to save! :)
    if(empty($data))then
    (
        error:response("MIDOED0001")
    )
    else if($data instance of xs:string and xs:string($data) eq "")then
    (
        error:response("MIDOED0001")
    )
    else
    (
        (: are we saving an xml or binary document? :)
        if(ends-with($originalURI, ".xml"))then
        (
            (: XML Document :)
            if(local:isVersionedDocumentType($data//an:akomaNtoso))then (: buggy with in-memory nodes  - SF Bug ID - 1758589 :)
            (: if(node-name($data/child::node()[position() eq 2]) = $config:versionedDocumentTypes)then :) (: temporary work around :)
            (
                if($versionDate)then
                (
                    (: versioned XML document :)
                    let $valid := local:isValidVersion($data, $originalURI, $versionDate) return
                        if(empty($valid))then
                        (
                               (: save the versioned XML document :)
                               let $dbNewXMLDocURI := uri:ANManifestationURIToDBURI(local:manifestationURIWithVersion($originalURI, $versionDate)),
                                    $storedURI := xmldb:store(
                                        uri:collectionURIFromResourceURI($dbNewXMLDocURI),
                                        uri:resourceNameFromResourceURI($dbNewXMLDocURI),
                                        $data
                                    ) return
                                    
                                        (: return the stored document :)
                                        doc($storedURI)
                        )
                        else
                        (
                            error:response($valid)
                        )
                )
                else
                (
                    (: versioned document, but no version provided :)
                    error:response("MIVEED0001")
                )
            )
            else
            (
                (: save the un-versioned XML document :)
                let $dbNewXMLDocURI := uri:ANManifestationURIToDBURI($originalURI),
                    $storedURI := xmldb:store(
                        uri:collectionURIFromResourceURI($dbNewXMLDocURI),
                        uri:resourceNameFromResourceURI($dbNewXMLDocURI),
                        $data
                    ) return
                    
                        (: return the stored document :)
                        doc($storedURI)
            )
        )
        else
        (
            (: Binary Document :)
            let $dbOriginalBinaryDocURI := uri:ANManifestationURIToDBURI($originalURI) return
            
            (: determine the db uri for storing the binary document :)
            let $dbNewBinaryDocURI := if($versionDate)then
                (
                    (: new binary versioned document :)
                    uri:ANManifestationURIToDBURI(local:manifestationURIWithVersion($originalURI, $versionDate))
                )
                else
                (
                    (: un-versioned binary document :)
                    $dbOriginalBinaryDocURI
                )
            return
                
                (: store the document :)
                let $storedURI := xmldb:store(
                        uri:collectionURIFromResourceURI($dbNewBinaryDocURI),
                        uri:resourceNameFromResourceURI($dbNewBinaryDocURI),
                        $data,
                        xmldb:get-mime-type(xs:anyURI($dbOriginalBinaryDocURI))
                ) return
                
                    (: return the stored document :)
                    response:stream-binary(util:binary-doc($storedURI), xmldb:get-mime-type(xs:anyURI($storedURI)),())
        )
    )
};

(:~
:    Stores a new document
:
:    Currently this only supports XML documents
:    The expression uri in the document is checked against the provided Akoma Ntoso URI
:    If the document already exists then an error is thrown.
:
:    @param newURI The Akoma Ntoso URI for the new document
:    @param data The HTTP POST data, i.e. the document to Save
:    @return The stored XML document or otherwise an error element
:)
declare function local:new($newURI as xs:string, $data) as node()
{
    (: check the expression uri matches the suggested uri :)
    if($data/child::node()/an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value eq local:expressionURIFromManifestationURI($newURI))then
    (
        let $dbNewXMLDocURI := uri:ANManifestationURIToDBURI($newURI) return
        
            (: check the document does not already exist in the db :)
            if(doc-available($dbNewXMLDocURI))then
            (
                (: Document already exists in the database, should not overwrite! :)
                error:response("EXDODB0001")
            )
            else
            (
                (: create an appropriate collection (if needed) :)
                let $collectionPath := uri:collectionURIFromResourceURI($dbNewXMLDocURI), 
                $null := db:createCollectionsFromPath($collectionPath),
            
                (: store the document :)
                $storedURI := xmldb:store(
                    $collectionPath,
                    uri:resourceNameFromResourceURI($dbNewXMLDocURI),
                    $data
                ) return
                
                    (: return the stored document :)
                    doc($storedURI)
            )
    )
    else
    (
        (: expression uri in the document does not correspond to the provided manifestation uri :)
        error:response("EXUMAU0001")
    )
};


(: main entry point - choose a function based on the uri :)
if(request:get-parameter("action",()) eq "save" and request:get-parameter("uri",())  and request:get-method() eq "POST")then
(
    (: save an edited document, document should be in the POST body :)
    local:save(request:get-parameter("uri",()), request:get-parameter("version",()), request:get-data())
)
else if(request:get-parameter("action",()) eq "new" and request:get-parameter("uri",()) and request:get-method() eq "POST")then
(
    (: create a new document, document should be in the POST body :)
    local:new(request:get-parameter("uri",()), request:get-data())
)
else
(
    if(request:get-parameter("uri",()))then
    (
        (: edit a document :)
        local:edit(request:get-parameter("uri",()), request:get-parameter("version",()))
    )
    else
    (
        error:response("MIDUED0001")
    )
)