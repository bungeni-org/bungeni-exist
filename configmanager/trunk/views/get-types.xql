xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";


import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";


declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all tasks matching the query :)
declare function local:main() as node() * {
    for $workflow in local:get-matching-tasks()
        return
            <tr>
                <td class="selectorCol"><input type="checkbox" dojotype="dijit.form.CheckBox" value="{data($workflow/@document-name)}" /></td>
                <td>{data($workflow/@title)}</td>
                <td>{data($workflow/@description)}</td>
                <td>{count($workflow/tags/tag)}</td>
                <td><div class="col-count">{count($workflow/state)}</div>(<a href="javascript:dojo.publish('/wf_states/edit',['{data($workflow/@document-name)}']);">edit</a>)</td>
                <td><div class="col-count">{count($workflow/transition)}</div>(<a href="javascript:dojo.publish('/wf_transitions/edit',['{data($workflow/@document-name)}']);">edit</a>)</td>
                <td>{count($workflow/grant)}</td>
                <td><a href="javascript:dojo.publish('/wf/edit',['{data($workflow/@document-name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/wf/delete',['{data($workflow/@document-name)}']);">delete</a></td>
            </tr>
};

(: fetch all tasks matching the query params passed from the search submission :)
declare function local:get-matching-tasks() as node() * {
    let $xsl := appconfig:get-xslt("wf_split_attrs.xsl")
    for $workflow in collection($appconfig:WF-FOLDER)/workflow
        let $workflow-project := data($workflow/@title) 
        order by $workflow-project ascending
        return transform:transform($workflow, 
                $xsl, 
                <parameters>
                    <param name="docname" value="{util:document-name($workflow)}" />
                </parameters>)

};


let $CXT := request:get-context-path()
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>All Tasks</title>
      <link rel="stylesheet" type="text/css"
                href="{$appconfig:rest-css($CXT, 'main.css')}"/>

    </head>
    <body>
        <div id="contextTitle">
            <span id="durationLabel">
                <span id="durationLabel-value" class="xfValue">Workflows</span>
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
				<th>Doctype</th>
				<th>Description</th>
				<th>Tags</th>
				<th>States</th>
				<th>Transitions</th>
				<th>Role Grants</th>
				<th colspan="2"> </th>
			 </tr>
			 {local:main()}
		 </table>
	 </div>
    </body>
</html>
