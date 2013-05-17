xquery version "3.0";

module namespace bun = "http://exist.bungeni.org/bun";
(:import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";:)
import module namespace i18n = "http://exist-db.org/xquery/i18n" at "../i18n.xql";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace xps="http://www.w3.org/2005/xpath-functions";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";
import module namespace functx = "http://www.functx.com" at "../functx.xqm";
import module namespace scriba = "http://scribaebookmake.sourceforge.net/1.0/" at "../scriba.xqm";
(:import module namespace vdex = "http://www.imsglobal.org/xsd/imsvdex_v1p0" at "vdex.xqm";:)
import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo="http://exist-db.org/xquery/xslfo"; 
import module namespace json="http://www.json.org";

declare namespace epub="http://exist-db.org/xquery/epub";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace bu="http://portal.bungeni.org/1.0/";


(:
Library for common lex functions
uses bungenicommon
:)

(:~
Default Variables
:)
declare variable $bun:SORT-BY := 'bu:statusDate';

declare variable $bun:SERVER-URL := "http://" || $template:SERVER-NAME || ":" || $template:SERVER-PORT || "/exist/apps";

declare variable $bun:OFF-SET := 0;
declare variable $bun:LIMIT := cmn:get-listings-config-limit();
declare variable $bun:VISIBLEPAGES := cmn:get-listings-config-visiblepages();
declare variable $bun:DOCNO := "NULL";

(:
declare function bun:translate($node as node(), $params as element(parameters)?, $model as item()*) {
    let $selectedLang := $params/param[@name = "lang"]/@value
    let $catalogues := $params/param[@name = "catalogues"]/@value
    let $cpath :=
        (: if path to catalogues is relative, resolve it relative to the app root :)
        if (starts-with($catalogues, "/")) then
            $catalogues
        else
            concat($config:app-root, "/", $catalogues)
    let $translated :=
        i18n:process($node/*, $selectedLang, $cpath, ())
    return
        element { node-name($node) } {
            $node/@*,
            templates:process($translated, $model)
        }
};
:)

(:~
    Service for checking status of file before update eXist repository
    @param uri
        Document URI
    @param statusdate
        The status date in the document
        
    @return <response>
                <status>overwrite|new|ignore</status>
            </response>
:)
declare function bun:check-update($uri as xs:string, $statusdate as xs:string) {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    (: !+TODO (ao, 2-May-2012) Currently some documents have @internal-uri this, has to be factored into 
    this checker :)
    (: let $docitem := collection(cmn:get-lex-db())/bu:ontology/child::*[@uri=$uri, @internal-uri=$uri]/ancestor::bu:ontology :)
    let $docitem := (for $i in collection(cmn:get-lex-db())/bu:ontology/child::*[if (@uri) then (@uri=$uri) else (@internal-uri=$uri)]/ancestor::bu:ontology return $i)[1]
    let $doc := <response>        
        {
            if($docitem) then (
                if($statusdate eq "") then 
                    (:  Means no `bu:statusDate` node in the external document, default is to overwrite  
                        repository version 
                    :)
                    <status>overwrite</status>
                else if(xs:dateTime($docitem/child::*/bu:statusDate) lt $statusdate cast as xs:dateTime) then 
                    (: Means eXist version of the doc is old... do replace by all means :)
                    <status>overwrite</status>
                else
                    (: Ambiguous scenario, ignore :)
                    <status>overwrite</status>
            )
            else
                (: Not found on eXist :)
                <status>new</status>
        }
        </response>   
        
    return $doc
};

(:~
:  Renders PDF output for parliamentary document using xslfo module
    @param controller contains context and parliament information
    @param docid
    @param views used to acculute all the tabs of this document
:   The URI of the document
:
: @return
:   A PDF document for download
:)
declare function bun:gen-pdf-output($controller as node()?, $docid as xs:string)
{
    (: stylesheet to transform :) 
    let $stylesheet := cmn:get-xslt('xsl/xhtml2fo.xsl') 
    let $server-path := $bun:SERVER-URL || $controller/exist-cont/text() || "/" || $controller/parliament/type/text()
    let $base := $bun:SERVER-URL || $controller/exist-cont/text()
    let $font-path := $bun:SERVER-URL || $controller/exist-cont/text() || "/assets/fonts/"
    let $fop-config :=  local:fop-config($base, $font-path)

    let $doc := collection(cmn:get-lex-db())/bu:ontology/bu:document[if (@uri) then (@uri=$docid) else (@internal-uri=$docid)]/ancestor::bu:ontology
    let $title := $doc/bu:document/bu:title  
    let $doc-type := $doc/bu:document/bu:docType/bu:value
    let $views := cmn:get-views-for-type($doc-type)    
    
    let $lang := template:set-lang()    
    let $orientation := local:get-orientation($lang)

    let $pages := local:generate-pages($doc,$views,$lang,$orientation/xh/text())
    
    let $xhtml := <html xmlns="http://www.w3.org/1999/xhtml" xmlns:i18n="http://exist-db.org/xquery/i18n" xml:lang="{$lang}">
                    <head>
                        <title>{$title}</title>
                    </head>
                    <body>    
                        {$pages}
                    </body>
                  </html>  
    
    let $transformed := transform:transform($xhtml,$stylesheet, <parameters>
                                                                    <param name="base-url" value="{$server-path}"/>
                                                                    <param name="writing-mode" value="{$orientation/fo/text()}"/>
                                                                </parameters>)
    let $pdf := xslfo:render($transformed, "application/pdf", <parameters>
                                                                <param name="keywords" value="Parlimentary, document"/>
                                                            </parameters>,
                                                            $fop-config)
          
    let $output-nolang := functx:substring-before-last($docid, '/')
    let $output := concat(replace(substring-after($output-nolang, '/'),'/','-'),"-",$lang,".pdf")
    (: 
    Set the content disposition header with the file name and the return type as attachment 
    For some odd reason return the response stream binary fails the request, i have to send
    a valid xml document as the last thing returned from the response
    :) 
    let $header := 
        response:set-header("Content-Disposition" , concat("attachment; filename=",  $output)) 
    let $out := response:stream-binary($pdf, "application/pdf")     
    return <xml />    
    
};

(:~
:  Renders ePUB output for parliamentary document using scriba module
: @param docid
:   The URI of the document
:
: @return
:   A ePUB document
:)
declare function bun:gen-epub-output($exist-cont as xs:string, $docid as xs:string)
{
    let $doc := collection(cmn:get-lex-db())/bu:ontology/bu:document[if (@uri) then (@uri=$docid) else (@internal-uri=$docid)]/ancestor::bu:ontology
    let $title := $doc/bu:document/bu:title
    let $doc-type := $doc/bu:document/bu:docType/bu:value
    let $views := cmn:get-views-for-type($doc-type)
    
    let $lang := template:set-lang()
    let $orientation := local:get-orientation($lang)
    
    let $pages := local:generate-pages($doc,$views,$lang,$orientation/xh/text())
    
    (: creating unique output filename based on URI and active LANGUAGE :)    
    let $output-nolang := functx:substring-before-last($docid, '/')
    let $output := concat(replace(substring-after($output-nolang, '/'),'/','-'),"-",$lang,".epub")
    
    let $authors := <creators>
                        <creator role="aut">{data($doc/bu:document/bu:owner/bu:person/@showAs)}</creator>
            {
                for $signatory in $doc/bu:signatories/bu:signatory
                    return 
                        <creator role="edt">{data($signatory/bu:person/@showAs)}</creator>
            }</creators>    
                
    let $pages-abs-links := template:re-write-paths($exist-cont,$pages)
    let $book := scriba:create-book($lang,$orientation/xh/text(),$title,$authors,$pages-abs-links)
        
    let $epub := epub:scriba-ebook-maker($book)
    let $header := response:set-header("Content-Disposition" , concat("attachment; filename=",  $output)) 
    let $out := response:stream-binary($epub, "application/epub+zip")     
    return <xml />     
    
};


declare function local:generate-pages($doc as node()?, 
                            $views as node(), 
                            $lang as xs:string,
                            $orientation as xs:string) {
    
    (: for timeline :)
    let $timeline-doc := bun:get-ref-timeline-activities($doc,<doc/>)
    (: iterate the views with @tab and create all the html views to be rendered :)
    let $pages := <div>{
        for $view in $views/view[@tag eq 'tab']
            return
                if (data($view/@id) eq 'timeline') then (
                    <div dir="{$orientation}" id="i18n({$view/title/i18n:text/@key},chapter)">{
                        transform:transform($timeline-doc, cmn:get-xslt($view/xsl), 
                                                <parameters>
                                                    <param name="epub" value="true" />
                                                </parameters>)
                     }</div>
                 )
                 else (
                    <div dir="{$orientation}" id="i18n({$view/title/i18n:text/@key},chapter)">{
                        transform:transform(<doc>{$doc}</doc>, cmn:get-xslt($view/xsl), 
                                                <parameters>
                                                    <param name="epub" value="true" />
                                                </parameters>)
                     }</div>                 
                 )
         }</div>
         
      let $pages-i18n := i18n:process($pages, $lang, $config:I18N-MESSAGES, $config:DEFAULT-LANG)
      return
        $pages-i18n
};

declare function local:get-orientation($lang as xs:string) {

    let $lang-node := cmn:get-langs-config()/languages/language[@id=$lang]
    let $orientation := if(xs:boolean(data($lang-node/@rtl))) then 
                            <orient>
                                <fo>rl-tb</fo>
                                <xh>rtl</xh>
                            </orient>
                       else
                            <orient>
                                <fo>lr-tb</fo>
                                <xh>ltr</xh>
                           </orient> 
    return
        $orientation
};

(:~
:  streams the attachment with the given id
: @param acl 
:   permissions scheme allowed for this file
: @param uri 
:   for thi document
: @param attid 
:   file id of the attachment as defined
: @return
:   A document for download with original name and extension and correct mimeType
:)
declare function bun:get-attachment($acl as xs:string, $uri as xs:string, $attid as xs:integer) {
    
    (: get the document through acl as validation :)
    let $acl-permissions := cmn:get-acl-permissions($acl)
    let $att-acl := bun:documentitem-full-acl($acl, $uri,"NULL")   

    (: get the attachment with the given file id :)
    for $attachedfile in $att-acl/bu:attachments/bu:attachment
    return
        if($attachedfile/bu:attachmentId cast as xs:integer eq $attid) then (
            response:stream-binary(
                util:binary-doc(concat(cmn:get-att-db(),'/',$attachedfile/bu:attachmentHash)) cast as xs:base64Binary,
                $attachedfile/bu:mimetype/bu:value,
                $attachedfile/bu:name),
            response:set-header("Content-Disposition" , concat("attachment; filename=",  $attachedfile/bu:name)),
            <xml/>
        )
        else () 
};

declare function bun:get-image($hash as xs:string, $name as xs:string) {

    (: get the image with the given hash from the bungeni-atts folder :)
    let $imgpath := cmn:get-att-db() || "/" || $hash
    let $placeholder := $config:fw-root || "/bungeni/assets/images/placeholder.jpg"
    return
        if($hash eq 'none') then (
            response:stream-binary(util:binary-doc($placeholder) cast as xs:base64Binary, "media-type=image/jpeg"),
            response:set-header("Content-Disposition" , concat("inline; filename=",  "placeholder.jpg")),
            <xml/>        
        )
        else
        (
            response:stream-binary(util:binary-doc($imgpath) cast as xs:base64Binary, "media-type=image/jpeg"),
            response:set-header("Content-Disposition" , concat("inline; filename=",  $name)),
            <xml/>
        )
};

(:
    fop-configuration node
:)
declare function local:fop-config($base as xs:string, $font-path as xs:string) {
    
    (: fop-base - this is prepended on @src of all the <img/> elements in the documents /> :)
    <fop version="1.1">
        <base>{$base}</base>   
        <font-base>{$font-path}</font-base>
        <renderers>
            <renderer mime="application/pdf">
                <filterList>
                    <value>null</value>
                </filterList>
                <fonts>
                    <font embed-url="Arial.ttf" embedding-mode="full">
                        <font-triplet name="Arial" style="normal" weight="normal"/>
                    </font>
                    <font embed-url="Arial_Bold.ttf" embedding-mode="full">
                        <font-triplet name="Arial" style="normal" weight="bold"/>
                    </font>   
                    <font embed-url="Arial_Bold_Italic.ttf" embedding-mode="full">
                        <font-triplet name="Arial" style="italic" weight="bold"/>
                    </font>                                        
                </fonts>
            </renderer>
        </renderers>   
    </fop>

};

(:~
:  Renders PDF output for MP profile using xslfo module
: @param memberid
:   The URI of the parliamentary user
: @return
:   A PDF document for download
:)
declare function bun:gen-member-pdf($controller as node()?,$memberid as xs:string) {

    (: stylesheet to transform :) 
    let $stylesheet := cmn:get-xslt('xsl/xhtml2fo.xsl') 
    let $server-path := $bun:SERVER-URL || $controller/exist-cont/text() || "/" || $controller/parliament/type/text()
    let $base := $bun:SERVER-URL || $controller/exist-cont/text()
    let $font-path := $bun:SERVER-URL || $controller/exist-cont/text() || "/assets/fonts/"
    let $fop-config :=  local:fop-config($base, $font-path)

    let $lang := template:set-lang()    
    let $orientation := local:get-orientation($lang)

    let $member-doc := collection(cmn:get-lex-db())/bu:ontology/bu:membership[@uri=$memberid]/ancestor::bu:ontology
        
    let $title := $member-doc/bu:membership/bu:title
    let $doc-type := $member-doc/bu:membership/bu:docType/bu:value/text() 
    let $user-uri := data($member-doc/bu:membership/bu:referenceToUser/bu:refersTo/@href)
    let $views := cmn:get-views-for-type($doc-type)

    let $doc := <doc>
                    {$member-doc}
                    <ref>
                    {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$user-uri][1]/ancestor::bu:ontology}
                    </ref>
                </doc>
                
    let $pages := <div>{
        for $view in $views/view[@tag eq 'tab']
            return
                if (data($view/@id) eq 'member') then (
                    <div dir="{$orientation}" id="i18n({$view/title/i18n:text/@key},chapter)">{
                        transform:transform($doc, cmn:get-xslt($view/xsl), 
                                                <parameters>
                                                    <param name="epub" value="true" />
                                                    <param name="chamber" value="{$controller/parliament/type/text()}" />
                                                    <param name="chamber-id" value="{$controller/parliament/identifier/text()}" />
                                                </parameters>)
                     }</div>
                 )
                else if (data($view/@id) eq 'biographical') then (
                    <div dir="{$orientation}" id="i18n({$view/title/i18n:text/@key},chapter)">{
                        transform:transform($doc, cmn:get-xslt($view/xsl), 
                                                <parameters>
                                                    <param name="epub" value="true" />
                                                    <param name="chamber" value="{$controller/parliament/type/text()}" />
                                                    <param name="chamber-id" value="{$controller/parliament/identifier/text()}" />
                                                </parameters>)
                     }</div>
                 )                 
                 else ()
         }</div>
     
    let $pages-i18n := i18n:process($pages, $lang, $config:I18N-MESSAGES, $config:DEFAULT-LANG)
    
    let $xhtml := <html xmlns="http://www.w3.org/1999/xhtml" xmlns:i18n="http://exist-db.org/xquery/i18n" xml:lang="{$lang}">
                    <head>
                        <title>{$title}</title>
                    </head>
                    <body>    
                        {$pages-i18n}
                    </body>
                  </html>
    
    let $transformed := transform:transform($xhtml,$stylesheet, <parameters>
                                                                    <param name="base-url" value="{$server-path}"/>
                                                                    <param name="writing-mode" value="{$orientation/fo/text()}"/>
                                                                </parameters>)
    let $pdf := xslfo:render($transformed, "application/pdf", <parameters>
                                                                <param name="keywords" value="Parlimentary, document"/>
                                                            </parameters>,
                                                            $fop-config)    
    
    let $header := 
        response:set-header("Content-Disposition" , concat("attachment; filename=",  "output.pdf"))  
    
    let $out := response:stream-binary($pdf, "application/pdf")     
    
    return <xml />     
};

