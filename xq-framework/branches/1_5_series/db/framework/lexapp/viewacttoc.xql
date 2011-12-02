xquery version "1.0";

import module namespace lex="http://exist.bungeni.org/lex" at "lex.xqm";
declare namespace request="http://exist-db.org/xquery/request";

declare option exist:serialize "method=xml media-type=application/xml";

declare function local:get-toc() as element() {
    let $actid := xs:string(request:get-parameter("actid", ""))
    return lex:get-toc($actid)    
  };

(: set a request attribute for the next script in the execution chain :)
request:set-attribute("xml.doc", local:get-toc()) 




