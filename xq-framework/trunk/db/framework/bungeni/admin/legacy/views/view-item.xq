xquery version "1.0";

declare option exist:serialize "method=xhtml media-type=text/html";

let $id := request:get-parameter('id', '')

(: check for required parameters :)
return

if (not($id))
    then (
    <error>
        <message>Parameter "id" is missing.  This argument is required for this web service.</message>
    </error>)
    else
      let $server-port := substring-before(request:get-url(), '/exist/rest/db/') 
      let $collection := '/db/framework/bungeni/admin/legacy/data'
return
<html>
   <head>
      <title>View Document</title>
       <style language="text/css">
          <![CDATA[
            body {font-family: Arial, Helvetica; sans-serif;}
           ]]>
      </style>
   </head>
   <body>
   <h1>View Document</h1>
   {let $item := collection($collection)/subscription[id = $id]
      return
         <table>
             <tr><td>User:</td><td>{$item/username/text()}</td></tr>
             <tr><td>Password:</td><td>{$item/password/text()}</td></tr>
             <tr><td>Area:</td><td>{$item/area/text()}</td></tr>
             <tr><td>Status:</td><td>{$item/status/text()}</td></tr>

          </table>
   }
   <a href="../edit/edit.xq?id={$id}">Edit Item</a>
             <a href="../edit/delete.xq?id={$id}">Delete Item</a>
   <p><a href="list-items.xq">List all items</a></p>
   </body>
</html>