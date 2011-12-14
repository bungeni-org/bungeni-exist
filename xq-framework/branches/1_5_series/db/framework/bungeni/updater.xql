xquery version "1.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace exist="http://exist.sourceforge.net/NS/exist"; 
declare option exist:serialize "method=xhtml media-type=text/html indent=no";

(:~
:   Get request parameters   
:)
declare variable $docnumber := xs:string(request:get-parameter("uri",""));
declare variable $doctype := xs:string(request:get-parameter("type","question"));
    
declare function local:get-body() as node() {
    let $doc := collection('/db/bungeni-xml')//bu:ontology/bu:legislativeItem[@uri=$docnumber]/ancestor::bu:ontology/bu:legislativeItem/bu:body/*
    
    return
        <decoded>
        {
            if(fn:matches(fn:string($doc),"&lt;") = true()) then
                fn:replace(fn:replace($doc,'>','&gt;'),'<','&lt;')
            else
                fn:replace(fn:replace(util:serialize($doc,"method=xhtml"),'>','&gt;'),'<','&lt;')                
        }
        </decoded>
};

declare function local:get-real-name() {
    util:document-name(collection('/db/bungeni-xml')//bu:ontology/bu:legislativeItem[@uri=$docnumber])
};

<html xmlns="http://www.w3.org/1999/xhtml" xmlns:bu="http://portal.bungeni.org/1.0/"  xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <head>
        <title>Config Param</title>
        <meta name="author" content="anthony at googlemail.com"/>
        <meta name="author" content="ashok at parliaments.info"/>
        <meta name="description" content="XForms with config options"/>
        <link rel="stylesheet" href="../assets/bungeni/css/boilerplate.css"/>
        <link rel="stylesheet" href="../assets/bungeni/css/bungeni.css"/>
        <link rel="stylesheet" type="text/css" href="../assets/bungeni/css/xforms.css" />
        
        <xf:model id="m-user-config">
            <xf:instance id="document" xmlns="" src="../../bungeni-xml/{local:get-real-name()}"/>            
            <xf:instance id="requests">
                <request xmlns="">
                    <host>{request:get-server-name()}</host>
                    <doc>/db/bungeni-xml/{local:get-real-name()}</doc>
                    <body>{local:get-body()}</body>
                    <remote-host>{request:get-remote-host()}</remote-host>
                    <remote-ip>{request:get-remote-addr()}</remote-ip>
                </request>                                      
            </xf:instance> 
            <xf:bind nodeset="instance('requests')/body/decoded" id="doc-body" required="true()"/>
            <xf:submission id="s-send" replace="none" resource="../../bungeni-xml/{local:get-real-name()}" method="put" 
            includenamespaceprefixes="#default">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message>Config Update failed. Please fill in valid values</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>You have updated successfully.</xf:message>
                </xf:action>
            </xf:submission>
            <!--<xf:setfocus control="first" ev:event="xforms-ready"/>-->
            <xf:bind id="pcount" nodeset="//range1">
                <xf:bind constraint="boolean-from-string(../@constraint)" id="C190" nodeset="value" type="integer"/>
            </xf:bind>
        </xf:model>        
    </head>
    <body>
        <div id="container" style="background-color:#eeeeee;">
            <div id="header">
                <div id="header-banner"/>
                <div class="header-nav">
                    <div id="mainnav" class="menu">
                    --incoming--
                    </div>
                </div>
            </div>
            <div id="sub-header">
                <div class="header-nav">
                    <div id="subnav" class="submenu">
                        --incoming--
                    </div>
                </div>
            </div>
            <div id="main-wrapper">
                <div id="xforms" style="margin:0 auto 0 auto;width:960px;">
                    <div id="do-config" class="InlineRoundBordersAlert">                    
                        <xf:group id="itema-ui" ref="instance('document')" appearance="bf:verticalTable">                       
                            <xf:input class="docTitle" ref="/bu:ontology/bu:legislativeItem/bu:shortName">
                                <xf:label>Title:</xf:label>
                                <xf:hint>how many items to list per page</xf:hint>
                            </xf:input>
                            <xf:output value="instance('requests')/doc" />
                            <xf:textarea style="margin-top:10px;overflow-y:auto;overflow-x:hidden;height:400px;" class="bodyTextArea" bind="doc-body" ref="/bu:ontology/bu:legislativeItem/bu:body" mediatype="text/html" inputmode="user predictOn" incremental="true">
                                <xf:label>Edit Body:</xf:label>
                                <xf:hint>The body of the Question / Bill</xf:hint>
                                <xf:help>help for textarea1</xf:help>
                                <xf:alert>invalid</xf:alert>
                            </xf:textarea>
                            <xf:label/>
                            <!--xf:range end="10" incremental="true" ref="//range1/value" start="1" step="1">
                                <xf:label id="C195">Pagination Count</xf:label>
                                <xf:hint id="C196">a Hint for this control</xf:hint>
                                <xf:help id="C197">help for range1</xf:help>
                                <xf:alert id="C198">invalid</xf:alert>
                            </xf:range-->                         
                            <xf:trigger appearance="bf:verticalTable">
                                <xf:label>Update changes</xf:label>
                                <xf:hint>Be calm - this is jus a tinker! ;)</xf:hint>
                                <xf:setvalue ref="/bu:ontology/bu:legislativeItem/bu:body/*" value="instance('requests')/body/decoded"/>
                                <xf:send submission="s-send"/>
                            </xf:trigger>
                        </xf:group>                      
                    </div>
                 </div>
            </div>
        </div>
    </body>
</html>