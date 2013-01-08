xquery version "3.0";

(: this takes the list of boundaries and converts it to a selection list for the form :)

let $doc := 'areas.xml'

return
<codes>
    <itemset name="area">{
       for $item in doc($doc)/boundaries/boundary/@area
          order by $item
       return
       <item>
          <label>{string($item)}</label>
          <value>{string($item)}</value>
       </item>
    }</itemset>
</codes>