declare function bun:get-all-by-role($roles-string as xs:string) as node()* {

    let $eval-query :=  fn:concat("collection('",cmn:get-lex-db() ,"')",
                        (: the first node in root element has the documents main permission :)
                        "/bu:ontology/child::node()[1]/bu:permissions",
                        "[",$roles-string,"]/ancestor::bu:ontology")
    return 
        util:eval($eval-query)   

};

(:~
:   Generates a xquery string with applied permissions
: @param acl
:   permission type
: @return
:   A string with embedded permissions ready for evaluation.
:)
declare function bun:xqy-all-documentitems-with-acl($acl as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    
    (:~ !+FIX_THIS_WARNING - parameterized XPath queries are broken in eXist 1.5 dev, converted this to an EVAL-ed query to 
    make it work - not query on the parent axis i.e./bu:ontology[....] is also broken - so we have to use the ancestor axis :)
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@for='document']",
                "/bu:document/(bu:permissions except bu:versions)",
                "/bu:control[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

(:~
:   Generates a xquery string with applied permissions
: @param acl
:   permission type
: @param type
:   document type 
: @return
:   A string with embedded permissions ready for evaluation.
:)
declare function bun:xqy-list-documentitems-with-acl($chamber-id as xs:string, $acl as xs:string, $type as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    
    (:~ !+FIX_THIS_WARNING - parameterized XPath queries are broken in eXist 1.5 dev, converted this to an EVAL-ed query to 
    make it work - not query on the parent axis i.e./bu:ontology[....] is also broken - so we have to use the ancestor axis :)
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:document/bu:docType[bu:value eq '",$type,"']",
                "/ancestor::bu:document[bu:origin/bu:identifier eq '",$chamber-id,"']",
                "/(bu:permissions except bu:versions)",
                "/bu:control[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-list-documentitems-with-acl-n-tabs($chamber-id as xs:string?, 
                                                            $acl as xs:string, 
                                                            $type as xs:string, 
                                                            $tag as xs:string) {
    let $acl-filter := cmn:get-acl-permission-as-attr($acl),
        $list-tabs :=  cmn:get-listings-config($type)[@id eq $tag]/text()
    
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:document[bu:origin/bu:identifier eq '",$chamber-id,"']",
                "/bu:docType[bu:value eq '",$type,"']",
                "/ancestor::bu:document/(bu:permissions except bu:versions)",
                "/bu:control[",$acl-filter,"]",
                "/ancestor::bu:ontology/bu:bungeni[",$list-tabs,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-search-legis-with-acl($acl as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:document",
                "/(bu:permissions except bu:versions)",
                "/bu:control[",$acl-filter,"]",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-list-groupitem($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:group[@type='",$type,"']",
                "/ancestor::bu:ontology")
};

declare function bun:xqy-list-groupitems-with-tabs($chamber as xs:string?, $type as xs:string, $status as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:group[bu:origin/bu:identifier eq '",$chamber,"' and bu:docType/bu:value eq '",$type,"' and bu:status/bu:value eq '",$status,"']",
                "/ancestor::bu:ontology")
};

declare function bun:list-groupitems-with-tabs($chamber as xs:string?, $type as xs:string, $status as xs:string) {

    let $eval-query := bun:xqy-list-groupitems-with-tabs($chamber, $type, $status)
    return 
        util:eval($eval-query)
};


declare function bun:xqy-search-group() {

    fn:concat("collection('",cmn:get-lex-db() ,"')","/bu:ontology[@for='group']")
};

declare function bun:xqy-list-membership($type as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:membership/bu:docType[bu:value eq 'Member']",
                "/ancestor::bu:ontology")
};


declare function bun:xqy-list-membership-with-tabs($chamber as xs:string?, $type as xs:string, $status as xs:string) {

    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology/bu:membership[bu:origin/bu:identifier eq '",$chamber,"' and ",$status,"]",
                "/bu:docType[bu:value eq 'Member']",
                "/ancestor::bu:ontology")
};

declare function bun:list-membership($eval-query as xs:string, $sortby as xs:string) {

        if ($sortby = 'ln_desc') then (
        
            for $match in util:eval($eval-query)
            order by $match/bu:membership/bu:lastName descending
            return 
                $match    
        )
        else if ($sortby = 'ln_asc') then (
            for $match in util:eval($eval-query)
            order by $match/bu:membership/bu:lastName ascending
            return 
                $match        
        )                 
        else if ($sortby = 'fn_desc') then (
            for $match in util:eval($eval-query)
            order by $match/bu:membership/bu:firstName descending
            return 
                $match       
        )  
        else if ($sortby = 'fn_asc') then (
            for $match in util:eval($eval-query)
            order by $match/bu:membership/bu:firstName ascending
            return 
                $match       
        )                 
        else  (
            for $match in util:eval($eval-query)
            order by $match/bu:membership/bu:lastName descending
            return 
                $match        
        )
};


declare function bun:list-membership-with-tabs($chamber as xs:string?, $type as xs:string, $status as xs:string, $sortby as xs:string) {
    
    let $eval-query := bun:xqy-list-membership-with-tabs($chamber, $type, $status)

    return 
    if ($sortby = 'ln_desc') then (
    
        for $match in util:eval($eval-query)
        order by $match/bu:membership/bu:lastName descending
        return 
            $match    
    )
    else if ($sortby = 'ln_asc') then (
        for $match in util:eval($eval-query)
        order by $match/bu:membership/bu:lastName ascending
        return 
            $match        
    )                 
    else if ($sortby = 'fn_desc') then (
        for $match in util:eval($eval-query)
        order by $match/bu:membership/bu:firstName descending
        return 
            $match       
    )  
    else if ($sortby = 'fn_asc') then (
        for $match in util:eval($eval-query)
        order by $match/bu:membership/bu:firstName ascending
        return 
            $match       
    )                 
    else  (
        for $match in util:eval($eval-query)
        order by $match/bu:membership/bu:lastName ascending
        return 
            $match        
    )
};


declare function bun:xqy-search-membership() {
    fn:concat("collection('",cmn:get-lex-db() ,"')",
            "/bu:ontology/bu:membership/bu:docType[bu:value eq 'Membership']",
            "/ancestor::bu:ontology")
};

(:~ !+FIXED(ah,05-01-2012) 

- the searchin/@field configuration must be relative to bu:ontology, it had field mappings 
as bu:shortName, bu:body etc. the collection context for the search is bu:ontology - so the full text search fails because 
there is no node context for bu:ontology/bu:shortName. This is fixed by setting the searchin/@field relative to bu:ontology.
from : bu:shortName to bu:legislativeItem/bu:shortName. 

- additionally the return context of the ft search was ancestor::bu:ontology this is not required because the ft:search is 
run in the context of bu:ontology (i.e. bu:ontology[ft:search()] ...) and not in a sub-context (i.e. bu:ontology/ft:search() )
:)
(:~ !+WAS_FIX_THIS (ao, 20 Dec 2011) - return bu:ontology begat a problem on eXist 1.5's Lucene where the ft:query() could
    not traverse up to and yielded nothing.
:)
(:
declare function bun:xqy-list-documentitems-with-acl-tmp($acl as xs:string, $type as xs:string) {
  let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    

  return  
    fn:concat("collection('",cmn:get-lex-db() ,"')",
                "/bu:ontology[@type='document']",
                "/bu:document[@type='",$type,"']",
                "/following-sibling::bu:legislativeItem",
                "/(bu:permissions except bu:versions)",
                "/bu:permission[",$acl-filter,"]",
                "/ancestor::bu:legislativeItem")
};
:)

(:~
:   Implements xqy-list-documentitems-with-acl()
: @param acl
:   permission type
: @param type
:   document type
: @return
:   Evaluates xquery to return document(s) matching permission that was given
:)
declare function bun:list-documentitems-with-acl($chamber-id as xs:string, $acl as xs:string, $type as xs:string) {
    let $eval-query := bun:xqy-list-documentitems-with-acl($chamber-id, $acl, $type)
    let $coll :=  util:eval($eval-query)
    let $sortord := xs:string(request:get-parameter("s","none"))
    let $orderby := cmn:get-orderby-config-name($type, $sortord)
    return 
        util:eval(fn:concat("for $match in $coll ",
                            "order by xs:dateTime($match/",data($orderby/@field),") ",data($orderby/@order)," ",
                            "return $match"))    
};

declare function bun:list-documentitems-with-acl-n-tabs($chamber as xs:string?,
                                                        $acl as xs:string, 
                                                        $type as xs:string, 
                                                        $tag as xs:string) {
    let $eval-query := bun:xqy-list-documentitems-with-acl-n-tabs($chamber, $acl, $type, $tag)
    let $coll :=  util:eval($eval-query)
    let $sortord := xs:string(request:get-parameter("s","none"))
    let $orderby := cmn:get-orderby-config-name($type, $sortord)
    return 
        util:eval(fn:concat("for $match in $coll ",
                            "order by xs:dateTime($match/",data($orderby/@field),") ",data($orderby/@order)," ",
                            "return $match"))
};

(:~
:   Returns all documents requested and applying the appropriate sort order
: @param acl
:   permission type
: @param type
:   document type
: @param url-prefix
:   Default page-tab to link to if needed
: @param stylesheet
:   The stylesheet that transforms this xml output
: @param offset
:   The xquery subsequence offet utilised the paginator in the stylesheet defined above
: @param querystr
:   User's search terms to be passed to the lucene ft-search()
: @param sortby
:   The element to order-by, descending / ascending
: @return
:   Evaluates xquery to return document(s) matching permission that was given
:)
declare function bun:get-documentitems(
            $view-rel-path as xs:string,
            $parliament as node()?,
            $acl as xs:string,
            $type as xs:string,
            $parts as node(),
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/view/xsl)    
    let $tab := xs:string(request:get-parameter("tab",'uc'))    
    let $coll := bun:list-documentitems-with-acl-n-tabs($parliament/identifier/text(), $acl, $type, $tab)
    let $listings-filter := cmn:get-listings-config($type)
    let $getqrystr := xs:string(request:get-query-string())    
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents | active-tab count if the view is tabbed :)
            <count>{
                    count($coll)
             }</count>
            <tags>
            {
                for $listing in $listings-filter
                    return 
                        <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(util:eval(bun:xqy-list-documentitems-with-acl-n-tabs($parliament/identifier/text(), $acl, $type, $listing/@id))) }">{data($listing/@name)}</tag>
             }
             </tags>    
            <chamber>{$parliament/type/text()}</chamber>
            <currentView>{$parts/current-view}</currentView>
            <documentType>{$type}</documentType>
            <listingUrlPrefix>{$parts/default-view}</listingUrlPrefix>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <i18nlabel>{$type}</i18nlabel>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            for $match in subsequence($coll,$query-offset,$limit) 
            (:where $coll/bu:bungeni/bu:tags[contains(bu:tag,'terminal')]:)
            return 
                bun:get-reference($match)         
        } 
        </alisting>
    </docs>

    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
                <param name="listing-tab" value="{$tab}" />
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="item-listing-rel-base" value="{$view-rel-path}" />
            </parameters>
           ) 
       
};

declare function bun:search-criteria(
        $controller as node()?,
        $acl as xs:string, 
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string,
        $typeofdoc as xs:string) as element() {
        
        if ($typeofdoc eq "Committee" or $typeofdoc eq "political-group") then
            bun:search-groupitems($controller,$acl, $typeofdoc, "committee-text", "xsl/committees.xsl", $offset, $limit, $querystr, $sortby)
        else if ($typeofdoc eq "Membership") then
            bun:search-membership($controller,$acl, $typeofdoc, "member-text", "xsl/members.xsl", $offset, $limit, $querystr, $sortby)
        else
            bun:search-documentitems($controller, $acl, $typeofdoc, "bill-text", "xsl/search-listing.xsl", $offset, $limit, $querystr, $sortby)
};

(:~
:   This filters out the search-centric parameters that need to be sustained with the corresponding paginator xslt
: @param querystr
: @return
:   xhtml query string that will be appended to paginator.
:)
declare function local:generate-qry-str($getqrystr) {
        let $rem-dups := if (matches($getqrystr,"offset")) then fn:substring-before($getqrystr, '&amp;offset') else $getqrystr,
            $tokened := tokenize($rem-dups,'&amp;')
         
        (: Remove constant params like limit,offset etc :)
        let $off := for $toks1 in $tokened 
            return
                if (contains($toks1,"offset")) then (
                    remove($tokened,index-of($tokened,$toks1))
                )
                else ($tokened)
                
        let $lim := for $toks2 in $tokened 
            return
                if (contains($toks2,"limit")) then (
                    remove($tokened,index-of($tokened,$toks2))
                )
                else ($tokened)

         return 
                string(string-join(distinct-values($off[.=$lim]),"&amp;"))
};

