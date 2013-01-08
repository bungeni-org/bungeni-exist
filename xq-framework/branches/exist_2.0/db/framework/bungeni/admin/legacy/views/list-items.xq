xquery version "3.0";

declare option exist:serialize "method=html media-type=text/html indent=yes";
 
let $collection := '/db/framework/bungeni/admin/legacy/data'

return

<html>
   <head>
      <title>Documents</title>
      <style language="text/css">
          <![CDATA[
            body {font-family: Arial, Helvetica; sans-serif;}
           ]]>
      </style>
   </head>
   <body>
   <h1>Legislative Documents</h1>
   <table>
       <thead>
       <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Status</th>
          <th>View</th>
          <th>Edit</th>
          <th>Delete</th>
       </tr>
    </thead>
    <tbody>{
      for $item in collection($collection)/subscription
         let $id := $item/id/text()
      return
         <tr>
            <td>{$item/id/text()}</td>
            <td>{$item/username/text()}</td>
            <td>{$item/status/text()}</td>
             <td><a href="view-item.xq?id={$id}">View</a></td>
             <td><a href="../edit/edit.xq?id={$id}">Edit</a></td>
             <td><a href="../edit/delete.xq?id={$id}">Delete</a></td>
         </tr> 
   }</tbody></table>
   <a href="../edit/edit.xq?new=true">New</a>
   </body>
</html>