xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:fn-formsui() as xs:string {

    let $contextPath := request:get-context-path()
    let $path2resource := concat($contextPath,"/apps/config_editor/edit/split-forms.xql?doc=","custom.xml")
    let $xsl := doc('/db/config_editor/xsl/forms_split_attrs.xsl')
    let $doc := doc($path2resource)
    let $splitted := transform:transform($doc, $xsl, <parameters>
                                                            <param name="fname" value="custom" />
                                                     </parameters>)
    return $path2resource
};

(: creates the output for all tasks matching the query :)
declare function local:main($doctype) as node() * {
    let $count := count(local:getMatchingTasks())
    for $field at $pos in local:getMatchingTasks()
        return
            <tr>
                <td>{data($field/@name)}</td>
                <td>{data($field/@label)}</td>
                <td>{data($field/@required)}</td>
                <td>{data($field/@value_type)}</td>
                <td>{data($field/@render_type)}</td>  
                <td>
                    <b>shown:</b> {data($field/show/modes)}
                    <b>hidden:</b> {data($field/hide/modes)}
                </td>    
                <td>
                {
                    if($pos eq 1) then
                        <span>
                        &#160;&#160;&#160;
                        &#160;&#160;&#160;
                        <a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="images/down.png"/></a>
                        </span>
                    else if ($pos eq $count) then 
                        <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="images/up.png"/></a>
                    else 
                    (
                        <span>
                            <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="images/up.png"/></a>
                            &#160;
                            <a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="images/down.png"/></a>
                        </span>
                    )
                }               
                </td>
                <td><a href="javascript:dojo.publish('/field/edit',['{$doctype}','{data($field/@name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/field/delete',['{$doctype}','{data($field/@name)}']);">delete</a></td>
            </tr>
};

declare function local:getMatchingTasks() as node() * {
    let $form-id := request:get-parameter("doc", "nothing")
    let $doc := let $form := doc('/db/config_editor/bungeni_custom/forms/custom.xml')
                let $xsl := doc('/db/config_editor/xsl/forms_split_attrs.xsl')
                return transform:transform($form, $xsl, <parameters>
                                                            <param name="fname" value="custom" />
                                                         </parameters>)
    
    for $splitted in $doc/descriptor[@name eq $form-id]/field
    return $splitted

};

