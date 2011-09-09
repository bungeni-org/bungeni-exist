module namespace lexcustom = "http://exist.bungeni.org/lexcustom";
import module namespace lexcommon = "http://exist.bungeni.org/lexcommon" at "common.xqm" ;
(:
Custom css overrides loaded from the filesystem
:)
declare function lexcustom:get-custom-css() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
     <link rel="stylesheet" type="text/css" href="css/custom.css"/>
 };
 
 
 
 (:
 This must be included in the <head /> of every page.
 It initializes the YUI namespace
 :)
 declare function lexcustom:get-root-js() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
       <script type="text/javascript">
       /** BeginRenderedBy(lexcustom:get-root-js()) **/
        /** define an object namespace **/
        YAHOO.namespace("kenyalex.bungeni");
        var Dom = YAHOO.util.Dom,
                Event = YAHOO.util.Event,
                log = YAHOO.log;
        YAHOO.kenyalex.bungeni.COLLECTION = "{lexcommon:get-lex-db()}";        
         /** EndRenderedBy(lexcustom:get-root-js()) **/          
        </script>   
 };
 
 (:
 Common helper JS functions, which for technical reasons cannot be loaded in XQuery.
 e.g. the ampersand character in JS is not allowed in XQuery
 :)
 declare function lexcustom:get-file-js() as element() {
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
    <script src="scripts/lex.js" type="text/javascript" />
 };
 
  