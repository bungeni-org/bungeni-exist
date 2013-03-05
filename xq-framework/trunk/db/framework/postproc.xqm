xquery version "3.0";

module namespace pproc = "http://exist.bungeni.org/pproc";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace bu="http://portal.bungeni.org/1.0/";

(:
Library to do Post Process and validation of references especially on:
    ~Signatory->Users/Person
    ~ParliamentaryItems->Events, 
    ~Groupsittings->ParliamentaryItems
:)

(: Default Variables :)
declare variable $pproc:PARL-ID := 2;

(:~
    This method inserts <bu:person/> node in the bu:signatory based on bu:userId provided by each 
    signatory node in a parliamentary document.
    
    @return nothing or <response type="error">
                            <code/>
                            <desc/>
                        </response>
:)
declare function pproc:update-signatories() {

    try {
        (: iterate through all documents with bu:signatory nodes and update with retrived Person's URI :)
        for $signatory in collection(cmn:get-lex-db())/bu:ontology[@for='document']/bu:signatories/bu:signatory
        let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[bu:userId eq $signatory/bu:userId][1]
        let $user-uri := $user/@uri
        let $user-name := concat($user/bu:lastName,", ",$user/bu:firstName)
        return 
            (: safe-guarding multiple <bu:person/> nodes since 2012! :)
            if (empty($signatory/bu:person)) then
                update insert <bu:person isA="TLCPerson" href="{$user-uri}" showAs="{$user-name}" /> into $signatory
            else
                ()
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};

(:~
    This method inserts <bu:person/> node in the bu:member based on bu:userId provided by each 
    signatory node in a parliamentary document.
    
    @return nothing or <response type="error">
                            <code/>
                            <desc/>
                        </response>
:)
declare function pproc:update-groups() {

    try {
        (: iterate through all groups with bu:member nodes and update with retrived Person's URI :)
        for $membership in collection(cmn:get-lex-db())/bu:ontology[@for='group']/bu:members/bu:member
        let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[bu:userId eq $membership/bu:userId][1]
        let $user-uri := $user/@uri
        let $user-name := concat($user/bu:lastName,", ",$user/bu:firstName)
        return 
            (: safe-guarding multiple <bu:person/> nodes since 2012! :)
            if (empty($membership/bu:person)) then
                update insert <bu:person isA="TLCPerson" href="{$user-uri}" showAs="{$user-name}" /> into $membership
            else
                ()
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};

(:~
    This method replaces place-holder for referenced document within an Event: First get all non-Event documents, if 
    they contain workflowEvents, we use the docIds to locate the Event documents being referred to and update 
    the refersTo href attributes. Consequently, workflowEvents in the non-Event documents are also updated with 
    the URI of the gotten Event.
:)
declare function pproc:update-events() {

    try {
        for $wfe in collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value ne 'Event']/ancestor::bu:document/bu:workflowEvents/bu:workflowEvent
        let $doc-node := $wfe/ancestor::bu:document
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        let $event := collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value eq 'Event']/ancestor::bu:document[bu:docId eq $wfe/bu:docId]
        return (
                update replace $event/bu:eventOf/bu:refersTo/@href with $docuri,
                update replace $doc-node/bu:workflowEvents/bu:workflowEvent[bu:docId=$wfe/bu:docId]/@href with if($event/@uri) then $event/@uri else "E_DOC_NOT_FOUND"
               )
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }
    
};

(:~
    This method replaces place-holder for referenced document within an Attachment: First get all non-Attachment documents, if 
    they contain Attachment nodes, we use the attachmentIds to locate the Attachment documents being referred to and update 
    the refersTo href attributes. Consequently, attachments in the non-Attachment documents are also updated with 
    the URI of the gotten Attachment.
    
    !+NOTE (ao, 18th Dec 2012) Work-in-Progress, not yet tested to be working
:)
declare function pproc:update-attachments() {

    try {
        for $attnode in collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value ne 'Attachment']/ancestor::bu:document/bu:attachments/bu:attachment
        let $doc-node := $attnode/ancestor::bu:document
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        let $attdoc := collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value eq 'Attachment']/ancestor::bu:document[bu:attachmentId eq $attnode/bu:attachmentId]
        return (
                update replace $attdoc/bu:attachmentOf/bu:refersTo/@href with $docuri,
                update insert attribute href { concat(xs:string($docuri),"@/attachment",$attnode/bu:attachmentId) } into $doc-node/bu:attachments/bu:attachment[bu:attachmentId=$attnode/bu:attachmentId]
               )
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }
    
};