(:~
:   Similar to documents listings above and implements ft-search() to perform
:   full-text search on the sorted documents
: @param querystr
: @param type
: @param url-prefix
: @param stylesheet
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return
:   xhtml query string that will be appended to paginator.
: @stylesheet 
:   search-listing.xsl
:)
declare function bun:search-documentitems(
            $controller as node()?,
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)
    let $chamber-id := $controller/parliament/identifier/text()
    let $getqrystr := xs:string(request:get-query-string())
    (: Escape all invalid characters :)
    let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`') 

    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    let $xqy-coll-rs := bun:xqy-list-documentitems-with-acl($chamber-id,$acl, $type)  
    let $coll-ft-search := $xqy-coll-rs || "[ft:query(., '" || $escaped || "*')]"
    let $eval-query := "subsequence(" || $coll-ft-search || ",$query-offset,$limit)"
        
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count( if ($querystr ne "") then 
                            util:eval($coll-ft-search) 
                       else 
                            bun:list-documentitems-with-acl($chamber-id,$acl, $type)
                )
             }</count>
             <currentView>search</currentView>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if($querystr ne "") then (
                for $search-rs in util:eval($eval-query)
                let $expanded := kwic:expand($search-rs),
                $config := <config xmlns="" width="160"/>                        
                order by ft:score($search-rs) descending
                return 
                    <doc>
                        {$search-rs}
                        <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
                    </doc>
             ) else (
                for $match in subsequence(bun:list-documentitems-with-acl($chamber-id,$acl, $type),$query-offset,$limit)
                return 
                    bun:get-reference($match)               
             )
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
                <param name="chamber" value="{$controller/parliament/type/text()}" />
            </parameters>
           )
};

(:~
:   
: @param qryall
: @param qryexact
: @param qryhas
: @param parent-types
: @param doc-types
: @param limit
: @param offset
: @param sortby
: @return
:   all documents that matched filters
: @stylesheet 
:   advanced-search.xsl
:)
declare function bun:advanced-search($chamber as xs:string,
            $qryall as xs:string,
            $qryexact as xs:string?,
            $qryhas as xs:string?, 
            $parent-types as xs:string*,
            $doc-types as xs:string*,
            $parts as node(),
            $offset as xs:integer, 
            $limit as xs:integer, 
            $status as xs:string,
            $startdate as xs:string,
            $enddate as xs:string,            
            $sortby as xs:string) as element()* {
      
    let $stylesheet := xs:string($parts/xsl)  
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    let $getqrystr := xs:string(request:get-query-string())    
    let $search-filter := cmn:get-doctypes()
    
    let $subset-chambers-coll :=    if($chamber ne "") then (
                                        (:  if chamber is filled then we need to acknowledge that this is a bicameral 
                                            setup and provide the collection subset filtered by the option chosen :)
                                        if ($chamber eq "both") then (
                                            collection(cmn:get-lex-db())/bu:ontology
                                        ) 
                                        else 
                                            collection(cmn:get-lex-db())/bu:ontology/child::*[1]/bu:origin[bu:identifier eq $chamber]/ancestor::bu:ontology
                                    )
                                    else 
                                        collection(cmn:get-lex-db())/bu:ontology
    
    let $subset-parents-coll :=    if(not(empty($parent-types))) then (
                                        (: iterate through the all known (distinctly)categories from config :)
                                        for $category in distinct-values($search-filter/@category)
                                            (: iterate through the categories received from search form :)
                                            for $ptype in $parent-types
                                                return
                                                    if($ptype eq $category) then 
                                                        $subset-chambers-coll[@for=$category]
                                                    else ()
                                    )
                                    else ()
                            
    let $subset-docs-coll :=    if(not(empty($doc-types))) then (
                                    (: iterate through the all known categories from config :)
                                    for $filter in $search-filter                                    
                                        (: iterate through the doctypes received :)
                                        for $dtype in $doc-types
                                        return
                                            (:  as per current structure, these types dont need summons to bu:ontology ancestor::
                                                this is determined when the (ontology type is the same as the document type) in 
                                                a child node 
                                            :)
                                            if(($filter/@name eq $filter/@category) and $dtype eq $filter/@name) then 
                                                $subset-chambers-coll[@for=$filter/@name]
                                            (: check for ontology type only, which represents a category of a particular 
                                                type of documents 
                                            :)
                                            else if($dtype eq $filter/@name) then 
                                                $subset-chambers-coll[@for=$filter/@category]/bu:document/bu:docType[bu:value=$filter/@name]/ancestor::bu:ontology                                       
                                            else ()
                                    )
                                    else ()    
       
    (: merge both sets :)
    let $coll_subset := ($subset-parents-coll, $subset-docs-coll)
    
    (: trim collection subset by bu:status :)
    let $subset_w_status := if ($status ne "none") then (
                                for $match in $coll_subset
                                (:  this is placed here and not with the order by sort 
                                    because it affects the <count/> if put after the search 
                                    of the total documents found 
                                :)
                                where $match/child::*/bu:status eq $status 
                                return 
                                    $match 
                            )
                            else 
                                $coll_subset
                                
    (: trim collection subset by bu:statusDate :)
    let $subset_w_st_date := if ($startdate ne "" and $enddate ne "") then (
                                for $match in $subset_w_status
                                return 
                                    $match/child::*[bu:statusDate gt xs:dateTime(concat($startdate,"T00:00:00"))]
                                    [bu:statusDate lt xs:dateTime(concat($enddate,"T23:59:59"))]/ancestor::bu:ontology
                                )
                                else 
                                    $subset_w_status                                
    
    (: check if search is there are search terms so as to proceed to search or not :)    
    let $subset_rs := if ($qryall ne "" or $qryexact ne "" or $qryhas ne "") then 
                        bun:adv-ft-search($subset_w_st_date, $qryall, $qryexact, $qryhas) 
                    else ( 
                        for $doc in $subset_w_st_date
                        return 
                            <doc>{$doc}</doc>
                    )
    
    (: document node to be returned to transforming stylesheet :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents for display.  :)
            <count>{
                count(
                    $subset_rs
                  )
             }</count>
            <currentView>search-adv</currentView>
            <documentType>question</documentType>
            <qryAll>{$qryall}</qryAll>
            <qryExact>{$qryexact}</qryExact>
            <qryHas>{$qryhas}</qryHas>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$doc-types}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
                if ($sortby = 'std_oldest') then (
                    for $match in subsequence($subset_rs,$query-offset,$limit)              
                    order by $match/bu:ontology/child::*/bu:statusDate ascending 
                    return 
                        $match 
                )
                else  (
                    for $match in subsequence($subset_rs,$query-offset,$limit)              
                    order by $match/bu:ontology/child::*/bu:statusDate descending 
                    return 
                        $match     
                )        
        } 
        </alisting>
    </docs>
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sort" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Performs a lucene search using the XML syntax
: @param coll-subset
: @param qryall
: @param qryexact
: @param qryhas
: @return
:   search results in a <doc/> document
:)
declare function bun:adv-ft-search(
            $coll-subset as node()*, 
            $qryall as xs:string,
            $qryexact as xs:string,
            $qryhas as xs:string) as element()* {
        
        let $qryall-words := tokenize($qryall, '\s')
        let $qryhas-words := tokenize($qryhas, 'OR')
        let $query-node :=  <query>
                                <bool>
                                    <bool> {
                                        for $word in $qryall-words
                                            return
                                            <term occur="must">{$word}</term>
                                        }
                                    </bool>                                    
                                    <phrase>{$qryexact}</phrase>
                                    <bool> {
                                       for $word in $qryhas-words
                                           return
                                           <term occur="should">{$word}</term>
                                       }
                                    </bool>      
                                </bool>
                            </query>        
        
        for $search-rs in $coll-subset[ft:query(., $query-node)]
        let $expanded := kwic:expand($search-rs),
        $config := <config xmlns="" width="160"/>
        order by ft:score($search-rs) descending
        return
            (:  <doc>
                    <bu:ontology/>
                    <kwic/>
                </doc>
            :)
            <doc>
                {$search-rs}
                <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
            </doc>
};

(:~
:   Performs a lucene search using the XML syntax
: @param coll-subset
: @param qryall
: @param qryexact
: @param qryhas
: @return
:   search results in a <doc/> document
:)
declare function bun:adv-ft-search($coll-subset as node()*, 
                                    $qryall as xs:string) as element()* {
        
        let $qryall-words := tokenize($qryall, '\s')
        let $query-node :=  <query>
                                {           
                                (: if there is an instance of the double-quote,
                                 : assumes that there are exact phrases to be matched 
                                 :)
                                if(contains($qryall,'"')) then (
                                    (: match anything within double-quotes as phrases :)
                                    let $phrased := for $match in functx:get-matches($qryall,'(".*?")')
                                                    return 
                                                      if($match ne "") then 
                                                        <phrase>{substring-before(substring-after($match,'"'),'"')}</phrase>
                                                      else ()
                                    (: for those not in double-quotes, match them as single items :)
                                    let $unphrased := <bool>{
                                                        for $match in tokenize($qryall,'(".*?")')
                                                        let $match-words := tokenize($match, '\s')
                                                        for $word in $match-words
                                                            return
                                                                if($word ne "") then 
                                                                    <term occur="must">{$word}</term>
                                                                else ()
                                                      }
                                                      </bool>
                                    return ($phrased,$unphrased)
                                )
                                (: if there is no instance of the double-quote, split items for search :)                                
                                else (
                                    <bool> 
                                        {
                                        for $word in $qryall-words
                                           return
                                           <term occur="must">{$word}</term>
                                        }
                                    </bool>                                  
                                )
                                }                                                               
                            </query>     
        for $search-rs in $coll-subset[ft:query(., $query-node)]
        let $expanded := kwic:expand($search-rs),
        $config := <config xmlns="" width="160"/>
        order by ft:score($search-rs) descending
        return
            (:  <doc>
                    <bu:ontology/>
                    <kwic/>
                </doc>
            :)
            <doc>
                {$search-rs}
                <bu:attachment-links>
                {
                (: adding attachments with relative path to links :)                
                    functx:replace-element-values($search-rs/bu:attachments/bu:attachment,
                           for $p in $search-rs/bu:attachments/bu:attachment/bu:fileHash
                           return concat("/exist/rest/bungeni-atts/",$p)) 
                }   
                </bu:attachment-links>
                <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
            </doc>
};

(:~
:   Similar to bun:search-documentitems()
:)
declare function bun:search-groupitems(
            $controller as node()?,
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)    
    let $coll_rs := bun:xqy-list-groupitem($type)
    let $getqrystr := xs:string(request:get-query-string())

    (: check if search is there so as to proceed to search or not :)    
    let $coll := if ($querystr ne "") then bun:ft-search($coll_rs, $querystr, $type) else util:eval($coll_rs)
    
    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count(
                    $coll
                  )
             }</count>
            <currentView>search</currentView>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislature/bu:statusDate ascending
                return 
                    <doc>{$match}</doc>      
                )             
            else  (
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match}</doc>        
                )
                (:ft:score($m):)
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Similar to bun:search-documentitems()
:)
declare function bun:search-membership(
            $controller as node()?,
            $acl as xs:string,
            $type as xs:string,
            $url-prefix as xs:string,
            $stylesheet as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
            
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($stylesheet)
    let $getqrystr := xs:string(request:get-query-string())
    (: Escape all invalid characters :)
    let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`') 

    (: 
        Logical offset is set to Zero but since there is no document Zero
        in the case of 0,10 which will return 9 records in subsequence instead of expected 10 records.
        Need arises to  alter the $offset to 1 for the first page limit only.
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    
    let $xqy-coll-rs := bun:xqy-list-membership($type)  
    let $coll-ft-search := $xqy-coll-rs || "[ft:query(., '" || $escaped || "*')]"
    let $eval-query := "subsequence(" || $coll-ft-search || ",$query-offset,$limit)"
        
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{
                count( if ($querystr ne "") then 
                            util:eval($coll-ft-search) 
                       else 
                            bun:list-membership($xqy-coll-rs, $sortby)
                )
             }</count>
             <currentView>search</currentView>
            <documentType>{$type}</documentType>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <listingUrlPrefix>{$url-prefix}</listingUrlPrefix>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            if($querystr ne "") then (
                for $search-rs in util:eval($eval-query)
                let $userid := data($search-rs/bu:membership/bu:referenceToUser/bu:refersTo/@href)
                let $expanded := kwic:expand($search-rs),
                $config := <config xmlns="" width="160"/>                        
                order by ft:score($search-rs) descending
                return 
                    <doc>
                        {$search-rs}
                        <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
                        <ref>
                            {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$userid][1]/ancestor::bu:ontology}
                        </ref>                         
                    </doc>
             ) else (
                for $match in subsequence(bun:list-membership($xqy-coll-rs, $sortby),$query-offset,$limit)
                return 
                    bun:get-reference($match)               
             )            
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Performs a full-text on a set of documents, based on Lucene
:
: @param collection query
:   A xquery to return the collection of documents we want to search in 
: @param querystr
:   The raw search terms / parameters by the user
: @param type
:   The document type to filter the search scope to particular type e.g. bill, question, motion
: @return
:   Results matching the search terms and returned in search index/indices field(s) that was 
:   specified in the filter options e.g. bu:shortName, bu:registryNumber
:)
declare function bun:ft-search(
            $coll-query as xs:string, 
            $querystr as xs:string,
            $type as xs:string) as element()* {
        (: 
            There are special characters for Lucene that we have to escape 
            incase they form part of the user's search input. More on this...
           
            http://sewm.pku.edu.cn/src/other/clucene/doc/queryparsersyntax.html
            http://www.addedbytes.com/cheat-sheets/regular-expressions-cheat-sheet/
        :)

        let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`'),
            $ultimate-path := local:build-search-objects($type),
            $eval-query := concat($coll-query,"[ft:query((",$ultimate-path,"), '",$escaped,"*')]")
            
        let $coll :=  util:eval($eval-query)
        let $sortord := xs:string(request:get-parameter("s","none"))
        let $orderby := cmn:get-orderby-config-name($type, $sortord)
        return 
            util:eval(fn:concat("for $match in $coll ",
                                "order by $match/",data($orderby/@field)," ",data($orderby/@order)," ",
                                "return $match"))
        (: We want to use user's sort order instead of ft:score engine :)
        (:     
        for $search-rs in util:eval($eval-query)
        order by ft:score($search-rs) descending      
            
        return
            (:<params>{$ultimate-path}</params> !+DEBUG_WITH_test.xql:)
            $search-rs   
        :)
};

(:~
:   Searches the entire document for matching text/strings within the lucene-indexed fields
:   in the Bungeni collection.
: @param acl
: @param offset
: @param limit
: @param querystr
: @param scope
: @param sortby
: @return
:   A <doc/> with paginator items where applicable and also found results wrapped in respective
:   category. Three categories define at the moment <legis/>, <groups/> and <members/>.
: @stylesheet 
:   global-search-summary.xsl OR global-search-results.xsl
:)
declare function bun:search-global(
            $acl as xs:string,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $querystr as xs:string, 
            $scope as xs:string,
            $sortby as xs:string) as element() {
            
    (: convinience variables :)
    let $qry-available := if($querystr ne "") then true() else false() 
    
    (: stylesheet to transform: ephemeral or paginated :)
    let $stylesheet := if ($scope eq "global" ) then 
                            cmn:get-xslt("xsl/global-search-summary.xsl") 
                       else cmn:get-xslt("xsl/global-search-results.xsl")
    
    (:let $coll_rs := bun:xqy-list-groupitem("membership"):)
    let $getqrystr := xs:string(request:get-query-string())

    (: toggle summary and categorized :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset
    let $query-limit := if ($scope eq "global" ) then 3 else $limit
    
    let $coll-legis := bun:xqy-search-legis-with-acl($acl),
        $coll-groups := bun:xqy-search-group(),
        $coll-members := bun:xqy-search-membership()
    
    (: Escape all invalid characters :)
    let $escaped := replace($querystr,'^[*|?]|(:)|(\+)|(\()|(!)|(\{)|(\})|(\[)|(\])','\$`')       
      
    let $count :=   if($scope eq "legis") then (
                        count(util:eval(concat($coll-legis,"[ft:query(., '",$escaped,"')]")))
                    )
                    else if($scope eq "groups") then (
                        count(util:eval(concat($coll-groups,"[ft:query(., '",$escaped,"')]")))
                    )
                    else if($scope eq "members") then (
                        count(util:eval(concat($coll-members,"[ft:query(., '",$escaped,"')]")))
                    )   
                    else()
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
            (: Count the total number of documents :)
            <count>{ $count }</count>
            <currentView>search-all</currentView>
            <documentType>global</documentType>
            <qryStr>{$querystr}</qryStr>
            <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <legis>
            {
                (: check if search is there so as to proceed to search or not :) 
                if(($querystr ne "" and $scope eq "global") or
                    ($querystr ne "" and $scope eq "legis")) then (
                    element count { count(util:eval(concat($coll-legis,"[ft:query(., '",$escaped,"')]"))) }, 
                    
                    let $eval-query := concat("subsequence(",$coll-legis,"[ft:query(., '",$escaped,"')]",",$query-offset,$query-limit)")
                    
                    for $search-rs in util:eval($eval-query)
                    let $expanded := kwic:expand($search-rs),
                    $config := <config xmlns="" width="160"/>                        
                    order by ft:score($search-rs) descending
                    return 
                        <doc>
                            {$search-rs}
                            <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
                        </doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </legis>
        <groups>
            {
                attribute having { "ola"},
                if(($querystr ne "" and $scope eq "global") or
                    ($querystr ne "" and $scope eq "groups")) then (
                    element count { count(util:eval(concat($coll-groups,"[ft:query(., '",$escaped,"')]"))) },
                    
                    let $eval-query := concat("subsequence(",$coll-groups,"[ft:query(., '",$escaped,"')]",",$query-offset,$query-limit)")
                    
                    for $search-rs in util:eval($eval-query)
                    let $expanded := kwic:expand($search-rs),
                    $config := <config xmlns="" width="160"/>                    
                    order by ft:score($search-rs) descending
                    return 
                        <doc>
                            {$search-rs}
                            <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
                        </doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </groups>     
        <members>
            {
                if(($querystr ne "" and $scope eq "global") or ($querystr ne "" and $scope eq "members")) then (                    
                    element count { count(util:eval(concat($coll-members,"[ft:query(., '",$escaped,"*')]"))) },
                    
                    
                    let $eval-query := concat("subsequence(",$coll-members,"[ft:query(., '",$escaped,"*')]",",$query-offset,$query-limit)")
                    for $search-rs in util:eval($eval-query)
                    let $userid := data($search-rs/bu:membership/bu:referenceToUser/bu:refersTo/@href)
                    let $expanded := kwic:expand($search-rs),
                    $config := <config xmlns="" width="160"/>
                    order by ft:score($search-rs) descending 
                    return 
                        <doc>
                            {$search-rs}
                            <kwic>{kwic:get-summary($expanded, ($expanded//exist:match)[1], $config)}</kwic>
                            <ref>
                                {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$userid][1]/ancestor::bu:ontology}
                            </ref>                            
                        </doc>
                     )
                 else (<none>{$querystr}</none>)                
            } 
        </members>            

    </docs>
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           )
};

(:~
:   Generates list of indexed items selected by user and match the ui-config option for that type of document.
:   +NOTES: The items in the ui-config must also be indexed in the /db/system/db/config/bungeni-xml/collection.xconf
:
: @param type
: @return 
:   Comma seperated list of indexed nodes as set in the ui-config.
:)
declare function local:build-search-objects($type as xs:string) {
    
  let 
    $search-filter := cmn:get-searchins-config($type),
    $filter_names := request:get-parameter-names()
    (:$filter_names := fn:tokenize('f_t f_b s q','\s+') !+DEBUG_WITH_test.xql:)
  
    (: Loop the number of items checked by the user :)
    let $list := 
        for $token in $filter_names 
            (: Loop the number of times we have <searchins> in ui-config :)
            for $searchins in $search-filter
                return
                    if ($token eq $searchins/@name) then $searchins/@field else ()
    return 
        (: Recurvice appends the matched indexed items :)
        string-join($list, ",")
};

(:~
:   Re-writes the search-form used in legislative-items listing using input from <searchins>
:   and <orderbys> in ui-config. 
:
: @param tmpl
:   A xml template that has the skeleton form
: @param type
:   The document type
: @return 
:   Returns re-written nodes and elements in the form listing-search-form.xml
:)
declare function local:rewrite-listing-search-form($CONTROLLER as node()?, $tmpl as element(), $type as xs:string)  {

    (: get the current doc-types search conf:)
    let $search-filter := cmn:get-searchins-config($type),
        $search-orderby := cmn:get-orderby-config($type),
        $qry := xs:string(request:get-parameter("q",'')),          
        $allparams := request:get-parameter-names()
        
    return 
      (: [Re]writing the doc_type with the one gotten from rou:listing-documentitem() :)    
      if ($tmpl/self::xh:input[@id eq "doc_type"]) then 
        element input {
            attribute type { "hidden" },
            attribute name { "type" },
            attribute value { $type }
        }   
      else if($tmpl/self::xh:input[@id eq "exist_path"]) then
        element input {
            attribute type { "hidden" },
            attribute name { "exist_path" },
            attribute value { $CONTROLLER/exist-path/text() }
        }   
      else if($tmpl/self::xh:input[@id eq "chamber_id"]) then
        element input {
            attribute type { "hidden" },
            attribute name { "chamber_id" },
            attribute value { $CONTROLLER/parliament/identifier/text() }
        }  
      else if($tmpl/self::xh:input[@id eq "chamber"]) then
        element input {
            attribute type { "hidden" },
            attribute name { "chamber" },
            attribute value { $CONTROLLER/parliament/type/text() }
        }          
      (: [Re]writing the search-field with search text :)    
      else if ($tmpl/self::xh:input[@id eq "search_for"]) then 
        element input {
            attribute id { "search_for" },
            attribute name { "q" },
            attribute class { "search_for" },
            attribute type { "text" },
            attribute placeholder { "i18n(ph-searchlisting,search...)" },
            attribute value { $qry }
        }
       
      (: [Re]Writing the filter_by options from ui-config :)
      else if ($tmpl/self::xh:ul[@id eq 'filter_by']) then 
          element ul 
          {
            attribute id {$tmpl/@id},
            attribute class {$tmpl/@class},      
            (: The filter title :)
            element li {
                attribute class { "sb_filter" },
                "Filter your search"
            },  
            (: End of filter title :)
            
            (: initialize form-filter to field set in ui-config.xml :)
            if ($qry eq '') 
               then 
                for $searchins in $search-filter
                    return 
                        element li {
                            element input {
                                if ($searchins/@default eq "true")
                                  then
                                   attribute checked { "checked" }
                                else
                                   ()
                            ,
                            attribute type { "checkbox" },
                            attribute name { $searchins/@name },
                            $searchins/@value
                        },
                        local:filter-labels($searchins)
                    }
            else
               for $searchins in $search-filter
                return
                    element li {
                        element input {
                             for $param in $allparams 
                                return
                                    if($param eq $searchins/@name) 
                                      then
                                        attribute checked { "checked" }
                                    else 
                                        () 
                            ,                    
                            attribute type { "checkbox" },
                            attribute name { $searchins/@name },
                            $searchins/@value
                        },
                        local:filter-labels($searchins)
                    }
          }
        (: [Re]Writing the sort_by options from ui-config :)
        else if ($tmpl/self::xh:select[@id eq 'sort_by']) then 
          element select 
          {
            attribute id {$tmpl/@id},
            attribute name {$tmpl/@name},
            
            for $orderbys in $search-orderby
            return
                if (data($orderbys/@default) eq "true") then (
                    element option {
                        attribute selected {"selected"},                    
                        attribute value { $orderbys/@value },
                        $orderbys/text()
                    }
                )
                else (
                    element option {
                        attribute value { $orderbys/@value },
                        $orderbys/text()
                    }
               )
                
          }                  
        else
  		    element { node-name($tmpl)}
		  		 {$tmpl/@*, 
			         for $child in $tmpl/node()
				        return if ($child instance of element())
					       then local:rewrite-listing-search-form($CONTROLLER, $child, $type)
					       else $child
				 }

};

declare function local:filter-labels($searchins as element()) {
    element label { 
        attribute for { $searchins/@value},
         if($searchins/@name eq 'all') then 
            element b {
                <i18n:text key="{$searchins/text()}">{$searchins/text()}(nt)</i18n:text>
            }
         else
            <i18n:text key="{$searchins/text()}">{$searchins/text()}(nt)</i18n:text>
                
    }
};

(:~
:   Re-writes the search-form-global that does a full-text search across all documents.
:
: @param tmpl
:   A xml template that has the skeleton form
: @param type
:   The document type
: @return 
:   Returns re-written nodes and elements in the form global-search-form.xml
:)
declare function local:rewrite-global-search-form($EXIST-PATH as xs:string, $tmpl as element(), $qry as xs:string)  {
   
    (: [Re]writing the search-field with search text :)    
    if ($tmpl/self::xh:input[@id eq "global-search"]) then 
        element input {
            attribute id { "global-search" },
            attribute name { "q" },
            attribute class { "search_for" },
            attribute type { "text" },
            attribute value { "BOOHOO" }
    } 
    else
      element { node-name($tmpl)}
      		 {$tmpl/@*,
    	         for $child in $tmpl/node()
    		        return if ($child instance of element())
    			       then local:rewrite-global-search-form($EXIST-PATH, $child, $qry)
    			       else $child
    		 }

};

(:~
:   The main search API in appcontroller that accepts all requests routed to /search
:  
: @param embed_tmpl
:   XML skeleton global/listing-search-form.xml that is merged into the main layout template.
: @param scope
:   Can either be known 'doctype' or '"global"'
: @param doctype
:   The document type
: @return
:   A Re-written search-form with relevant sort-by field and filter-options
:)
declare function bun:get-listing-search-context(
                        $EXIST-CONTROLLER as node()?, 
                        $embed_tmpl as xs:string,
                        $doctype as xs:string) {

    (: get the template to be embedded :)
    let $xh-tmpl := fw:app-tmpl($embed_tmpl)
    let $tmpl := local:form-rewrite($xh-tmpl,$EXIST-CONTROLLER/parliament/type/text())    
    
    return
        document {
                local:rewrite-listing-search-form($EXIST-CONTROLLER, $tmpl, $doctype)
        }
};

(:
    For purpose of re-writing the form element itself and put the correct 
    chamber-path    
:)
declare function local:form-rewrite($tmpl as document-node(), $chamber as xs:string?) as element() {

        <div xmlns="http://www.w3.org/1999/xhtml" xmlns:i18n="http://exist-db.org/xquery/i18n" id="search-form">
        {
            if ($tmpl/descendant-or-self::xh:form[@id eq "ui_search"]) then 
            element xh:form {
                attribute method { "GET" },
                attribute action { $chamber || "/search" },
                attribute name { "search_sort" },
                attribute autocomplete { "off" },
                $tmpl/(@*,*)
            }  
            else 
                ()
        }
        </div>
};


declare function bun:get-global-search-context(
                        $EXIST-PATH as xs:string, 
                        $embed_tmpl as xs:string, 
                        $scope as xs:string) {

    (: get the template to be embedded :)
    let $tmpl := fw:app-tmpl($embed_tmpl), 
        $qry := xs:string(request:get-parameter("q",'')) 
    
    return
        document {
                local:rewrite-global-search-form($EXIST-PATH, $tmpl/xh:div, $qry)
        }
};

declare function bun:get-advanced-search-context($CONTROLLER-DOC as node()?, $embed_tmpl as xs:string) {

    (: get the template to be embedded :)
    let $tmpl := fw:app-tmpl($embed_tmpl)
    
    return
        document {
                local:rewrite-advanced-search-form($CONTROLLER-DOC, $tmpl/xh:div)
        }
};

(:~
:   The advanced search API 
:  
: @param EXIST-PATH
:   default path
: @param tmpl
:   The advanced search template
: @return
:   A Re-written advanced search form
:)
declare function local:rewrite-advanced-search-form($CONTROLLER-DOC as node()?, $tmpl as element())  {

    let $search-filter := cmn:get-doctypes()
    (: queries the xml repository for available doctypes so as to show only those present :)
    let $current-types := string-join(distinct-values(collection(cmn:get-lex-db())/bu:ontology/child::*/bu:docType[@isA='TLCTerm']/bu:value)," ")
    
    return 
    if ($tmpl/self::xh:fieldset[@id eq 'bicameral-filter']) then (
        let $legis-info := cmn:get-parl-config()
        let $bicameral := if(count($legis-info/parliaments/parliament) > 1) then true() else false()
        return
            if ($bicameral) then 
                element fieldset {
                    element legend {
                        <i18n:text key="chamber-filter">Filter by chamber(nt)</i18n:text>
                    },
                    element div {
                        attribute class {"row chamber-options"},
                        element div {
                            attribute class {"b-chambers"},
                            element ul {
                                element li {
                                    <i18n:text key="chamber-both">Both(nt)</i18n:text>,
                                    element input {
                                        attribute type { "radio" },
                                        attribute name { "chamber" },
                                        attribute value { "both" },
                                        attribute checked { "checked" }
                                    }
                                },                            
                                let $ref-chamber := xs:string(request:get-parameter("referrer",''))
                                for $chamber in $legis-info/parliaments/parliament 
                                return 
                                    element li {
                                        data($chamber/type/@displayAs),
                                        element input {
                                            attribute type { "radio" },
                                            attribute name { "chamber" },
                                            attribute value { $chamber/identifier/text() }
                                        }
                                    }
                            }
                        }
                    }
                }
            else
                ()
    )
    else if ($tmpl/self::xh:div[@id eq "search-groups"]) then 
    (: writing the search categories and doctypes :)      
        element div {
            attribute id { "search-groups" },
            attribute class { "b-left" },
            (: loops through categories filtering duplicates :)
            for $category in distinct-values($search-filter/@category) 
                return 
                    element div {
                        attribute class {"category-block"},
                        element span {
                            attribute class {"ul-list-header"},
                            <i18n:text key="{concat('cate-',$category)}">{$category}(nt)</i18n:text>,
                            element br {},
                            element span {
                                attribute class {"checkall"},
                                <i18n:text key="select-all">check all(nt)</i18n:text>
                            },
                            element input {
                                attribute type {"checkbox"},
                                attribute name {"types"},
                                attribute value {$category}
                            }
                        },
                        element ul {
                            for $doctype in $search-filter
                                return  
                                    if($doctype/@category eq $category and contains($current-types,$doctype/@name)) then (
                                        element li {
                                            <i18n:text key="{concat('doc-',lower-case($doctype/@name))}">{lower-case($doctype/@name)}(nt)</i18n:text>,
                                            element input {
                                                attribute type {"checkbox"},
                                                attribute name {"docs"},
                                                attribute value {$doctype/@name}
                                            }
                                        }
                                    )                             
                                    else ()
                        }
                    }
        }   
    (: render the status dropdown :)
    else if ($tmpl/self::xh:select[@id eq "status"]) then 
        element select {
            attribute id { "status" },
            attribute name { "std" },
            element option {
                attribute value {"none"},
                attribute selected {"selected"},
                <i18n:text key="status-default">select one(nt)</i18n:text>
            },
            for $status in distinct-values(collection(cmn:get-lex-db())/bu:ontology/child::*/bu:status[@isA='TLCTerm']/bu:value)
                return 
                element option {
                    attribute value {$status},
                    $status
                }
        } 
    else
      element { node-name($tmpl)}
      		 {$tmpl/@*,
    	         for $child in $tmpl/node()
    		        return if ($child instance of element())
    			       then local:rewrite-advanced-search-form($CONTROLLER-DOC/exist-cont, $child)
    			       else $child
    		 }

};

(:~
:   Generates Atom FEED for Bungeni Documents Bills, Questions, TabledDocuments and Motions.
:    
: @param acl
:   permissions setting
: @param doctype
:   The document type
: @param outputtype
:   Can either be a "user" or "service" request.
: @return
:   A qualified atom feed limited to 10 items
:)
declare function bun:get-documents-feed(
            $controller as node()?,
            $acl as xs:string, 
            $doctype as xs:string, 
            $outputtype as xs:string
            ) as element() {
    util:declare-option("exist:serialize", "media-type=application/atom+xml method=xml"),
    
    let $chamber-id := $controller/parliament/identifier/text()
    let $chamber := $controller/parliament/type/text()   
    let $chamber-name := data($controller/parliament/type/@displayAs)   
    let $server-path := $bun:SERVER-URL || $controller/exist-cont/text()
    
    let $feed := <feed xmlns="http://www.w3.org/2005/Atom" xmlns:atom="http://www.w3.org/2005/Atom">
        <title>{concat($chamber-name, " ", upper-case(substring($doctype, 1, 1)), substring($doctype, 2))}s Atom</title>
        <id>http://portal.bungeni.org/1.0/</id>
        <updated>{current-dateTime()}</updated>
        <generator uri="http://sourceforge.net/projects/exist/" version="2.0">eXist XML Database</generator>      
        <id>urn:uuid:31337-4n70n9-w00t-l33t-5p3364</id>
        <link rel="self" href="{$server-path}/{$chamber}/bills/rss" />
       {
            for $i in subsequence(bun:list-documentitems-with-acl($chamber-id,$acl, $doctype),0,10)
            order by $i/bu:document/bu:statusDate descending
            (:let $path :=  substring-after(substring-before(base-uri($i),'/.feed.atom'),'/db/bungeni-xml'):)
            return 
            (   <entry>
                    <id>{data($i/bu:document/@uri)}</id>
                    <title>{$i/bu:document/bu:title/node()}</title>
                    {
                       <summary> 
                       {
                           $i/bu:document/bu:docType/bu:value/node(),
                           $i/bu:document/bu:title/node()
                       }
                       </summary>,
                       if ($outputtype = 'user')  then (
                            <link rel="alternate" type="application/xhtml" href="{$server-path}/{$chamber}/{lower-case($doctype)}-text?uri={$i/bu:document/@uri}"/>
                        )  (: "service" output :)
                        else (
                            <link rel="alternate" type="application/xml" href="{$server-path}/{$chamber}/{lower-case($doctype)}-xml?uri={$i/bu:document/@uri}"/>
                        )  
                    }
                    <content type='html'>{$i/bu:document/bu:body/node()}</content>
                    <published>{$i/bu:document/bu:publicationDate/node()}</published>
                    <updated>{$i/bu:document/bu:statusDate/node()}</updated>                           
                </entry>
            )
       }
    </feed>
    
    return 
        $feed
};

(:~
:   Generates Atom FEED for Bungeni Sittings.
:    
: @param outputtype
:   Can either be a "user" or "service" request.
: @return
:   A qualified atom feed limited to 10 items
:)
declare function bun:get-sittings-feed($controller as node()?, $acl as xs:string, $outputtype as xs:string  ) as element() {
    util:declare-option("exist:serialize", "media-type=application/atom+xml method=xml"),
    
    let $chamber-id := $controller/parliament/identifier/text()
    let $chamber := $controller/parliament/type/text()   
    let $chamber-name := data($controller/parliament/type/@displayAs)   
    let $server-path := $bun:SERVER-URL || $controller/exist-cont/text()
    
    let $feed := <feed xmlns="http://www.w3.org/2005/Atom" xmlns:atom="http://www.w3.org/2005/Atom">
        <title>{$chamber-name} sittings Atom</title>
        <id>http://portal.bungeni.org/1.0/</id>
        <updated>{current-dateTime()}</updated>
        <generator uri="http://sourceforge.net/projects/exist/" version="2.0">eXist XML Database</generator>      
        <id>urn:uuid:31337-4n70n9-w00t-l33t-5p3364</id>
        <link rel="self" href="{$server-path}/{$chamber}/sittings/rss" />
       {
            let $sittings-coll := util:eval(concat("collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology/bu:sitting[bu:origin/bu:identifier/bu:value eq '",$chamber-id,"']/",
                                            bun:xqy-docitem-perms($acl)))   
            for $i in subsequence($sittings-coll/ancestor::bu:ontology,0,10)
            
            order by $i/bu:sitting/bu:statusDate descending
            (:let $path :=  substring-after(substring-before(base-uri($i),'/.feed.atom'),'/db/bungeni-xml'):)
            return 
            (   <entry>
                    <id>{data($i/bu:sitting/@uri)}</id>
                    <title>{$i/bu:sitting/bu:shortName/node()}</title>
                    {
                       <summary> 
                       {
                          $i/bu:sitting/bu:shortName/node()  || " - " || data($i/bu:sitting/bu:activityType/@showAs)
                       }
                       </summary>,
                       <link rel="alternate" type="application/xhtml" href="{$server-path}/{$chamber}/sitting?uri={$i/bu:sitting/@uri}"/> 
                    }
                    <content type='html'>{$i/bu:sitting/bu:body/node()}</content>
                    <published>{$i/bu:sitting/bu:startDate/node()}</published>
                    <updated>{$i/bu:sitting/bu:statusDate/node()}</updated>                           
                </entry>
            )
       }
    </feed>
    
    return 
        $feed
};

(:~
:   Outputs the raw xml document with some omissions. Currently for legislative-items only
: 
: @param docid
:   The URI for the document
: @return
    Returns the fetched document as a XML document
:)
declare function bun:get-raw-xml($docid as xs:string) as element() {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    let $doc := functx:remove-elements-deep(collection(cmn:get-lex-db())/bu:ontology[child::*[@uri eq $docid, @internal-uri eq $docid]],
                ('bu:versions', 'bu:permissions', 'bu:changes','bu:description'))
    let $output := concat(replace(substring-after($docid, '/'),'/','-'),".xml")
    let $header := response:set-header("Content-Disposition" , concat("attachment; filename=",$output)) 
    return 
        $doc
};

(:~
:  Renders AkomaNtoso output for parliamentary document
: @param docid
:   The URI of the document
:
: @return
:   An AKN document
:)
declare function bun:get-akn-xml($docid as xs:string)
{
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('xsl/bu-to-akn.xsl') 
    
    let $doc := collection(cmn:get-lex-db())/bu:ontology/bu:document[@uri eq $docid, @internal-uri eq $docid]/ancestor::bu:ontology
    let $akn := transform:transform($doc,$stylesheet,())
    let $output := concat('akn-',replace(substring-after($docid, '/'),'/','-'),".xml")
    let $header := response:set-header("Content-Disposition" , concat("attachment; filename=",$output))

    return $akn 
    
};

(:~
:  Renders xCard. vCard v4.0 output for parliamentary document
: @param docid
:   The URI of the document
:
: @return
:   An xCard document
:)
declare function bun:get-xcard-xml($docid as xs:string)
{
    util:declare-option("exist:serialize", "media-type=application/xml method=xml indent=yes"),
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt('xsl/bu-to-xcard.xsl')
    let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$docid][1]/ancestor::bu:ontology

    (: return AN Committee document with all items assigned to it :)
    let $doc := <doc>
                {
                    $user          
                }
                <membership>{
                    collection(cmn:get-lex-db())/bu:ontology/bu:membership/bu:referenceToUser[bu:refersTo/@href=$docid][1]/ancestor::bu:ontology             
                }</membership>
                <ref/>
                </doc> 
    let $server-path := "http://" || $template:SERVER-NAME || ":" || $template:SERVER-PORT || "/exist/apps/"
    let $transformed := transform:transform($doc,$stylesheet,   <parameters>
                                                                    <param name="server-path" value="{$server-path}" />
                                                                </parameters>)
    
    let $header := response:set-header("Content-Type" , "text/xml")    
    let $header := response:set-header("Content-Disposition" , concat("attachment; filename=",  $user/bu:user/bu:firstName || $user/bu:user/bu:lastName || ".vcf"))
    
    return $transformed   
};

(:~
:   Retieves all group documents of type committee
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type committee
:)
declare function bun:get-committees(
        $view-rel-path as xs:string,
        $parliament as node()?,
        $offset as xs:integer, 
        $limit as xs:integer, 
        $parts as node(),
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {   
    
    let $getqrystr := xs:string(request:get-query-string())
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/view/xsl)
    
    let $tab := xs:string(request:get-parameter("tab","active")) 
    let $listings-filter := cmn:get-listings-config($parts/doctype)    
    let $coll := bun:list-groupitems-with-tabs($parliament/identifier/text(), $parts/doctype, $tab)
    
    (: The line below is documented in bun:get-documentitems() :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count($coll)}</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(bun:list-groupitems-with-tabs($parliament/identifier/text(),$parts/doctype, $listing/@id)) }">{data($listing/@name)}</tag>
                    
         }
         </tags>    
        <currentView>{$parts/current-view}</currentView>
        <documentType>committee</documentType>
        <listingUrlPrefix>committee/text</listingUrlPrefix>
        <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>        
        </paginator>
        <alisting>
        {
                for $match in subsequence($coll,$query-offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match}</doc>
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
                <param name="listing-tab" value="{$tab}" />
                <param name="item-listing-rel-base" value="{$view-rel-path}" />  
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                  
            </parameters>
           )   
};

(:~
:   Retieves all group documents of type sittings
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type sittings
:)
declare function bun:get-sittings(
        $offset as xs:integer, 
        $limit as xs:integer, 
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("xsl/sittings.xsl")    
    
    (: 
        The line below is documented in bun:get-documentitems()
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@for='sitting'])}</count>
        <documentType>groupsitting</documentType>
        <listingUrlPrefix>sittings/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>        
        </paginator>
        <alisting>
        {
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@for='sitting'],$offset,$limit)
                order by $match/bu:sitting/bu:statusDate descending
                return 
                    local:get-sitting-items($match,())
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc,
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           ) 
       
};

