xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all roles :)
declare function local:roles() as node() * {
    let $count := count(local:getMatchingTasks()/roles/role)
    for $role at $pos in local:getMatchingTasks()/roles/role
        return
            <tr>
                <td>{data($role)}</td>
                <td><a href="javascript:dojo.publish('/role/edit',['role','{$role}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/role/delete',['role','{$role}']);">delete</a></td>
            </tr>
};

declare function local:getMatchingTasks() as node() * {
    let $doc := let $form := doc('/db/config_editor/bungeni_custom/forms/custom.xml')
                let $xsl := doc('/db/config_editor/xsl/forms_split_attrs.xsl')
                return transform:transform($form, $xsl, <parameters>
                                                            <param name="fname" value="custom" />
                                                         </parameters>)
    return $doc
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","all"))
let $showing := xs:string(request:get-parameter("tab","fields"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>List Roles</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">  	
            <div style="width: 100%; height: auto;">
                    <h1>Custom / Roles / {$docname} </h1>
                    <br/>
                    <table class="listingTable" style="width:auto;">
                        <tr>                      			 
                            <th>Role</th>
                            <th colspan="2">Actions</th>
                        </tr>
                        {local:roles()}
                    </table>
                    <span>
                        <a href="javascript:dojo.publish('/role/add',['role','new']);">add role</a>
                    </span>  
            </div>                    
        </div>
    </body>
</html>