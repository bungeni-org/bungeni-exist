xquery version "3.0";

module namespace vocab="http://exist.bungeni.org/vocalularies";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace vdex="http://www.imsglobal.org/xsd/imsvdex_v1p0" ;


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

declare variable $vocab:CXT := request:get-context-path();
declare variable $vocab:REST-CXT-APP :=  $vocab:CXT || "/rest" || $config:app-root;
declare variable $vocab:REST-CXT-CONFIGVOCABS := $vocab:REST-CXT-APP || "/working/live/bungeni_custom/vocabularies";
declare variable $vocab:REST-CXT-MODELTMPL := $vocab:REST-CXT-APP || "/model_templates";

declare 
function local:get-vocabs() {
    for $vdex at $pos in collection($appconfig:VOCABS-FOLDER)
    let $count := count(doc($appconfig:VOCABS-FOLDER))
    order by $vdex/vdex:vdex/vdex:vocabName ascending
    return    
        <tr>
            <td><a class="editlink" href="vocab.html?doc={util:document-name($vdex)}">{data($vdex/vdex:vdex/vdex:vocabName/vdex:langstring[@language eq 'en'])}</a></td>
            <td><a class="deleteLink" href="vocab.html?doc={util:document-name($vdex)}">{data($vdex/vdex:vdex/@orderSignificant)}</a></td>
        </tr>    
};

declare 
function vocab:list($node as node(), $model as map(*)) {

    <div>
        <h3>All Vocabularies</h3>
        <table class="listingTable" style="width:auto;">
            <tr>                      			 
                <th title="Showing default strings">name(en)</th>
                <th>ordered</th>
            </tr>
            {local:get-vocabs()}
        </table>     
        <div style="margin-top:15px;"/> 
        <a class="button-link" href="type-add.html?type=none&amp;doc=none&amp;pos=0">add vocabulary</a>  
    </div>
};

declare 
function vocab:edit($node as node(), $model as map(*)) {

    let $docname := xs:string(request:get-parameter("doc","none"))    
    return 
        (: Element to pop up :)
    	<div xmlns:vdex="http://www.imsglobal.org/xsd/imsvdex_v1p0">
            <div style="display:none">
                <xf:model>
                    <xf:instance id="i-vocab" src="{$vocab:REST-CXT-CONFIGVOCABS}/{$docname}" xmlns="http://www.imsglobal.org/xsd/imsvdex_v1p0"/>                      

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@name" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@title" type="xf:string" required="true()"constraint="string-length(.) &gt; 3" />
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$vocab:REST-CXT-MODELTMPL}/controller.xml"/>
                    
                    <xf:instance id="i-langs" xmlns="">
                        <data>
                            <languages>
                                <language>en</language>
                                <language>es</language>
                                <language>fr</language>
                                <language>pt</language>
                                <language>sw</language>
                            </languages>                        
                        </data>
                    </xf:instance>                    
                    
                    <xf:submission id="s-get-form"
                        method="get"
                        resource="{$vocab:REST-CXT-CONFIGVOCABS}/{$docname}"
                        replace="instance"
                        serialization="none">
                    </xf:submission>

                    <xf:instance id="i-controller" src="{$vocab:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$vocab:REST-CXT-CONFIGVOCABS}/{$docname}'"/>
    
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
                            <xf:message level="ephemeral">Vocabulary changes updated successfully</xf:message>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:action ev:event="xforms-ready" >

                    </xf:action>

            </xf:model>
            
            </div>
            
            <div>
                <xf:group ref=".">                   
                    <h1><xf:output ref="./vdex:vocabName/vdex:langstring"/></h1>
                    <xf:group appearance="bf:verticalTable">
                        <xf:input ref="./vdex:vocabIdentifier" incremental="true">
                            <xf:label>vocabulary ID</xf:label>
                        </xf:input>                    
                        <xf:group appearance="bf:GroupLabelLeft">
                            <xf:label>Vocab Name(s)</xf:label>                        
                            <xf:repeat id="repeat2" nodeset="./vdex:vocabName/vdex:langstring" appearance="compact">
                                <xf:input ref="." incremental="true">
                                    <xf:label>string</xf:label>
                                </xf:input>
                                <xf:select1 id="select1" ref="./@language" appearance="minimal" incremental="true">
                                    <xf:label>language</xf:label>
                                    <xf:hint>a Hint for this control</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid</xf:alert>
                                    <xf:itemset nodeset="instance('i-langs')/languages/language">
                                        <xf:label ref="."></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                            </xf:repeat>
                        </xf:group>
                        <xf:group appearance="compact"> 
                            <xf:label>Terms</xf:label>
                            <xf:repeat id="repeat2" nodeset="./vdex:term" appearance="compact">
                                <xf:input ref="./vdex:termIdentifier">
                                    <xf:label>string</xf:label>
                                </xf:input>
                                <xf:group appearance="bf:verticalTable">
                                    <xf:label>Caption(s)</xf:label>     
                                    <xf:repeat id="r-captions" nodeset="./vdex:caption/vdex:langstring" appearance="compact">
                                        <xf:input ref="." incremental="true">
                                            <xf:label>term id</xf:label>
                                        </xf:input>
                                        <xf:select1 id="select1" ref="./@language" appearance="minimal" incremental="true">
                                            <xf:label>language</xf:label>
                                            <xf:hint>a Hint for this control</xf:hint>
                                            <xf:help>help for select1</xf:help>
                                            <xf:alert>invalid</xf:alert>
                                            <xf:itemset nodeset="instance('i-langs')/languages/language">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1>
                                    </xf:repeat>
                                    <br/>
                                    <xf:group appearance="bf:horizontalTable">
                                        <xf:label>selected</xf:label>
                                        <xf:trigger>
                                            <xf:label>insert</xf:label>
                                            <xf:action>
                                                <xf:insert nodeset="./vdex:caption/vdex:langstring"></xf:insert>
                                            </xf:action>
                                        </xf:trigger>
                                        
                                        <xf:trigger>
                                            <xf:label>delete</xf:label>
                                            <xf:action>
                                                <xf:delete nodeset="./vdex:caption/vdex:langstring[index('r-captions')]"></xf:delete>
                                            </xf:action>
                                        </xf:trigger>  
                                    </xf:group>
                                    
                                </xf:group> 
                            </xf:repeat>
                        </xf:group>                        
                    </xf:group>
                    <xf:trigger>
                        <xf:label>Save</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>                                
                    </xf:trigger>                     
                </xf:group>                  
            </div>                 
        </div>
};