xquery version "1.0";

declare option exist:serialize "method=xml media-type=text/xml";

declare function local:copy-filter-elements(
      $element as element()) as element() {
   element {node-name($element) }
             { $element/@*,
               for $child in $element/node()[not(namespace-uri(.)='http://info.org')]
                  return if ($child instance of element())
                    then local:copy-filter-elements($child)
                    else $child
           }
};


let $f1 := <file xmlns="http://one.org">
			<name>hello</name>
		    <info:name xmlns:info="http://info.org">Ashok</info:name>
		   </file>

return 
	local:copy-filter-elements($f1)