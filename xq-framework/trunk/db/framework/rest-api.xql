xquery version "3.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "template.xqm";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni/bungeni.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace json="http://www.json.org";
import module namespace datetime = "http://exist-db.org/xquery/datetime";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace ex="http://exist-db.org/xquery/ex";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace an='http://www.akomantoso.org/2.0';

(:
 : This XQuery script provides a REST API based on RESTXQ extension
 :
 : @author Anthony Oduor <aowino@googlemail.com>
 : 
 : http://localhost:8088/exist/restxq/ontology?group=document&type=Bill?offset=1&limit=5
 :
:)

declare
    %rest:path("/ontology")
    %rest:POST("{$body}")    
    %rest:form-param("role", "{$role}", "bungeni.Anonymous")     
    %rest:form-param("group", "{$group}", "*")    
    %rest:form-param("type", "{$type}", "*")
    %rest:form-param("offset", "{$offset}", 1)
    %rest:form-param("limit", "{$limit}", 10) (: set a default and then return next offset for next batch :)   
    %rest:form-param("search", "{$search}", "none")
    %rest:form-param("status", "{$status}", "*")
    %rest:form-param("daterange", "{$daterange}", "*")
    %output:method("json")
    
    (: Cascading collection based on parameters given, default apply when not given explicitly by client :)
    function local:documents(
        $body as xs:string*,
        $role as xs:string*,        
        $group as xs:string*,
        $type as xs:string*, 
        $offset as xs:int*,
        $limit as xs:int*,
        $search as xs:string*,
        $status as xs:string*,
        $daterange as xs:string*) {
        <docs>
            <role>{$role}</role>         
            <group>{$group}</group>           
            <type>{$type}</type>   
            <offset>{$offset}</offset>
            <next-offset>{($offset+$limit)}</next-offset>
            <limit>{$limit}</limit>
            <search>{$search}</search>
            <status>{$status}</status>
            <daterange>{$daterange}</daterange>
            {
                let $acl-filter-attr := cmn:get-acl-permission-as-attr-for-role($role)
                let $acl-filter-node := cmn:get-acl-permission-as-node-for-role($role)
                
                let $token-roles := tokenize($role,",")
                let $roles :=   for $arole at $pos in $token-roles
                                let $counter := count($token-roles)
                                return (
                                    fn:concat("bu:control[",cmn:get-acl-permission-as-attr-for-role($arole),"]"),
                                    if($pos lt $counter) then "and" else () )
                
                let $roles-string := fn:string-join($roles," ")
                  
                let $coll := bun:get-all-by-role($roles-string)            
            
                (: get entire collection OR trim by group types mainly: document, group, membership... :)
                let $coll-by-group :=  
                    switch($group)
                        case "*"
                            return $coll
                        default
                            return
                                for $dgroup in tokenize($group,",")
                                return $coll[@for=$dgroup]   
                
                (: from $coll-by-group get collection by docTypes mainly: Bill, Question, Motion... :)
                let $coll-by-doctype := 
                    switch($type)
                        case "*"
                            return $coll-by-group
                        default
                            return
                                for $dtype in tokenize($type,",")
                                return $coll-by-group/child::*/bu:docType[bu:value=$dtype]/ancestor::bu:ontology
                                
                (: trim $coll-by-doctype subset by bu:status :)
                let $coll-by-status := 
                    switch($status)
                        case "*"
                            return $coll-by-doctype
                        default
                            return
                                for $dstatus in $coll-by-doctype
                                where $dstatus/child::*/bu:status/bu:value eq $status 
                                return $dstatus  
                                
                (: trim $coll-by-status subset by bu:statusDate :)
                let $coll-by-statusdate := 
                    switch($daterange)
                        case "*"
                            return $coll-by-status
                        default
                            return
                                for $match in $coll-by-status
                                let $dates := tokenize($daterange,",")
                                return 
                                    $match/child::*[xs:dateTime(bu:statusDate) gt xs:dateTime(concat($dates[1],"T00:00:00"))]
                                    [xs:dateTime(bu:statusDate) lt xs:dateTime(concat($dates[2],"T23:59:59"))]/ancestor::bu:ontology                        

                (: finally search the subset collection if and only if there are is a search param given :)    
                let $ontology_rs := 
                    switch($search)
                        case "none" return
                            for $ontology in $coll-by-statusdate
                            return
                                <doc>{$ontology}</doc>                        
                        default
                            return
                                bun:adv-ft-search($coll-by-statusdate, $search)                          
                  
                (: strip nodes with failing permissions recursively to all nodes :)
                let $ontology_strip_deep := for $doc in $ontology_rs
                                            return bun:treewalker-acl($acl-filter-node,document{$doc})                                 
                        
                (: strip classified nodes :)
                let $ontology_strip := functx:remove-elements-deep($ontology_strip_deep,
                                    ('bu:bungeni','bu:legislature','bu:versions', 'bu:permissions', 
                                    'bu:audits', 'bu:attachments', 'bu:signatories','bu:changes', 'bu:workflowEvents'))
                                                      
                return 
                    (   <total>{count($ontology_rs)}</total>,
                        subsequence($ontology_strip,$offset,$limit)
                     )                  
                    (:$acl-filter-node:)
                    (:<count>{count($ontology_rs)}</count>:)
            }
        </docs>
};

