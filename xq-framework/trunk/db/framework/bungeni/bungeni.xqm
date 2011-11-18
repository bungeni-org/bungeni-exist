module namespace bun = "http://exist.bungeni.org/bun";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";


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
declare variable $bun:WHERE := 'body_text';

declare variable $bun:OFF-SET := 0;
declare variable $bun:LIMIT :=10;
declare variable $bun:DOCNO := 1;


(: Search for the doc matching the actid in the parameter and return the document :)
declare function bun:get-doc($actid as xs:string) as element() {
     for $match in collection(cmn:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};


declare function bun:get-bills($acl as xs:string, $offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("legislativeitem-listing.xsl")    
    let $acl-filter := cmn:get-acl-filter($acl)
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of bills only :)
        <count>{
            count(
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter]
              )
         }</count>
        <documentType>bill</documentType>
        <listingUrlPrefix>bill/text</listingUrlPrefix>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='bill'][$acl-filter],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
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

declare function bun:get-atom-feed($item as xs:string) as element() {
    util:declare-option("exist:serialize", "media-type=application/atom+xml method=xml"),

    let $feed := <feed xmlns="http://www.w3.org/2005/Atom" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:bu="http://portal.bungeni.org/1.0/">
        <title>Bills Atom</title>
        <id>http://portal.bungeni.org/1.0/</id>
        <updated>{current-dateTime()}</updated>
        <generator uri="http://exist.sourceforge.net/" version="1.4.5">eXist XML Database</generator>      
        <id>urn:uuid:31337-4n70n9-w00t-l33t-5p3364</id>
        <link rel="self" href="/bills/rss" />
       {
         let $current := substring-before(base-uri(/bu:ontology/bu:legislativeItem[@uri='/ke/parliament/2011-03-02/bill/467:38-bill/en']),'/.feed.atom'),
             $current-path := substring-after($current,'/db/bungeni-xml')
            for $i in (collection($current)/bu:ontology[@type='document']/bu:document[@type='bill'])/ancestor::bu:ontology
               (:let $path :=  substring-after(substring-before(base-uri($i),'/.feed.atom'),'/db/bungeni-xml'):)
                  return ( <entry>
                            <id>{data($i/bu:legislativeItem/@uri)}</id>
                            <title>{$i/bu:legislativeItem/bu:shortName/node()}</title>
                            {
                               <summary> {
                                   $i/bu:document/@type,
                                   $i/bu:legislativeItem/bu:shortName/node()
                               }</summary>,
                               <link rel="alternate" type="application/atom+xml" href="/bills/{/bu:legislativeItem/@uri}"/>
                           }
                            <content type='html'>{$i/bu:legislativeItem/bu:body/node()}</content>
                            <published>{$i/bu:legislativeItem/bu:publicationDate/node()}</published>
                            <updated>{$i/bu:legislativeItem/bu:statusDate/node()}</updated>                           
                           </entry>
                         )
       }
    </feed>
    
    return 
        $feed
};

declare function bun:get-committees($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("committees.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'])}</count>
        <documentType>group</documentType>
        <listingUrlPrefix>committee/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            if ($sortby = 'start_dt_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='committee'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>
                   
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

declare function bun:get-politicalgroups($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("politicalgroups.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of groups :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'])}</count>
        <documentType>group</documentType>
        <listingUrlPrefix>committee/profile</listingUrlPrefix>        
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            if ($sortby = 'start_dt_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>  
                )
                
            else if ($sortby eq 'start_dt_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:group/bu:startDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>     
                )
            else if ($sortby = 'fN_asc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName ascending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>      
                )    
            else if ($sortby = 'fN_desc') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislature/bu:fullName descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>        
                )                 
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@type='political-group'],$offset,$limit)
                order by $match/bu:legislature/bu:statusDate descending
                return 
                    <document>{$match/ancestor::bu:ontology}</document>
                   
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
    This function runs a sub-query to get ministry information
    It takes in primary results of main query as input to search
    for group documents with matching URI
:)
declare function bun:get-reference($docitem as node()) {
            <document>
                <output> 
                {
                    $docitem/ancestor::bu:ontology
                }
                </output>
                <referenceInfo>
                    <ref>
                    {
                        let $doc-ref := data($docitem/ancestor::bu:ontology/bu:*/bu:group/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../bu:ministry
                    }
                    </ref>
                </referenceInfo>
            </document>     
};

declare function bun:get-questions($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("legislativeitem-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'])}</count>
        <documentType>question</documentType>
        <listingUrlPrefix>question/text</listingUrlPrefix>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='question'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)         
                )         
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           ) 
       
}; 

declare function bun:get-motions($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("legislativeitem-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'])}</count>
        <documentType>motion</documentType>
        <listingUrlPrefix>motion/text</listingUrlPrefix>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )             
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='motion'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)         
                )            
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           ) 
       
};

declare function bun:get-tableddocs($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("legislativeitem-listing.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of questions only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'])}</count>
        <documentType>tableddocument</documentType>
        <listingUrlPrefix>tableddocument/text</listingUrlPrefix>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {            
            if ($sortby = 'st_date_oldest') then (
               (:if (fn:ni$qrystr):)
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate ascending
                return 
                    bun:get-reference($match)       
                )
                
            else if ($sortby eq 'st_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'sub_date_oldest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date ascending
                return 
                    bun:get-reference($match)         
                )    
            else if ($sortby = 'sub_date_newest') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:bungeni/bu:parliament/@date descending
                return 
                    bun:get-reference($match)         
                )               
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='tableddocument'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:legislativeItem/bu:statusDate descending
                return 
                    bun:get-reference($match)         
                )              
        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, 
            $stylesheet, 
            <parameters>
                <param name="sortby" value="{$sortby}" />
            </parameters>
           ) 
       
};

