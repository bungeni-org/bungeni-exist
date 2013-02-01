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
        <li>
            <a class="editlink" href="vocab.html?doc={util:document-name($vdex)}">{data($vdex/vdex:vdex/vdex:vocabName/vdex:langstring[@language eq 'en'])}</a>
        </li>     
};

declare 
function vocab:list($node as node(), $model as map(*)) {

    <div>
        <div class="ulisting">
            <h2>All Vocabularies</h2>
            <ul class="clearfix">
                {local:get-vocabs()}
            </ul>
            
            <a class="button-link" href="type-add.html?type=none&amp;doc=none&amp;pos=0">add vocabulary</a>
        </div>    
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

                    <xf:instance id="i-controller" src="{$vocab:REST-CXT-MODELTMPL}/controller.xml"/>
                    
                    <xf:instance id="i-langs" xmlns="">
                        <data>
                            <languages>
                                <language>en</language>
                                <language>es</language>
                                <language>fr</language>
                                <language>pt</language>
                                <language>sw</language>
                                <language>it</language>
                            </languages>                        
                        </data>
                    </xf:instance> 
                    
                    <xf:instance id="i-term" xmlns="http://www.imsglobal.org/xsd/imsvdex_v1p0">
                        <data>
                            <term>
                                <termIdentifier></termIdentifier>
                                <caption>
                                    <langstring language="en"></langstring>
                                </caption>
                            </term>                     
                        </data>
                    </xf:instance>                     
                    
                    <xf:instance id="i-langstring" xmlns="http://www.imsglobal.org/xsd/imsvdex_v1p0">
                        <data>
                            <langstring language=""></langstring>                        
                        </data>
                    </xf:instance>
                    
                    <xf:bind nodeset="instance()">
                        <xf:bind nodeset="//vdex:vocabName/vdex:langstring/@language" type="xf:string" required="true()" constraint="string-length(.) &gt; 1 and (count(instance()//vdex:vocabName/vdex:langstring) eq count(distinct-values(instance()//vdex:vocabName/vdex:langstring/@language)))" />                    
                        <xf:bind nodeset="//vdex:vocabName/vdex:langstring" type="xf:string" required="true()" constraint="string-length(.) &gt; 3 and xs:string(node-name(.)) eq 'langstring'" />
                        <xf:bind nodeset="@orderSignificant" type="xf:boolean" required="true()" />
                        <xf:bind nodeset="//vdex:caption/vdex:langstring/@language" type="xf:string" required="true()" constraint="string-length(.) &gt; 1" /> 
                        <!--xf:bind nodeset="//vdex:caption/vdex:langstring/@language" type="xf:string" required="true()" constraint="count(instance()//vdex:caption/vdex:langstring) eq count(instance()//vdex:vocabName/vdex:langstring)" /-->                          
                    </xf:bind>
                    
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
                        <!-- insert a template to be used for inserting -->
                        <xf:insert ev:event="DOMActivate" nodeset="instance()/vdex:vocabName/child::*" at="last()" position="after" origin="instance('i-langstring')/vdex:langstring"/>
                    </xf:action>

            </xf:model>
            
            </div>
            
            <div>
                <xf:group ref=".">                   
                    <h1>Vocabulary: <xf:output ref="./vdex:vocabName/vdex:langstring" class="transition-inline"/></h1>
                    <xf:group appearance="bf:verticalTable">                                    
                        <xf:group appearance="bf:GroupLabelLeft">
                            <xf:label>Name(s)</xf:label>                              
                            <xf:repeat id="r-vocabs" nodeset="./vdex:vocabName/vdex:langstring[position() != last()]" appearance="compact">
                                <xf:input ref="." incremental="true">
                                    <xf:label>string</xf:label>
                                </xf:input>
                                <xf:select1 ref="./@language" appearance="minimal" incremental="true" class="xshortestWidth">
                                    <xf:label>language</xf:label>
                                    <xf:hint>select a supported language from the dropdown</xf:hint>
                                    <xf:help>help for select1</xf:help>
                                    <xf:alert>invalid: duplicate language or empty</xf:alert>
                                    <xf:itemset nodeset="instance('i-langs')/languages/language">
                                        <xf:label ref="."></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                                &#160;
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-vocabs')[position()]"></xf:delete>                                 
                                    </xf:action>
                                </xf:trigger>                                  
                            </xf:repeat>                           
                        </xf:group>
                        <br/>
                        <xf:trigger class="noOffSet">
                            <xf:label>add language</xf:label>
                            <xf:action>
                                <xf:insert nodeset="./vdex:vocabName/vdex:langstring"></xf:insert>
                            </xf:action>
                        </xf:trigger>   
                        <br/>
                        <xf:input ref="@orderSignificant" incremental="true">
                            <xf:label>order significance?</xf:label>
                            <xf:hint>order the terms below</xf:hint>
                            <xf:help>if the ordering of terms below have to be specified</xf:help>                            
                        </xf:input>                                                               
                        
                        <xf:output ref="./vdex:vocabIdentifier" incremental="true" class="xLongwidth">
                            <xf:label>vocabulary ID</xf:label>
                        </xf:output>                          
                        <hr/>
                        <xf:group appearance="compact"> 
                            <xf:label><h1>Vocabulary list</h1></xf:label>
                            <xf:repeat id="r-terms" nodeset="./vdex:term" appearance="compact">
                                <xf:input ref="./vdex:termIdentifier">
                                    <xf:label>Term ID</xf:label>
                                </xf:input>
                                <xf:group ref="." appearance="bf:verticalTable" class="hideRepeatHeader">
                                    <xf:label>Label(s)</xf:label>     
                                    <xf:repeat id="r-captions" nodeset="./vdex:caption/vdex:langstring" appearance="compact">
                                        <xf:input ref="." incremental="true"></xf:input>
                                        <xf:select1 ref="./@language" appearance="minimal" incremental="true" class="xshortestWidth">
                                            <xf:hint>select a supported language from the dropdown</xf:hint>
                                            <xf:help>help for select1</xf:help>
                                            <xf:alert>invalid: cannot be empty</xf:alert>
                                            <xf:itemset nodeset="instance('i-langs')/languages/language">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1>
                                        <xf:trigger>
                                            <xf:label>delete</xf:label>
                                            <xf:action>
                                                <xf:delete at="index('r-captions')[position()]"></xf:delete>
                                            </xf:action>
                                        </xf:trigger>                                         
                                    </xf:repeat>
                                    <br/>
                                    <xf:trigger>
                                        <xf:label>add new label</xf:label>
                                        <xf:action>
                                            <xf:insert ev:event="DOMActivate" nodeset=".[position()]/vdex:caption/child::*" at="last()" position="after" origin="instance('i-langstring')/vdex:langstring"/>
                                        </xf:action>
                                    </xf:trigger>
                                </xf:group> 
                            </xf:repeat>
                            <br/>
                            <xf:trigger class="noOffSet">
                                <xf:label>add term</xf:label>
                                <xf:action>
                                    <xf:insert nodeset="./vdex:vocabName/vdex:langstring"></xf:insert>
                                    <xf:insert ev:event="DOMActivate" nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-term')/vdex:term"/>
                                </xf:action>
                            </xf:trigger>                                
                        </xf:group>                        
                    </xf:group>
                    <hr/>
                    <xf:trigger>
                        <xf:label>Save Changes</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <!-- remove all the template added at XForms ready with missing language! -->
                            <xf:delete nodeset="instance()/vdex:vocabName/child::*[@language = '']"/>
                            <xf:send submission="s-add"/>
                            <xf:insert ev:event="DOMActivate" nodeset="instance()/vdex:vocabName/child::*" at="last()" position="after" origin="instance('i-langstring')/vdex:langstring"/>
                        </xf:action>                                
                    </xf:trigger>                     
                </xf:group>                  
            </div>                 
        </div>
};