declare function local:mode() as xs:string {
    let $doc := request:get-parameter("doc", "nothing")

    let $mode := if($doc eq "undefined") then "new"
                 else "edit"

    return $mode
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","nothing"))
let $showing := xs:string(request:get-parameter("tab","fields"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Database</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="i-formsui" src="{$contextPath}/rest/db/config_editor/data/forms.xml"/>   
                    
                    <xf:instance id="i-archetypes" xmlns="">
                        <data>
                            <archetypes>
                               <arche>doc</arche>
                               <arche>group</arche>                                 
                               <arche>group_membership</arche>
                            </archetypes>
                        </data>
                    </xf:instance>                        

                    <xf:bind nodeset="descriptor[@name eq '{$docname}']">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" />
                        <xf:bind nodeset="@order" type="xf:integer" required="true()" />
                        <xf:bind nodeset="@archetype" type="xf:string" required="true()" />
                    </xf:bind>
                    
                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{local:fn-formsui()}"
                        ref="descriptor[@name eq 'formname']"
                        replace="instance"
                        serialization="none">
                    </xf:submission>

                    <xf:instance id="i-controller" src="{$contextPath}/rest/db/config_editor/data/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                <xf:submission id="s-add"
                               method="put"
                               replace="none"
                               ref="instance()">
                    <xf:resource value="'{$contextPath}/rest/db/config_editor/bungeni_custom/forms/custom.xml'"/>

                    <xf:header>
                        <xf:name>username</xf:name>
                        <xf:value>admin</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>password</xf:name>
                        <xf:value></xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>realm</xf:name>
                        <xf:value>exist</xf:value>
                    </xf:header>

                    <xf:action ev:event="xforms-submit" if="'{local:mode()}' = 'new'">
                        <xf:message level="ephemeral">Creating timestamp as name</xf:message>
                        <!--xf:setvalue ref="instance('i-formsui')/@name" value="now()" /-->
                    </xf:action>

                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">FORM details saved successfully</xf:message>
                        <script type="text/javascript" if="instance('tmp')/wantsToClose">
                            dijit.byId("formsDialog").hide();
                            dojo.publish('/form/view',['{$docname}','details']);  
                        </script>
                        <xf:send submission="s-clean" if="'{local:mode()}' = 'new'"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The form details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>

                <xf:submission id="s-clean"
                               ref="instance('i-formsui')"
                               resource="{$contextPath}/rest/db/config_editor/data/forms.xml"
                               method="get"
                               replace="instance"
                               instance="i-formsui">
                </xf:submission>
                <xf:action ev:event="xforms-ready" >
                    <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                    <script type="text/javascript" if="'{$showing}' = 'fields'">
                        dijit.byId("switchDiv").selectChild("fieldsDiv");                        
                    </script>                     
                    <!--xf:setfocus control="date"/-->
                </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <div dojoType="dijit.layout.TabContainer" id="switchDiv" style="width: 100%; height: 100%;">
                    <xf:label>Types / {$docname} / forms </xf:label>
                    <div dojoType="dijit.layout.ContentPane" title="Edit Details" id="detailsDiv" selected="true">
                        <div class="caseContent">
                            <xf:group ref="descriptor[@name eq '{$docname}']" class="{if(local:mode()='edit') then 'suppressInfo' else ''}">
                                <xf:group appearance="bf:verticalTable">
                                    <xf:output value="'{$docname}'">
                                        <xf:label>Form:</xf:label>
                                    </xf:output>               
                                 
                                    <xf:input id="form-name" ref="@name">
                                        <xf:label>Form Name</xf:label>
                                        <xf:hint>Unique name given to the form</xf:hint>
                                        <xf:alert>Invalid form name</xf:alert>
                                    </xf:input> 
                                    
                                    <xf:select1 id="descriptor-archetype" ref="@archetype" appearance="minimal" incremental="true">
                                        <xf:label>archetypes</xf:label>
                                        <xf:hint>select parent type</xf:hint>
                                        <xf:help>help for archtypes</xf:help>
                                        <xf:alert>invalid</xf:alert>
                                        <xf:itemset nodeset="instance('i-archetypes')/archetypes/arche">
                                            <xf:label ref="."></xf:label>
                                            <xf:value ref="."></xf:value>
                                        </xf:itemset>
                                    </xf:select1>                            
                                    
                                    <xf:input id="descriptor-order" ref="@order">
                                        <xf:label>Order</xf:label>
                                        <xf:alert>Invalid number.</xf:alert>
                                        <xf:help>Enter an integer to represent the </xf:help>
                                        <xf:hint>order of this descriptor</xf:hint>
                                    </xf:input>                 
                                    
                                    <br/>
                                    <xf:group id="dialogButtons" appearance="bf:horizontalTable">
                                        <xf:label/>
                                        <xf:trigger>
                                            <xf:label>Save</xf:label>
                                            <xf:action>
                                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                                <xf:send submission="s-add"/>
                                            </xf:action>
                                        </xf:trigger>                  
                                    </xf:group>
                                 </xf:group>
                            </xf:group>
                        </div>
                    </div>
                    <div dojoType="dijit.layout.ContentPane" title="Edit fields" id="fieldsDiv">
                        <xf:label>Edit Fields</xf:label>
                        <div class="caseContent">
                        <table id="listingTable" style="width:100%;">
                            <tr>                      			 
                                <th>Name</th>
                                <th>Label</th>
                                <th>Required</th>
                                <th>Value Type</th>
                                <th>Render Type</th>
                                <th>Modes</th>
                                <th class="w40">Move</th>
                                <th colspan="2">Actions</th>
                            </tr>
                            {local:main($docname)}
                        </table> 
                        <span>
                            <a href="javascript:dojo.publish('/field/add',['{$docname}','{data(local:getMatchingTasks()[last()]/@name)}']);">add field</a>
                        </span>
                        </div>
                    </div>
                </div>                       
            </div>                    
        </div>
    </body>
</html>