xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";


declare function local:timestamp() as xs:string {
      let $timestamp := request:get-parameter("timestamp", "")
      let $contextPath := request:get-context-path()
      let $path2resource := concat($contextPath,"/apps/configeditor/edit/config-db.xql")
      let $doc := doc($path2resource)
      let $xsl := doc('/db/configeditor/xsl/wf_split_attrs.xsl')
      let $splitted := transform:transform($doc, $xsl, <parameters>
                                                          <param name="docname" value="{util:document-name($path2resource)}" />
                                                       </parameters>)
      return $path2resource
};

declare function local:mode() as xs:string {
    let $timestamp := request:get-parameter("timestamp", "undefined")

    let $mode := if($timestamp = "undefined") then "new"
                 else "edit"

    return $mode
};

let $contextPath := request:get-context-path()
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Database</title>
       <link rel="stylesheet" type="text/css" href="./styles/configeditor.css"/>
    </head>
    <body class="tundra InlineRoundBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-database" xmlns="http://namespaces.zope.org/zope" src="{$contextPath}/rest/db/configeditor/configs/sys/db.zcml"/>                  

                    <xf:bind nodeset="include/@file" type="xf:string" required="true()" />
                    <xf:bind nodeset="include/@package" type="xf:string" required="true()" />                
                    <xf:bind nodeset="db:engine/@name" constraint="string-length(.) &gt; 3" required="true()"/>
                    <xf:bind nodeset="db:engine/@url" constraint="string-length(.) &gt;= 6" required="true()"/>

                    <xf:submission id="s-get-workflow"
                                 method="get"
                                 resource="{local:timestamp()}"
                                 replace="instance"
                                 serialization="none">
                    </xf:submission>
                    
                 <xf:instance id="i-controller"  src="{$contextPath}/rest/db/configeditor/data/controller.xml"/>

                 <xf:instance id="tmp">
                    <data xmlns="">
                        <wantsToClose>false</wantsToClose>
                    </data>
                 </xf:instance>

                <xf:submission id="s-add"
                               method="put"
                               replace="none"
                               ref="instance()">
                    <xf:resource value="'{$contextPath}/rest/db/configeditor/configs/sys/db.zcml'"/>

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
                        <!--xf:setvalue ref="instance('i-database')/@file" value="now()" /-->
                    </xf:action>

                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">Database configuration saved successfully</xf:message>
                        <script type="text/javascript" if="instance('tmp')/wantsToClose">
                            dijit.byId("dbDialog").hide();
                            dojo.publish("/wf/refresh");
                        </script>
                        <xf:send submission="s-clean" if="'{local:mode()}' = 'new'"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The form has not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>

                <xf:submission id="s-clean"
                               ref="instance('i-database')"
                               resource="{$contextPath}/rest/db/configeditor/data/workflow.xml"
                               method="get"
                               replace="instance"
                               instance="i-database">
                </xf:submission>
            <xf:action ev:event="xforms-ready" >
                <xf:send submission="s-get-workflow" if="'{local:mode()}' = 'edit'"/>
                <!--xf:setfocus control="date"/-->
            </xf:action>

            </xf:model>
        </div>

        <xf:group ref="." class="{if(local:mode()='edit') then 'suppressInfo' else ''}">
            <xf:group id="databaseconf-ui" appearance="bf:verticalTable">
                <xf:label>Specify the db connection string here</xf:label>
                <xf:input id="package" ref="zope:include/@package">
                    <xf:label>Package:</xf:label>
                    <xf:hint>enter the package name</xf:hint>
                </xf:input>
                <xf:input id="file" ref="zope:include/@file">
                    <xf:label>File:</xf:label>
                    <xf:hint>enter the name of the file</xf:hint>
                    <xf:help>e.g. meta.zcml</xf:help>
                    <xf:alert>invalid filename name</xf:alert>
                </xf:input>
                <xf:input id="name" ref="db:engine/@name">
                    <xf:label>name:</xf:label>
                    <xf:hint>enter the name of the database</xf:hint>
                    <xf:help>e.g. bungeni-db</xf:help>
                    <xf:alert>invalid database name</xf:alert>
                </xf:input>
                <xf:input id="url" ref="db:engine/@url">
                    <xf:label>postgres url:</xf:label>
                    <xf:hint>enter the full url to access the database</xf:hint>
                    <xf:help>e.g. postgres://localhost/bungeni</xf:help>
                    <xf:alert>invalid postgres url</xf:alert>
                </xf:input>
                <xf:select1 id="echo" ref="db:engine/@echo" appearance="default" incremental="true">
                    <xf:label>echo</xf:label>
                    <xf:hint>sort order</xf:hint>
                    <xf:help>Toggle between true and false</xf:help>
                    <xf:item>
                        <xf:label>true</xf:label>
                        <xf:value>true</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>false</xf:label>
                        <xf:value>false</xf:value>
                    </xf:item>
                </xf:select1>
                <br/>
                <xf:group id="dialogButtons" appearance="bf:horizontalTable">
                    <xf:label/>
                    <xf:trigger>
                        <xf:label>Update db.zcml</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Close</xf:label>
                        <script type="text/javascript">
                            dijit.byId("dbDialog").hide();
                        </script>
                    </xf:trigger>                    
                </xf:group>                
            </xf:group>
			<xf:output mediatype="text/html" ref="instance('i-controller')/error" id="errorReport"/>

        </xf:group>
        </div>
    </body>
</html>
