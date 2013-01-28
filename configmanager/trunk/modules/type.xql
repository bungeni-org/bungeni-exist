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
declare variable $type:REST-CXT-APP :=  $type:CXT || "/rest" || $config:app-root;

declare 
function local:get-types() {
    for $docu at $pos in doc($appconfig:TYPES-XML)/types/*
    let $count := count(doc($appconfig:TYPES-XML)/types/*)
    return    
        <tr>
            <td><a class="editlink" href="type.html?type={node-name($docu)}&amp;doc={data($docu/@name)}&amp;pos={$pos}">{data($docu/@name)}</a></td>
            <td><a class="deleteLink" href="type.html?type={node-name($docu)}&amp;doc={data($docu/@name)}&amp;pos={$pos}">{data($docu/@enabled)}</a></td>
        </tr>    
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
                <xf:instance id="i-type" src="{$type:REST-CXT-APP}/working/live/bungeni_custom/types.xml"/>
                
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
                    <xf:resource value="'{$type:REST-CXT-APP}/working/live/bungeni_custom/types.xml'"/>
                    
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
                    <xf:input bind="typename" id="type-name">
                        <xf:label>name</xf:label>
                        <xf:hint>Unique name</xf:hint>
                        <xf:help>Neither are spaces allowed in between</xf:help>
                        <xf:alert>invalid form name / duplicate / empty space(s)</xf:alert>
                    </xf:input>
                    <xf:input bind="typenable" id="type-enabled">
                        <xf:label>enabled</xf:label>
                        <xf:hint>check to enable this</xf:hint>
                    </xf:input>
                    <br/>
                    <xf:group id="typeButtons">
                        <xf:trigger>
                            <xf:label>Update</xf:label>
                            <xf:action if="'doc' = 'doc'">
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>
                            <xf:action if="'group' = 'group'">
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
        <div>
            <h3>All Types</h3>
            <table class="listingTable" style="width:auto;">
                <tr>                      			 
                    <th>type</th>
                    <th>enabled</th>
                </tr>
                {local:get-types()}
            </table>     
            <div style="margin-top:15px;"/> 
            <a class="button-link" href="type-add.html?type=none&amp;doc=none&amp;pos=0">add type</a>  
        </div>
};