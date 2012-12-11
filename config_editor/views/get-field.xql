xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:fn-formsui() as xs:string {

    let $contextPath := request:get-context-path()
    let $path2resource := concat($contextPath,"/apps/config_editor/edit/split-forms.xql?doc=","custom.xml")
    let $xsl := cfg:get-xslt('/xsl/forms_split_attrs.xsl')
    return $path2resource
};

declare function local:mode() as xs:string {
    let $field := request:get-parameter("field", "none")
    let $mode := if($field eq "undefined") then "new"
                 else "edit"
    return $mode
};

let $contextPath := request:get-context-path()
let $docname := xs:string(request:get-parameter("doc","none"))
let $fieldname := xs:string(request:get-parameter("field","none"))
let $mode := xs:string(request:get-parameter("mode","old"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Field</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="i-field" src="{$contextPath}/rest/db/config_editor/data/forms.xml"/>   
                    <xf:instance id="i-modes" xmlns="">
                        <data>
                            <modes>
                               <mode>add</mode>
                               <mode>edit</mode>
                               <mode>view</mode>
                               <mode>listing</mode>                               
                            </modes>
                        </data>
                    </xf:instance>
                    
                    <xf:instance id="i-originrole" xmlns="">
                        <data>
                            <roles originAttr="roles">
                               <role/>                               
                            </roles>
                        </data>
                    </xf:instance>                     
                    
                    <xf:instance id="i-rendertypes" xmlns="">
                        <data>
                            <rendertypes>
                               <rendertype>text_line</rendertype>
                               <rendertype>rich_text</rendertype>      
                               <rendertype>single_select</rendertype> 
                               <rendertype>number</rendertype> 
                               <rendertype>text_box</rendertype> 
                               <rendertype>date</rendertype>
                            </rendertypes>
                        </data>
                    </xf:instance>     
                    
                    <xf:instance id="i-valuetypes" xmlns="">
                        <data>
                            <valuetypes>
                               <valuetype>text</valuetype>
                               <valuetype>language</valuetype>
                               <valuetype>vocabulary</valuetype>                                 
                               <valuetype>date</valuetype>
                               <valuetype>number</valuetype>
                            </valuetypes>
                        </data>
                    </xf:instance>               
                    
                    <xf:bind nodeset="descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" />
                        <xf:bind nodeset="@label" type="xf:string" required="true()" />
                        <xf:bind id="req-field" nodeset="@required" type="xs:boolean"/>  
                        <xf:bind nodeset="@value_type" type="xs:string" required="true()"/>
                        <xf:bind nodeset="@render_type" type="xs:string" required="true()"/>
                        <xf:bind id="showmodes" nodeset="instance('i-modes')/show/modes/mode" type="xs:string" constraint="instance()/show/modes/mode[not(.)]" />     
                        <xf:bind id="hidemodes" nodeset="instance('i-modes')/hide/modes/mode" type="xs:string" /> 
                    </xf:bind>

                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{local:fn-formsui()}"
                        ref="descriptor[@name eq 'formname']/field[@name eq 'undefined']"
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
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">field '{$fieldname}' saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dojo.publish('/form/view',['{$docname}','fields']);                      
                                dijit.byId("taskDialog").hide();
                            </script>
                            <xf:send submission="s-clean" if="'{local:mode()}' = 'new'"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The form fields have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
    
                    <xf:submission id="s-clean"
                                   ref="instance('i-field')/descriptor/field"
                                   resource="{$contextPath}/rest/db/config_editor/bungeni_custom/custom.xml"
                                   method="get"
                                   replace="instance"
                                   instance="i-field">
                    </xf:submission>
                    <xf:action ev:event="xforms-ready" >
                        <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                        <xf:setfocus control="field-name"/>
                    </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: auto">
                <xf:group id="g-field" ref="descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']">

                        <xf:group appearance="bf:verticalTable">
                            <xf:input id="field-name" ref="@name">
                                <xf:label>field title</xf:label>
                                <xf:hint>Must be an existing title</xf:hint>
                                <xf:alert>invalid field name</xf:alert>
                                <xf:help>help with name of field</xf:help>
                            </xf:input> 
                            
                            <xf:input id="label-name" ref="@label">
                                <xf:label>label</xf:label>
                                <xf:hint>Label used for this field</xf:hint>
                                <xf:alert>invalid label name</xf:alert>
                                <xf:help>help with label of field</xf:help>
                            </xf:input> 
                            
                            <xf:input id="input-req-field" ref="@required">
                                <xf:label>required</xf:label>
                                <xf:hint>Enabling this means it is a required field</xf:hint>
                                <xf:alert>invalid null boolean</xf:alert>
                            </xf:input>  
                            
                             <xf:select1 id="select-val-type" ref="@value_type" appearance="minimal" incremental="true">
                                 <xf:label>value type</xf:label>
                                 <xf:hint>a Hint for this control</xf:hint>
                                 <xf:help>help for select1</xf:help>
                                 <xf:alert>invalid</xf:alert>
                                 <xf:itemset nodeset="instance('i-valuetypes')/valuetypes/valuetype">
                                     <xf:label ref="."></xf:label>
                                     <xf:value ref="."></xf:value>
                                 </xf:itemset>
                             </xf:select1>  
                             
                             <xf:select1 id="select-ren-type" ref="@render_type" appearance="minimal" incremental="true">
                                 <xf:label>render type</xf:label>
                                 <xf:hint>a Hint for this control</xf:hint>
                                 <xf:help>help for select1</xf:help>
                                 <xf:alert>invalid</xf:alert>
                                 <xf:itemset nodeset="instance('i-rendertypes')/rendertypes/rendertype">
                                     <xf:label ref="."></xf:label>
                                     <xf:value ref="."></xf:value>
                                 </xf:itemset>
                             </xf:select1>  
                        </xf:group>
                        <!-- 
                        !+FIX_THIS (ao, Dec 11th 2012) Roles are currently unusable
                        <xf:select ref="show/modes[@originAttr='modes']" selection="closed" appearance="full" incremental="true" >  
                             <xf:label>show modes</xf:label>
                             <xf:itemset id="showmodes"nodeset="instance('i-modes')/modes/mode">
                                 <xf:label ref="."></xf:label>
                                 <xf:value ref="."></xf:value>
                             </xf:itemset>                           
                        </xf:select>        
                        <xf:group appearance="minimal">
                           <table>
                               <thead>
                                   <tr>                                
                                       <th>
                                           role
                                       </th>                                
                                       <th>
                                           actions
                                       </th>                               
                                   </tr>
                               </thead>
                               <tbody id="r-shownfieldattrs" xf:repeat-nodeset="show/roles/role" startindex="1">
                                   <tr>                                
                                       <td style="color:steelblue;font-weight:bold;">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:label>a select1 combobox</xf:label>
                                               <xf:hint>Edit this role</xf:hint>
                                               <xf:help>Type a Role</xf:help>
                                               <xf:alert>invalid role</xf:alert>
                                                <xf:itemset nodeset="instance()/roles/role">
                                                    <xf:label ref="."></xf:label>
                                                    <xf:value ref="."></xf:value>
                                                </xf:itemset>
                                            </xf:select1>                                           
                                       </td>                                           
                                       <td style="color:red;">                                           
                                           <xf:trigger>
                                               <xf:label>delete</xf:label>
                                               <xf:action>
                                                   <xf:delete nodeset="." ev:event="DOMActivate"></xf:delete>
                                               </xf:action>
                                           </xf:trigger>   
                                       </td>                            
                                   </tr>
                               </tbody>
                           </table>    
                            <xf:trigger>
                               <xf:label>insert</xf:label>
                               <xf:action>
                                   <xf:insert nodeset="show/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                               </xf:action>
                           </xf:trigger> 
                        </xf:group>                         
                
                        <xf:select ref="hide/modes[@originAttr='modes']" selection="closed" appearance="full" incremental="true" >  
                             <xf:label>hide modes</xf:label>
                             <xf:itemset id="hidemodes"nodeset="instance('i-modes')/modes/mode">
                                 <xf:label ref="node()"></xf:label>
                                 <xf:value ref="node()"></xf:value>
                             </xf:itemset>                           
                        </xf:select>                 
                        <xf:group appearance="minimal">
                           <table>
                               <thead>
                                   <tr>                                
                                       <th>
                                           role
                                       </th>                                
                                       <th>
                                           actions
                                       </th>                               
                                   </tr>
                               </thead>
                               <tbody id="r-hiddenfieldattrs" xf:repeat-nodeset="hide/roles/role">
                                   <tr>                                
                                       <td style="color:steelblue;font-weight:bold;">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:label>a select1 combobox</xf:label>
                                               <xf:hint>Edit this role</xf:hint>
                                               <xf:help>Type a Role</xf:help>
                                               <xf:alert>invalid role</xf:alert>
                                                <xf:itemset nodeset="instance()/roles/role">
                                                    <xf:label ref="."></xf:label>
                                                    <xf:value ref="."></xf:value>
                                                </xf:itemset>
                                            </xf:select1>                                           
                                       </td>                                           
                                       <td style="color:red;">                                           
                                           <xf:trigger>
                                               <xf:label>delete</xf:label>
                                               <xf:action>
                                                   <xf:delete nodeset="." ev:event="DOMActivate"></xf:delete>
                                               </xf:action>
                                           </xf:trigger>   
                                       </td>                            
                                   </tr>
                               </tbody>
                           </table>    
                            <xf:trigger>
                               <xf:label>insert</xf:label>
                               <xf:action>
                                   <xf:insert nodeset="hide/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                               </xf:action>
                           </xf:trigger> 
                        </xf:group>                          
                        -->
                        <br/>
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label/>
                            <xf:trigger>
                                <xf:label>Save</xf:label>
                                <xf:action>
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                    <xf:send submission="s-add"/>
                                </xf:action>                              
                            </xf:trigger>
                            <xf:trigger>
                                <xf:label>Close</xf:label>
                                <script type="text/javascript">
                                    dijit.byId("taskDialog").hide();
                                </script>
                            </xf:trigger>                    
                        </xf:group>   
                        
                        <xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>
                                   
                </xf:group>                
            </div>                    
        </div>
    </body>
</html>