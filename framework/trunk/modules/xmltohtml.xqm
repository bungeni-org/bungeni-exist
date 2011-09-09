module namespace xmltohtml = "http://exist.bungeni.org/xmltohtml";
declare namespace util="http://exist-db.org/xquery/util";


(:-
XML to HTML Viewer 

Converts XML to verbose HTML 
 
:)


(: sequence dispatcher :)
declare function xmltohtml:xmltohtml($input as node()*, $depth as xs:integer) as item()* {
let $left-margin := concat('margin-left: ', ($depth * 5), 'px' )
for $node in $input
   return 
      typeswitch($node)
        case text() return normalize-space(<span class="d">{$node}</span>)
        case element()
           return
              <div class="element" style="{$left-margin}">
                    <span class="t">&lt;{name($node)}</span>
                    { (: for each attribute create two spans for the name and value :)
                     for $att in $node/@*
                        return
                           (
                              <span class="an"> {name($att)}=</span>,
                              <span class="av">"{string($att)}"</span>
                           )
                    }
                    {normalize-space(<span class="t">&gt;</span>)}
                    { (: now get the sub elements :)
                       for $c in $node
                          return xmltohtml:xmltohtml($c/node(), $depth + 1)
                    }
                    <span class="t">&lt;/{name($node)}&gt;</span>
             </div> 
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return $node
};