declare
    %rest:GET
    %rest:path("/{$country-code}/{$type}")
    
    function local:documents($country-code as xs:string, $type as xs:string) {
        <docs>
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value eq $type]
            }
        </docs>
};

declare
    %rest:GET
    %rest:path("/{$country-code}/{$type}/{$docid}")
    
    function local:documents($country-code as xs:string, $type as xs:string, $docid as xs:int) {
        <docs>
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:document[bu:docType/bu:value eq $type][bu:docId = $docid]/parent::node()
            }
        </docs>
};

declare
    %rest:GET
    %rest:path("/unknown/{$name}")
    function local:goodbye($name) {
        (<rest:response>
            <http:response status="404"/>
        </rest:response>,
        <goodbye>{$name}</goodbye>
        )
};

(: 
 : Test list attachments
 :  :)
declare function local:get-mock-attachments() as node(){
    
    let $coll := <collection>
        {collection('/db/bungeni-xml')/bu:ontology/bu:attachments/bu:attachment}
        </collection>
        
    return $coll 
};

(: 
 : Retrieve collection of attachments
 : :)
declare function local:get-matched-attachments($match as xs:string) as node(){
        
    collection('/db/bungeni-xml')/bu:ontology[@for='document']
    [bu:document[bu:docType[bu:value[. = 'Bill']]][bu:status[bu:value[. = 'received']]]]
    /bu:attachments/bu:attachment[bu:type[bu:value[. = 'main-xml']]]
    [bu:name[matches(., $match, 'i')]]
};

(: 
 : Retrieve an attachment by name
 :  :)
declare function local:get-attachment-hash-by-name($name as xs:string){
    
    collection('/db/bungeni-xml')/bu:ontology[@for='document']
    [bu:document[bu:docType[bu:value[. = 'Bill']]][bu:status[bu:value[. = 'received']]]]
    /bu:attachments/bu:attachment[bu:type[bu:value[. = 'main-xml']]]
    [bu:name[.=$name]]/bu:attachmentHash/string()
};

(: 
 : Search for attachments by partial name
 :  and return list with hash and name
 :  :)