(:
    This method updates itemSchedules with with item URI as reference to the 
    actual document. Iterates through all the groupsitting documents' itemSchedules, and then using 
    the itemId==docId condition to retrieve a URI which is injected to itemSchedule as bu:document node 
    with a TLCReference attribute.
:)
declare function pproc:update-sittings() {

    try {
        for $anItem in collection(cmn:get-lex-db())/bu:ontology/bu:groupsitting/bu:itemSchedules/bu:itemSchedule
        let $doc-node := collection(cmn:get-lex-db())/bu:ontology/bu:document[bu:docId eq $anItem/bu:itemId]
        let $docId := $doc-node/bu:docId
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        return 
            if ($anItem/bu:itemType/bu:value ne 'heading' and empty($anItem/bu:document)) then
                update insert <bu:document isA="TLCReference" href="{$docuri}" id="bungeniDocument" /> into $anItem[bu:itemId eq $docId]
             else
                 ()
    }
    catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};

(:
 : Updates all with URI as parameter 
 :)
declare function pproc:update-document($uri as xs:string) {

    try {
        (: it's signatories :)    
        let $doc := collection(cmn:get-lex-db())/bu:ontology/bu:document[if (@uri) then (@uri=$uri) else (@internal-uri=$uri)]/ancestor::bu:ontology
        for $signatory in $doc/bu:signatories/bu:signatory
        let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[bu:userId eq $signatory/bu:userId][1]
        let $user-uri := $user/@uri
        let $user-name := concat($user/bu:lastName,", ",$user/bu:firstName)
        let $up-sigs := if (empty($signatory/bu:person)) then update insert <bu:person isA="TLCPerson" href="{$user-uri}" showAs="{$user-name}" /> into $signatory else ()
        return 
            (),            
        (: it's sittings :)
        let $doc := collection(cmn:get-lex-db())/bu:ontology/bu:groupsitting[@uri=$uri]/ancestor::bu:ontology
        for $anItem in $doc/bu:ontology/bu:groupsitting/bu:itemSchedules/bu:itemSchedule
        let $doc-node := collection(cmn:get-lex-db())/bu:ontology/bu:document[bu:docId eq $anItem/bu:itemId]
        let $docId := $doc-node/bu:docId
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        return 
            if ($anItem/bu:itemType/bu:value ne 'heading' and empty($anItem/bu:document)) then
                update insert <bu:document isA="TLCReference" href="{$docuri}" id="bungeniDocument" /> into $anItem[bu:itemId eq $docId]
             else
                 (),
            (: Adding sitting's href :)
        let $sitting := collection(cmn:get-lex-db())/bu:ontology/bu:groupsitting[@uri=$uri]/ancestor::bu:ontology
        let $group-node := collection(cmn:get-lex-db())/bu:ontology/bu:group[bu:committeeId eq $sitting/bu:legislature/bu:group/bu:groupId]
        let $groupId := $group-node/bu:committeeId
        return 
            update insert attribute href { xs:string(data($group-node/@uri)) } into $sitting/bu:legislature/bu:group,                 
        (: groups :)
        let $doc := collection(cmn:get-lex-db())/bu:ontology[@for='group']/bu:group[@uri=$uri]/ancestor::bu:ontology
        for $membership in $doc/bu:members/bu:member
        let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[bu:userId eq $membership/bu:userId][1]
        let $user-uri := $user/@uri
        let $user-name := concat($user/bu:lastName,", ",$user/bu:firstName)
        return 
            (: safe-guarding multiple <bu:person/> nodes since 2012! :)
            if (empty($membership/bu:person)) then
                update insert <bu:person isA="TLCPerson" href="{$user-uri}" showAs="{$user-name}" /> into $membership
            else
                ()
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};
