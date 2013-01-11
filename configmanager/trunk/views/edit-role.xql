xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

declare function local:mode() as xs:string {
    let $field := request:get-parameter("field", "none")
    let $mode := if($field eq "undefined") then "new"
                 else "edit"
    return $mode
};

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","none"))
let $REST-CXT-MODELTMPL := $CXT || "/rest" || $appconfig:ROOT || "/model_templates"
let $REST-CXT-CONFIGFORMS := $CXT || "/rest" || $appconfig:FORM-FOLDER
let $ROLEID := xs:string(request:get-parameter("role","none"))
let $MODE := xs:string(request:get-parameter("mode","old"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Role</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="i-field" src="{$REST-CXT-MODELTMPL}/forms.xml"/>               
 
                    <xf:bind nodeset="roles/role[. eq '{$DOCNAME}']">
                        <xf:bind nodeset="" type="xf:string" required="true" />
                    </xf:bind>

                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{$REST-CXT-CONFIGFORMS}/ui.xml"
                        ref="roles/role[. eq 'undefined']"
                        replace="instance"
                        serialization="none">
                    </xf:submission>                   

                    <xf:instance id="i-controller" src="{$REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                                   
                        <xf:resource value="'{$REST-CXT-CONFIGFORMS}/ui.xml'"/>
    
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
                            <xf:message level="ephemeral">field '{$ROLEID}' saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dojo.publish('/view',['roles','roles','none','none','none']);                      
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
                        <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                        <xf:setfocus control="role-name"/>
                    </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: auto">
                <xf:group id="g-role" ref="roles/role[{$ROLEID}]" appearance="bf:verticalTable">

                       <xf:input id="role-name" ref=".">
                           <xf:label>role</xf:label>
                           <xf:hint>Should be a defined role</xf:hint>
                           <xf:alert>invalid role</xf:alert>
                           <xf:help>help with name of role</xf:help>
                       </xf:input>                         
                        
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