(:
    Given a date, it return start and end dates for the week that 
    date lies in
:)
declare function local:start-end-of-week($adate as xs:date) {

    let $abbr-day := functx:day-of-week-abbrev-en($adate)
    
    return
        switch($abbr-day)

        case 'Sun' return
            <range>
                <start>{($adate - xs:dayTimeDuration('P6D')) || "T00:00:00"}</start>
                <end>{$adate || "T23:59:59"}</end>
            </range>
        case 'Mon' return
            <range>
                <start>{$adate || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P6D')) || "T23:59:59"}</end>
            </range>
        case 'Tues' return 
            <range>
                <start>{($adate - xs:dayTimeDuration('P1D')) || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P5D')) || "T23:59:59"}</end>
            </range>          
        case 'Wed' return 
            <range>
                <start>{($adate - xs:dayTimeDuration('P2D')) || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P4D')) || "T23:59:59"}</end>
            </range>             
        case 'Thurs' return
            <range>
                <start>{($adate - xs:dayTimeDuration('P3D')) || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P3D')) || "T23:59:59"}</end>
            </range>             
        case 'Fri' return
            <range>
                <start>{($adate - xs:dayTimeDuration('P4D')) || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P2D')) || "T23:59:59"}</end>
            </range>      
        case 'Sat' return
            <range>
                <start>{($adate - xs:dayTimeDuration('P5D')) || "T00:00:00"}</start>
                <end>{($adate + xs:dayTimeDuration('P1D')) || "T23:59:59"}</end>
            </range>
        default return
            ()
};

declare function local:old-future-sittings($range as xs:string) {

    let $twk := substring-before(current-date() cast as xs:string,"+") cast as xs:date
    let $pwk := local:start-end-of-week(substring-before(current-date() cast as xs:string,"+") cast as xs:date - xs:dayTimeDuration('P7D'))
    let $nwk := local:start-end-of-week(substring-before(current-date() cast as xs:string,"+") cast as xs:date + xs:dayTimeDuration('P7D'))
    
    return
        switch($range)

        (: For old and fut sittings, we get 30 days before and after current-date :)
        case 'old' return
            <range>
                <start>{($twk - xs:dayTimeDuration('P30D')) || "T00:00:00"}</start>
                <end>{($twk - xs:dayTimeDuration('P1D')) || "T23:59:59"}</end>
            </range>
        case 'fut' return
            <range>
                <start>{($twk + xs:dayTimeDuration('P1D')) || "T00:00:00"}</start>
                <end>{($twk + xs:dayTimeDuration('P30D')) || "T23:59:59"}</end>
            </range>
        default return
            ()
};

declare function local:validate-custom-date($from as xs:date, $to as xs:date) {
    let $calc-max := cmn:whatson-range-limit()
    let $max-date := $from + xs:dayTimeDuration('P' || xs:integer($calc-max/text()) || 'D')
    (: if `$to` date is set greater than config limit, override with max-limit calculated :)
    let $set-to := if($max-date gt $to) then $to else $max-date
    return 
        <range>
            <start>{($from || "T00:00:00")}</start>
            <end>{($set-to || "T23:59:59")}</end>
        </range>
};

declare function local:get-sitting-subset($sittings) {
    for $sitting in $sittings
    order by $sitting/bu:statusDate ascending
    return 
        if ($sitting/bu:sitting/bu:scheduleItems/bu:scheduleItem) then (
            let $uri := <uri>{data($sitting/bu:sitting/@uri)}</uri>
            let $startdate := $sitting/bu:sitting/bu:startDate
            let $venue := $sitting/bu:sitting/bu:venue/bu:shortName/text()
            let $title := $sitting/bu:sitting/bu:shortName
            return 
                <ref sitting="{$uri}">
                    {   $startdate, 
                        for $eachitem in $sitting/bu:sitting/bu:scheduleItems/bu:scheduleItem
                        return $eachitem, 
                        $title, 
                        <bu:venue>{$venue}</bu:venue> 
                    }
                </ref>
        )
        else (
            let $uri := <uri>{data($sitting/bu:sitting/@uri)}</uri>
            let $startdate := $sitting/bu:sitting/bu:startDate
            let $venue := $sitting/bu:sitting/bu:venue/bu:shortName/text()
            let $title := $sitting/bu:chamber/bu:shortName
            return 
                <ref sitting="{$uri}">
                    { $startdate, <bu:scheduleItem/>, $title, <bu:venue>{$venue}</bu:venue>}
                </ref>        
        )
};

(: !+EXIST_20_UPG :)
declare function local:grouped-sitting-items-by-itemtype($sittings) {
    for $item in local:get-sitting-subset($sittings)/bu:scheduleItem
    where $item/bu:sourceItem/bu:refersTo/bu:type/bu:value/text() ne 'NOT_FOUND'
    group by $key := $item/bu:sourceItem/bu:refersTo/bu:type/bu:value
    return 
        <doc title="{$key}">
            {$item/parent::node()}
        </doc>
};

(: !+EXIST_20_UPG :)
declare function local:grouped-sitting-items-by-date($sittings) {
    for $item in local:get-sitting-subset($sittings)
    group by $key := <date>{substring-before($item/bu:startDate,"T")}</date>
    order by $key ascending
    return 
        <doc title="{$key}">
            {$item}
        </doc>
};

declare function local:grouped-sitting-meeting-type($chamber-id as xs:string?, $dates-range as node(),$mtype as xs:string) {
    if ($mtype eq 'any') then (
        for $sittings in collection(cmn:get-lex-db())/bu:ontology/bu:sitting[bu:origin/bu:identifier eq $chamber-id][xs:dateTime(bu:startDate) gt xs:dateTime($dates-range/start)][xs:dateTime(bu:startDate) lt xs:dateTime($dates-range/end)]/ancestor::bu:ontology
        order by $sittings/bu:sitting/bu:startDate ascending
        return $sittings
    ) else (
       for $sittings in collection(cmn:get-lex-db())/bu:ontology/bu:sitting[bu:origin/bu:identifier eq $chamber-id][xs:dateTime(bu:startDate) gt xs:dateTime($dates-range/start)][xs:dateTime(bu:startDate) lt xs:dateTime($dates-range/end)]/ancestor::bu:ontology
       where $sittings/bu:sitting/bu:meetingType[bu:value eq $mtype] 
       order by $sittings/bu:sitting/bu:startDate ascending
       return $sittings    
    )
};


(:~
:   Retieves all group documents of type sittings
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type sittings
:   NOTE: Return deviates from standard
:)
declare function bun:get-whatson(
        $whatsonview as xs:string, 
        $tab as xs:string,
        $mtype as xs:string,
        $parts as node()?,
        $parliament as node()?) as element() {
    
    (: stylesheet to transform :)  
    let $stylesheet := cmn:get-xslt($parts/xsl)
    let $f := request:get-parameter("f",substring-before(current-date() cast as xs:string,"+") cast as xs:date)
    let $t := request:get-parameter("t",substring-before(current-date() cast as xs:string,"+") cast as xs:date)
    let $listings-filter := cmn:get-listings-config('Groupsitting')
    let $chamber-id := $parliament/identifier/text()
    
    let $view := if ($whatsonview ne 'none') 
        then 
            $whatsonview   
        else
            'custom'
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology/bu:sitting[bu:origin/bu:identifier eq $parliament/identifier]/ancestor::bu:ontology)}</count>
        <documentType>sitting</documentType>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="20">{data($listing/@name)}</tag>
         }
         </tags>   
        { cmn:get-whatsonviews() }      
        <meetingtypes>
            <meetingtype>any</meetingtype>
        { 
            for $node in distinct-values(collection(cmn:get-lex-db())/bu:ontology/bu:sitting[bu:origin/bu:identifier eq $parliament/identifier]/bu:meetingType/bu:value)
            return <meetingtype>{string($node)}</meetingtype>
        } 
        </meetingtypes>
        <listingUrlPrefix>sittings/profile</listingUrlPrefix>
        </paginator>
        <alisting>
        {
            switch ($view)
            
            case 'old' return 
                let $dates-range := local:old-future-sittings($whatsonview)
                return             
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype) 
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )
                
            case 'pwk' return 
                let $dates-range := local:start-end-of-week(substring-before(current-date() cast as xs:string,"+") cast as xs:date - xs:dayTimeDuration('P7D'))
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype) 
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    ) 

            case 'twk' return
                (: !+FIX_THIS (ao, 21-May-2012) Somehow current-date() returns like this 2012-05-21+03:00, we remove the timezone :)
                let $dates-range := local:start-end-of-week(substring-before(current-date() cast as xs:string,"+"))
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype)              
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )
  
            case 'nwk' return 
                let $dates-range := local:start-end-of-week(substring-before(current-date() cast as xs:string,"+") cast as xs:date + xs:dayTimeDuration('P7D'))
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype) 
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )      
             
            case 'fut' return 
                let $dates-range := local:old-future-sittings($whatsonview)
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype) 
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )     
                    
            case 'custom' return 
                let $dates-range := local:validate-custom-date($f, $t)
                let $sittings := local:grouped-sitting-meeting-type($chamber-id,$dates-range,$mtype)
                return 
                    if ($tab eq 'sittings') then (
                        $dates-range,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        $dates-range,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )                     
             
            default return           
                let $sittings := collection(cmn:get-lex-db())/bu:ontology/bu:sitting[xs:date(substring-before(bu:startDate, "T")) eq current-date()]/ancestor::bu:ontology
                return 
                    if ($tab eq 'sittings') then (
                        <range>
                            <start>{current-dateTime()}</start>
                            <end>{current-dateTime()}</end>
                        </range>,
                        local:grouped-sitting-items-by-date($sittings)  
                    )
                    else (
                        <range>
                            <start>{current-dateTime()}</start>
                            <end>{current-dateTime()}</end>
                        </range>,
                        local:grouped-sitting-items-by-itemtype($sittings)  
                    )
        }
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc,
            $stylesheet, 
            <parameters>
                <param name="filter" value="{$listings-filter}" />
                <param name="listing-tab" value="{$tab}" />
                <param name="meeting-type" value="{$mtype}" />
                <param name="whatson-view" value="{$whatsonview}" />
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                   
            </parameters>
           )
};

