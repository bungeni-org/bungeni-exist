(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Akoma Ntoso URI Handler
:    
:    Designed to work as a receiver for the Akoma Ntoso URI Resolver
:    written by Luca Cervone and Fabio Vitali of the University of Bologna
:    available from http://akn.web.cs.unibo.it/
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.3.4
:)
xquery version "1.0";

(: eXist function namespaces :)
declare namespace compression = "http://exist-db.org/xquery/compression";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: user defined namespaces :)
declare namespace handler = "http://exist.bungeni.org/query/AkomaNtosoURIHandler";
declare namespace an = "http://www.akomantoso.org/1.0";

(: user defined function modules :)
import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";
import module namespace error = "http://exist.bungeni.org/query/error" at "error.xqm";
import module namespace uri = "http://exist.bungeni.org/query/util/uri" at "util/uri.xqm";



(:~
:    Builds a Collection URI from Akoma Ntoso URI parameters
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @return xs:string of the collection uri
:)
declare function handler:buildCollectionURI($country as xs:string, $type as xs:string, $date as xs:string) as xs:string
{
    concat($config:data_collection, "/", $country, "/", $type, "/", substring-before($date, "-"))
};


(:~
:    Builds a relative Akoma Ntoso Work URI from Akoma Ntoso URI parameters
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @paran $number the number of the document (if any)
:    @return xs:string of the AkomaNtoso Work URI
:)
declare function handler:buildWorkURI($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?) as xs:string
{
    concat("/", $country, "/", $type, "/", $date,
        if($number)then
        (
            concat("/", $number)
        )else()
    )
};


(:~
:    Builds a relative Akoma Ntoso Expression URI from Akoma Ntoso URI parameters
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @param $number the number of the document (if any)
:    @param $language the language of the document
:    @param $version the version of the document (if any)
:    @return xs:string of the Akoma Ntoso Expression URI
:)
declare function handler:buildExpressionURI($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?, $language as xs:string, $version as xs:string?, $component as xs:string*) as xs:string
{
    concat(
        handler:buildWorkURI($country, $type, $date, $number),
        "/",
        $language,
        if($version eq "")then
        (
            (: first version :)
            "@"
        )
        else if($version)then
        (
            (: specific version :)
            concat("@", $version) 
        )
        else
        (
            (: in-force version :)
        ),
        string-join(
            for $c in $component return
                concat("/", $c),
            ""
        )
    )
};


(:~
:    Builds a relative Akoma Ntoso Manifestation URI from Akoma Ntoso URI parameters
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @param $number the number of the document (if any)
:    @param $language the language of the document
:    @param $version the version of the document (if any)
:    @param $component the component of the document (if any)
:    @param $dataformat the dataformat of the document
:    @return xs:string of the Akoma Ntoso Manifestation URI
:)
declare function handler:buildManifestationURI($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?, $language as xs:string, $version as xs:string?, $component as xs:string*, $dataformat as xs:string) as xs:string
{
    concat(handler:buildExpressionURI($country, $type, $date, $number, $language, $version, $component), ".", $dataformat)
};


(:~
:    Returns Expressions of a Work
:
:    Looks up manifestations based on their Work URI
:    and returns the corresponding Expression URI
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @return one or more Expression elements
:)
declare function handler:work($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?) as element(handler:results)?
{   
    (: determine the collection URI :)
    let $collectionURI := handler:buildCollectionURI($country, $type, $date),
    
    (: determine the work uri :)
    $workURI :=  handler:buildWorkURI($country, $type, $date, $number) return
    
        (: return the expressions of the work :)
        element handler:results {
            for $work in collection($collectionURI)/an:akomaNtoso/child::element()[local-name(.) eq $type][an:meta/an:identification/an:FRBRWork/an:FRBRuri/@value eq $workURI] return
                element an:akomaNtoso {    
                    element { concat("an:", $type) } {
                        element an:meta
                        {
                            element an:identification {
                                $work/an:meta/an:identification/an:FRBRExpression        
                            }
                        },
                        element an:preface {
                            $work/an:preface/an:p[an:ActTitle],
                            $work/an:preface/an:p[an:ActPurpose]
                        }
                    }
                }
        }
};


(:~
:    Returns Manifestations of an Expression
:
:    Looks up manifestations based on their Expression URI
:    and returns the corresponding Manifestation URI
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @return one or more Manifestation elements
:)
declare function handler:expression($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?, $lang as xs:string, $version as xs:string?, $component as xs:string*) as element(handler:results)?
{
    (: determine the collection URI :)
    let $collectionURI := handler:buildCollectionURI($country, $type, $date),
    
    (: determine the expression uri :)
    $expressionURI :=  handler:buildExpressionURI($country, $type, $date, $number, $lang, $version, $component) return
    
        (: return details of the expressions and links to the manifestation :)
        element handler:results{
            for $expression in collection($collectionURI)/an:akomaNtoso/child::element()[local-name(.) eq $type][an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value eq $expressionURI] return
                element an:akomaNtoso {    
                    element { concat("an:", $type) } {
                        element an:meta
                        {
                            element an:identification {
                                $expression/an:meta/an:identification/an:FRBRManifestation        
                            }
                        },
                        element an:preface {
                            $expression/an:preface/an:p[an:ActTitle],
                            $expression/an:preface/an:p[an:ActPurpose]
                        }
                    }
                }
        }
};


