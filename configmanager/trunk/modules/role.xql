xquery version "3.0";

module namespace role="http://exist.bungeni.org/rolefunctions";
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

declare variable $role:CXT := request:get-context-path();
declare variable $role:RESTXQ := request:get-context-path() || "/restxq";
declare variable $role:REST-CXT-APP :=  $role:CXT || $appconfig:REST-APP-ROOT;
declare variable $role:REST-BC-LIVE :=  $role:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;

declare function local:get-custom-roles() as node() * {
    doc($appconfig:SYS-FOLDER || '/acl/roles.xml')/roles
};

declare function local:occurrences() {

    for $instance in collection($appconfig:CONFIGS-FOLDER)
    let $name := request:get-parameter("doc", "none")
    let $in-coll := util:collection-name($instance)
    let $path := document-uri($instance)
    let $where := functx:substring-after-last($in-coll,'/')
    let $doc-name := substring-before(util:document-name($instance),".")
    where $instance//child::node()[. eq $name or contains(data(./@name), "_"||$name)]
    return
        <li>
            {   
            if (contains($path, "workflows")) then 
                <span>workflow - <a title="{$path}" href="workflow.html?type=doc&amp;doc={$doc-name}&amp;pos=0#tabfacets">{$doc-name}<i class="icon-edit add"></i></a></span>
            else if (contains($path, "forms")) then 
                <span>form - <a title="{$path}" href="form.html?type=doc&amp;doc={$doc-name}&amp;pos=0">{$doc-name}<i class="icon-edit add"></i></a></span>
            else
                ()
            }
        </li>

};

declare 
function role:roles($node as node(), $model as map(*)) { 
        <div>
            <div class="ulisting">
                <h2>custom roles</h2>
                <ul class="clearfix">
                    {
                        for $role in local:get-custom-roles()/role
                        let $count := count(local:get-custom-roles()/role)
                        let $subroles := if(count($role/subrole) ne 0) then "+" || count($role/subrole) || "subroles" else ""
                        order by $role/@title ascending 
                        return  
                            <li>
                                <a class="editlink" href="role.html?doc={data($role/@id)}">{data($role/@title)}</a>&#160;
                                <tt class="roles-inline">{$subroles}</tt>
                            </li>                    
                    }
                </ul>
                
                <a class="button-link" href="role-add.html?doc=new">add role</a>
            </div> 
        </div>   
};