declare function bun:get-sitting($acl as xs:string, 
            $doc-uri as xs:string, 
            $parts as node(), 
            $parliament as node()?) as element()* {
            
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl)

    let $identifier := $parliament/identifier/text()
    let $doc := 
            (:Returs a Sittings Document :)
            let $match := util:eval(concat( "collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology/bu:sitting[bu:origin/bu:identifier/bu:value eq '",$identifier,"' and @uri eq '",$doc-uri,"']/",
                                            bun:xqy-docitem-perms($acl)))
            
            return
                local:get-sitting-items($match/ancestor::bu:ontology,$parts)   
    return
        transform:transform($doc, $stylesheet, ())
 };

(:~
:   Retieves all group documents of type sittings
: @param acl
: @param doc-uri
: @param _tmpl
: @return 
:   A listing of documents of group type sittings
:)
declare function bun:get-calendar($acl as xs:string, 
            $doc-uri as xs:string, 
            $_tmpl as xs:string,
            $parliament as node()?) as element()* {
            
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    let $identifier := $parliament/identifier/text()
    let $doc := 
            (:Returs a Sittings Document :)
            let $match := util:eval(concat( "collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology/bu:sitting[bu:origin/bu:identifier/bu:value eq '",$identifier,"' and @uri eq '",$doc-uri,"']/",
                                            bun:xqy-docitem-perms($acl)))
            
            return
                local:get-sitting-items($match/ancestor::bu:ontology,())   
    return
        transform:transform($doc, $stylesheet, ())
 };
 
