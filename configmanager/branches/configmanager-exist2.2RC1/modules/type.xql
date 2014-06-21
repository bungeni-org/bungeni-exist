xquery version "3.0";

module namespace type="http://exist.bungeni.org/types";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace ce="http://bungeni.org/config_editor" ;


import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="models:type-edit". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)

declare variable $type:CXT := request:get-context-path();
declare variable $type:REST-CXT-APP :=  $type:CXT || $appconfig:REST-APP-ROOT;
declare variable $type:REST-BC-LIVE :=  $type:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;

(:
    Renders the Types
:)
declare function local:get-types() {
    let $d := doc($appconfig:TYPES-XML)/types
    let $flattened := <grouped>{appconfig:flatten($d)}</grouped>
    for $archetype at $pos in appconfig:three-in-one($flattened)/child::*[@key ne 'member']
    let $count := count(appconfig:three-in-one($flattened)/child::*)
    order by $archetype/@key ascending
    return  
        local:wrap-type($archetype)
};

declare function local:arche-types() {
    <archetypes>{
        let $types := doc($appconfig:TYPES-XML)/types
        let $base-types := distinct-values($types/doc/@archetype)
        for $base-type in $base-types
        return 
            element archetype {
                $base-type
            }
    }</archetypes>
};

(: GET ALL TEH FORM NAMES :)
declare function local:descriptors() {
    <descriptors>{
        for $descriptor in collection($appconfig:FORM-FOLDER)/descriptor
        order by util:document-name($descriptor) ascending
        return 
            element descriptor {
                substring-before(util:document-name($descriptor),'.')
            }
    }</descriptors>
};

(: GET ALL TEH WORKFLOW NAMES :)
declare function local:workflows() {
    <workflows>{
        for $workflow in collection($appconfig:WF-FOLDER)/workflow
        order by util:document-name($workflow) ascending
        return 
            element workflow {
                substring-before(util:document-name($workflow),'.')
            }
    }</workflows>
};

(:
    Encapsulates each of the 3 archtypes into their own column for rendering
  @param archetype
  @return
    HTML <div/>
:)
declare function local:wrap-type($archetype as node()) {
    <div class="ulisting">
        <h2>{data($archetype/@key)}</h2>            
        <ul class="clearfix">                      			 
            {
            for $type at $pos in $archetype/child::*
            let $count := count($archetype/child::*)
            let $type-added := xs:string(request:get-parameter("type", ""))
            order by $type/@name ascending
            return  
                <li>
                {
                    if($type-added eq xs:string(node-name($type)) and $pos eq $count) then 
                        <a class="{if(data($type/@enabled) = 'true') then 'deep' else 'greyed' }" title="{if (data($type/@enabled) = 'true') then 'enabled' else 'disabled' }" href="type.html?type={node-name($type)}&amp;doc={data($type/@name)}&amp;pos={$pos}">{data($type/@name)}<i class="icon-plus new"></i></a>
                    else                     
                        <a class="{if(data($type/@enabled) = 'true') then 'deep' else 'greyed' }" title="{if (data($type/@enabled) = 'true') then 'enabled' else 'disabled' }" href="type.html?type={node-name($type)}&amp;doc={data($type/@name)}&amp;pos={$pos}">{data($type/@name)}</a>
                }
                {
                    if($type/child::*) then 
                        <ul>
                        {
                            for $member in $type/child::*
                            return
                                <li>
                                    {
                                      if($type-added eq xs:string(node-name($type)) and $pos eq $count) then 
                                          <a class="{if(data($member/@enabled) = 'true') then 'deep' else 'greyed' }" title="{if (data($member/@enabled) = 'true') then 'enabled' else 'disabled' }" href="type.html?type={node-name($member)}&amp;doc={data($member/@name)}&amp;pos={$pos}">{data($member/@name)}<i class="icon-plus new"></i></a>
                                      else                     
                                          <a class="{if(data($member/@enabled) = 'true') then 'deep' else 'greyed' }" title="{if (data($member/@enabled) = 'true') then 'enabled' else 'disabled' }" href="type.html?type={node-name($member)}&amp;doc={data($member/@name)}&amp;pos={$pos}">{data($member/@name)}</a>                                        
                                    }
                                </li>
                        }
                        </ul>
                    else    
                        ()
                }
                </li>
            }
        </ul>  
        <a class="button-link" href="type-add.html?type={data($archetype/@key)}&amp;doc=new">add {data($archetype/@key)} type</a>
    </div>  
};

