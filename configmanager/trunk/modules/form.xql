xquery version "3.0";

module namespace form="http://exist.bungeni.org/formfunctions";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace ev="http://www.w3.org/2001/xml-events" ;

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $form:CXT := request:get-context-path();
declare variable $form:REST-CXT-APP :=  $form:CXT || "/rest" || $config:app-root;


(: creates the output for all fields :)
declare function local:fields($doctype) as node() * {
    let $type := request:get-parameter("type", "")
    let $form-id := request:get-parameter("doc", "")
    
    let $form := local:get-form($form-id)
    
    let $count := count($form/descriptor/field)
    for $field at $pos in $form/descriptor/field
        return
            <tr>
                <td>{data($field/@name)}</td>
                <td>{data($field/@label)}</td>
                <td>{data($field/@required)}</td>
                <td>{data($field/@value_type)}</td>
                <td>{data($field/@render_type)}</td>  
                <td>
                    <b>view:</b> {$field/view/roles/role[position()!=last()]} 
                    <b>edit:</b> {$field/edit/roles/role[position()!=last()]} 
                    <b>add:</b> {$field/add/roles/role[position()!=last()]} 
                    <b>listing:</b> {$field/listing/roles/role[position()!=last()]}
                </td>    
                <td>
                {
                    if($pos eq 1) then
                        <span>
                        &#160;&#160;&#160;
                        &#160;&#160;&#160;
                        <a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="resources/images/down.png"/></a>
                        </span>
                    else if ($pos eq $count) then 
                        <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="resources/images/up.png"/></a>
                    else 
                    (
                        <span>
                            <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="resources/images/up.png"/></a>
                            &#160;<a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="resources/images/down.png"/></a>
                        </span>
                    )
                }               
                </td>
                <td><a href="field-edit.html?type={$type}&amp;doc={$doctype}&amp;node=field&amp;id={$pos}">edit</a></td>
                <td><a href="field-delete.html?type={$type}&amp;doc={$doctype}&amp;node=field&amp;id={$pos}">delete</a></td>
            </tr>
};

declare function local:get-form($docname as xs:string) as node() * {
    doc($appconfig:FORM-FOLDER || '/' || $docname || '.xml')
};

declare function local:mode() as xs:string {
    let $doc := request:get-parameter("doc", "nothing")

    let $mode := if($doc eq "undefined") then "new"
                 else "edit"

    return $mode
};