declare function bun:strip-namespace($e as node()) {
  element {QName((), local-name($e))} {
    for $child in $e/(@*,*)
    return
      if ($child instance of element())
      then bun:strip-namespace($child)
      else $child
  }
};

declare function bun:get-sittings-xml($acl as xs:string, $parliament as node()?) as element()* {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),

    let $identifier := $parliament/identifier/text()
    let $events := <data> {
            for $s in util:eval(concat( "collection('",cmn:get-lex-db(),"')/",
                                            "bu:ontology/bu:sitting[bu:origin/bu:identifier eq '",$identifier,"']/",
                                            bun:xqy-generic-perms($acl),"/",
                                            "ancestor::bu:ontology"))
            return <event>
                        <start_date>{replace($s/bu:sitting/bu:startDate/text(),"T", " ")}</start_date>
                        <end_date>{replace($s/bu:sitting/bu:endDate/text(),"T", " ")}</end_date>
                        <text>
                            &lt;a href="sitting?uri={data($s/bu:sitting/@uri)}"&gt;
                                {$s/bu:sitting/bu:shortName/text()}
                            &lt;/a&gt; @ {$s/bu:sitting/bu:venue/bu:shortName/text()}
                        </text>
                        <details>{$s/bu:sitting/bu:shortName/text()}</details>            
                   </event>
    }
    </data>
    
    return
        $events
};
 
declare function bun:strip-namespace($e as node()) {
  element {QName((), local-name($e))} {
    for $child in $e/(@*,*)
    return
      if ($child instance of element())
      then bun:strip-namespace($child)
      else $child
  }
};

declare function local:get-sitting-items($sittingdoc as node()?, $parts as node()?) {
    <doc>
        {if ($sittingdoc) then $sittingdoc else $sittingdoc}
        <ref>
            {
                for $eachitem in $sittingdoc/bu:sitting/bu:scheduleItems/bu:scheduleItem
                return 
                    collection(cmn:get-lex-db())/bu:ontology/bu:document[@internal-uri eq data($eachitem/bu:sourceItem/bu:refersTo/@href)]/ancestor::bu:ontology
            }
        </ref>
        {bun:get-excludes($sittingdoc, $parts/parent::node())}
    </doc>     
};

(:~
:   Retieves all group documents of type politicalgroups
: @param offset
: @param limit
: @param querystr
: @param sortby
: @return 
:   A listing of documents of group type policicalgroups
:)
declare function bun:get-politicalgroups(
        $view-rel-path as xs:string,
        $parliament as node()?,
        $offset as xs:integer, 
        $limit as xs:integer, 
        $parts as node(),
        $querystr as xs:string, 
        $sortby as xs:string
        ) as element() {
    
    let $getqrystr := xs:string(request:get-query-string())
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/view/xsl)    
    
    let $tab := xs:string(request:get-parameter("tab","active")) 
    let $listings-filter := cmn:get-listings-config("PoliticalGroup")    
    let $coll := bun:list-groupitems-with-tabs($parliament/identifier/text(),$parts/doctype, $tab)    
    
    (: 
        The line below is documented in bun:get-documentitems()
    :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset      
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count($coll)}</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(bun:list-groupitems-with-tabs($parliament/identifier/text(),$parts/doctype, $listing/@id)) }">{data($listing/@name)}</tag>
                    
         }
         </tags>         
        <currentView>{$parts/current-view}</currentView>
        <documentType>political-group</documentType>
        <listingUrlPrefix>political-group/text</listingUrlPrefix>      
        <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            switch ($sortby)
            
            case 'start_dt_oldest' return 
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:group/bu:startDate ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>  
                
            case 'start_dt_newest' return 
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:group/bu:startDate descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>     

            case 'fN_asc' return
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislature/bu:fullName ascending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>      
  
            case 'fN_desc' return 
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislature/bu:fullName descending
                return 
                    <doc>{$match/ancestor::bu:ontology}</doc>        
             
            default return 
                for $match in subsequence($coll,$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <doc>{$match}</doc>
        } 
        </alisting>
    </docs>
    (: !+SORT_ORDER(ah, nov-2011) - pass the $sortby parameter to the xslt rendering the listing to be able higlight
    the correct sort combo in the transformed output. See corresponding comment in XSLT :)
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
                <param name="listing-tab" value="{$tab}" />
                <param name="item-listing-rel-base" value="{$view-rel-path}" />  
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                   
            </parameters>
           )     
};

