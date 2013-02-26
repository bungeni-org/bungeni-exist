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
declare variable $form:RESTXQ := request:get-context-path() || "/restxq";
declare variable $form:REST-CXT-APP :=  $form:CXT || $appconfig:REST-APP-ROOT;
declare variable $form:REST-BC-LIVE :=  $form:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;


(: creates the output for all fields :)
declare function local:fields($doctype) as node() * {
    let $type := request:get-parameter("type", "")
    let $form-id := request:get-parameter("doc", "")
    let $docpos := request:get-parameter("pos", "")
    
    let $form := local:get-form($form-id)
    
    let $count := count($form/descriptor/field)
    for $field at $pos in $form/descriptor/field
        return
            <li>
                <span><a href="field-edit.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;node=field&amp;id={data($field/@name)}">{data($field/@label)}</a></span>
                 <div class="roles-wrapper clearfix">
                    {
                     (: Showing only with @show = true :)
                     (: view roles :)
                     if (some $role in $field/view/roles/role satisfies (contains($role/text(), 'ALL')) and count($field/view/roles/role) <= 1 and $field/view[@show = 'true']) then (
                        <span>
                            <b>view</b> <tt class="roles-inline">(ALL)</tt> <br/>
                        </span>
                     ) 
                     else if ($field/view[@show = 'true']) then (
                        <span>
                            <b>view</b> <tt class="roles-inline">({string-join($field/view/roles/role[position()!=last()],", ")})</tt> <br/>
                        </span>                          
                     ) 
                     else
                     (),
                     (: edit roles :)
                     if (some $role in $field/edit/roles/role satisfies (contains($role/text(), 'ALL')) and count($field/edit/roles/role) <= 1 and $field/edit[@show = 'true']) then (
                        <span>
                            <b>edit</b> <tt class="roles-inline">(ALL)</tt> <br/> 
                        </span>                     
                     )
                     else if ($field/edit[@show = 'true']) then (
                        <span>
                            <b>edit</b> <tt class="roles-inline">({string-join($field/edit/roles/role[position()!=last()],", ")})</tt> <br/>
                        </span>                          
                     ) 
                     else
                     (),                     
                     (: add roles :)
                     if (some $role in $field/add/roles/role satisfies (contains($role/text(), 'ALL')) and count($field/add/roles/role) <= 1 and $field/add[@show = 'true']) then (
                        <span>
                            <b>add</b> <tt class="roles-inline">(ALL)</tt> <br/>
                        </span>                     
                     )
                     else if ($field/add[@show = 'true']) then (
                        <span>
                            <b>view</b> <tt class="roles-inline">({string-join($field/add/roles/role[position()!=last()],", ")})</tt> <br/>
                        </span>                          
                     ) 
                     else
                     (),
                     (: listing roles :)
                     if (some $role in $field/listing/roles/role satisfies (contains($role/text(), 'ALL')) and count($field/listing/roles/role) <= 1 and $field/listing[@show = 'true']) then (
                        <span>
                            <b>listing</b> <tt class="roles-inline">(ALL)</tt> <br/>
                        </span>                     
                     )
                     else if ($field/listing[@show = 'true']) then (
                        <span>
                            <b>view</b> <tt class="roles-inline">({string-join($field/listing/roles/role[position()!=last()],", ")})</tt> <br/>
                        </span>                          
                     ) 
                     else
                     ()                     
                    }
                </div>    
                <span class="nodeMove">
                    <span style="float:right;">
                        <a class="up edit" title="Move up" href="{$form:RESTXQ}/form/{$doctype}/{data($field/@name)}/up"><i class="icon-up"></i></a>
                        &#160;<a class="down edit" title="Move down" href="{$form:RESTXQ}/form/{$doctype}/{data($field/@name)}/down"><i class="icon-down"></i></a>
                    </span>
                </span>
                &#160;<a class="delete" title="Delete field" href="{$form:RESTXQ}/form/{$doctype}/{data($field/@name)}"><i class="icon-cancel-circled"></i></a>
            </li>
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

    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc","none"))    
    let $pos := xs:string(request:get-parameter("pos",""))
    let $lastfield := data(local:get-form($docname)/descriptor/field[last()]/@name)
    let $form-doc := $appconfig:CONFIGS-FOLDER || "/forms/" || $docname || ".xml"
    let $init := xs:string(request:get-parameter("init",""))
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model id="m-form">
                    {
                        (: if adding a new form is true :)
                        if(not(doc-available($form-doc))) then 
                            <xf:instance id="i-form" src="{$form:REST-CXT-APP}/model_templates/forms.xml"/>
                        else
                            <xf:instance id="i-form" src="{$form:REST-BC-LIVE}/forms/{$docname}.xml"/> 
                    } 
                    
                    <xf:instance id="i-constraints" src="{$form:REST-BC-LIVE}/forms/.auto/_constraints.xml"/> 
                    
                    <xf:instance id="i-validations" src="{$form:REST-BC-LIVE}/forms/.auto/_validations.xml"/>
                    
                    <xf:instance id="i-integrity" xmlns="">
                        <data>
                            <integrity constraints="" validations=""/>                        
                        </data>
                    </xf:instance>
                    
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

                    <xf:instance id="i-controller" src="{$form:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-save"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$form:REST-BC-LIVE}/forms/{$docname}.xml'"/>
    
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
                            <xf:message level="ephemeral">FORM details saved successfully</xf:message>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The form details have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:action if="'{$init}' eq 'true'">
                            <xf:setvalue ref="instance()/@name" value="'{$docname}'"/>
                            <xf:message level="ephemeral">loaded new template</xf:message>
                        </xf:action>                        
                        <xf:action if="empty(instance()/integrity)">
                            <xf:message level="ephemeral">added optional integrity contraints and validations</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-integrity')/integrity" />
                        </xf:action>
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
                                <xf:label>archetype</xf:label>
                                <xf:hint>select parent type</xf:hint>
                                <xf:help>help for archtypes</xf:help>
                                <xf:alert>invalid</xf:alert>
                                <xf:itemset nodeset="instance('i-archetypes')/archetypes/arche">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                            
                            
                            <xf:input id="descriptor-order" ref="@order" incremental="true">
                                <xf:label>Order</xf:label>
                                <xf:alert>Invalid value. Between 1 &#8596; 100</xf:alert>
                                <xf:help>Enter an integer between 1 and 100 </xf:help>
                                <xf:hint>order of this descriptor</xf:hint>
                                <xf:message ev:event="xforms-readonly" level="ephemeral">NOTE: That number is taken already.</xf:message>
                            </xf:input>
                         </xf:group>
                    </xf:group>
                   
                    <xf:group>
                        <xf:label><h3>Manage integrity checks</h3></xf:label>
                        <xf:group appearance="bf:horizontalTable">   
                            <xf:label>constraints</xf:label>
                            <xf:select id="c-contraints" ref="integrity/@constraints" appearance="full" incremental="true" class="inlineCheckbox">
                                <xf:hint>set restrictions to be enforced on this form</xf:hint>
                                <xf:itemset nodeset="instance('i-constraints')/constraint">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                            </xf:select>  
                        </xf:group>
                        
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label>validations</xf:label>
                            <xf:select id="c-validations" ref="integrity/@validations" appearance="full" incremental="true" class="inlineCheckbox">
                                <xf:hint>validate data entries to this form</xf:hint>
                                <xf:itemset nodeset="instance('i-validations')/validation">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                            </xf:select>  
                        </xf:group>                    
                    </xf:group>
                    
                    <xf:group id="dialogButtons" appearance="bf:horizontalTable">
                        <xf:label/>
                        <xf:trigger>
                            <xf:label>Save</xf:label>                                          
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:delete nodeset="instance()/integrity[@constraints = '' and @validations = '']"/>
                                <xf:send submission="s-save"/>
                                <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-integrity')/integrity" />
                                <xf:refresh ev:event="DOMActivate" model="m-form"/>
                            </xf:action>
                        </xf:trigger>
                      
                    </xf:group>                    
                </div>
                <div id="fields" class="tab_content">
                    <div class="ulisting">
                        <ul class="ulfields clearfix">
                            {local:fields($docname)}
                        </ul>
                        <a class="button-link" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">add field</a>
                    </div>
                </div>
            </div>                 
        </div>
};