declare
function form:edit($node as node(), $model as map(*)) {

    let $docname := xs:string(request:get-parameter("doc","none"))
    let $lastfield := data(local:get-form($docname)/descriptor/field[last()]/@name)
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-form" src="{$form:REST-CXT-APP}/model_templates/forms.xml"/>   
                    
                    <xf:instance id="i-archetypes" xmlns="">
                        <data>
                            <archetypes>
                               <arche>doc</arche>
                               <arche>group</arche>                                 
                               <arche>group_membership</arche>
                            </archetypes>
                        </data>
                    </xf:instance>                        

                    <xf:bind nodeset=".[@name eq '{$docname}']">
                        <xf:bind nodeset="@order" type="xf:integer" required="true()" constraint="(. &lt; 100) and (. &gt; 0)" />
                        <xf:bind nodeset="@archetype" type="xf:string" required="true()" />
                    </xf:bind>
                    
                    <xf:submission id="s-get-form"
                        method="get"
                        resource="{$form:REST-CXT-APP}/working/live/bungeni_custom/forms/{$docname}.xml"
                        replace="instance"
                        serialization="none">
                    </xf:submission>

                    <xf:instance id="i-controller" src="{$form:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="concat('{$form:REST-CXT-APP}/working/live/bungeni_custom/forms/',instance('i-controller')/lastAddedType,'.xml')"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">new form details saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dijit.byId("formsDialog").hide();
                                dojo.publish('/form/view',['{$docname}','details']);  
                            </script>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The form details have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:submission id="s-save"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$form:REST-CXT-APP}/working/live/bungeni_custom/forms/{$docname}.xml'"/>
    
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
                            <!--xf:setvalue ref="instance('i-form')/@name" value="now()" /-->
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
                                   ref="instance('i-form')"
                                   resource="{$form:REST-CXT-APP}/model_templates/forms.xml"
                                   method="get"
                                   replace="instance"
                                   instance="i-form">
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:send submission="s-get-form" if="'{local:mode()}' = 'edit'"/>
                        <xf:action if="'{$docname}' = 'new'">
                            <xf:setvalue ref="instance()/@name" value="instance('i-controller')/lastAddedType"/>
                        </xf:action>
                        <script type="text/javascript" if="'{$showing}' = 'fields'">
                            dijit.byId("switchDiv").selectChild("fieldsDiv");                        
                        </script>   
                    </xf:action>

            </xf:model>
            
            </div>
            
            <div id="tabs_container">
                <ul id="tabs">
                    <li id="tabdetails" class="active"><a href="#details">Form details</a></li>
                    <li id="tabfields" ><a href="#fields">Fields</a></li>
                </ul>
            </div>
            
            <div id="tabs_content_container">
                <div id="details" class="tab_content" style="display: block;">
                    <xf:group ref="." class="{if(local:mode()='edit') then 'suppressInfo' else ''}">
                        <xf:group appearance="bf:verticalTable">
                            <xf:output ref="@name">
                                <xf:label>Form:</xf:label>
                            </xf:output>
                            
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
                                <xf:help>Enter an integer between 1 and 100 </xf:help>
                                <xf:hint>order of this descriptor</xf:hint>
                                <xf:message ev:event="xforms-readonly" level="ephemeral">NOTE: That number is taken already.</xf:message>
                            </xf:input>                 
                            
                            <br/>
                            <xf:group id="dialogButtons" appearance="bf:horizontalTable">
                                <xf:label/>
                                <xf:trigger>
                                    <xf:label>Save</xf:label>
                                    <xf:action if="'{$docname}' = 'new'">
                                        <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                        <xf:setvalue ref="./@name" value="instance('i-controller')/lastAddedType"/>
                                        <xf:send submission="s-add"/>
                                    </xf:action>                                            
                                    <xf:action if="'{$docname}' != 'new'">
                                        <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                        <xf:send submission="s-save"/>
                                    </xf:action>
                                </xf:trigger>                  
                            </xf:group>
                         </xf:group>
                    </xf:group>
                </div>
                <div id="fields" class="tab_content">
                    <table class="listingTable" style="width:auto;">
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
                        {local:fields($docname)}
                    </table> 
                    <span>
                        <!--a href="javascript:dojo.publish('/field/add',['{$docname}','{$lastfield}']);">add field</a-->
                    </span>
                </div>
            </div>                 
        </div>
};

