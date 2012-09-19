xquery version "3.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml indent=yes";  
(: update.xq :)
 
let $collection := '/db/framework/bungeni/admin/legacy/data'
 
(: this is where the form "POSTS" documents to this XQuery using the POST method of a submission :)
let $item := request:get-data()
 
(: this logs you into the collection :)
let $login := xmldb:login($collection, 'admin', '')

(: get the id out of the posted document :)
let $id := $item/subscription/id/text()

let $file := concat($id,'.xml')
 
(: this saves the new file and overwrites the old one :)
let $store := xmldb:store($collection, $file, $item)

return
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
       <title>Update Confirmation</title>
    </head>
    <body>
    <p>Item {$id} has been updated.</p>
    <a href="../views/list-items.xq">List all items</a>
    </body>
</html>