declare
    %rest:POST
    %rest:path("/attachments")
    %rest:form-param("search", "{$search}","")  
    %rest:form-param("page", "{$page}", "1") 
    %rest:form-param("perPage", "{$perPage}", "2") 
    %output:method("xml")
    function local:search-for-attachments($search as xs:string*, $page as xs:string*, $perPage as xs:string*){
        
        try{
            let $startItem := if (xs:integer($page) eq 1) then
                                    xs:integer(1)
                                else
                                    ((xs:integer($page)-1)*xs:integer($perPage))+1
                    
            let $allResultsMatched := local:get-matched-attachments($search)
            let $page := if(count($allResultsMatched) eq 1) then
                            xs:integer(1)
                        else
                            $page
                        
            let $pagedResult := for $i in subsequence($allResultsMatched, xs:integer($startItem), xs:integer($perPage))
                    return 
                        <attachment>
                            <hash>{$i/bu:attachmentHash/string()}</hash>
                            <name>{$i/bu:name/string()}</name>
                            <title>{$i/bu:title/string()}</title>
                            {if(not(empty($i/bu:description/string()))) then
                                <descr>{$i/bu:description/string()}</descr>
                            else
                                <descr>None</descr>}
                            <statusDate>{datetime:format-dateTime(xs:dateTime($i/bu:statusDate/string()),"EEE, d MMM yyyy HH:mm:ss Z")}</statusDate>
                        </attachment>
            
            return 
                <attachments>{
                    if(empty($pagedResult)) then
                        <totalCount>0</totalCount>
                    else
                        (<totalCount>{count($allResultsMatched)}</totalCount>,
                        <page>{$page}</page>,
                        <perPage>{$perPage}</perPage>,
                        $pagedResult)
                }</attachments>
        }
        catch *{
            
            <attachments>
                <totalCount>0</totalCount>
                <error>
                    <errorCode>{$err:code}</errorCode>
                    <errorDescr>{$err:description}</errorDescr>
                    <errorMod>{$err:module, "(", $err:line-number, ",", $err:column-number, ")"}</errorMod>
                </error>
            </attachments>    
        }
};

(: 
 : Test search GET attachment list
 :  :)
declare
    %rest:GET
    %rest:path("/test/get/attachments")
    %rest:form-param("search", "{$search}","")  
    %rest:form-param("page", "{$page}", "1") 
    %rest:form-param("perPage", "{$perPage}", "2") 
    %output:method("xml")
    function local:expose-get-search-attachmemnts($search as xs:string*, $page as xs:string*, $perPage as xs:string*){
      
       local:search-for-attachments($search, $page, $perPage)   
};

(: 
 : Get an attachment by name
 :  and return document
 :  :)    
declare
    %rest:POST
    %rest:path("/attachment")
    %rest:form-param("name", "{$name}","*")  
    %output:method("xml")
    function local:get-attachment($name as xs:string*){
        
      util:parse(util:binary-to-string(util:binary-doc(concat("/db/bungeni-atts/", local:get-attachment-hash-by-name($name)))))
};


(: 
 : Test expose GET attachment hash by name
 :  :)
declare
    %rest:GET
    %rest:path("/test/get/attachment/hash")
    %rest:form-param("name", "{$name}","*")  
    %output:method("xml")
    function local:expose-get-attachment-hash-by-name($name as xs:string*){
        
        <attachmentDetails>
            <hash>{local:get-attachment-hash-by-name($name)}</hash>      
            <name>{$name}</name>
        </attachmentDetails>
    };


(: 
 : Test GET attachment
 :  :)
declare
    %rest:GET
    %rest:path("/test/get/attachment")
    %rest:form-param("name", "{$name}","*")  
    %output:method("xml")
    function local:expose-get-attachment($name as xs:string*){
        
      local:get-attachment($name)
};

(: 
 : Authenticate and delete amendment document from /db/bungeni-xml
 :  :)
declare 
    %rest:POST
    %rest:path("/amendment/remove")	
    %rest:form-param("username","{$username}")
    %rest:form-param("password","{$password}")
    %rest:form-param("filename","{$filename}")
    %output:method("xml")
    function local:pop-document($username as xs:string*, $password as xs:string*, $filename as xs:string*){
        
        try{
            
            let $password := if ($password eq "*") then 
                                "" 
                            else    
                                $password
            let $login := xmldb:login("/db/bungeni-xml", $username, $password)
            let $store-return-status := xmldb:remove("/db/bungeni-xml", $filename)
                return
                    <popAttachment>
                        <success>True</success>
                        <attachmentName>{$filename}</attachmentName>
                    </popAttachment> 
        }
        catch *{
            
            <popAttachment>
                <success>False</success>
                <attachmentName>{$filename}</attachmentName>
                <error>
                    <errorCode>{$err:code}</errorCode>
                    <errorDescr>{$err:description}</errorDescr>
                    <errorMod>{$err:module, "(", $err:line-number, ",", $err:column-number, ")"}</errorMod>
                </error>
            </popAttachment> 
        }
  };

(:
 : Authenticate and save amendment document from /db/bungeni-xml
 :)