declare 
function type:edit($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $TYPE := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    let $pos := request:get-parameter("pos", "none")
    return
        <div xmlns:ce="http://bungeni.org/config_editor">
            <xf:model>
                <xf:instance id="i-type" src="{$type:REST-BC-LIVE}/types.xml"/>
                  
                <xf:instance id="i-boolean" src="{$type:REST-CXT-APP}/model_templates/boolean.xml"/>
                
                <xf:instance xmlns="" id="i-typedoc">
                    <data>
                        <doc name="" enabled="false"/>
                    </data>
                </xf:instance>
                
                <xf:instance xmlns="" id="i-typegroup">
                    <data>
                        <group name="" workflow="group" enabled="false"/>
                    </data>
                </xf:instance>
                
                <xf:instance xmlns="" id="i-groupmember">
                    <data>
                        <member name="{concat($name,'_')}" enabled="true" workflow="group_membership"/>
                    </data>
                </xf:instance> 
                
                <xf:instance xmlns="" id="i-archetypes">
                    {local:arche-types()}
                </xf:instance>                
                
                <xf:instance xmlns="" id="i-descriptors">
                    {local:descriptors()}
                </xf:instance>      
                
                <xf:instance xmlns="" id="i-workflows">
                    {local:workflows()}
                </xf:instance>  
                
                <xf:instance id="i-vars" src="{$type:REST-CXT-APP}/model_templates/vars.xml"/>
                
                <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-controller" src="{$type:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/{$TYPE}[{$pos}]">
                    <xf:bind id="typename" nodeset="@name" type="xf:string" readonly="true()" required="true()" constraint="string-length(.) > 0 and string-length(replace(.,' ','')) = string-length(.)" />
                    <xf:bind id="typelabel" nodeset="@label" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z ]+$')" />
                    <xf:bind id="typecontainerlabel" nodeset="@container_label" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z ]+$')" />
                    <xf:bind id="typearchetype" nodeset="@archetype" required="false()" type="xf:string" constraint="(string-length(.) &gt; 1 and matches(., '^[a-z_]+$')) or (string-length(.) &lt; 1)" />
                    <xf:bind id="typedescriptor" nodeset="@descriptor" required="true()" type="xf:string" constraint="string-length(.) &gt; 1 and matches(., '^[a-z_]+$')" />
                    <xf:bind id="typeworkflow" nodeset="@workflow" required="true()" type="xf:string" constraint="string-length(.) &gt; 1 and matches(., '^[a-z_]+$')" />                    
                    <xf:bind id="typenable" nodeset="@enabled" type="xf:boolean" required="true()"/>
                </xf:bind>
                
                <xf:submission id="s-controller"
                               method="put"
                               replace="none"
                               ref="instance('i-controller')">
                    <xf:resource value="'{$type:REST-CXT-APP}/model_templates/controller.xml'"/>
        
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
        
                    <xf:action ev:event="xforms-submit">
                        <xf:message level="ephemeral">Record the Type name to controller</xf:message>
                        <xf:setvalue ref="instance('i-controller')/lastAddedType" value="instance()/doc[last()]/@name" />
                        <xf:recalculate/>
                    </xf:action>
                </xf:submission> 
                
                <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$type:REST-BC-LIVE}/types.xml'"/>
                    
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
                        <xf:message level="ephemeral">Type details saved successfully</xf:message>
                        <script type="text/javascript" if="instance('tmp')/wantsToClose">
                            location.reload();
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
                
                <xf:submission id="s-delete" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$type:REST-BC-LIVE}/types.xml'"/>

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
                        <xf:message level="ephemeral">Type deleted successfully</xf:message>
                        <script type="text/javascript">
                            document.location.href = 'types.html?rand={current-time()}';
                        </script> 
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>Transition information have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>                 
                
                <xf:action ev:event="xforms-ready">
                    <!--xf:action if="'{$TYPE}' = 'doc'">
                        <xf:insert nodeset="instance()/doc" at="last()" position="after" origin="instance('i-typedoc')/doc" />
                    </xf:action>
                    <xf:action if="'{$TYPE}' = 'group'">
                        <xf:insert nodeset="instance()/group" at="last()" position="after" origin="instance('i-typegroup')/group" />
                    </xf:action>  
                    <xf:setfocus control="type-name"/-->
                </xf:action>        
            </xf:model>
            <!-- ######################### Views start ################################## -->
            <h2>Edit {$TYPE}-type</h2>
            <xf:group appearance="compact" ref="./{$TYPE}[{$pos}]">
                <xf:group appearance="bf:verticalTable">
                    <xf:input bind="typename" id="type-label" incremental="true">
                        <xf:label>name:</xf:label>
                    </xf:input>                
                    <xf:input bind="typelabel" id="type-label" incremental="true">
                        <xf:label>label:</xf:label>
                        <xf:hint>Used in menus</xf:hint>
                        <xf:alert>invalid label - non-alphabets disallowed</xf:alert>
                    </xf:input>
                    <xf:input bind="typecontainerlabel" id="type-containerlabel" incremental="true">
                        <xf:label>container label:</xf:label>
                        <xf:hint>Label on the folder containing this doc-type</xf:hint>
                        <xf:alert>invalid container label - non-alphabets disallowed</xf:alert>
                    </xf:input>                
                    <xf:select1 bind="typenable" id="c-enabled" appearance="minimal" class="xsmallWidth" incremental="true">
                        <xf:label>type status:</xf:label>
                        <xf:hint>enable this {$TYPE}-type in Bungeni</xf:hint>
                        <xf:help>help for select1</xf:help>
                        <xf:alert>invalid</xf:alert>
                        <xf:itemset nodeset="instance('i-boolean')/bool">
                            <xf:label ref="@name"></xf:label>
                            <xf:value ref="."></xf:value>
                        </xf:itemset>
                    </xf:select1>
                    {
                    if($TYPE eq 'doc') then 
                        <xf:group appearance="bf:verticalTable">
                            <xf:select1 bind="typearchetype" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>archetype:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a newone</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-archetypes')/archetype">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>
                            <xf:select1 bind="typedescriptor" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>descriptor:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a new base-type</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-descriptors')/descriptor">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                         
                            <xf:select1 bind="typeworkflow" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>workflow:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a new base-type</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-workflows')/workflow">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1> 
                        </xf:group>
                    else ()
                    }
                </xf:group>
                <hr/>                  
                {
                if ($TYPE eq 'group') then (             
                    <xf:group appearance="bf:verticalTable">
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label>member types</xf:label>
                            <xf:repeat id="r-groupmembers" nodeset="member" appearance="compact">
                                <xf:input ref="@name" incremental="true">
                                    <xf:label>name</xf:label>
                                    <xf:hint>{$name}_member.</xf:hint>
                                    <xf:help>should be attached to role is using a dot</xf:help>
                                    <xf:message ev:event="xforms-invalid" level="ephemeral">member name must start with `{$name}_` and avoid spaces</xf:message>
                                </xf:input>  
                                <xf:select1 ref="@enabled" appearance="minimal" class="xsmallWidth" incremental="true">
                                    <xf:label>type status</xf:label>
                                    <xf:hint>a Hint for this control</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-boolean')/bool">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1>                            
                                <xf:select1 ref="@workflow" appearance="minimal" class="xmediumWidth" incremental="true">
                                    <xf:label>workflow</xf:label>
                                    <xf:hint>the workflow that handles this</xf:hint>
                                    <xf:help>pick from the list of workflow</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-workflows')/workflow">
                                        <xf:label ref="."></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1> 
                                <xf:trigger src="resources/images/delete.png">
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-groupmembers')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                        </xf:group>   
                        <br/>
                        <xf:group appearance="minimal">
                            <xf:trigger>
                               <xf:label>add member type</xf:label>
                               <xf:action>
                                   <xf:insert nodeset="member" at="last()" position="after" origin="instance('i-groupmember')/member"/>
                                   <xf:setfocus control="r-groupmembers"/>
                               </xf:action>
                            </xf:trigger>     
                        </xf:group>                        
                    </xf:group>                    
                ) else ()
                }
                <hr/>                  
                <xf:group id="typeButtons" appearance="bf:horizontalTable">
                    <xf:trigger>
                        <xf:label>update</xf:label>
                        <xf:action if="'{$TYPE}' = 'doc'">
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>
                        <xf:action if="'{$TYPE}' = 'group'">
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>
                        <xf:action>
                            <xf:setvalue ref="instance('i-vars')/renameDoc" value="concat(instance()/{$TYPE}[{$pos}]/@name,'.xml')"/>
                            <xf:load show="none" targetid="secondary-menu">
                                <xf:resource value="concat('{$type:REST-CXT-APP}/doc_actions/rename.xql?doc={$name}.xml&amp;rename=',instance('i-vars')/renameDoc,'')"/>
                            </xf:load>
                        </xf:action>                            
                    </xf:trigger>
                    
                    <xf:group appearance="bf:verticalTable">                      
                         <xf:switch>
                            <xf:case id="delete">
                               <xf:trigger ref="instance()/{$TYPE}">
                                  <xf:label>delete</xf:label>
                                  <xf:action ev:event="DOMActivate">
                                     <xf:toggle case="confirm" />
                                  </xf:action>
                               </xf:trigger>
                            </xf:case>
                            <xf:case id="confirm">
                               <h2>Are you sure you want to delete this doctype?</h2>
                               <xf:group appearance="bf:horizontalTable">
                                   <xf:trigger>
                                      <xf:label>Delete</xf:label>
                                      <xf:action ev:event="DOMActivate">
                                        <xf:delete nodeset="instance()/descendant-or-self::*[data(@name) eq '{$name}']"/>
                                        <xf:send submission="s-delete"/>
                                        <xf:toggle case="delete" />
                                      </xf:action>
                                   </xf:trigger>
                                   <xf:trigger>
                                        <xf:label>Cancel</xf:label>
                                        <xf:toggle case="delete" ev:event="DOMActivate" />
                                   </xf:trigger>
                                </xf:group>
                            </xf:case>
                         </xf:switch>   
                    </xf:group>                        
                </xf:group>
            </xf:group>
            <!-- ######################### Views end ################################## -->  
        </div>
};