declare
function form:field-edit($node as node(), $model as map(*)) {

    let $docname := xs:string(request:get-parameter("doc",""))
    let $node := xs:string(request:get-parameter("node",""))
    let $fieldid := xs:string(request:get-parameter("id",""))
    return 
        (: Element to pop up :)
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:db="http://namespaces.objectrealms.net/rdb" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:zope="http://namespaces.zope.org/zope" xmlns:xf="http://www.w3.org/2002/xforms">
            <a href="#">
                <img src="resources/images/back_arrow.png" title="back to form" alt="back to workflow states"/>
            </a>
            <br/>
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="i-field" src="{$form:REST-CXT-APP}/model_templates/forms.xml"/> 
                    
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
                    
                    <xf:instance id="i-globalroles" xmlns="">
                        <data>
                            <roles originAttr="roles">
                                <role>CommitteeMember</role>
                                <role>Minister</role>
                                <role>Owner</role>
                                <role>Clerk.HeadClerk</role>
                                <role>Signatory</role>
                                <role>Anonymous</role>
                                <role>MP</role>
                                <role>Authenticated</role>
                                <role>Speaker</role>
                                <role>PoliticalGroupMember</role>
                                <role>Admin</role>
                                <role>Government</role>
                                <role>Clerk.QuestionClerk</role>
                                <role>Translator</role>
                                <role>Clerk</role>
                                <role>ALL</role>
                            </roles>                        
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

                    <xf:bind nodeset=".[@name eq '{$docname}']/field[{$fieldid}]">
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
                        <!-- THE RULES BELOW, explained 
                            1) role ALL exists exclusively, you cannot allow it with something else e.g.
                                <roles>
                                    <role>ALL</role>
                                    <role>Clerk</role>
                                </roles>
                            2) You cannot allow duplicate role, e.g.
                                <roles>
                                    <role>Clerk</role>
                                    <role>Clerk</role>
                                </roles>
                        -->
                        <xf:bind id="view" nodeset="view/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/view/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/view/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="edit" nodeset="edit/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/edit/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/edit/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="add" nodeset="add/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/add/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/add/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/listing/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/listing/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        
                    </xf:bind>
                    
                    <xf:submission id="s-get-form"
                        method="get"
                        resource="{$form:REST-CXT-APP}/working/live/bungeni_custom/forms/{$docname}.xml"
                        replace="instance"
                        serialization="none">
                    </xf:submission> 
                    
                    <xf:instance id="i-controller" src="{$form:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                                   
                        <xf:resource value="'{$form:REST-CXT-APP}/working/live/bungeni_custom/forms/{$docname}.xml'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>{$appconfig:admin-username}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value>{$appconfig:admin-password}</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">field '{$fieldid}' saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                console.log("done");
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
                        <xf:send submission="s-get-form"/>
                        <xf:setfocus control="field-name"/>
                    </xf:action>
                </xf:model>
            
            </div>
            
            <div>
                <xf:group id="g-field" ref=".[@name eq '{$docname}']/field[{$fieldid}]" class="fieldEdit">               
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
                                    <table class="fieldModes">
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>                                    
                                       <tbody id="r-viewfieldattrs" xf:repeat-nodeset="view/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td>
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>select a role</xf:label>
                                                        <xf:alert>duplicates or invalid role options</xf:alert>
                                                        <xf:itemset nodeset="instance('i-globalroles')/roles/role">
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
                                                   <td>
                                                        <xf:trigger>
                                                           <xf:label>insert</xf:label>
                                                           <xf:action>
                                                               <xf:insert nodeset="view/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                           </xf:action>
                                                        </xf:trigger>                                       
                                                   </td>                                           
                                                   <td>                                           
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
                                   <table class="fieldModes">
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>
                                       <tbody id="r-editfieldattrs" appearance="minimal" xf:repeat-nodeset="edit/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>select a role</xf:label>
                                                        <xf:alert>duplicates or invalid role options</xf:alert>
                                                        <xf:itemset nodeset="instance('i-globalroles')/roles/role">
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
                                    <table class="fieldModes">
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>                                    
                                       <tbody id="r-addfieldattrs" xf:repeat-nodeset="add/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>select a role</xf:label>
                                                        <xf:alert>duplicates or invalid role options</xf:alert>
                                                        <xf:itemset nodeset="instance('i-globalroles')/roles/role">
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
                                   <table class="fieldModes">
                                       <thead>
                                           <tr>                                
                                               <th colspan="2"/>                               
                                           </tr>
                                       </thead>
                                       <tbody id="r-listingfieldattrs" appearance="minimal" xf:repeat-nodeset="listing/roles/role[position()!=last()]" startindex="1">
                                           <tr>                                
                                               <td style="color:steelblue;font-weight:bold;">
                                                    <xf:select1 ref="." appearance="minimal" incremental="true">
                                                        <xf:label>select a role</xf:label>
                                                        <xf:alert>duplicates or invalid role options</xf:alert>
                                                        <xf:itemset nodeset="instance('i-globalroles')/roles/role">
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
                                <xf:label>Cancel</xf:label>
                            </xf:trigger>                    
                        </xf:group>   
                        
                        <xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>                        
                </xf:group>                
            
            </div>                 
        </div>
};