(:~
:    Returns Manifestations
:
:    Looks up manifestations based on their Manifestation URI
:    and returns the corresponding Manifestation
:
:    @param $country the country code
:    @param $type the document type
:    @param $date the date of the document
:    @return one or more XML Manifestations or if a Binary Manifestation it is streamed directly to the HTTP Response
:)
declare function handler:manifestation($country as xs:string, $type as xs:string, $date as xs:string, $number as xs:string?, $lang as xs:string, $version as xs:string?, $component as xs:string*, $dataformat as xs:string) as element()?
{       
    (: determine the collection URI :)
    let $collectionURI := handler:buildCollectionURI($country, $type, $date),
    
    (: determine the manifestation uri :)
    $manifestationURI :=  handler:buildManifestationURI($country, $type, $date, $number, $lang, $version, $component, $dataformat) return
    
        (: what sort of Manifestation do we want? :)
        if($dataformat eq "xml")then
        (
            (: we want the XML Manifestation, get the xml manifestation :)
            let $xmlManifestation := collection($collectionURI)/an:akomaNtoso[local-name(child::element()[an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value eq $manifestationURI]) eq $type] return
                $xmlManifestation
        )
        else
        (
            (: we want a Binary Manifestation :)
            let $dbManifestationURI := uri:ANManifestationURIToDBURI($manifestationURI) return
        
               (: check for a Manifestation package URI :)
               if($dataformat eq $config:manifestation_package_extension)then
               (
                   (: we want a Manifestation package, so find all suitable manifestations and package them up :)
                
                   let $baseName := substring-before(uri:resourceNameFromResourceURI($dbManifestationURI), ".") return
                
                       (: stream a zip of all relevant resources to the http response :)
                       response:stream-binary(
                           compression:zip(
                               (: get a list of all resources in the collection :)
                               (
                                   for $an-resource in xmldb:get-child-resources($collectionURI)[starts-with(., $baseName)]
                                   let $an-resource-uri := concat($collectionURI, "/", $an-resource) return
                                        <entry name="{uri:parse-db-uri-to-akn-entry-uri($an-resource-uri)}" type="uri">{xs:anyURI($an-resource-uri)}</entry>
                               ),
                               false()
                           ),
                           $config:manifestation_package_mimeType,
                           uri:parse-db-uri-to-akn-entry-uri($dbManifestationURI)
                       )
               )
               else
               (
                   (: we want a specific binary Manifestation file :)
                   
                   (: stream the binary resource to the http response :)
                   response:stream-binary(util:binary-doc($dbManifestationURI), xmldb:get-mime-type(xs:anyURI($dbManifestationURI)), uri:resourceNameFromResourceURI($manifestationURI))
               )
        )
};


declare function handler:process() as element()?
{
    let $uriType := request:get-parameter("uriType",()),
    $country := request:get-parameter("country", ()),
    $type := request:get-parameter("type", ()),
    $date := request:get-parameter("date", ()),
    $number := request:get-parameter("number", ()) (: optional :)
    return
    
        if($uriType = ("work", "expression", "manifestation")) then
        (
            (: check common parameters :)
            if(empty($country)) then
            (
                error:response(concat("MICO", upper-case(substring($uriType, 1, 2)), "0001")) 
            )
            else if(empty($type)) then
            (
                error:response(concat("MITY", upper-case(substring($uriType, 1, 2)), "0001"))
            )
            else if(empty($date)) then
            (
                error:response(concat("MIDT", upper-case(substring($uriType, 1, 2)), "0001"))
            )
            else
            (
                if($uriType eq "work")then
                (
                    handler:work($country, $type, $date, $number)
                )
                else
                (
                    (: optional http params :)
                    let $version := request:get-parameter("version",()),
                    $lang := request:get-parameter("lang",()),
                    $component := request:get-parameter("component", ()) return
                    
                        (: check lang parameter - common to expression and manifestation :)
                        if(empty($lang))then
                        (
                            error:response(concat("MILA", upper-case(substring($uriType, 1, 2)), "0001"))
                        )
                        else
                        (
                            if($uriType eq "expression") then
                            (
                                handler:expression($country, $type, $date, $number, $lang, $version, $component)
                            )
                            else if($uriType eq "manifestation") then
                            (
                                let $dataformat := request:get-parameter("dataformat",()) return
                                    if(empty($dataformat))then
                                    (
                                        error:response("MIDFMA0001")
                                    )
                                    else
                                    (
                                        handler:manifestation($country, $type, $date, $number, $lang, $version, $component, $dataformat)
                                    )
                            )
                            else
                            (
                                error:response("IVDUTY0001")
                            )
                        )
                )
            )
        )
        else
        (
            error:response("IVDUTY0001")
        )
};

(: main entry point - choose a function based on the uri type :)
let $result := handler:process() return
    if(request:get-parameter("output", "xml") eq "xhtml")then
    (
        (: xhtml output :)
        util:declare-option("exist:serialize", "method=xhtml media-type=text/html indent=yes omit-xml-declaration=no doctype-public=-//W3C//DTD&#160;XHTML&#160;1.1//EN doctype-system=http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"),
        transform:transform($result, doc($config:handler_results_xslt), ())
    )
    else
    (
        (: xml output :)
        util:declare-option("exist:serialize", "method=xml media-type=application/xml indent=yes omit-xml-declaration=no"),
        $result
    )