declare 
function type:add($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $TYPE := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    let $pos := request:get-parameter("pos", "none")
    return
        <div xmlns:ce="http://bungeni.org/config_editor">
            <xf:model>
                <xf:instance id="i-type" src="{$type:REST-BC-LIVE}/types.xml"/>
                
                <xf:instance id="i-boolean" src="{$type:REST-CXT-APP}/model_templates/boolean.xml"/>                
                
                <xf:instance xmlns="" id="i-archetypes">
                    {local:arche-types()}
                </xf:instance>   
                
                <xf:instance xmlns="" id="i-descriptors">
                    {local:descriptors()}
                </xf:instance>      
                
                <xf:instance xmlns="" id="i-workflows">
                    {local:workflows()}
                </xf:instance>                 
                
                <xf:instance xmlns="" id="i-typedoc">
                    <data>
                        <doc name="" enabled="false" archetype="doc" label="" container_label="" descriptor="" workflow=""/>
                    </data>
                </xf:instance>
                
                <xf:instance xmlns="" id="i-typeevent">
                    <data>
                        <event name="" enabled="false" archetype="event" label="" container_label="" descriptor="" workflow=""/>
                    </data>
                </xf:instance>                
                
                <xf:instance xmlns="" id="i-typegroup">
                    <data>
                        <group name="" workflow="group" enabled="false"/>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-vars" src="{$type:REST-CXT-APP}/model_templates/vars.xml"/>
                
                <xf:instance id="tmp" src="{$type:REST-CXT-APP}/model_templates/tmp.xml"/>
                
                <xf:instance id="i-controller" src="{$type:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/{$TYPE}[last()]">
                    <xf:bind id="typename" nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and count(instance()/{$TYPE}/@name) eq count(distinct-values(instance()/{$TYPE}/@name))" />
                    <xf:bind id="typelabel" nodeset="@label" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z ]+$')" />
                    <xf:bind id="typecontainerlabel" nodeset="@container_label" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z ]+$')" />
                    <xf:bind id="typearchetype" nodeset="@archetype" required="false()" type="xf:string" constraint="(string-length(.) &gt; 1 and matches(., '^[a-z_]+$')) or (string-length(.) &lt; 1)" />
                    <xf:bind id="typedescriptor" nodeset="@descriptor" required="true()" type="xf:string" constraint="string-length(.) &gt; 1 and matches(., '^[a-z_]+$')" />
                    <xf:bind id="typeworkflow" nodeset="@workflow" required="true()" type="xf:string" constraint="string-length(.) &gt; 1 and matches(., '^[a-z_]+$')" />
                    <xf:bind id="typenable" nodeset="@enabled" type="xf:boolean" required="true()"/>
                </xf:bind>
                
                <xf:submission id="s-controller"
                               method="put"
                               replace="none"
                               ref="instance('i-controller')">
                    <xf:resource value="'{$type:REST-CXT-APP}/model_templates/controller.xml'"/>
        
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
        
                    <xf:action ev:event="xforms-submit">
                        <xf:message level="ephemeral">Record the Type name to controller</xf:message>
                        <xf:setvalue ref="instance('i-controller')/lastAddedType" value="instance()/doc[last()]/@name" />
                        <xf:recalculate/>
                    </xf:action>
                </xf:submission> 
                
                <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$type:REST-BC-LIVE}/types.xml'"/>
                    
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
                        <xf:message level="ephemeral">New type added successfully</xf:message>
                        <script type="text/javascript">
                            document.location.href = 'types.html?rand={current-time()}&#38;amp;type={$TYPE}';
                        </script> 
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The type details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>    
                
                <xf:action ev:event="xforms-ready">
                    <xf:action if="'{$TYPE}' = 'doc'">
                        <xf:insert nodeset="instance()/doc" at="last()" position="after" origin="instance('i-typedoc')/doc" />
                    </xf:action>
                    <xf:action if="'{$TYPE}' = 'event'">
                        <xf:insert nodeset="instance()/event" context="instance()" at="last()" position="after" origin="instance('i-typeevent')/event" />
                    </xf:action>                    
                    <xf:action if="'{$TYPE}' = 'group'">
                        <xf:insert nodeset="instance()/group" at="last()" position="after" origin="instance('i-typegroup')/group" />
                    </xf:action>  
                    <xf:setfocus control="type-name"/>
                </xf:action>        
            </xf:model>
            <!-- ######################### View start ################################## -->
            <h2>Add {$TYPE}-type</h2>
            <xf:group appearance="compact" ref="instance()/doc[last()]">
                <xf:group appearance="bf:verticalTable">
                    <xf:input bind="typename" id="type-name" incremental="true">
                        <xf:label>name:</xf:label>
                        <xf:hint>Unique / no spaces / lower-case alphabets only</xf:hint>
                        <xf:alert>invalid name - duplicate / empty space(s) disallowded</xf:alert>
                        <xf:action ev:event="xforms-valid">
                            <xf:setvalue ref="instance()/doc[last()]/@descriptor" value="instance()/doc[last()]/@name"/>
                            <xf:setvalue ref="instance()/doc[last()]/@workflow" value="instance()/doc[last()]/@name"/>
                        </xf:action>
                    </xf:input>   
                    <xf:input bind="typelabel" id="type-label" incremental="true">
                        <xf:label>label:</xf:label>
                        <xf:hint>Used in menus</xf:hint>
                        <xf:alert>invalid label - non-alphabets disallowed</xf:alert>
                    </xf:input>
                    <xf:input bind="typecontainerlabel" id="type-containerlabel" incremental="true">
                        <xf:label>container label:</xf:label>
                        <xf:hint>Label on the folder containing this doc-type</xf:hint>
                        <xf:alert>invalid container label - non-alphabets disallowed</xf:alert>
                    </xf:input>                      
                    <xf:select1 id="c-enabled" bind="typenable" appearance="minimal" class="xsmallWidth" incremental="true">
                        <xf:label>type status:</xf:label>
                        <xf:help>enable this {$TYPE}-type in Bungeni</xf:help>
                        <xf:alert>invalid</xf:alert>
                        <xf:itemset nodeset="instance('i-boolean')/bool">
                            <xf:label ref="@name"></xf:label>
                            <xf:value ref="."></xf:value>
                        </xf:itemset>
                    </xf:select1>
                    {
                    if($TYPE eq 'doc') then 
                        <xf:group appearance="bf:verticalTable">
                            <xf:select1 bind="typearchetype" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>archetype:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a new base-type</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-archetypes')/archetype">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>
                            <xf:select1 bind="typedescriptor" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>descriptor:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a new base-type</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-descriptors')/descriptor">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                         
                            <xf:select1 bind="typeworkflow" class="choiceInput" selection="open" appearance="minimal" incremental="true">
                                <xf:label>workflow:</xf:label>
                                <xf:hint>choose doc base-type from dropdown or add a new base-type</xf:hint>
                                <xf:help>denotes the original type this document is derived from</xf:help>
                                <xf:alert>invalid type name / empty space(s)</xf:alert>
                                <xf:itemset nodeset="instance('i-workflows')/workflow">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>
                        </xf:group>
                    else ()
                    }                    
                    <br/>
                    <xf:group id="typeButtons">
                        <xf:trigger>
                            <xf:label>Add</xf:label>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>                        
                        </xf:trigger>
                    </xf:group>
                </xf:group>
            </xf:group>
            <!-- ######################### View end ################################## -->  
        </div>
};

declare 
function type:types($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $type := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    let $pos := request:get-parameter("pos", "none")
    return
        <div class="allTypes">
            <div class="commit-holder">
                <h1>arche-types</h1>
                <a class="commit" href="/exist/restxq/system/commit/types" title="save this file back to the filesystem">commit types</a>
            </div>        
            {local:get-types()}
            <br/>
            <div style="clear:both;"/>
            <div style="margin-top:20px;float:left;">
                <h1>supported-types</h1>   
            </div>
        </div>
};