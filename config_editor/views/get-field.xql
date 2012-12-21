xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

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
                            <view show="true">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </view>
                            <edit show="true">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </edit>
                            <add show="true">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </add>
                            <listing show="true">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </listing> 
                        </data>
                    </xf:instance>
                    
                    <xf:instance id="i-originrole" xmlns="">
                        <data>
                            <roles>
                               <role>ALL</role>                               
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
                        
                        <xf:bind nodeset="view/@show" type="xs:boolean"/>  
                        <xf:bind nodeset="edit/@show" type="xs:boolean"/>
                        <xf:bind nodeset="add/@show" type="xs:boolean"/>
                        <xf:bind nodeset="listing/@show" type="xs:boolean"/>
                        
                        <!-- ensure the roles are not empty -->
                        <xf:bind id="view" nodeset="view/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/view/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]"/>
                        <xf:bind id="edit" nodeset="edit/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/edit/roles[count(role) eq count(distinct-values(role))]"/>
                        <xf:bind id="add" nodeset="add/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/add/roles[count(role) eq count(distinct-values(role))]"/>
                        <xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/listing/roles[count(role) eq count(distinct-values(role))]"/>
                        
                        <!--xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/listing/roles[count(role) eq count(distinct-values(role))+1]" /-->
                        <!--xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="instance()/descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']/listing/roles[(contains(role,'ALL') and (count(role) = 1)) or (not(contains(role,'ALL')) and count(role) gt 1)]" /--> 
                        <!--xf:bind id="view" nodeset="instance('i-modes')/view/roles/role" type="xs:string" constraint="instance()/view/roles/role[not(.)]" />     
                        <xf:bind id="edit" nodeset="instance('i-modes')/edit/roles/role" type="xs:string" /--> 
                    </xf:bind>

                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{$contextPath}/rest/db/config_editor/bungeni_custom/forms/custom.xml"
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
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The form fields have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >
                        <xf:send submission="s-get-formsui"/>
                        <xf:setfocus control="field-name"/>
                    </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: auto">
                <xf:group id="g-field" ref="descriptor[@name eq '{$docname}']/field[@name eq '{$fieldname}']" class="fieldEdit">

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
                             
                            <xf:group appearance="compact">
                                <xf:label>Modes</xf:label>
                                <!-- view mode -->
                                <xf:group appearance="bf:verticalTable">
                                    <xf:label>view</xf:label>
                                    <xf:input id="input-viewshow" ref="view/@show">
                                        <xf:label>show/hide</xf:label>
                                    </xf:input>                                        
                                    <table>
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>                                    
                                       <tbody id="r-viewfieldattrs" xf:repeat-nodeset="view/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>a select1 combobox</xf:label>
                                                       <xf:alert>duplicate role or empty role</xf:alert>
                                                        <xf:itemset nodeset="instance()/roles/role">
                                                            <xf:label ref="."></xf:label>
                                                            <xf:value ref="."></xf:value>
                                                        </xf:itemset>
                                                    </xf:select1>                                           
                                               </td>                                           
                                               <td style="color:red;width:50px;height:30px;">&#160;</td>                            
                                           </tr>
                                       </tbody>
                                    </table>    
                                    <xf:group appearance="minimal">
                                        <table>                              
                                           <tbody>
                                               <tr>                                
                                                   <td style="color:steelblue;font-weight:bold;">
                                                        <xf:trigger>
                                                           <xf:label>insert</xf:label>
                                                           <xf:action>
                                                               <xf:insert nodeset="view/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                           </xf:action>
                                                        </xf:trigger>                                       
                                                   </td>                                           
                                                   <td style="color:red;">                                           
                                                        <xf:trigger>
                                                            <xf:label>delete</xf:label>
                                                            <xf:action ev:event="DOMActivate">
                                                                <!--    For known reason you cannot delete the nodeset.
                                                                        http://en.wikibooks.org/wiki/XForms/Delete
                                                                        http://www.w3.org/TR/xforms/#action-insert
                                                                        Solution:
                                                                        http://publib.boulder.ibm.com/infocenter/forms/v3r5m1/index.jsp?topic=%2Fcom.ibm.form.designer.xfdl.doc%2Fi_xfdl_g_xforms_actions_xforms_delete.html
                                                                -->
                                                                <xf:delete nodeset="view/roles/role[last()>1]" at="index('r-viewfieldattrs')"/>
                                                                <xf:insert nodeset="view/roles/role[last()=1]" at="1" position="before"/>
                                                                <xf:setfocus control="r-viewfieldattrs"/>
                                                            </xf:action> 
                                                        </xf:trigger>  
                                                   </td>                            
                                               </tr>
                                           </tbody>
                                        </table>
                                    </xf:group>
                                </xf:group>
                                
                                <!-- edit mode -->
                                <xf:group appearance="bf:verticalTable">
                                   <xf:label>edit</xf:label>
                                    <xf:input id="input-editshow" ref="edit/@show">
                                        <xf:label>show/hide</xf:label>
                                    </xf:input>                                
                                   <table>
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>
                                       <tbody id="r-editfieldattrs" appearance="minimal" xf:repeat-nodeset="edit/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>a select1 combobox</xf:label>
                                                       <xf:alert>invalid role</xf:alert>
                                                        <xf:itemset nodeset="instance()/roles/role">
                                                            <xf:label ref="."></xf:label>
                                                            <xf:value ref="."></xf:value>
                                                        </xf:itemset>
                                                    </xf:select1>                                           
                                               </td>                                           
                                               <td style="color:red;width:50px;height:30px;">&#160;</td>                           
                                           </tr>
                                       </tbody>
                                   </table>    
                                    <xf:group appearance="minimal">
                                        <table>                              
                                           <tbody>
                                               <tr>                                
                                                   <td style="color:steelblue;font-weight:bold;">
                                                        <xf:trigger>
                                                           <xf:label>insert</xf:label>
                                                           <xf:action>
                                                               <xf:insert nodeset="edit/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                           </xf:action>
                                                        </xf:trigger>                                       
                                                   </td>                                           
                                                   <td style="color:red;">                                           
                                                        <xf:trigger>
                                                            <xf:label>delete</xf:label>
                                                            <xf:action ev:event="DOMActivate">
                                                                <xf:delete nodeset="edit/roles/role[last()>1]" at="index('r-editfieldattrs')"/>
                                                                <xf:insert nodeset="edit/roles/role[last()=1]" at="1" position="before"/>
                                                                <xf:setfocus control="r-editfieldattrs"/>
                                                            </xf:action> 
                                                        </xf:trigger>  
                                                   </td>                            
                                               </tr>
                                           </tbody>
                                        </table>
                                    </xf:group>
                                </xf:group>
                                
                                <!-- add -->
                                <xf:group appearance="bf:verticalTable">
                                    <xf:label>add</xf:label>
                                    <xf:input id="input-addshow" ref="add/@show">
                                        <xf:label>show/hide</xf:label>
                                    </xf:input>                                        
                                    <table>
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>                                    
                                       <tbody id="r-addfieldattrs" xf:repeat-nodeset="add/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>a select1 combobox</xf:label>
                                                       <xf:alert>invalid role</xf:alert>
                                                        <xf:itemset nodeset="instance()/roles/role">
                                                            <xf:label ref="."></xf:label>
                                                            <xf:value ref="."></xf:value>
                                                        </xf:itemset>
                                                    </xf:select1>                                           
                                               </td>                                           
                                               <td style="color:red;width:50px;height:30px;">&#160;</td>                            
                                           </tr>
                                       </tbody>
                                    </table>    
                                    <xf:group appearance="minimal">
                                        <table>                              
                                           <tbody>
                                               <tr>                                
                                                   <td style="color:steelblue;font-weight:bold;">
                                                        <xf:trigger>
                                                           <xf:label>insert</xf:label>
                                                           <xf:action>
                                                               <xf:insert nodeset="add/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                           </xf:action>
                                                        </xf:trigger>                                       
                                                   </td>                                           
                                                   <td style="color:red;">                                           
                                                        <xf:trigger>
                                                            <xf:label>delete</xf:label>
                                                            <xf:action ev:event="DOMActivate">
                                                                <xf:delete nodeset="add/roles/role[last()>1]" at="index('r-addfieldattrs')"/>
                                                                <xf:insert nodeset="add/roles/role[last()=1]" at="1" position="before"/>
                                                                <xf:setfocus control="r-addfieldattrs"/>
                                                            </xf:action> 
                                                        </xf:trigger>  
                                                   </td>                            
                                               </tr>
                                           </tbody>
                                        </table>
                                    </xf:group>
                                </xf:group>
                                     
                                <!-- listing -->
                                <xf:group appearance="bf:verticalTable">
                                   <xf:label>listing</xf:label>
                                    <xf:input id="input-listingshow" ref="listing/@show">
                                        <xf:label>show/hide</xf:label>
                                    </xf:input>                                
                                   <table>
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>
                                       <tbody id="r-listingfieldattrs" appearance="minimal" xf:repeat-nodeset="listing/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>a select1 combobox</xf:label>
                                                       <xf:alert>invalid listing role(s)</xf:alert>
                                                        <xf:itemset nodeset="instance()/roles/role">
                                                            <xf:label ref="."></xf:label>
                                                            <xf:value ref="."></xf:value>
                                                        </xf:itemset>
                                                    </xf:select1>                                           
                                               </td>                                           
                                               <td style="color:red;width:50px;height:30px;">&#160;</td>                           
                                           </tr>
                                       </tbody>
                                   </table>    
                                    <xf:group appearance="minimal">
                                        <table>                              
                                           <tbody>
                                               <tr>                                
                                                   <td style="color:steelblue;font-weight:bold;">
                                                        <xf:trigger>
                                                           <xf:label>insert</xf:label>
                                                           <xf:action>
                                                               <xf:insert nodeset="listing/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                           </xf:action>
                                                        </xf:trigger>                                       
                                                   </td>                                           
                                                   <td style="color:red;">                                           
                                                        <xf:trigger>
                                                            <xf:label>delete</xf:label>           
                                                            <xf:action ev:event="DOMActivate">
                                                                <xf:delete nodeset="listing/roles/role[last()>1]" at="index('r-listingfieldattrs')"/>
                                                                <xf:insert nodeset="listing/roles/role[last()=1]" at="1" position="before"/>
                                                                <xf:setfocus control="r-listingfieldattrs"/>
                                                            </xf:action>                                                            
                                                        </xf:trigger>  
                                                   </td>                            
                                               </tr>
                                           </tbody>
                                        </table>
                                    </xf:group>
                                </xf:group>
                                                                  
                            </xf:group>                             
                                              
                        </xf:group>                         
                        
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