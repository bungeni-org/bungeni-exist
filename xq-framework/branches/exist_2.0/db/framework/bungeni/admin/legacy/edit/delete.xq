xquery version "3.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml indent=yes"; 
(: delete.xq :)

let $collection := '/db/framework/bungeni/admin/legacy/data'
 
(: this script takes the integer value of the id parameter passed via get :)
let $id := xs:integer(request:get-parameter('id', ''))

(: this logs you into the collection :)
let $login := xmldb:login($collection, 'admin', '')

(: this constructs the filename from the id :)
let $file := concat($id, '.xml')

(: this deletes the file :)
let $store := xmldb:remove($collection, $file)

return
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
       <title>Delete Confirmation</title>
    </head>
    <body>
    <p>Item {$id} has been deleted.</p>
    <a href="../views/list-items.xq">List all items</a>
    </body>
</html>