(:~
:   This function runs a sub-query to get related information of type="group" and has
:   has matching URI of the input document-docitem
: 
: @param docitem
:   A document-node
: @return
:   docitem together with any reference group documents found... simplistic structure below
:   <doc>
:       <bu:ontology/> Main document
:       <ref/> Referenced Documents
:   </doc>
:)
declare function bun:get-reference($docitem as node()) {
    <doc>
        {$docitem}
        <ref>
            {
                let $doc-ref := data($docitem/bu:*/bu:group/@href)
                return 
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../bu:ministry
            }
         </ref>
    </doc>     
};


(:~
:
: The following are query builder functions for generating the document access query
: It supports applying of ACLs
:
:)
declare function bun:xqy-docitem-uri($uri as xs:string, $internal-uri as xs:string?) as xs:string {
    if ($internal-uri eq "NULL") then 
        fn:concat("collection(cmn:get-lex-db())/bu:ontology/bu:document[@uri='", $uri,"'][1]")  
    else
        fn:concat("collection(cmn:get-lex-db())/bu:ontology/bu:document[@internal-uri='", $internal-uri,"'][1]")  
};        

declare function bun:xqy-docitem-perms($acl as xs:string) as xs:string{
    let $acl-permissions := cmn:get-acl-permissions($acl)
    (:
    : Regarding (bu:permissions except bu:versions) 
    : see : 
    : "XQuery wrong xpath resolution bug"
    : <http://sourceforge.net/mailarchive/forum.php?thread_name=CAPoZz4TDjD1B1JqJOKF9z%3DWFGO%3D1xVVg5xo_ksc8y5H66hGNag%40mail.gmail.com&forum_name=exist-open>
    :)
    return fn:concat(
        "(bu:permissions except bu:versions)/bu:control[", 
        cmn:get-acl-permission-attr($acl-permissions), 
        "]")
};

declare function bun:xqy-generic-perms($acl as xs:string) as xs:string{
    let $acl-permissions := cmn:get-acl-permissions($acl)
    (:
    : !+NOTES(ao, 16 Mar 2012) After moving permissions into main ontological document 
    : containing the uri of a document, the bun:xqy-docitem-perms() applies in less instances 
    : if any and will be deprecated.
    :)
    return fn:concat(
        "bu:permissions/bu:control[", 
        cmn:get-acl-permission-attr($acl-permissions), 
        "]")
};

declare function bun:xqy-docitem-ancestor-root() as xs:string{
    xs:string("ancestor::bu:ontology")
};

declare function bun:xqy-docitem-acl-uri($acl as xs:string, $uri as xs:string, $internal-uri as xs:string?) as xs:string {
    fn:concat(
        bun:xqy-docitem-uri($uri,$internal-uri), 
        "/", 
        bun:xqy-docitem-perms($acl),
        "/",
        bun:xqy-docitem-ancestor-root()
        )
};

declare function bun:documentitem-full-acl($acl as xs:string, $uri as xs:string, $internal-uri as xs:string?) {
    let $acl-permissions := cmn:get-acl-permissions($acl)

    (: authenticate access to document itself first :)
    let $match := 
        document {
            util:eval(bun:xqy-docitem-acl-uri($acl, $uri, $internal-uri))
        }

    return 
        bun:treewalker-acl($acl-permissions, $match)
};

(:
    Applys recursive ACL on the given document
    
    @param acl-permissions
        a node of permissions
    @param doc
        the document to be authenticated, node by node.
    @return
        the document without unauthorised nodes()
:)
declare function bun:treewalker-acl($acl-permissions as node(), $doc) {

    let $children := $doc/*
    return
        if(empty($children)) then ()
        else 
        for $c in $children
        return
            (: passes authentication, add to tree :)
            if ($c/bu:permissions/bu:control[
                    @name=data($acl-permissions/@name) and 
                    @role=data($acl-permissions/@role) and 
                    @setting=data($acl-permissions/@setting)
                ]) then
                    element {name($c)}{
                         $c/@*,
                         $c/text(),
                         bun:treewalker-acl($acl-permissions, $c)
                      }
            (: 'c' has no bu:permissions node, add to tree :)
            else if (not($c/bu:permissions/bu:control)) then
                    element {name($c)}{
                         $c/@*,
                         $c/text(),
                         bun:treewalker-acl($acl-permissions, $c)
                      }
            (: fails above two checks, omit from tree :)
            else   
                 ()
};

(:~ 
    Removes changes that don't fit the permissions given.
    
    !+NOTE (ao, 7th-May-2012) This and similar methods are deprecated in favour of 
    bun:treewalker-acl(). Reason being it complicated the views because they were called 
    only on certain views and would disappear otherwise. This inconsistency had to be 
    eliminated
:)
declare function bun:documentitem-changes-with-acl($acl-permissions as node(), $docitem as node() ) {
  if ($docitem/self::bu:change) then
        if ($docitem/bu:permissions/bu:control[
                @name=data($acl-permissions/@name) and 
                @role=data($acl-permissions/@role) and 
                @setting=data($acl-permissions/@setting)
                ]) then
            $docitem
        else
            ()
  else 
    (:~
     return the default 
     :)
  		element { node-name($docitem)}
		  		 {$docitem/@*, 
					for $child in $docitem/node()
						return if ($child instance of element())
							   then bun:documentitem-changes-with-acl($acl-permissions, $child)
							   else $child
				 }
};

(:~
:   Used to retrieve a legislative-document
:
: @param acl
: @param docid
: @param _tmpl
: @param tab
:   The corresponding transform template passed by the calling funcction
:)
declare function bun:get-parl-doc($acl as xs:string, 
            $doc-uri as xs:string, 
            $doc-internal-uri as xs:string?,
            $parts as node(),
            $parliament as node()?) as element()* {
            
    let $parent-uri := xps:substring-before($doc-uri, "@") (: extract parent-uri @ exists :)
    let $version := if(string-length($parent-uri) > 2) then true() else false()
    let $uri := if($version) then $parent-uri else $doc-uri

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    (: !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    
    let $doc := document {
            let $match := bun:documentitem-full-acl($acl, $uri, $doc-internal-uri)
            return
                (: $parts/parent::node() returns all tabs of this doctype :)
                bun:get-ref-assigned-grps($match, $parts/parent::node())
        }
    return
        transform:transform($doc, $stylesheet,
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />   
                <param name="version" value="{$version}" />
                <param name="version-uri" value="{$doc-uri}" /> 
            </parameters>
        )
};

(:~
:   Used to retrieve a legislative-document with events applying acl
:
: @param acl
: @param docid
: @param _tmpl
: @param tab
:   The corresponding transform template passed by the calling funcction
:)
declare function bun:get-parl-doc-with-events($acl as xs:string, 
            $doc-uri as xs:string, 
            $parts as node(),
            $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    (: !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    
    let $doc := document {
            (:Returs a AN Document :)
            (:  !+ACL_NEW_API - changed call to use new ACL API , 
            :   the root is an ontology document now not a legislativeItem
            :)
            let $match := bun:documentitem-full-acl($acl, $doc-uri,"NULL")
            return
                (: $parts/parent::node() returns all tabs of this doctype :)
                bun:get-ref-events($match, $parts/parent::node())
        }
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>           
        )
};

(:~
:   Used to retrieve a legislative-document timeline page
:
: @param acl
: @param docid
: @param parts
:)
declare function bun:get-parl-doc-timeline($acl as xs:string, 
            $doc-uri as xs:string, 
            $internal-uri as xs:string?,
            $parts as node(),
            $parliament as node()) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    let $doc := let $match := bun:documentitem-full-acl($acl, $doc-uri,$internal-uri)
                return
                    (: $parts/parent::node() returns all tabs of this doctype :)
                    bun:get-ref-timeline-activities($match, $parts/parent::node())
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

declare function bun:get-parl-doc-scheduleItem(  $acl as xs:string, 
                                            $uri as xs:string, 
                                            $internal-uri as xs:string?,
                                            $parts as node(),
                                            $parliament as node()) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $identifier := $parliament/identifier/text()
    
    let $match := bun:documentitem-full-acl($acl, $uri,$internal-uri)
    let $doc-internal-uri := data($match/bu:document/@internal-uri)
    
    let $sitting := for $item in util:eval(concat("collection('",cmn:get-lex-db(),"')/",
                                "bu:ontology/bu:sitting[bu:origin/bu:identifier/bu:value eq '",$identifier,"'][",bun:xqy-docitem-perms($acl),"]/bu:scheduleItems/bu:scheduleItem[bu:sourceItem/bu:refersTo/@href eq '",$doc-internal-uri,"']"))
                    let $sitting := $item/ancestor::bu:sitting                         
                    return
                        element item { 
                                        element bu:sitting {
                                            $sitting/(@*)
                                        },
                                        $sitting/bu:shortName,
                                        $sitting/bu:statusDate,
                                        $sitting/bu:startDate,
                                        $sitting/bu:venue,
                                        $item 
                                     }
                                
    let $doc := <doc>
                    {$match}
                    <ref>
                        {$sitting}
                    </ref>
                    {bun:get-excludes($match, $parts/parent::node())}
                </doc> 
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

(:~ 
:   Used to retrieve a government info
:
: @param _tmpl
: @return
:   A document-node of subtype government
: @stylesheet 
:   committee.xsl, home.xsl
:)
declare function bun:get-parliament($parts as node(), $chamber-id as xs:string?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $doc := <doc>{
                    (: 
                        !+FIX_THIS (ao, 16th Nov 2012) Temp fix to show one parliament infor in cases
                        where multiple parliament info are present. Pending support for closing and opening
                        parliaments.
                    :)
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group/bu:docType[bu:value eq 'Chamber']/preceding-sibling::bu:origin[bu:identifier eq $chamber-id]/ancestor::bu:ontology
                    return
                        $match  
                }</doc>   
    return
        transform:transform($doc, $stylesheet, ())
};

(:~ 
:   Used to retrieve a group document with a given URI
:
: @param acl
: @param docid
: @param _tmpl
: @return
:   A document-node of type group
: @stylesheet 
:   committee.xsl, comm-*.xsl
:)
declare function bun:get-parl-group(
            $acl as xs:string, 
            $docid as xs:string, 
            $parts as node(),
            $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    (: !+FIX_THIS , !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    let $doc := document {
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[data(@uri) eq $docid]/ancestor::bu:ontology
                    return
                        (: $parts/parent::node() returns all tabs of this doctype :)
                        bun:get-ref-assigned-grps($match, $parts/parent::node())   
                }     
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

declare function bun:get-group-members(
            $acl as xs:string, 
            $docid as xs:string, 
            $mem-status as xs:string?,
            $parts as node(),
            $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $doc := document {
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$docid]/ancestor::bu:ontology
                    return
                        bun:get-ref-assigned-grps($match, $parts/parent::node())   
                }     
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="mem-status" value="{$mem-status}" />
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                  
            </parameters>)
};

declare function bun:get-parl-committee(
            $acl as xs:string, 
            $docid as xs:string, 
            $mem-status as xs:string,
            $parts as node(),
            $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    (: !+FIX_THIS , !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    let $doc := document {
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[data(@uri)=$docid]/ancestor::bu:ontology
                    return
                        (: $parts/parent::node() returns all tabs of this doctype :)
                        bun:get-ref-comm-members($match, $parts/parent::node())   
                }     
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="mem-status" value="{$mem-status}" />
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                                                   
            </parameters>)
};

declare function bun:get-ref-comm-members($docitem as node(), $docviews as node()) {
    <doc>
        {$docitem}
        <ref/>
        {bun:get-excludes($docitem, $docviews)}
    </doc>     
};

declare function bun:get-parl-committee-sittings(
            $acl as xs:string, 
            $docid as xs:string, 
            $parts as node(),
            $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    (: !+FIX_THIS , !+ACL_NEW_API
    let $acl-filter := cmn:get-acl-filter($acl)
    :)
    let $doc := document {
                    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[data(@uri)=$docid]/ancestor::bu:ontology
                    return
                        (: $parts/parent::node() returns all tabs of this doctype :)
                        bun:get-ref-comm-sitting($match, $parts/parent::node())   
                }     
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                                                   
            </parameters>)
};

declare function bun:get-ref-comm-sitting($docitem as node(), $docviews as node()) {
    <doc>
        {$docitem}
        <ref>
        {
            for $match in collection(cmn:get-lex-db())/bu:ontology/bu:sitting
            where data($match/bu:sittingOf/bu:refersTo/@href) eq data($docitem/bu:group/@uri)
            order by $match/bu:statusDate descending
            return 
                $match/ancestor::bu:ontology 
        }
        </ref>
        {bun:get-excludes($docitem, $docviews)}
    </doc>     
};

(:~
:   Retrives all the groups assigned to the membership or referenced documents from the 
:   input document-node.
:
: @param docitem
: @return 
:   Document node with main document as a <bu:ontology/> and any referenced documents within 
:   <ref/> node
:   <doc>
:       <bu:ontology/>
:       <ref>
:           <bu:ontology/>
:       </ref>
:   </doc>
:)
declare function bun:get-ref-assigned-grps($docitem as node()?, $docviews as node()) {
    <doc>
        {$docitem}
        <ref>
            {
                let $doc-ref := data($docitem/child::*/bu:group/@href)
                return 
                    (: !+FIX_THIS - ultimately this should be replaced by the acl based group access api :)
                    collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/ancestor::bu:ontology
            }
        </ref>
        {bun:get-excludes($docitem, $docviews)}
    </doc>     
};

declare function bun:get-ref-events($docitem as node(), $docviews as node()) {
    <doc>
        {$docitem}
        <ref>
        {
            let $uri := data(if ($docitem/bu:document/@uri) then ($docitem/bu:document/@uri) else ($docitem/bu:document/@internal-uri) )
            let $acl-filter := cmn:get-acl-permission-as-attr(data($docviews/@name),'public-view')
            return
                bun:xqy-list-events-with-acl($uri, $acl-filter)
        }
        </ref>
        {bun:get-excludes($docitem, $docviews)}
    </doc>     
};

declare function bun:xqy-list-events-with-acl($parent-uri as xs:string, $acl-filter as xs:string) {

    let $events-qry := fn:concat("collection('",cmn:get-lex-db() ,"')",
        "/bu:ontology[@for='document']",
        "/bu:document[bu:docType/bu:value eq 'Event']",
        "[bu:eventOf/bu:refersTo[@href eq '",$parent-uri,"']]",
        "/(bu:permissions except bu:versions)",
        "/bu:control[",$acl-filter,"]",
        "/ancestor::bu:ontology")
     return 
        util:eval($events-qry)
};

