module namespace bun = "http://exist.bungeni.org/bun";
import module namespace lexcommon = "http://exist.bungeni.org/lexcommon" at "common.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xh = "http://www.w3.org/1999/xhtml";

(:
Library for common lex functions
uses lexcommon
:)


(: Search for the doc matching the actid in the parameter and return the document :)
declare function bun:get-doc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso
};

    
(:
declare function lex:paginator($totalcount as xs:integer, $offset as xs:integer, $limit as xs:integer) as element(xh:div) {
<xh:div id="paginator>
{
     return $totalcount

}
<xh:div>
};
:)


declare function bun:get-acts() as element(xh:ul) {
<xh:ul id="list-toggle" class="ls-row" style="clear:both">
{    
for $match in subsequence(collection(lexcommon:get-lex-db())//akomaNtoso,1,15)
   let $actid := $match//docNumber[@id='ActIdentifier']/text()
   return element xh:li{
 			element xh:a {
                attribute href { fn:concat("actview?actid=", $actid, "&amp;pref=ts") },
                $match//docTitle[@id='ActTitle']/text()
            },
            element xh:span {
                "+"
            },
            element xh:div {
                attribute class { "doc-toggle" },
                element xh:table {
                    attribute class {"doc-tbl-details"},
                    element xh:tr {
                        element xh:td {
                            attribute class { "labels" },                            
                            "id:"
                        },                        
                        element xh:td {
                            $match//docNumber[@refersTo='#TheActNumber']/text()
                        }
                    },
                    element xh:tr {
                        element xh:td {
                            attribute class { "labels" },                            
                            "moved by:"
                        },                        
                        element xh:td {
                            $match//docDate[@refersTo='#CommencementDate']/text()
                        }
                    },
                    element xh:tr {
                        element xh:td {
                            attribute class { "labels" },                            
                            "status:"
                        },                        
                        element xh:td {
                            $match//docTitle[@refersTo='#TheActLongTitle']/text()
                        }
                    },
                    element xh:tr {
                        element xh:td {
                            attribute class { "labels" },                            
                            "status date:"
                        },                        
                        element xh:td {
                            $match//docDate[@refersTo='#AssentDate']/text()
                        }
                    }                          
    			}
    	  }
	}
}
</xh:ul>
};


(: Search for the doc matching the actid in the parameter and return the tabel of contents :)
declare function bun:get-toc($actid as xs:string) as element() {
     for $match in collection(lexcommon:get-lex-db())//akomaNtoso//docNumber[@id='ActIdentifier']
      let $c := string($match)
      where $c = $actid
    return $match/ancestor::akomaNtoso//preamble/toc
};


declare function bun:get-act($actid as xs:string, $pref as xs:string, $xslt as xs:string) {
    (: First get the act document :)
    let $doc := bun:get-doc($actid),
    (: Next get the doc of the XSLT :)   
     $doc-xslt := lexcommon:get-xslt($xslt),
    (: Now transform the doc with the XSLT :)
     $doc-transformed := transform:transform($doc, 
		$doc-xslt,
        <parameters>
            <param name="pref" value="{$pref}" />
        </parameters>)
     return $doc-transformed
};