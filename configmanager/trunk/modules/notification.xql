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

declare function local:get-workflow($doctype) as node() * {
    let $notif := doc($appconfig:WF-FOLDER || "/" || $doctype || ".xml")/workflow
    return $notif
};

(: returns all the states nodes :)
declare function local:workflow-states($doctype) as node() * {
    let $states := local:get-workflow($doctype)/state
    for $state at $pos in $states
        return
            element state { 
                attribute id { data($state/@id) },
                attribute title { data($state/@title) }
            }
};

declare function local:workflow() {

    let $docname := xs:string(request:get-parameter("doc","none"))
    let $doc := doc($appconfig:WF-FOLDER || "/" || $docname || ".xml")/workflow
    return 
        $doc
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
                    {
                        (: if adding a new workflow is true :)
                        if($init eq "true") then 
                            <xf:instance id="i-notification" src="{$notif:REST-CXT-MODELTMPL}/notification.xml"/>
                        else
                            <xf:instance id="i-notification" src="{$notif:REST-BC-LIVE}/notifications/{$docname}.xml"/> 
                    }
                    
                    <xf:instance xmlns="" id="i-states">
                        <states>
                            {local:workflow-states($docname)}
                        </states>
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
                    
                    <xf:submission id="s-delete" method="delete" replace="none" ref="instance()">
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
                            <xf:message level="ephemeral">Deleted successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'notifications.html?type={$type}&#38;amp;doc={$docname}&#38;amp;pos={$pos}';
                            </script> 
                        </xf:action>
                        
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
                        
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>Go uncheck notifications on the workflow in-order delete it.</xf:message>
                        </xf:action>
                    </xf:submission>                    
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:insert nodeset="instance()/permActions" at="1" position="after" origin="instance('i-features')/feature" />                        
                    </xf:action>

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
                <xf:group ref="." appearance="bf:horizontalTable">
                
                    <xf:repeat id="r-notifs" nodeset="./notify[@roles]" appearance="compact">
                            <xf:output ref="@roles">
                                <xf:label>Roles</xf:label>
                            </xf:output>                  
                            <xf:select ref="@onstate" appearance="minimal" incremental="true">
                                <xf:alert>invalid selection</xf:alert>
                                <xf:hint>hold ctrl + click the roles you want to </xf:hint>   
                                <xf:itemset nodeset="instance('i-states')/state">
                                    <xf:label ref="@title"/>                                       
                                    <xf:value ref="@id"/>
                                </xf:itemset>
                            </xf:select>
                            <xf:select ref="@afterstate" appearance="minimal" incremental="true">
                                <xf:alert>invalid selection</xf:alert>
                                <xf:hint>hold ctrl + click the roles you want to </xf:hint>   
                                <xf:itemset nodeset="instance('i-states')/state">
                                    <xf:label ref="@title"/>                                       
                                    <xf:value ref="@id"/>
                                </xf:itemset>
                            </xf:select>
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