declare function bun:xqy-list-attachments-with-acl($parent-uri as xs:string, $acl-filter as xs:string) {

    let $attachments-qry := fn:concat("collection('",cmn:get-lex-db() ,"')",
        "/bu:ontology[@for='document']",
        "/bu:document[bu:docType/bu:value eq 'Attachment']",
        "[bu:attachmentOf/bu:refersTo[@href eq '",$parent-uri,"']]",
        "/(bu:permissions except bu:versions)",
        "/bu:control[",$acl-filter,"]",
        "/ancestor::bu:ontology")
     return 
        util:eval($attachments-qry)
};

(:~
:   Retrives all the items to be display on timeline from work-flow in the input document-node.
:
: @param docitem
: @return 
:   Document node with main document as <bu:ontology/> and any referenced documents that will be part 
:   part of timeline activities
:   <doc>
:       <bu:ontology/>
:       <ref>
:           <bu:ontology/>
:       </ref>
:   </doc>
:)
declare function bun:get-ref-timeline-activities($docitem as node()?, $docviews as node()) {
    <doc>
        {$docitem}
        <ref>
            {$docitem},
            {
                (:
                : !+FIX_THIS (ao, 8th Aug 2012) workflowEvents dont have permissions with them...
                : currently using 'internal' to hide them from anonymous :)
                let $wfevents := for $event in $docitem/bu:document/bu:workflowEvents/bu:workflowEvent return element timeline { attribute href { $event/@href }, element bu:chronoTime { $event/bu:statusDate/text() }, $event/child::*}
                let $audits := for $audit in $docitem/bu:document/bu:audits/child::*[bu:auditAction/bu:value eq 'workflow'] return element timeline { attribute id {$audit/@id }, element bu:chronoTime { $audit/bu:statusDate/text() }, $audit/child::*}
                let $versions := for $version in $docitem/bu:document/bu:versions/child::* return element timeline { attribute id {$version/@id }, attribute uri { $version/@uri }, element bu:chronoTime { $version/bu:statusDate/text() }, $version/child::*}
                
                for $eachitem in ($wfevents, $versions) 
                where $eachitem/bu:chronoTime/text() ne ""
                order by $eachitem/bu:chronoTime descending
                return $eachitem
            }
        </ref>
        {bun:get-excludes($docitem, $docviews)}
    </doc>     
};

(:~
:   Adds an <exclude/> node in the returning document to exclude certain tab views.
:
: @param docitem
: @param docviews
: @return 
:   exclude node with tabs that will node be rendered on the ui.
:   <exclude>
:       <tab/> ++
:   </exclude>
:)
declare function bun:get-excludes($docitem as node()?, $docviews as node()?) {
    <exclude>
        {
            let $collection-api := fn:concat("collection('",cmn:get-lex-db() ,"')")
            for $view in $docviews/view[@tag eq 'tab']
            return
                (: must have @check-for attribute first! :)
                if($view/@check-for) then (
                    (: putting a evaluate condition to @check-for... :)
                    if(starts-with($view/@check-for, "global|")) then 
                        (
                            if(not(empty(util:eval(fn:replace(substring-after($view/@check-for,"global|"),"@COLLECTION",$collection-api))))) then 
                                ()
                            else    
                                <tab>{data($view/@id)}</tab>
                        )
                    else if(not(empty(util:eval(concat("$docitem","/*",$view/@check-for))))) then 
                        ()
                    else 
                        <tab>{data($view/@id)}</tab>   
                 )
                 else ()
        }
    </exclude>    
};

(:~
:   Retrives contacts for member/group eith particular id.
:
: @param focal - the focal-point, group/user who(s) addresses we want to get
: @param acl - access control list
: @return 
:   Document node with main document as primary and any group documents assigned to that MP as secondary
:   <doc>
:       <bu:ontology/>
:       <ref/>
:   </doc>
:)
declare function bun:get-contacts-by-uri($acl as xs:string, 
                    $address-type as xs:string, 
                    $focal as xs:string,
                    $parts as node(),
                    $parliament as node()?) {
    let $stylesheet := cmn:get-xslt($parts/xsl)
    let $acl-filter := cmn:get-acl-permission-as-attr($acl)
    let $doc := <doc>
                    document {
                            if($address-type eq 'Group') then 
                                collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$focal][1]/ancestor::bu:ontology
                            else
                                collection(cmn:get-lex-db())/bu:ontology/bu:membership/bu:referenceToUser[bu:refersTo/@href=$focal][1]/ancestor::bu:ontology
                        }
                    <ref>
                        {
                            collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$focal][1]/ancestor::bu:ontology
                        }
                    </ref>
                </doc>     
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="address_type" value="{$address-type}" />
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />                                                    
            </parameters>
          )       
};

(:~
:   Get parliamentary document based on a version URI
:   +NOTES
:   Follows the same structure as get-parl-doc() in that it returns 
:   <doc>
:       <bu:ontology/>
:       <ref/>
:       <version>id</version>
:   </document>
:
: @param versionid
:   Unique ID for the document version
: @param _tmpl
:   The .xsl template that will handle the return output
: @return 
:   Documennt node similar to get-ref-assigned-grps() above
:
: @stylesheet [document-type]/version/text e.g question/version/text
:)
declare function bun:get-doc-version($acl as xs:string, $uri as xs:string, $internal-uri as xs:string?, $parts as node()) as element()* {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl)    
    
    let $parent-uri := xps:substring-before($uri, "@")
    let $foundversions := if($parent-uri) then true() else false()
    let $doc-uri := if($foundversions) then $parent-uri else $uri
    
    let $docitem := bun:documentitem-full-acl($acl, $doc-uri,$internal-uri)
    
    let $latest := if(not($foundversions)) then max($docitem/bu:document/bu:versions/bu:version/bu:auditId) else ()
    let $currenturi := if(not($foundversions)) then data($docitem/bu:document/bu:versions/bu:version[bu:auditId = $latest]/@uri) else $uri
    
    let $doc := <doc>
                    {$docitem}
                    <ref/>
                    {bun:get-excludes($docitem, $parts/parent::node())}
                </doc>   
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                                <param name="version-uri" value="{$currenturi}" />
                            </parameters>)
};



declare function bun:get-doc-attachment($acl as xs:string,
                                        $doc-uri as xs:string, 
                                        $attid as xs:integer, 
                                        $parts as node()) as element()* {

    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    let $docitem := bun:documentitem-full-acl($acl, $doc-uri,"NULL")
    
    let $doc := <doc>{$docitem}</doc>  

    return
        transform:transform($doc, $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                                <param name="attachment-id" value="{$attid}" />
                            </parameters>
       )
                            
};

declare function bun:get-doc-event($eventid as xs:string, 
            $seq-id as xs:integer,
            $parts as node()) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 

    let $match := collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:workflowEvents/bu:workflowEvent[@href = $eventid]/ancestor::bu:ontology
    let $foundevent := if($match) then true() else false()
    
    let $doc-node := if(not($foundevent)) then (
                        bun:documentitem-full-acl('public-view', $eventid, "NULL")/child::* 
                     )
                     else (
                        let $acl-filter := cmn:get-acl-permission-as-node('Event','public-view')
                        return bun:treewalker-acl($acl-filter, $match)
                     )
    let $docitem := document { $doc-node }                
    let $latest := if(not($foundevent)) then max($docitem/bu:document/bu:workflowEvents/bu:workflowEvent/bu:docId) else ()             
    let $currenturi := if(not($foundevent)) then data($docitem/bu:document/bu:workflowEvents/bu:workflowEvent[bu:docId = $latest]/@href) else $eventid
          
    let $doc := <doc>      
                    { $docitem }
                    <ref/>
                    <event>{$currenturi}</event>
                    {bun:get-excludes($docitem, $parts/parent::node())}
                </doc>                
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                                <param name="event-uri" value="$currenturi" />
                                <param name="sequence-id" value="{xs:integer($seq-id)}" />
                            </parameters>)
};

declare function bun:get-doc-event-popout($eventid as xs:string, $parts as node()) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    
    let $doc := <doc>       
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value eq 'Event' or bu:value eq 'EventResponse']/parent::bu:document[@internal-uri eq $eventid]/ancestor::bu:ontology
            }            
            <event>{$eventid}</event>
        </doc>
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                            </parameters>)
};

declare function bun:get-members(
            $view-rel-path as xs:string,
            $parliament as node()?,
            $offset as xs:integer, 
            $limit as xs:integer, 
            $parts as node(),
            $querystr as xs:string, 
            $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/view/xsl)    
    let $tab := xs:string(request:get-parameter("tab","current")) 
    let $getqrystr := xs:string(request:get-query-string())  
    
    let $listings-filter := cmn:get-listings-config($parts/doctype) 
    let $coll := bun:list-membership-with-tabs($parliament/identifier/text(), $parts/doctype, $listings-filter[@id eq $tab]/text(), $sortby)    
    
    (: The line below is documented in bun:get-documentitems() :)
    let $query-offset := if ($offset eq 0 ) then 1 else $offset       
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of members :)
        <count>{count($coll)}</count>
        <tags>
        {
            for $listing in $listings-filter
                return 
                    <tag id="{$listing/@id}" name="{$listing/@name}" count="{ count(bun:list-membership-with-tabs($parliament/identifier/text(), $parts/doctype, $listing/text(), $sortby)) }">{data($listing/@name)}</tag>
                    
        }
        </tags>     
        <chamber>{$parliament/type/text()}</chamber>
        <currentView>{$parts/current-view}</currentView>
        <documentType>{$parts/doctype}</documentType>
        <listingUrlPrefix>{$parts/default-view}</listingUrlPrefix>
        <fullQryStr>{local:generate-qry-str($getqrystr)}</fullQryStr>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        <visiblePages>{$bun:VISIBLEPAGES}</visiblePages>
        </paginator>
        <alisting>
        {
            for $match in subsequence($coll,$offset,$limit)                
            return 
                <doc>
                    {$match}
                    <ref>
                    {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=data($match/bu:membership/bu:referenceToUser/bu:refersTo/@href)]/ancestor::bu:ontology}
                    </ref>                    
                </doc>
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="listing-tab" value="{$tab}" />
                <param name="item-listing-rel-base" value="{$view-rel-path}" />  
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-d" value="{$parliament/identifier/text()}" />
            </parameters>
        
        ) 
       
};

declare function bun:get-member($memberid as xs:string, $parts as node(), $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $member-doc := collection(cmn:get-lex-db())/bu:ontology/bu:membership[bu:referenceToUser[bu:refersTo/@href=$memberid]][bu:docType[bu:value eq 'Member']][1]/ancestor::bu:ontology

    (: return AN Member document as singleton :)
    let $doc := <doc>
                    {$member-doc}
                    <ref>
                    {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$memberid][1]/ancestor::bu:ontology}
                    </ref>
                </doc>
    
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

declare function bun:get-member-officesheld($memberid as xs:string?, $parts as node()*, $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $member-doc := collection(cmn:get-lex-db())/bu:ontology/bu:membership[bu:referenceToUser[bu:refersTo/@href=$memberid]][bu:docType[bu:value eq 'Member']][1]/ancestor::bu:ontology

    (: return AN Member document as singleton :)
    let $doc := <doc>
                    {$member-doc}
                    <ref>
                    {
                      for $doc in collection(cmn:get-lex-db())/bu:ontology/bu:members/bu:member[bu:person/@href eq $memberid]
                      let $group-name := $doc/ancestor::bu:ontology/bu:group/bu:fullName 
                      order by $doc/bu:designations/bu:designation/bu:sortOrder ascending 
                      return 
                            element bu:office {
                                ($doc, $group-name)
                            }
                    }
                    </ref>
                </doc>
    
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

declare function bun:get-member-biographical($memberid as xs:string?, $parts as node()*, $parliament as node()?) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl) 
    let $member-doc := collection(cmn:get-lex-db())/bu:ontology/bu:membership[bu:referenceToUser[bu:refersTo/@href=$memberid]][bu:docType[bu:value eq 'Member']][1]/ancestor::bu:ontology

    (: return AN Member document as singleton :)
    let $doc := <doc>
                    {$member-doc}
                    <ref>
                    {collection(cmn:get-lex-db())/bu:ontology/bu:user[@uri=$memberid][1]/ancestor::bu:ontology}
                    </ref>
                </doc>
    
    return
        transform:transform($doc, $stylesheet, 
            <parameters>
                <param name="chamber" value="{$parliament/type/text()}" />
                <param name="chamber-id" value="{$parliament/identifier/text()}" />               
            </parameters>        
        )
};

declare function bun:get-parl-activities($acl as xs:string, $memberid as xs:string, $parts as node(), $parliament as node()?) as element()* {
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl)
   
    (: return AN Member document with his/her activities :)
    let $doc := <doc>
        { collection(cmn:get-lex-db())/bu:ontology/bu:membership[bu:docType/bu:value eq 'Member']/bu:referenceToUser[bu:refersTo/@href=$memberid][1]/ancestor::bu:ontology }
        <ref>    
            {
            (: Get all parliamentary documents the user is either owner or signatory :)          
            for $match in util:eval(bun:xqy-all-documentitems-with-acl($acl))
            where bu:signatories/bu:signatory[bu:person/@href=$memberid][bu:status/bu:value eq 'consented']/ancestor::bu:ontology or 
                  bu:document/bu:owner/bu:person[@href=$memberid]/ancestor::bu:ontology
            return
                  $match
            }
        </ref>         
    </doc> 
    
    return
        transform:transform($doc, $stylesheet,())    
};

declare function bun:get-assigned-items($committeeid as xs:string, $parts as node()) as element()* {

     (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($parts/xsl)

    (: return AN Committee document with all items assigned to it :)
    let $doc := <assigned-items>
    <group>
    {
        collection(cmn:get-lex-db())/bu:ontology[@for='group']/bu:group[@uri=$committeeid]/ancestor::bu:ontology
    }
    </group>
    {
    for $match in collection(cmn:get-lex-db())/bu:ontology[@for='document']/child::*/bu:group[@href=$committeeid]
    return
        <items>
            {
                $match/ancestor::bu:ontology
             }
        </items>
    }
    </assigned-items> 
    
    return
        transform:transform($doc, $stylesheet, ())  
};

declare function local:get-parl-info() as element() {

    collection(cmn:get-lex-db())/bu:ontology[@for='group']/bu:group/bu:docType[bu:value eq 'government'][1]/ancestor::bu:ontology

};