declare
function form:field-edit($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $pos := xs:string(request:get-parameter("pos",""))
    let $docname := xs:string(request:get-parameter("doc",""))
    let $node := xs:string(request:get-parameter("node",""))
    let $fieldname := xs:string(request:get-parameter("id",""))
    return 
        (: Element to pop up :)
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:db="http://namespaces.objectrealms.net/rdb" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:zope="http://namespaces.zope.org/zope" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model id="fieldedit">
                    <xf:instance id="i-field" src="{$form:REST-BC-LIVE}/forms/{$docname}.xml"/> 
                    
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
                    
                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>

                    <xf:instance id="i-originrole" xmlns="">
                        <data>
                            <roles>
                               <role>ALL</role>                               
                            </roles>
                        </data>
                    </xf:instance>                     
                    
                    <xf:instance id="i-valuetypes" src="{$form:REST-BC-LIVE}/forms/.auto/_valuetypes.xml"/> 
 
                    <xf:instance id="i-rendertypes" src="{$form:REST-BC-LIVE}/forms/.auto/_rendertypes.xml"/>

                    <xf:bind nodeset=".[@name eq '{$docname}']/field[@name eq '{$fieldname}']">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$') and (count(instance()/field/@name) eq count(distinct-values(instance()/field/@name)))" />
                        <xf:bind nodeset="@label" type="xf:string" required="true()" />
                        <xf:bind id="req-field" nodeset="@required" type="xs:boolean"/>  
                        <xf:bind nodeset="@value_type" type="xs:string" required="true()" />
                        <xf:bind id="b-rendertype" nodeset="@render_type" type="xs:string" required="true()"/>
                        
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
                        <xf:bind id="view" nodeset="view/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/view/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/view/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="edit" nodeset="edit/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/edit/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/edit/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="add" nodeset="add/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/add/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/add/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/listing/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[@name eq '{$fieldname}']/listing/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        
                    </xf:bind>
                    
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
                                   
                        <xf:resource value="'{$form:REST-BC-LIVE}/forms/{$docname}.xml'"/>
    
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
                            <xf:message level="ephemeral">field '{$fieldname}' saved successfully</xf:message>
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
                        <xf:setfocus control="field-name"/>
                    </xf:action>
                </xf:model>
            
            </div>
            
            <div>       
                <xf:group id="g-field" ref=".[@name eq '{$docname}']/field[@name eq '{$fieldname}']" class="fieldEdit">
                        <a href="form.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}#tabfields">
                            <img src="resources/images/back_arrow.png" title="back to form" alt="back to workflow states"/>
                        </a>
                        <h1><xf:output ref="@label"/></h1>                    
                        <xf:group appearance="bf:verticalTable">
                            <xf:group appearance="bf:horizontalTable">
                                <xf:input id="label-name" ref="@label" incremental="true">
                                    <xf:label>label</xf:label>
                                    <xf:hint>Label used for this field</xf:hint>
                                    <xf:alert>invalid label name</xf:alert>
                                    <xf:help>help with label of field</xf:help>
                                </xf:input> 
                                
                                <xf:input id="field-name" ref="@name" incremental="true">
                                    <xf:label>field name</xf:label>
                                    <xf:hint>Unique field name</xf:hint>
                                    <xf:alert>invalid: must be 3+ characters, A-z and _, unique name in the form</xf:alert>
                                    <xf:help>help with name of field</xf:help>
                                </xf:input> 
                                
                                <xf:input id="input-req-field" ref="@required">
                                    <xf:label>required</xf:label>
                                    <xf:hint>Enabling this means it is a required field</xf:hint>
                                    <xf:alert>invalid null boolean</xf:alert>
                                </xf:input>                                
                            </xf:group>
                            <div style="margin-bottom:10px;"/>                            
                            
                            <xf:group appearance="bf:horizontalTable">
                                <xf:label>Input types</xf:label>
                                <xf:select1 id="select-val-type" ref="@value_type" appearance="minimal" incremental="true">
                                    <xf:label>value type</xf:label>
                                    <xf:hint>internal value</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <!-- get only unique values -->
                                    <xf:itemset nodeset="instance('i-valuetypes')/valueType[not(./@name = preceding-sibling::node()/@name)]">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@name"></xf:value>
                                    </xf:itemset>
                                </xf:select1>  
                                
                                <xf:select1 bind="b-rendertype" appearance="minimal" incremental="true">
                                    <xf:label>widget</xf:label>
                                    <xf:hint>external value show on input forms</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-valuetypes')/valueType[@name eq instance()[@name eq '{$docname}']/field[@name eq '{$fieldname}']/@value_type]">
                                        <xf:label ref="@rendertype"></xf:label>
                                        <xf:value ref="@rendertype"></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                            </xf:group>
                        </xf:group>
                        <hr/>
                        <xf:group appearance="compact" class="modesWrapper">
                            <xf:label>Modes</xf:label>
                            
                            <!-- view mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>view</xf:label>
                                <xf:input id="input-viewshow" ref="view/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>     
                                <xf:repeat id="r-viewfieldattrs" nodeset="view/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-viewfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="view/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- edit mode -->
                            <xf:group appearance="bf:verticalTable">
                               <xf:label>edit</xf:label>
                                <xf:input id="input-editshow" ref="edit/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>  
                                <xf:repeat id="r-editfieldattrs" nodeset="edit/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-editfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="edit/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- add -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>add</xf:label>
                                <xf:input id="input-addshow" ref="add/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>   
                                <xf:repeat id="r-addfieldattrs" nodeset="add/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-addfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="add/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                 
                            <!-- listing -->
                            <xf:group appearance="bf:verticalTable">
                               <xf:label>listing</xf:label>
                                <xf:input id="input-listingshow" ref="listing/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>  
                                <xf:repeat id="r-listingfieldattrs" nodeset="listing/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-listingfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="listing/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                                                   
                        </xf:group>                        
                        <hr/>
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
                                <xf:label>Reset</xf:label>
                                <xf:hint>Resets the form prior to any modifications</xf:hint>                                
                                <xf:action>
                                    <xf:reset model="fieldedit" ev:event="DOMActivate"/>
                                </xf:action>
                            </xf:trigger>                     
                        </xf:group>   
                        
                        <xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>                        
                </xf:group>                
            
            </div>                 
        </div>
};

