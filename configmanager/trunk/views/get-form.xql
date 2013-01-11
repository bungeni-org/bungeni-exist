xquery version "3.0";

declare option exist:serialize "method=xhtml media-type=text/xml";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

(: creates the output for all fields :)
declare function local:fields($doctype) as node() * {
    let $form-id := request:get-parameter("doc", "nothing")
    
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
                        <a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="images/down.png"/></a>
                        </span>
                    else if ($pos eq $count) then 
                        <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="images/up.png"/></a>
                    else 
                    (
                        <span>
                            <a href="javascript:dojo.publish('/field/up',['{$doctype}','{data($field/@name)}']);"><img alt="up" src="images/up.png"/></a>
                            &#160;
                            <a href="javascript:dojo.publish('/field/down',['{$doctype}','{data($field/@name)}']);"><img alt="down" src="images/down.png"/></a>
                        </span>
                    )
                }               
                </td>
                <td><a href="javascript:dojo.publish('/field/edit',['{$doctype}','{data($field/@name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/field/delete',['{$doctype}','{data($field/@name)}']);">delete</a></td>
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

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","nothing"))
let $LASTFIELD := data(local:get-form($DOCNAME)/descriptor/field[last()]/@name)
let $SHOWING := xs:string(request:get-parameter("tab","fields"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb"
         xml:lang="en">
   <head>
      <title>Add/Edit Descriptor</title>
        <link rel="stylesheet" type="text/css" href="./css/main.css"/>      
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-formsui" src="{$REST-CXT-MODELTMPL}/forms.xml"/>   
                    
                    <xf:instance id="i-archetypes" xmlns="">
                        <data>
                            <archetypes>
                               <arche>doc</arche>
                               <arche>group</arche>                                 
                               <arche>group_membership</arche>
                            </archetypes>
                        </data>
                    </xf:instance>                        

                    <xf:bind nodeset=".[@name eq '{$DOCNAME}']">
                        <xf:bind nodeset="@order" type="xf:integer" required="true()" constraint="(. &lt; 100) and (. &gt; 0)" />
                        <xf:bind nodeset="@archetype" type="xf:string" required="true()" />
                    </xf:bind>
                    
                    <xf:submission id="s-get-formsui"
                        method="get"
                        resource="{$REST-CXT-CONFIGFORMS}/{$DOCNAME}.xml"
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
                        <xf:resource value="concat('{$REST-CXT-CONFIGFORMS}/',instance('i-controller')/lastAddedType,'.xml')"/>
    
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
                            <xf:message level="ephemeral">new form details saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dijit.byId("formsDialog").hide();
                                dojo.publish('/form/view',['{$DOCNAME}','details']);  
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
                        <xf:resource value="'{$REST-CXT-CONFIGFORMS}/{$DOCNAME}.xml'"/>
    
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
                            <!--xf:setvalue ref="instance('i-formsui')/@name" value="now()" /-->
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">FORM details saved successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dijit.byId("formsDialog").hide();
                                dojo.publish('/form/view',['{$DOCNAME}','details']);  
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
                                   ref="instance('i-formsui')"
                                   resource="{$REST-CXT-MODELTMPL}/forms.xml"
                                   method="get"
                                   replace="instance"
                                   instance="i-formsui">
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >
                        <xf:send submission="s-get-formsui" if="'{local:mode()}' = 'edit'"/>
                        <xf:action if="'{$DOCNAME}' = 'new'">
                            <xf:setvalue ref="instance()/@name" value="instance('i-controller')/lastAddedType"/>
                        </xf:action>
                        <script type="text/javascript" if="'{$SHOWING}' = 'fields'">
                            dijit.byId("switchDiv").selectChild("fieldsDiv");                        
                        </script>   
                    </xf:action>

            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <div dojoType="dijit.layout.TabContainer" id="switchDiv" style="width: 100%; height: 100%;">
                    <h1>Types / {$DOCNAME} / forms </h1>
                    <br/>
                    <div dojoType="dijit.layout.ContentPane" title="Edit Details" id="detailsDiv" selected="true">
                        <div class="caseContent">
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
                                            <xf:action if="'{$DOCNAME}' = 'new'">
                                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                                <xf:setvalue ref="./@name" value="instance('i-controller')/lastAddedType"/>
                                                <xf:send submission="s-add"/>
                                            </xf:action>                                            
                                            <xf:action if="'{$DOCNAME}' != 'new'">
                                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                                <xf:send submission="s-save"/>
                                            </xf:action>
                                        </xf:trigger>                  
                                    </xf:group>
                                 </xf:group>
                            </xf:group>
                        </div>
                    </div>                  
                    <div dojoType="dijit.layout.ContentPane" title="Edit fields" id="fieldsDiv">
                        <xf:label>Edit Fields</xf:label>
                        <div class="caseContent">
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
                                {local:fields($DOCNAME)}
                            </table> 
                            <span>
                                <a href="javascript:dojo.publish('/field/add',['{$DOCNAME}','{$LASTFIELD}']);">add field</a>
                            </span>
                        </div>
                    </div>
                </div>                       
            </div>                    
        </div>
    </body>
</html>