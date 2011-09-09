xquery version "1.0";

import module namespace lexpage="http://exist.bungeni.org/lexpage" at "modules/lexpage.xqm";

(: import module namespace json="http://www.json.org"; :)

declare option exist:serialize "method=xhtml media-type=text/html output-doctype=yes doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN";

let $xml_title := "Index Page"

let $page_info := <page>
                    <title>Kenya Law Search</title>
                    <heading>Legislative Search</heading>
                   </page>

return
   lexpage:display-page($page_info)