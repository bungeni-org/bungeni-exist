xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all tasks matching the query :)
declare function local:main() as node() * {
    let $form-id := request:get-parameter("form-id", "")
    for $formsui in local:getMatchingTasks()
        return
            <tr>
                <td class="selectorCol"><input type="checkbox" dojotype="dijit.form.CheckBox" value="{data($formsui/@id)}" /></td>
                <td>{data($formsui/@name)}</td>
                <td>{count($formsui/@archetype)}</td>
                <td>{count($formsui/@order)}</td>
                <td><a href="javascript:dojo.publish('/forms/edit',['{$form-id}.xml','{data($formsui/@name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/forms/delete',['{data($formsui/tags/@document-name)}']);">delete</a></td>
            </tr>
};

(: fetch all tasks matching the query params passed from the search submission :)
declare function local:getMatchingTasks() as node() * {
    let $form-id := request:get-parameter("form-id", "")
    let $doc := for $forms in collection('/db/configeditor/configs/forms')
                let $xsl := doc('/db/configeditor/xsl/forms_split_attrs.xsl')
                let $fname := substring-before(util:document-name($forms),'.xml')
                return transform:transform($forms, $xsl, <parameters>
                                                            <param name="fname" value="{$fname}" />
                                                         </parameters>)
    
    for $splitted in $doc[@name eq $form-id]/descriptor
        let $formsui-id := data($splitted/@name)        
        order by $formsui-id ascending
        return $splitted

};

let $contextPath := request:get-context-path()
let $form-name := request:get-parameter("form-id", "")
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>All Tasks</title>
      <link rel="stylesheet" type="text/css" href="{$contextPath}/rest/db/configeditor/styles/configeditor.css"/>
    </head>
    <body>
        <div id="contextTitle">
            <span id="durationLabel">
                <span id="durationLabel-value" class="xfValue">form {$form-name}</span>
            </span>
        </div>    
    	<div id="dataTable">
    	   <div id="checkBoxSelectors">
    	        Select: <a href="javascript:selectAll();">All</a> | <a href="javascript:selectNone();">None</a>
    	        <!--<button onclick="passValuesToXForms();" value="setSelected"/>-->
    	   </div>
		   <table id="listingTable">
			 <tr>
				<th></th>
				<th>descriptor name</th>
				<th>archetype</th>
				<th>order</th>
				<th colspan="2"> </th>
			 </tr>
			 {local:main()}
		 </table>
	 </div>
    </body>
</html>
