xquery version "3.0";

declare namespace  epub="http://exist-db.org/xquery/epub";
import module namespace scriba = "http://scribaebookmake.sourceforge.net/1.0/" at "scriba.xqm";

let $pages := for $match in collection("/db/bungeni-xml")
                  return <page>{$match}</page>

let $book := scriba:create-book("en","Bungeni State of Documents", <creators/>,<pages>{$pages}</pages>)

let $test := epub:scriba-ebook-maker($book)

let $header := response:set-header("Content-Disposition" , concat("attachment; filename=",  "output.epub")) 
let $out := response:stream-binary($test, "application/epub+zip")     
return <xml /> 