declare
function form:field-add($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $pos := xs:string(request:get-parameter("pos",""))
    let $docname := xs:string(request:get-parameter("doc",""))
    let $node := xs:string(request:get-parameter("node",""))
    let $form-doc := $appconfig:CONFIGS-FOLDER || "/forms/" || $docname || ".xml"    
    let $fieldid := xs:string(request:get-parameter("id",""))
    return 
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:db="http://namespaces.objectrealms.net/rdb" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:zope="http://namespaces.zope.org/zope" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model id="fieldadd">
                    {
                        (: if adding a new form is true :)
                        if(not(doc-available($form-doc))) then 
                            <xf:instance id="i-form" src="{$form:REST-CXT-APP}/model_templates/forms.xml"/>
                        else
                            <xf:instance id="i-form" src="{$form:REST-BC-LIVE}/forms/{$docname}.xml"/> 
                    }
                    
                    <xf:instance id="i-controller" src="{$form:REST-CXT-APP}/model_templates/controller.xml"/>                    
                    
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
                    
                    <xf:instance id="i-fieldtmpl" xmlns="">
                        <data>
                            <field name="" label="" required="false" value_type="" render_type="" vocabulary="">
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
 
                    <xf:instance id="i-allroles" xmlns="">
                        {appconfig:roles()}
                    </xf:instance>

                    <xf:instance id="i-originrole" xmlns="">
                        <data>
                            <roles>
                               <role>ALL</role>                               
                            </roles>
                        </data>
                    </xf:instance>                     
                    
                    <xf:instance id="i-valuetypes" src="{$form:REST-BC-LIVE}/forms/.auto/_valuetypes.xml"/> 
                    
                    <xf:instance id="i-rendertypes" src="{$form:REST-BC-LIVE}/forms/.auto/_rendertypes.xml"/>

                    <xf:bind nodeset="./field[last()]">
                        <xf:bind id="b-fieldname" nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$') and (count(instance()/field/@name) eq count(distinct-values(instance()/field/@name)))" />
                        <xf:bind nodeset="@label" type="xf:string" required="true()" />
                        <xf:bind id="req-field" nodeset="@required" type="xs:boolean"/>  
                        <xf:bind nodeset="@value_type" type="xs:string" required="true()"/>
                        <xf:bind id="b-rendertype" nodeset="@render_type" type="xs:string" required="true()"/>
                        
                        <xf:bind nodeset="view/@show" type="xs:boolean"/>  
                        <xf:bind nodeset="edit/@show" type="xs:boolean"/>
                        <xf:bind nodeset="add/@show" type="xs:boolean"/>
                        <xf:bind nodeset="listing/@show" type="xs:boolean"/>
                     
                        <xf:bind id="view" nodeset="view/roles/role" required="true()" type="xs:string" constraint="(instance()/field[last()]/view/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/field[last()]/view/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="edit" nodeset="edit/roles/role" required="true()" type="xs:string" constraint="(instance()/field[last()]/edit/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/field[last()]/edit/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="add" nodeset="add/roles/role" required="true()" type="xs:string" constraint="(instance()/field[last()]/add/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/field[last()]/add/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="listing" nodeset="listing/roles/role" required="true()" type="xs:string" constraint="(instance()/field[last()]/listing/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/field[last()]/listing/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        
                    </xf:bind>
                    
                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()" 
                                   validate="true">
                                   
                        <xf:resource value="'{$form:REST-BC-LIVE}/forms/{$docname}.xml'"/>
    
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
                        <xf:setvalue ref="instance()/@name" value="'{$docname}'"/>
                        <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-fieldtmpl')/field" />
                        <xf:setfocus control="label-name"/>
                    </xf:action>
                </xf:model>
            
            </div>
            
            <div>
                <xf:group id="g-field" ref="instance()/field[last()]" class="fieldAdd">               
                       <a href="form.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}#tabfields">
                            <img src="resources/images/back_arrow.png" title="back to form" alt="back to workflow states"/>
                        </a>
                        <h1><xf:output ref="@label"/></h1>                    
                        <xf:group appearance="bf:verticalTable">
                            <xf:group appearance="bf:horizontalTable">
                                <xf:input id="label-name" ref="@label" incremental="true">
                                    <xf:label>label</xf:label>
                                    <xf:hint>Label used for this field</xf:hint>
                                    <xf:alert>invalid label name</xf:alert>
                                    <xf:help>help with label of field</xf:help>
                                </xf:input> 
                                
                                <xf:input id="field-name" ref="@name" incremental="true">
                                    <xf:label>field name</xf:label>
                                    <xf:hint>Enter be the field title</xf:hint>
                                    <xf:alert>invalid: must be 3+ characters, A-z and _, unique name in the form</xf:alert>
                                    <xf:help>Use A-z with the underscore character to avoid spaces</xf:help>
                                </xf:input>                                 
                                <xf:input id="input-req-field" ref="@required">
                                    <xf:label>required</xf:label>
                                    <xf:hint>Enabling this means it is a required field</xf:hint>
                                    <xf:alert>invalid null boolean</xf:alert>
                                </xf:input>                                
                            </xf:group>
                            <div style="margin-bottom:10px;"/>                            
                            
                            <xf:group appearance="bf:horizontalTable">
                                <xf:label>Input types</xf:label>
                                <xf:select1 id="select-val-type" ref="@value_type" appearance="minimal" incremental="true">
                                    <xf:label>value type</xf:label>
                                    <xf:hint>internal value</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-valuetypes')/valueType[not(./@name = preceding-sibling::node()/@name)]">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@name"></xf:value>
                                    </xf:itemset>
                                </xf:select1>  
                                
                                <xf:select1 bind="b-rendertype" appearance="minimal" incremental="true">
                                    <xf:label>widget</xf:label>
                                    <xf:hint>external value show on input forms</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-valuetypes')/valueType[@name eq instance()/field[last()]/@value_type]">
                                        <xf:label ref="@rendertype"></xf:label>
                                        <xf:value ref="@rendertype"></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                            </xf:group>
                                                    
                        </xf:group>
                        <hr/>
                        <xf:group appearance="compact" class="modesWrapper">
                            <xf:label>Modes</xf:label>
                            
                            <!-- view mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>view</xf:label>
                                <xf:input id="input-viewshow" ref="view/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>     
                                <xf:repeat id="r-viewfieldattrs" nodeset="view/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-viewfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="view/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- edit mode -->
                            <xf:group appearance="bf:verticalTable">
                                 <xf:label>edit</xf:label>
                                  <xf:input id="input-editshow" ref="edit/@show">
                                      <xf:label>show</xf:label>
                                  </xf:input>  
                                  <xf:repeat id="r-editfieldattrs" nodeset="edit/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                      <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                          <xf:label>select a role</xf:label>
                                          <xf:help>help for select1</xf:help>
                                          <xf:alert>invalid: cannot be empty</xf:alert>
                                          <xf:itemset nodeset="instance('i-allroles')/role">
                                              <xf:label ref="@name"></xf:label>
                                              <xf:value ref="@name"></xf:value>
                                          </xf:itemset>
                                      </xf:select1>
                                      <xf:trigger>
                                          <xf:label>delete</xf:label>
                                          <xf:action>
                                              <xf:delete at="index('r-editfieldattrs')[position()]"></xf:delete>
                                          </xf:action>
                                      </xf:trigger>                                         
                                  </xf:repeat>
                                  <br/>
                                  <xf:group appearance="minimal">
                                      <xf:trigger>
                                         <xf:label>add role</xf:label>
                                         <xf:action>
                                             <xf:insert nodeset="edit/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                         </xf:action>
                                      </xf:trigger>     
                                  </xf:group>
                            </xf:group>
                            
                            <!-- add -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>add</xf:label>
                                <xf:input id="input-addshow" ref="add/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>   
                                <xf:repeat id="r-addfieldattrs" nodeset="add/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-addfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="add/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                             
                            <!-- listing -->
                            <xf:group appearance="bf:verticalTable">
                               <xf:label>listing</xf:label>
                                <xf:input id="input-listingshow" ref="listing/@show">
                                    <xf:label>show</xf:label>
                                </xf:input>  
                                <xf:repeat id="r-listingfieldattrs" nodeset="listing/roles/role[position()!=last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>select a role</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-listingfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="listing/roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                                             
                        </xf:group>                           
                        <hr/>
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label/>
                            <xf:trigger>
                                <xf:label>Save</xf:label>
                                <xf:action>
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                    <xf:send submission="s-add"/>
                                </xf:action>                              
                            </xf:trigger>                  
                        </xf:group>   
                        
                        <xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>                      
                </xf:group>                
            
            </div>                 
        </div>
};