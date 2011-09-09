module namespace jquery = "http://exist.bungeni.org/jquery";
declare namespace util="http://exist-db.org/xquery/util";


(:-
JQuery Includes
: 
:)


(:
get the generic js files 
:)
declare function jquery:get-generic-js() as element(){
    <script src="jquery/jquery.min.js" />
 };


(:
get the custom js files 
:)
declare function jquery:get-custom-js() as element(){
    <script src="jquery/custom.js" />
 };