declare function local:get-system-roles() {
    let $allroles := doc($appconfig:SYS-FOLDER || '/.auto/_roles.xml')/roles
    let $customroles := doc($appconfig:SYS-FOLDER || '/acl/roles.xml')/roles
    for $role in $allroles/role/@name
    return 
        if(every $sysrole in distinct-values($customroles//@id) satisfies $sysrole != data($role)) then 
            <li>
                {data($role)}
            </li>           
        else
            ()
};

declare 
function role:system-roles($node as node(), $model as map(*)) { 
        <div>
            <div class="sysroles">
                <h4>system roles</h4>
                <ul class="clearfix">
                    {local:get-system-roles()}
                </ul>
            </div> 
        </div>   
};

declare 
function role:edit($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $type := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    return
        <div>
            <xf:model id="master">
                <xf:instance id="i-customroles" src="{$role:REST-BC-LIVE}/sys/acl/roles.xml"/>
                  
                 <xf:instance id="i-boolean" src="{$role:REST-CXT-APP}/model_templates/boolean.xml"/>
                
                <xf:instance xmlns="" id="i-role">
                    <data>
                        <role id="" title=""/>
                    </data>
                </xf:instance>
                
                <xf:instance xmlns="" id="i-subrole">
                    <data>
                        <subrole id="{concat($name,'.')}" title=""/>
                    </data>
                </xf:instance>
                
                <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-controller" src="{$role:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/role[@id eq '{$name}']">
                    <xf:bind id="roletitle" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 2" />
                    <xf:bind id="roleid" nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$')" />
                    <xf:bind nodeset="subrole/@id" type="xf:string" required="true()" constraint="string-length(.) &gt; string-length('{$name}')+1 and starts-with(.,'{$name}.') and matches(., '^[A-z.]+$')" />
                    <xf:bind nodeset="subrole/@title" type="xf:string" required="true()" />
                </xf:bind>
                
                <xf:submission id="s-controller"
                               method="put"
                               replace="none"
                               ref="instance('i-controller')">
                    <xf:resource value="'{$role:REST-CXT-APP}/model_templates/controller.xml'"/>
        
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
                    <xf:resource value="'{$role:REST-BC-LIVE}/sys/acl/roles.xml'"/>
                    
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
                        <xf:message level="ephemeral">Role details saved successfully</xf:message>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The role details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>    
                
                <xf:submission id="s-delete" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$role:REST-BC-LIVE}/sys/acl/roles.xml'"/>

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
                        <xf:message level="ephemeral">Role deleted successfully</xf:message>
                        <script type="text/javascript">
                            document.location.href = 'roles.html?rand={current-time()}';
                        </script> 
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                </xf:submission>                 
                
                <xf:action ev:event="xforms-ready">

                </xf:action>        
            </xf:model>
            <!-- ######################### View start ################################## -->
            <div style="width: 100%; height: 100%;">
                <a href="roles.html">
                    <img src="resources/images/back_arrow.png" title="back to custom roles" alt="back to custom roles"/>
                </a>   
                <br/>            
                <h1>role | <xf:output value="role[@id eq '{$name}']/@id" class="transition-inline"/></h1>
                <br/>
                <div style="margin-top:10px;" />
                <xf:group ref="role[@id eq '{$name}']">
                    <xf:group appearance="bf:verticalTable">
                        <xf:input bind="roletitle" class="xsmallWidth" incremental="true">
                            <xf:label>title:</xf:label>
                            <xf:hint>a Hint for this control</xf:hint>
                            <xf:help>help for select1</xf:help>
                            <xf:alert>invalid</xf:alert>
                        </xf:input>                       
                    </xf:group>
                    <hr/>
                    <br/>
                    <h1>subroles</h1>
                    <div style="width:100%;">
                        <xf:group appearance="bf:horizontalTable">
                            <xf:repeat id="r-subroles" nodeset="subrole" appearance="compact">
                                <xf:input ref="@id" incremental="true">
                                    <xf:label>id:</xf:label>
                                    <xf:hint>{$name}.</xf:hint>
                                    <xf:help>should be attached to role is using a dot</xf:help>
                                    <xf:message ev:event="xforms-invalid" level="ephemeral">subroles ID must start with `{$name}.` and avoid spaces</xf:message>
                                </xf:input>                             
                                <xf:input ref="@title">
                                    <xf:label>title:</xf:label>
                                    <xf:hint>Subrole title</xf:hint>
                                    <xf:help>Title for the role</xf:help>
                                    <xf:alert>cannot be empty</xf:alert>
                                </xf:input> 
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-subroles')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                        </xf:group>   
                        <br/>
                        <xf:group appearance="minimal">
                            <xf:trigger>
                               <xf:label>add subrole</xf:label>
                               <xf:action>
                                   <xf:insert nodeset="subrole" at="last()" position="after" origin="instance('i-subrole')/subrole"/>
                                   <xf:setfocus control="r-subroles"/>
                               </xf:action>
                            </xf:trigger>     
                        </xf:group>                        
                    </div>
                    <hr/>
                    <br/>
                    <xf:group id="typeButtons" appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>Save</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                       
                        </xf:trigger>
                        {
                            if(local:occurrences()) then 
                                ()
                            else 
                                <xf:group appearance="bf:verticalTable">                      
                                     <xf:switch>
                                        <xf:case id="delete">
                                           <xf:trigger ref="instance()/child::*">
                                              <xf:label>delete</xf:label>
                                              <xf:action ev:event="DOMActivate">
                                                 <xf:toggle case="confirm" />
                                              </xf:action>
                                           </xf:trigger>
                                        </xf:case>
                                        <xf:case id="confirm">
                                           <h2>Are you sure you want to delete this role?</h2>
                                           <xf:group appearance="bf:horizontalTable">
                                               <xf:trigger>
                                                  <xf:label>Delete</xf:label>
                                                  <xf:action ev:event="DOMActivate">
                                                    <xf:delete nodeset="instance()/role[@id eq '{$name}']"/>
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
                        }
                    </xf:group>
                    <hr/>
                    <h1>participation</h1>
                    <div style="width:100%;">
                        <div class="ulisting">
                            {
                                if(local:occurrences()) then 
                                    <span class="warning">&#8211; NB: <b>deleting this role will only be possible once the facets / states and forms it features in below are removed first</b> &#8211;</span>
                                else  
                                    "none - can be safely deleted"
                            }
                            <ul class="clearfix ulfields">
                                {local:occurrences()}
                            </ul>                 
                        </div> 
                    </div>                  
                </xf:group>
            </div>
            <!-- ######################### View end ################################## -->  
        </div>
};


declare 
function role:add($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $type := request:get-parameter("type", "none")
    let $name := request:get-parameter("doc", "none")
    return
        <div>
            <xf:model id="master">
                <xf:instance id="i-customroles" src="{$role:REST-BC-LIVE}/sys/acl/roles.xml"/>
                  
                 <xf:instance id="i-boolean" src="{$role:REST-CXT-APP}/model_templates/boolean.xml"/>
                
                <xf:instance xmlns="" id="i-role">
                    <data>
                        <role id="" title=""/>
                    </data>
                </xf:instance>
                
                <xf:instance xmlns="" id="i-subrole">
                    <data>
                        <subrole id="" title=""/>
                    </data>
                </xf:instance>
                
                <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                </xf:instance>
                
                <xf:instance id="i-controller" src="{$role:REST-CXT-APP}/model_templates/controller.xml"/>        
                
                <xf:bind nodeset="instance()/role[last()]">
                    <xf:bind id="roletitle" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 2" />
                    <xf:bind id="roleid" nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$') and count(instance()/role/@id) eq count(distinct-values(instance()/role/@id))" />
                    <xf:bind nodeset="subrole/@id" type="xf:string" required="true()" constraint="string-length(.) &gt; string-length(instance()/role[last()]/@id)+1 and starts-with(.,concat(instance()/role[last()]/@id,'.')) and matches(., '^[A-z.]+$')" />
                    <xf:bind nodeset="subrole/@title" type="xf:string" required="true()" />
                </xf:bind>
                
                <xf:submission id="s-controller"
                               method="put"
                               replace="none"
                               ref="instance('i-controller')">
                    <xf:resource value="'{$role:REST-CXT-APP}/model_templates/controller.xml'"/>
        
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
                    <xf:resource value="'{$role:REST-BC-LIVE}/sys/acl/roles.xml'"/>
                    
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
                        <xf:message level="ephemeral">Role details saved successfully</xf:message>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The role details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>    

                <xf:action ev:event="xforms-ready">
                    <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-role')/role" />
                </xf:action>        
            </xf:model>
            <!-- ######################### View start ################################## -->
            <div style="width: 100%; height: 100%;">
                <a href="roles.html">
                    <img src="resources/images/back_arrow.png" title="back to custom roles" alt="back to custom roles"/>
                </a>   
                <br/>
                <h1>role | <xf:output value="role[last()]/@id" class="transition-inline"/></h1>
                <br/>
                <div style="margin-top:10px;" />
                <xf:group ref="role[last()]">
                    <xf:group appearance="bf:verticalTable">
                        <xf:input ref="@id" class="xsmallWidth" incremental="true">
                            <xf:label>id:</xf:label>
                            <xf:hint>Unique ID for this role</xf:hint>
                            <xf:help>help for select1</xf:help>
                            <xf:alert>must be unique / no spaces</xf:alert>
                        </xf:input>                     
                        <xf:input ref="@title" class="xsmallWidth" incremental="true">
                            <xf:label>title:</xf:label>
                            <xf:hint>Title for this role</xf:hint>
                            <xf:help>help for select1</xf:help>
                            <xf:alert>invalid: cannot be empty</xf:alert>
                        </xf:input>                            
                    </xf:group>
                    <hr/>
                    <br/>
                    <h1>subroles</h1>
                    <div style="width:100%;">
                        <xf:group appearance="bf:horizontalTable">
                            <xf:repeat id="r-subroles" nodeset="subrole" appearance="compact">
                                <xf:input ref="@id" incremental="true">
                                    <xf:label>id:</xf:label>
                                    <xf:hint>{$name}.</xf:hint>
                                    <xf:help>should be attached to role is using a dot</xf:help>
                                    <xf:message ev:event="xforms-invalid" level="ephemeral">subroles ID must start with `{$name}.` and avoid spaces</xf:message>
                                </xf:input>                             
                                <xf:input ref="@title">
                                    <xf:label>title:</xf:label>
                                    <xf:hint>Subrole title</xf:hint>
                                    <xf:help>Title for the role</xf:help>
                                    <xf:alert>cannot be empty</xf:alert>
                                </xf:input> 
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-subroles')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                        </xf:group>   
                        <br/>
                        <xf:group appearance="minimal">
                            <xf:trigger>
                               <xf:label>add subrole</xf:label>
                               <xf:action>
                                   <xf:setvalue ref="instance('i-subrole')/subrole/@id" value="concat(instance()/role[last()]/@id,'.')"/>
                                   <xf:insert nodeset="subrole" at="last()" position="after" origin="instance('i-subrole')/subrole"/>
                                   <xf:setfocus control="r-subroles"/>
                               </xf:action>
                            </xf:trigger>     
                        </xf:group>                        
                    </div>
                    <br/>                    
                    <hr/>
                    <xf:group id="typeButtons" appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>Save</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                       
                        </xf:trigger>                        
                    </xf:group>
                </xf:group>
            </div>
            <!-- ######################### View end ################################## -->  
        </div>
};