(: Search for the doc matching the actid in the parameter and return the tabel of contents :)
declare function bun:get-toc($actid as xs:string) as element() {
     for $match in collection(cmn:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};

declare function bun:get-parl-doc($acl as xs:string, $docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    let $acl-filter := cmn:get-acl-filter($acl)
 
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:legislativeItem[@uri=$docid][$acl-filter]
            return
                bun:get-ref-assigned-grps($match)   
        } 
    </parl-doc>    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-parl-group($acl as xs:string, $docid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    let $acl-filter := cmn:get-acl-filter($acl)
 
    let $doc := <parl-doc> 
        {
            (: return AN document as singleton :)
            let $match := collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri=$docid][$acl-filter]
            return
                bun:get-ref-assigned-grps($match)   
        } 
    </parl-doc>    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-ref-assigned-grps($docitem as node()) {
            <document>
                <primary> 
                {
                    $docitem/ancestor::bu:ontology
                }
                </primary>
                <secondary>
                    {
                        let $doc-ref := data($docitem/ancestor::bu:ontology/bu:*/bu:ministry/@href)
                        return 
                            collection(cmn:get-lex-db())/bu:ontology/bu:group[@uri eq $doc-ref]/../../bu:ontology
                    }
                </secondary>
            </document>     
};

(:~
    Get parliamentary document based on a version URI
    +NOTES
    Follows the same structure as get-parl-doc() in that it returns 
    <document>
        <version>id</version>
        <primary/>
        <secondary/>
    </document>
:)
declare function bun:get-doc-ver($versionid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    let $doc := <parl-doc>
        <document>
            <version>{$versionid}</version>
            <primary>         
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:versions/bu:version[@uri=$versionid]/ancestor::bu:ontology
            }
            </primary>
            <secondary>
            </secondary>
        </document>
    </parl-doc>   
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                            </parameters>)
};

declare function bun:get-doc-event($eventid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 
    
    let $doc := <parl-doc>
        <document>
            <event>{$eventid}</event>
            <primary>         
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:wfevents/bu:wfevent[@href = $eventid]/ancestor::bu:ontology
            }
            </primary>
            <secondary>
            {
                collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:document[@type='event']/../bu:legislativeItem[@uri eq $eventid]/ancestor::bu:ontology
            }            
            </secondary>
        </document>
    </parl-doc>   
    
    return
        transform:transform($doc, 
                            $stylesheet, 
                            <parameters>
                                <param name="version" value="true" />
                            </parameters>)
};

declare function bun:get-members($offset as xs:integer, $limit as xs:integer, $querystr as xs:string, $where as xs:string, $sortby as xs:string) as element() {
    
    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt("members.xsl")    
    
    (: input ONxml document in request :)
    let $doc := <docs> 
        <paginator>
        (: Count the total number of bills only :)
        <count>{count(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'])}</count>
        <offset>{$offset}</offset>
        <limit>{$limit}</limit>
        </paginator>
        <alisting>
        {
            if ($sortby = 'ln') then (
            
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)                
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='last_name'] descending
                return 
                    bun:get-reference($match)       
                )
            else if ($sortby = 'fn') then (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='first_name'] descending
                return 
                    bun:get-reference($match)         
                )                
            else  (
                for $match in subsequence(collection(cmn:get-lex-db())/bu:ontology[@type='userdata']/bu:metadata[@type='user'],$offset,$limit)
                order by $match/ancestor::bu:ontology/bu:user/bu:field[@name='last_name'] descending
                return 
                    bun:get-reference($match)         
                )

        } 
        </alisting>
    </docs>
    
    return
        transform:transform($doc, $stylesheet, ()) 
       
};

declare function bun:get-member($memberid as xs:string, $_tmpl as xs:string) as element()* {

    (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    (: return AN Member document as singleton :)
    let $doc := collection(cmn:get-lex-db())//bu:ontology//bu:user[@uri=$memberid]/ancestor::bu:ontology
    
    return
        transform:transform($doc, $stylesheet, ())
};

declare function bun:get-parl-activities($memberid as xs:string, $_tmpl as xs:string) as element()* {

     (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    (: return AN Member document with his/her activities :)
    let $doc := <activities>
    <member>
    {
        collection(cmn:get-lex-db())/bu:ontology//bu:user[@uri=$memberid]/ancestor::bu:ontology
    }
    </member>
    {
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:legislativeItem/bu:owner[@href=$memberid]
    return
        <docs>
            {
                $match/ancestor::bu:ontology
             }
        </docs>
    }
    </activities> 
    
    return
        transform:transform($doc, $stylesheet, ())    
};

declare function bun:get-assigned-items($committeeid as xs:string, $_tmpl as xs:string) as element()* {

     (: stylesheet to transform :)
    let $stylesheet := cmn:get-xslt($_tmpl) 

    (: return AN Committee document with all items assigned to it :)
    let $doc := <assigned-items>
    <group>
    {
        collection(cmn:get-lex-db())/bu:ontology[@type='group']/bu:group[@uri=$committeeid]/ancestor::bu:ontology
    }
    </group>
    {
    for $match in collection(cmn:get-lex-db())/bu:ontology[@type='document']/bu:*/bu:group[@href=$committeeid]
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