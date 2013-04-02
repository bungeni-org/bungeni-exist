xquery version "3.0";

module namespace type="http://exist.bungeni.org/types";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;


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
    for $archetype at $pos in appconfig:three-in-one($flattened)/child::*
    let $count := count(appconfig:three-in-one($flattened)/child::*)
    order by $archetype/@key ascending
    return  
        local:wrap-type($archetype)
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
                </li>
            }
        </ul>  
        <a class="button-link" href="type-add.html?type={data($archetype/@key)}&amp;doc=new">add {data($archetype/@key)} type</a>
    </div>  
};

declare 
function type:edit($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $type := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    let $pos := request:get-parameter("pos", "none")
    return
        <div>
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
                        <group name="" workflow="group" enabled="false">
                            <member name="member_member" workflow="group_membership" enabled="false"/>
                        </group>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-vars" src="{$type:REST-CXT-APP}/model_templates/vars.xml"/>
                
                <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-controller" src="{$type:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/{$type}[{$pos}]">
                    <xf:bind id="typename" nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) > 0 and string-length(replace(.,' ','')) = string-length(.)" />
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
                    <!--xf:action if="'{$type}' = 'doc'">
                        <xf:insert nodeset="instance()/doc" at="last()" position="after" origin="instance('i-typedoc')/doc" />
                    </xf:action>
                    <xf:action if="'{$type}' = 'group'">
                        <xf:insert nodeset="instance()/group" at="last()" position="after" origin="instance('i-typegroup')/group" />
                    </xf:action>  
                    <xf:setfocus control="type-name"/-->
                </xf:action>        
            </xf:model>
            <!-- ######################### Views start ################################## -->
            <p>Edit the type information || Click on the left to update parts</p>
            <xf:group appearance="compact">
                <xf:group>
                    <xf:group appearance="bf:verticalTable">
                        <xf:select1 id="c-enabled" bind="typenable" appearance="minimal" class="xsmallWidth" incremental="true">
                            <xf:label>type status:</xf:label>
                            <xf:hint>a Hint for this control</xf:hint>
                            <xf:help>help for select1</xf:help>
                            <xf:alert>invalid</xf:alert>
                            <xf:itemset nodeset="instance('i-boolean')/bool">
                                <xf:label ref="@name"></xf:label>
                                <xf:value ref="."></xf:value>
                            </xf:itemset>
                        </xf:select1>
                    </xf:group>
                    <br/>
                    <xf:group id="typeButtons" appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>update</xf:label>
                            <xf:action if="'{$type}' = 'doc'">
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>
                            <xf:action if="'{$type}' = 'group'">
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>
                            <xf:action>
                                <xf:setvalue ref="instance('i-vars')/renameDoc" value="concat(instance()/{$type}[{$pos}]/@name,'.xml')"/>
                                <xf:load show="none" targetid="secondary-menu">
                                    <xf:resource value="concat('{$type:REST-CXT-APP}/doc_actions/rename.xql?doc={$name}.xml&amp;rename=',instance('i-vars')/renameDoc,'')"/>
                                </xf:load>
                            </xf:action>                            
                        </xf:trigger>
                        <xf:group appearance="bf:verticalTable">                      
                             <xf:switch>
                                <xf:case id="delete">
                                   <xf:trigger ref="instance()/{$type}">
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
            </xf:group>
            <!-- ######################### Views end ################################## -->  
        </div>
};

declare 
function type:add($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $type := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    let $pos := request:get-parameter("pos", "none")
    return
        <div>
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
                        <group name="" workflow="group" enabled="false">
                            <member name="member_member" workflow="group_membership" enabled="false"/>
                        </group>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-vars" src="{$type:REST-CXT-APP}/model_templates/vars.xml"/>
                
                <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-controller" src="{$type:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/{$type}[last()]">
                    <xf:bind id="typename" nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and count(instance()/{$type}/@name) eq count(distinct-values(instance()/{$type}/@name))" />
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
                            document.location.href = 'types.html?rand={current-time()}&#38;amp;type={$type}';
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
                
                <xf:action ev:event="xforms-ready">
                    <xf:action if="'{$type}' = 'doc'">
                        <xf:insert nodeset="instance()/doc" at="last()" position="after" origin="instance('i-typedoc')/doc" />
                    </xf:action>
                    <xf:action if="'{$type}' = 'group'">
                        <xf:insert nodeset="instance()/group" at="last()" position="after" origin="instance('i-typegroup')/group" />
                    </xf:action>  
                    <xf:setfocus control="type-name"/>
                </xf:action>        
            </xf:model>
            <!-- ######################### Views start ################################## -->
            <p>Enter {$type}-type information || Click on the left to update parts</p>
            <xf:group appearance="compact" ref="instance()/doc[last()]">
                <xf:group appearance="bf:verticalTable">
                    <xf:input bind="typename" id="type-name" incremental="true">
                        <xf:label>name</xf:label>
                        <xf:hint>Unique / no spaces / lower-case alphabets only</xf:hint>
                        <xf:alert>invalid type name / duplicate / empty space(s)</xf:alert>
                    </xf:input>                  
                    <xf:select1 id="c-enabled" bind="typenable" appearance="minimal" class="xsmallWidth" incremental="true">
                        <xf:label>type status:</xf:label>
                        <xf:hint>a Hint for this control</xf:hint>
                        <xf:help>help for select1</xf:help>
                        <xf:alert>invalid</xf:alert>
                        <xf:itemset nodeset="instance('i-boolean')/bool">
                            <xf:label ref="@name"></xf:label>
                            <xf:value ref="."></xf:value>
                        </xf:itemset>
                    </xf:select1>
                    <br/>
                    <xf:group id="typeButtons">
                        <xf:trigger>
                            <xf:label>Add</xf:label>
                            <xf:action if="'doc' = 'doc'">
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>
                            <xf:action if="'group' = 'group'">
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>
                            <!--xf:action>
                                <xf:setvalue ref="instance('i-vars')/renameDoc" value="concat(instance()/{$type}[{$pos}]/@name,'.xml')"/>
                                <xf:load show="none" targetid="secondary-menu">
                                    <xf:resource value="concat('{$type:REST-CXT-APP}/doc_actions/rename.xql?doc={$name}.xml&amp;rename=',instance('i-vars')/renameDoc,'')"/>
                                </xf:load>
                            </xf:action-->                            
                        </xf:trigger>
                    </xf:group>
                </xf:group>
            </xf:group>
            <!-- ######################### Views end ################################## -->  
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
            <h1>arche-types</h1>
            {local:get-types()}
            <br/>
            <div style="clear:both;"/>
            <div style="margin-top:20px;float:left;">
                <h1>supported-types</h1>   
            </div>
        </div>
};