declare
    %rest:POST
    %rest:path("/amendment/save")
    %rest:form-param("username","{$username}")
    %rest:form-param("password","{$password}")
    %rest:form-param("filename","{$filename}")
    %rest:form-param("document","{$document}")
    %output:method("xml")
    function local:push-document($username as xs:string*, $password as xs:string*, $filename as xs:string*, $document as xs:string*){
        
         try{
            
            let $password := if ($password eq "*") then 
                                "" 
                            else    
                                $password
            let $login := xmldb:login("/db/bungeni-xml", $username, $password)
            let $store-return-status := xmldb:store("/db/bungeni-xml", $filename, $document)
                return
                    <pushAmendment>
                        <success>True</success>
                        <amendmentName>{$filename}</amendmentName>
                    </pushAmendment> 
        }
        catch *{
            
            <pushAmendment>
                <success>False</success>
                <amendmentName>{$filename}</amendmentName>
                <error>
                    <errorCode>{$err:code}</errorCode>
                    <errorDescr>{$err:description}</errorDescr>
                    <errorMod>{$err:module, "(", $err:line-number, ",", $err:column-number, ")"}</errorMod>
                </error>
            </pushAmendment> 
        }
 };


(:
 :DEPRECATED
 :)
declare 
    %rest:POST
    %rest:path("/amendment/details")
    %rest:form-param("filename", "{$filename}","*")  
    %output:method("xml")
    function local:get-amendment-details-by-attachment-file-name($filename as xs:string*){
    
        let $documentsDetail := for $i in collection('/db/bungeni-xml')
                [an:akomaNtoso/an:amendment/an:meta/an:references/an:activeRef[@href=$filename]]
            return
                <amendmentDocument>
                    <name>{util:document-name($i)}</name>
                    <ref>{$i/an:akomaNtoso/an:amendment/an:amendmentBody/an:amendmentContent/
                    an:block[@name='changeBlock']/an:mod/an:quotedStructure[1]/an:item/@id/string()}</ref>
                </amendmentDocument>
                
        return <amendments>{$documentsDetail}</amendments>
};

(: 
 : return's collection of amendments
 :  :)
declare 
    %rest:POST
    %rest:path("/amendments")
    %rest:form-param("filename", "{$filename}","*")  
    %output:method("xml")
    function local:get-amendments-by-attachment-file-name($filename as xs:string*){
    
        let $amendmentDocuments := for $i in collection('/db/bungeni-xml')
                [an:akomaNtoso/an:amendment/an:meta/an:references/an:activeRef[@href=$filename]]
            return
                <amendmentDocument>
                    <name>{util:document-name($i)}</name>
                    <ref>{$i/an:akomaNtoso/an:amendment/an:amendmentBody/an:amendmentContent/
                    an:block[@name='changeBlock']/an:mod/an:quotedStructure[1]/an:item/@id/string()}</ref>
                    {$i}
                </amendmentDocument>
                
        return <amendments>{$amendmentDocuments}</amendments>
};

(: 
 : expose function return amendment collection
 :  :)
declare
    %rest:GET
    %rest:path("/test/get/amendments")
    %rest:query-param("filename","{$filename}","*")
    %output:method("xml")
    function local:expose-get-amendments-by-attachment-file-name($filename as xs:string*){
        
        local:get-amendments-by-attachment-file-name($filename)
};

(:
 : expose get amendment details by attachment file name	
 :)
declare 
    %rest:GET
    %rest:path("/test/get/amendment/details")
    %rest:query-param("filename", "{$filename}","*")  
    %output:method("xml")
    function local:expose-get-amendment-details-by-attachment-file-name($filename as xs:string*){
    
        local:get-amendment-details-by-attachment-file-name($filename)
};

(:
 : fetch amendment by file name	
 :)
declare
    %rest:POST
    %rest:path("/amendment")
    %rest:form-param("filename","{$filename}","*")
    %output:method("xml")
    function local:get-amendment-by-file-name($filename as xs:string*){
  
        doc(concat("/db/bungeni-xml/", $filename))
};

(:
 :expose get amendment by file name
 :)
declare
    %rest:GET
    %rest:path("/test/get/amendment")
    %rest:form-param("filename","{$filename}","*")
    %output:method("xml")
    function local:expose-get-amendment-by-file-name($filename as xs:string*){
  
        local:get-amendment-by-file-name($filename)
};

local:goodbye("unknown")
