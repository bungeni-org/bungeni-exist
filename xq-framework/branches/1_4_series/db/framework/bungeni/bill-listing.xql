xquery version "1.0";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";

import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";
import module namespace bungenicommon="http://bungeni.org/pis/common" at "common.xqm";

(:

Returns a AkomaNtoso document from the requested act identifier ,
the document is set into a request parameter.

This script is called from controller.xql and forwards to translate-titlesearch.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

bun:get-bills() 