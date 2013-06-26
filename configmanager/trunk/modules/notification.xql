xquery version "3.0";

module namespace notif="http://exist.bungeni.org/notificationfunctions";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace ce="http://bungeni.org/configeditor" ;

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $notif:CXT := request:get-context-path();
declare variable $notif:RESTXQ := request:get-context-path() || "/restxq";
declare variable $notif:REST-CXT-APP :=  $notif:CXT || $appconfig:REST-APP-ROOT;
declare variable $notif:REST-BC-LIVE :=  $notif:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;
declare variable $notif:REST-XML-RESOURCES :=  $notif:CXT || $appconfig:REST-XML-RESOURCES;
declare variable $notif:REST-CXT-MODELTMPL := $notif:REST-CXT-APP || "/model_templates";

declare variable $notif:TYPE := xs:string(request:get-parameter("type",""));
declare variable $notif:DOCNAME := xs:string(request:get-parameter("doc",""));
declare variable $notif:NODENAME := xs:string(request:get-parameter("node",""));
declare variable $notif:FEATURE-FACET := xs:string(request:get-parameter("facet",""));
declare variable $notif:ATTR-ID := xs:integer(request:get-parameter("attr",0));
declare variable $notif:DOCPOS := xs:integer(request:get-parameter("pos",0));

declare function local:notifications() {

    let $notif-doc := $appconfig:NOTIF-FOLDER || "/" || $notif:DOCNAME || ".xml"
    return 
        if(doc-available($notif-doc)) then 
            doc($notif-doc)/notifications
        else
            doc($appconfig:MODEL-TEMPLATES || "/notification.xml")/notifications
};

declare function local:workflow() {

    let $doc := doc($appconfig:WF-FOLDER || "/" || $notif:DOCNAME || ".xml")/workflow
    return 
        $doc
};

(: returns all the states nodes :)
declare function local:workflow-states($doctype) as node() * {
    let $states := local:workflow()/state
    for $state at $pos in $states
        return
            element state { 
                attribute id { data($state/@id) },
                attribute title { data($state/@title) }
            }
};

declare function local:notifs() {

    <notifications>{
    let $roles := appconfig:roles()/role
    let $notifs := local:notifications()/notify
    for $role in $roles
    return
        if (some $notif in $notifs satisfies ($notif/@roles = $role/@name)) then 
            <notify 
                roles="{$role/@name}" 
                onstate="{$notifs[@roles = data($role/@name)]/@onstate}" 
                afterstate="{$notifs[@roles = data($role/@name)]/@afterstate}" 
                time="{$notifs[@roles = data($role/@name)]/@time}"/>
        else 
            <notify 
                roles="{$role/@name}" 
                onstate="" 
                afterstate="" 
                time=""/>
    }</notifications>
};

declare
function notif:edit($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc","none"))   
    let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
    let $featuregroupname :=if (doc-available($wf-doc)) then $docname else $type
    let $pos := xs:string(request:get-parameter("pos",""))
    let $init := xs:string(request:get-parameter("init",""))
    let $laststate := count(doc($wf-doc)/workflow/state)
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model id="master">
                    <xf:instance xmlns="" id="i-notification">
                        {local:notifs()}
                    </xf:instance>
                    
                    <xf:instance xmlns="" id="i-states">
                        <states>
                            {local:workflow-states($docname)}
                        </states>
                    </xf:instance>    
                    
                    <xf:instance xmlns="" id="i-roles">
                        <roles>
                            {appconfig:roles()/role}
                        </roles>
                    </xf:instance>

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="feature/@enabled" type="xf:boolean" />
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$notif:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp"  src="{$notif:REST-CXT-MODELTMPL}/tmp.xml"/>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$notif:REST-BC-LIVE}/notifications/{$docname}.xml'"/>
    
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
                            <xf:message level="ephemeral">Notification changes updated successfully</xf:message>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message level="modal">Error updating notifications</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready"/>
            </xf:model>
            
            </div>
            
            <div class="commit-holder">
                <a href="type.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <a class="commit" href="/exist/restxq/notification/commit/{$docname}" title="save this file back to the filesystem">commit notification</a>
            </div>   
                
            <div id="notif" class="tab_content" style="display: block;">
                <h2>Notifications</h2>    
                <div class="alert alert-info" style="width:67%;">
                  <strong>Heads Up!</strong> press and hold CTRL key while clicking on a role to select multiple roles.
                </div>                
                <xf:group ref="." appearance="bf:verticalTable">
                    <xf:repeat id="r-notifs" nodeset="./notify" appearance="bf:horizontalTable">                    
                        <h3><xf:output ref="@roles"/></h3>
                        <xf:group ref="." appearance="bf:verticalTable">
                            <xf:output ref="@onstate" incremental="true" class="alert alert-success">
                                <xf:label><b>onstate:</b>&#160;&#160;&#160;&#160;&#160;&#160;</xf:label>
                                <xf:hint>shows the currently selected states</xf:hint>
                                <xf:help>hold ctrl key as you select the roles you want to allow access</xf:help>                                                    
                            </xf:output>                                 
                            <xf:select ref="@onstate" appearance="minimal" incremental="true">
                                <xf:alert>invalid selection</xf:alert>
                                <xf:hint>hold ctrl + click the roles you want to </xf:hint>   
                                <xf:itemset nodeset="instance('i-states')/state">
                                    <xf:label ref="@title"/>                                       
                                    <xf:value ref="@id"/>
                                </xf:itemset>
                            </xf:select>                           
                        </xf:group>
                        <xf:group ref="." appearance="bf:verticalTable">
                            <xf:output ref="@afterstate" incremental="true" class="alert alert-success">
                                <xf:label><b>after state:</b>&#160;</xf:label>                            
                                <xf:hint>shows the currently selected states</xf:hint>
                                <xf:help>hold ctrl key as you select the roles you want to allow access</xf:help>                                                    
                            </xf:output>                                 
                            <xf:select ref="@afterstate" appearance="minimal" incremental="true">
                                <xf:alert>invalid selection</xf:alert>
                                <xf:hint>hold ctrl + click the roles you want to </xf:hint>   
                                <xf:itemset nodeset="instance('i-states')/state">
                                    <xf:label ref="@title"/>                                       
                                    <xf:value ref="@id"/>
                                </xf:itemset>
                            </xf:select>
                            <xf:input ref="@time" class="xmediumWidth">
                                <xf:label><b>time:</b>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xf:label>
                                <xf:help>at time:</xf:help>
                                <xf:hint>time afterstate e.g. 3w5d is 3 weeks and 5 days after passing that state</xf:hint>
                            </xf:input>                    
                        </xf:group>
                        <hr/>
                    </xf:repeat>
                </xf:group>
                <hr/>
                <xf:group appearance="bf:horizontalTable">
                    <xf:trigger>
                        <xf:label>Update</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <!--xf:delete nodeset="instance()/allow/roles/role[string-length(.) lt 2]" /--> 
                           
                            <xf:send submission="s-add"/>
                        </xf:action>                                
                    </xf:trigger>  
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
                               <h2>Are you sure you want to delete this workflow?</h2>
                               <xf:group appearance="bf:horizontalTable">
                                   <xf:trigger>
                                      <xf:label>Delete</xf:label>
                                      <xf:action ev:event="DOMActivate">
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
                
            </div>
        </div>
};