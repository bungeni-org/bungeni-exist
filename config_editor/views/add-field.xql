xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

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
                    
                    <xf:instance id="i-field" src="{$contextPath}/rest/db/config_editor/bungeni_custom/forms/{$docname}.xml"/>   
                    
                    <xf:instance id="i-controller" src="{$contextPath}/rest/db/config_editor/data/controller.xml"/>                    
                    
                    <xf:instance id="i-modes" xmlns="">
                        <data>
                            <view show="true">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </view>
                            <edit show="false">
                                <roles>
                                    <role>ALL</role>
                                </roles>
                            </edit>
                            <add show="false">
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
                    
                    <xf:instance id="i-fieldtmpl" xmlns="">
                        <data>
                            <field name="" label="" required="false" value_type="text" render_type="text_line" vocabulary="">
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
                            </field>
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

                    <xf:bind nodeset="instance('i-fieldtmpl')/field">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" />
                        <xf:bind nodeset="@label" type="xf:string" required="true()" />
                        <xf:bind id="req-field" nodeset="@required" type="xs:boolean"/>  
                        <xf:bind nodeset="@value_type" type="xs:string" required="true()"/>
                        <xf:bind nodeset="@render_type" type="xs:string" required="true()"/>
                        <xf:bind id="showmodes" nodeset="instance('i-modes')/show/modes/mode" type="xs:string" />     
                        <xf:bind id="hidemodes" nodeset="instance('i-modes')/hide/modes/mode" type="xs:string" />                  
                    </xf:bind>

                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{$contextPath}/rest/db/config_editor/bungeni_custom/forms/{$docname}.xml"
                        replace="instance"
                        serialization="none">
                    </xf:submission>                   

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                                   
                        <xf:resource value="'{$contextPath}/rest/db/config_editor/bungeni_custom/forms/{$docname}.xml'"/>
    
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
                            <xf:message level="ephemeral">Adding new field</xf:message>                          
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">field was saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dojo.publish('/form/view',['{$docname}','fields']);                      
                                dijit.byId("taskDialog").hide();
                            </script>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                             <xf:message level="ephemeral">error occured while saving the field</xf:message>
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The form fields have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                        <xf:setfocus control="field-name"/>
                    </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: auto">         
                <xf:group id="g-field" ref="instance('i-fieldtmpl')/field" appearance="bf:verticalTable">

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
                        
                        <xf:select ref="view" selection="closed" appearance="full" incremental="true" >  
                            <xf:label>show modes</xf:label>
                            <xf:itemset id="showmodes"nodeset="instance('i-modes')/view">
                                <xf:label ref="."></xf:label>
                                <xf:value ref="."></xf:value>
                            </xf:itemset>                           
                        </xf:select> 
                        
                        <xf:select ref="hide/modes[@originAttr='modes']" selection="closed" appearance="full" incremental="true" >  
                            <xf:label>hide modes</xf:label>
                            <xf:itemset id="hidemodes"nodeset="instance('i-modes')/modes/mode">
                                <xf:label ref="node()"></xf:label>
                                <xf:value ref="node()"></xf:value>
                            </xf:itemset>                           
                        </xf:select>  
                        
                        <br/>
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label/>
                            <xf:trigger>
                                <xf:label>Save</xf:label>
                                <xf:action if="'{$mode}' = 'new'">
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>                                   
                                    <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-fieldtmpl')/field" />
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