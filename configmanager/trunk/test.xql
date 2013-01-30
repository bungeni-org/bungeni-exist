xquery version "3.0";

(:declare option exist:serialize "method=xhtml media-type=application/xhtml+html";:)

(:
    Flattens the types.xml structure to get all the 3 archtypes 
    somehow.
    Returns 3 nodesets
:)
declare function local:getChildren($e as node(), $pID as xs:string?) as element()*
{
  for $i at $p in $e/(child::*)
  let $ID := if ($pID) then concat($pID,".",$p) else "1"
  return $i | local:getChildren($i,$ID)
};

declare function local:ThreeInOne($flattened as node()) {
    for $doc in $flattened/child::*
    group by $key := node-name($doc)
    return 
        <archetype key="{$key}">
         {$doc}
        </archetype>
};


let $d := doc("/db/apps/configmanager/working/live/bungeni_custom/types.xml")/types
let $flattened := <grouped>{local:getChildren($d,())}</grouped>
let $onedoc := <types>{local:ThreeInOne($flattened)}</types>
return $onedoc

(:<ul>
    <li>List item one</li>
    <li>List item two with subitems:
        <ul>
            <li>Subitem 1</li>
            <li>Subitem 2</li>
        </ul>
    </li>
    <li>Final list item</li>
</ul>:)
