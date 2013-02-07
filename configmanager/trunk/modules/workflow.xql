xquery version "3.0";

module namespace workflow="http://exist.bungeni.org/workflowfunctions";
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

declare variable $workflow:CXT := request:get-context-path();
declare variable $workflow:RESTXQ := request:get-context-path() || "/restxq";
declare variable $workflow:REST-CXT-APP :=  $workflow:CXT || $appconfig:REST-APP-ROOT;
declare variable $workflow:REST-BC-LIVE :=  $workflow:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;
declare variable $workflow:REST-CXT-MODELTMPL := $workflow:REST-CXT-APP || "/model_templates";


declare function local:get-workflow($doctype) as node() * {
    let $workflow := doc($appconfig:WF-FOLDER || "/" || $doctype || ".xml")/workflow
    return $workflow
};

(: creates the output for all document facets :)
declare function local:facets($doctype) as node() * {
    let $facets := local:get-workflow($doctype)/facet
    let $type := xs:string(request:get-parameter("type",""))
    let $docpos := xs:integer(request:get-parameter("pos",""))
    let $count := count($facets)
    for $facet at $pos in $facets
        return
            <li>
                <a class="editlink" href="facet.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;attr={$pos}&amp;node={data($facet/@name)}">{data($facet/@name)}</a>
                &#160;<a class="edit" href="#">[edit]</a>
                &#160;<a class="delete" href="#">[delete]</a>
            </li>
};

(: creates the output for all document states :)
declare function local:states($doctype) as node() * {
    let $states := local:get-workflow($doctype)/state
    let $type := xs:string(request:get-parameter("type",""))
    let $docpos := xs:integer(request:get-parameter("pos",""))
    let $count := count($states)
    for $state at $pos in $states
        return
            <li>
                <a class="editlink" href="state.html?type={$type}&amp;doc={$doctype}&amp;pos={$docpos}&amp;attr={$pos}&amp;node={data($state/@id)}">{data($state/@title)}</a>
                &#160;<a class="delete" href="#">[delete]</a>
            </li>
};

declare function local:get-form($docname as xs:string) as node() * {
    doc($appconfig:FORM-FOLDER || '/' || $docname || '.xml')
};

(: creates the output for all document transitions sources :)
declare function local:transition-to-from($doctype, $nodename) as node() * {

    for $transition at $pos in local:get-workflow($doctype)/transition
    where $transition/sources/source[. = $nodename] | $transition/destinations/destination[. = $nodename]
    return
        local:render-row($doctype, $nodename, $pos, $transition)
};

(: reused to render the destination and source transition tables below :)
declare function local:render-row($doctype as xs:string, $nodename as xs:string, $pos as xs:integer, $transition as node()) as node() * {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("node",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    let $sources :=  for $src in $transition/sources/source
                    return 
                        if($src/text() = $nodename) then
                            <span class="xposeGreen">{$src/text()}</span>
                        else
                            <span>{$src}&#160;</span>
    let $destinations :=  for $dest in $transition/destinations/destination
                    return 
                        if($dest/text() = $nodename) then
                            <span class="xposeGreen">&#160;{$dest/text()}</span>
                        else
                            <span>{$dest}&#160;</span>                            
    return 
    <tr>
        <td><a class="editlink" href="transition-edit.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;from={$NODENAME}&amp;nodepos={$pos}">{data($transition/@title)}</a></td>
        <td>{$sources}</td>
        <td>{$destinations}</td>
    </tr>
};

(: creates the output for all document transitions sources :)
declare function local:arrow-direction($doctype as xs:string, $nodepos as xs:integer, $nodename as xs:string) as node() * {

    let $workflow := local:get-workflow($doctype)
    let $state := data($workflow/transition[$nodepos]/@title)
    
    let $source-state-ids := $workflow/transition[$nodepos]/sources/source/text()
    let $source-state-titles := for $id in $source-state-ids return data($workflow/state[@id eq $id]/@title)
    
    let $title := data($workflow/state[@id eq $nodename]/@title)
    return
        if (empty($workflow/transition[$nodepos]/sources/source[. = $nodename])) then 
            (: <- :)
            <h4 title="Arrow points to the source(s)">{string-join($source-state-titles,", ")} &#8592; {$title}</h4>
        else 
            (: -> :)
            <h4 title="Arrow points to the destination">{$title} &#8594; {$state}</h4>
};

declare function local:mode() as xs:string {
    let $doc := request:get-parameter("doc", "nothing")

    let $mode := if($doc eq "undefined") then "new"
                 else "edit"

    return $mode
};

declare function local:all-feature() {
    <features> 
    {
        let $type := xs:string(request:get-parameter("type",""))
        let $docname := xs:string(request:get-parameter("doc","none"))
        let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
        let $featurename :=if (doc-available($wf-doc)) then $docname else $type
        let $feats-tmpl := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || "_features.xml")//features[@for eq $featurename]
        let $feats-wf := doc($appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml")//feature   
        for $feature in $feats-tmpl/feature    
        return 
            if($feats-wf[@name eq data($feature/@name)]) then 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute enabled { if(data($feats-wf[@name eq data($feature/@name)]/@enabled)) then xs:string(data($feats-wf[@name eq data($feature/@name)]/@enabled)) else "false" }
                }
            else 
                element feature {
                    attribute name { data($feature/@name) },
                    attribute workflow { data($feature/@workflow) },
                    attribute enabled { "false" }
                } 
    }
    </features>
};

declare
function workflow:edit($node as node(), $model as map(*)) {

    let $type := xs:string(request:get-parameter("type",""))
    let $docname := xs:string(request:get-parameter("doc","none"))   
    let $wf-doc := $appconfig:CONFIGS-FOLDER || "/workflows/" || $docname || ".xml"
    let $featuregroupname :=if (doc-available($wf-doc)) then $docname else $type
    let $pos := xs:string(request:get-parameter("pos",""))
    let $init := xs:string(request:get-parameter("init",""))
    let $lastfield := data(local:get-form($docname)/descriptor/field[last()]/@name)
    let $showing := xs:string(request:get-parameter("tab","fields"))
    return 
        (: Element to pop up :)
    	<div>
            <div style="display:none">
                <xf:model>
                    {
                        (: if adding a new workflow is true :)
                        if($init eq "true") then 
                            <xf:instance id="i-workflow" src="{$workflow:REST-CXT-MODELTMPL}/workflow.xml"/>
                        else
                            <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$docname}.xml"/> 
                    }
                    
                    <xf:instance id="i-grants">
                        <data>
                            <allow permission=".Add">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".Edit">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".View">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>
                            <allow permission=".Delete">
                                <roles originAttr="roles">
                                    <role/>
                                </roles>
                            </allow>                          
                        </data>
                    </xf:instance>
                    
                    <xf:instance id="i-alltags" src="{$workflow:REST-CXT-MODELTMPL}/_tags.xml"/>
                    
                    <xf:instance id="i-tags" src="{$workflow:REST-CXT-MODELTMPL}/tags.xml"/>                    
                    
                    <xf:instance id="i-allroles" src="{$workflow:REST-BC-LIVE}/sys/_roles.xml"/> 
                    
                    <xf:instance id="i-features" xmlns="">
                        <data>
                            {local:all-feature()}                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-tmplrole" xmlns="">
                        <data>
                            <roles>
                               <role/>                               
                            </roles>
                        </data>
                    </xf:instance> 

                    <xf:bind nodeset=".">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="feature/@enabled" type="xf:boolean" required="true()" />
                        
                        <!--xf:bind id="view" nodeset="allow[@permission eq '.View']/roles/role" required="true()" type="xs:string" constraint="(instance()/allow[@permission eq '.View']/roles[count(role) eq count(distinct-values(role)) and count(role[text() = '']) lt 2])"/>
                        <!xf:bind id="edit" nodeset="allow[@permission eq '.Edit']/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/edit/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/edit/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="add" nodeset="allow[@permission eq '.Add']/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/add/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/add/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/>
                        <xf:bind id="delete" nodeset="allow[@permission eq '.Delete']/roles/role" required="true()" type="xs:string" constraint="(instance()/.[@name eq '{$docname}']/field[{$fieldid}]/listing/roles[count(role) eq count(distinct-values(role)) and count(role[text() = 'ALL']) lt 2]) or (instance()/.[@name eq '{$docname}']/field[{$fieldid}]/listing/roles[count(role) eq 2 and count(role[text() = 'ALL']) = 2])"/-->                        
                    </xf:bind>
                    
                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-APP}/model_templates/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$docname}.xml'"/>
    
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
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
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
                        <xf:action if="'{$init}' eq 'true'">
                            <xf:setvalue ref="instance()/@name" value="'{$docname}'"/>
                        </xf:action>
                        <!-- remove the tags node if there is jus the template tag we insert -->
                        <xf:delete nodeset="instance()/tags[string-length(tag/text()) &lt; 1]" />   
                        
                        <!-- drop and add workflow features -->
                        <xf:message level="ephemeral">drop all &lt;xmp&gt;&lt;feature&gt;&lt;/xmp&gt; nodes on workflow</xf:message>
                        <xf:delete nodeset="instance()/feature"/>
                        <xf:insert nodeset="instance()/allow[last()]" at="1" position="after" origin="instance('i-features')/features/feature" />                       
                        
                        <!-- add workflow permissions -->
                        <xf:action if="empty(instance()/allow[@permission eq '.View'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".View"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.View']" />
                        </xf:action>
                        <xf:action if="empty(instance()/allow[@permission eq '.Add'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Add"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Add']" />
                        </xf:action>                        
                        <xf:action if="empty(instance()/allow[@permission eq '.Edit'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Edit"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Edit']" />
                        </xf:action>          
                        <xf:action if="empty(instance()/allow[@permission eq '.Delete'])">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;allow permission=".Delete"&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-grants')/allow[@permission eq '.Delete']" />
                        </xf:action>                        
                        
                        <xf:action if="empty(instance()/tags)">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;tags&gt;&lt;/xmp&gt; node on workflow</xf:message>
                            <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-tags')/tags" />
                        </xf:action>                             
                    </xf:action>

            </xf:model>
            
            </div>
            
            <div id="tabs_container">
                <ul id="tabs">
                    <li id="tabdetails" class="active"><a href="#details">Properties</a></li>
                    <li id="tabstates" ><a href="#states">States</a></li>
                    <li id="tabfacets" ><a href="#facets">Facets</a></li>
                </ul>
            </div>
            
            <div id="tabs_content_container">
                <div id="details" class="tab_content" style="display: block;">
                    <xf:group ref="." appearance="bf:horizontalTable">
                        <xf:label>Workflow Properties</xf:label>
                        <xf:input id="wf-title" ref="@title" incremental="true">
                            <xf:label>Title</xf:label>
                            <xf:hint>edit title of the workflow</xf:hint>
                            <xf:alert>enter more than 3 characters</xf:alert>
                        </xf:input>   
                        <xf:textarea id="wf-description" ref="@description" appearance="growing" class="xLongwidthMax" incremental="true">
                            <xf:label>Description</xf:label>
                            <xf:hint>lengthy description of the workflow</xf:hint>
                            <xf:alert>invalid</xf:alert>
                        </xf:textarea>
                    </xf:group>
                    <hr/>
                    <xf:group ref="." appearance="bf:horizontalTable">
                        <xf:label>Features &amp; Tags</xf:label>
                        <xf:group appearance="bf:horizontalTable">
                            <xf:label>features</xf:label>
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Workflowed</xf:label>
                                <xf:select id="c-wfeatures" ref="feature/@enabled" appearance="full" incremental="true" class="blockCheckbox">
                                    <xf:hint>enabled/disabled features on this workflow</xf:hint>
                                    <xf:itemset nodeset="instance()/feature[@workflow eq 'True']">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@enabled"></xf:value>
                                    </xf:itemset>
                                </xf:select>  
                            </xf:group>
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Non-workflowed</xf:label>
                                <xf:select id="c-nwfeatures" ref="feature/@enabled" appearance="full" incremental="true" class="blockCheckbox">
                                    <xf:hint>enabled/disabled features on this workflow</xf:hint>
                                    <xf:itemset nodeset="instance()/feature[@workflow eq 'False']">
                                        <xf:label ref="@name"></xf:label>
                                        <xf:value ref="@enabled"></xf:value>
                                    </xf:itemset>
                                </xf:select>  
                            </xf:group>
                        </xf:group>
                        <xf:group appearance="bf:verticalTable">
                            <xf:label>Workflow tags</xf:label>
                            <xf:repeat id="r-tags" nodeset="tags/tag[position() != last()]" appearance="compact">
                                <xf:select1 ref="." appearance="minimal" incremental="true">
                                    <xf:hint>a Hint for this control</xf:hint>
                                    <xf:alert>invalid: empty or non-unique tags</xf:alert>
                                    <xf:hint>tags should be unique</xf:hint>   
                                    <xf:itemset nodeset="instance('i-alltags')/tag">
                                        <xf:label ref="."></xf:label>                                       
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                                &#160;
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-tags')[position()]"></xf:delete>                                 
                                    </xf:action>
                                </xf:trigger>                                  
                            </xf:repeat>                                       
                            <xf:trigger>
                                <xf:label>add tag</xf:label>
                                <xf:action>
                                    <xf:insert nodeset="./tags/tag"></xf:insert>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>  
                    </xf:group>                    
                    <hr/>
                    <xf:group ref=".">
                        <xf:group appearance="compact" class="modesWrapper">
                            <xf:label>Global Grants</xf:label>
                            
                            <!-- view mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>View</xf:label>    
                                <xf:repeat id="r-viewfieldattrs" nodeset="allow[@permission eq '.View']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant view on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-viewfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.View']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- edit mode -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Edit</xf:label>    
                                <xf:repeat id="r-editwfieldattrs" nodeset="allow[@permission eq '.Edit']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant edit on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-editfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Edit']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                            
                            <!-- add -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Add</xf:label>    
                                <xf:repeat id="r-addwfieldattrs" nodeset="allow[@permission eq '.Add']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant add on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-addfieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Add']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                 
                            <!-- delete -->
                            <xf:group appearance="bf:verticalTable">
                                <xf:label>Delete</xf:label>    
                                <xf:repeat id="r-deletewfieldattrs" nodeset="allow[@permission eq '.Delete']/roles/role[position() != last()]" startindex="1" appearance="compact">
                                    <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                        <xf:label>grant delete on roles...</xf:label>
                                        <xf:help>help for select1</xf:help>
                                        <xf:alert>invalid: cannot be empty</xf:alert>
                                        <xf:itemset nodeset="instance('i-allroles')/role">
                                            <xf:label ref="@name"></xf:label>
                                            <xf:value ref="@name"></xf:value>
                                        </xf:itemset>
                                    </xf:select1>
                                    <xf:trigger>
                                        <xf:label>delete</xf:label>
                                        <xf:action>
                                            <xf:delete at="index('r-deletefieldattrs')[position()]"></xf:delete>
                                        </xf:action>
                                    </xf:trigger>                                         
                                </xf:repeat>
                                <br/>
                                <xf:group appearance="minimal">
                                    <xf:trigger>
                                       <xf:label>add role</xf:label>
                                       <xf:action>
                                           <xf:insert nodeset="allow[@permission eq '.Delete']/roles/role" at="last()" position="after" origin="instance('i-tmplrole')/roles/role"/>
                                       </xf:action>
                                    </xf:trigger>     
                                </xf:group>
                            </xf:group>
                                                                   
                        </xf:group>             
                    </xf:group>
                    <hr/>
                    <xf:group>
                        <xf:trigger>
                            <xf:label>Save</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                                
                        </xf:trigger>                         
                    </xf:group>                    
                    
                </div>
                <div id="states" class="tab_content">
                    <div class="ulisting">
                        <h2>States</h2>
                        <ul class="clearfix">
                            {local:states($docname)}
                        </ul>
                        <a class="button-link" href="state-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}">add state</a>                 
                    </div> 
                 </div>
                <div id="facets" class="tab_content">
                    <div class="ulisting">
                        <h2>Facets</h2>
                        <ul class="clearfix">
                            {local:facets($docname)}
                        </ul>
                        
                        <a class="button-link" href="field-add.html?type={$type}&amp;doc={$docname}&amp;pos={$pos}&amp;node=field&amp;after={$lastfield}">add facet</a>
                    </div>
                </div>               
            </div>                 
        </div>
};

declare
function workflow:state-edit($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("node",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model id="master">
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>

                    <xf:instance id="i-alltags" src="{$workflow:REST-CXT-MODELTMPL}/_tags.xml"/>

                    <xf:instance id="i-tags" src="{$workflow:REST-CXT-MODELTMPL}/tags.xml"/>

                    <xf:bind nodeset="./state">
                        <xf:bind nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 2" />                    
                        <xf:bind nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[A-z_]+$')" />
                        <xf:bind nodeset="tags/tag" type="xf:string" required="true()" constraint="count(instance()/state[{$ATTR}]/tags/tag) eq count(distinct-values(instance()/state[{$ATTR}]/tags/tag))" />
                        <xf:bind nodeset="@version" type="xf:boolean" required="true()" />
                        <!--xf:bind nodeset="../facet/allow/roles/role" type="xf:string" required="true()" /-->
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>                   

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
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
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
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
                        <!-- remove the tags node if there is jus the template tag we insert -->
                        <xf:delete nodeset="instance()/state[{$ATTR}]/tags[string-length(tag/text()) &lt; 2]" />                    
                        <xf:action if="not(empty(instance()/state[{$ATTR}]/tags))">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;tag&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/tags/child::*" at="last()" position="after" origin="instance('i-tags')/tags/tag" /> 
                        </xf:action>                       
                        <xf:action if="empty(instance()/state[{$ATTR}]/tags)">
                            <xf:message level="ephemeral">inserted a &lt;xmp&gt;&lt;tags&gt;&lt;/xmp&gt; node</xf:message>
                            <xf:insert nodeset="instance()/state[{$ATTR}]/child::*" at="last()" position="after" origin="instance('i-tags')/tags" />
                        </xf:action>                       
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <a href="workflow.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}#tabstates">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>              
                <h1>state | <xf:output value="./state[{$ATTR}]/@title" class="transition-inline"/></h1>
                <br/>                
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="width:100%;">
                                <xf:group ref="./state[{$ATTR}]" appearance="bf:horizontalTable"> 
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:label>properties</xf:label>
                                        <xf:input id="state-title" ref="@title" incremental="true">
                                            <xf:label>Title</xf:label>
                                            <xf:hint>edit title of the workflow</xf:hint>
                                            <xf:help>... and no spaces in between words</xf:help>
                                            <xf:alert>enter more than 3 characters...</xf:alert>
                                        </xf:input>                                       
                                        <xf:input id="state-id" ref="@id" incremental="true">
                                            <xf:label>ID</xf:label>
                                            <xf:hint>edit id of the workflow</xf:hint>
                                            <xf:help>Use A-z with the underscore character to avoid spaces</xf:help>
                                            <xf:alert>invalid: must be 3+ characters and A-z and _ allowed</xf:alert>
                                        </xf:input>                                   
                                        <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                            <xf:label>Permission from state</xf:label>
                                           <xf:hint>where to derive permissions for state</xf:hint>
                                           <xf:help>select one</xf:help>
                                            <xf:itemset nodeset="instance()/state[data(@id) ne '{$NODENAME}']/@id">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1>   
                                        <xf:input id="state-version" ref="@version">
                                            <xf:label>Version</xf:label>
                                            <xf:hint>support versioning</xf:hint>
                                        </xf:input>   
                                    </xf:group>
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:label>tags</xf:label>
                                        <xf:repeat id="r-statetags" nodeset="./tags/tag[position() != last()]" appearance="compact">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:hint>a Hint for this control</xf:hint>
                                                <xf:alert>invalid: emtpy or non-unique tags</xf:alert>
                                                <xf:hint>tags should be unique</xf:hint>   
                                                <xf:itemset nodeset="instance()/tags/tag">
                                                    <xf:label ref="."></xf:label>                                       
                                                    <xf:value ref="."></xf:value>
                                                </xf:itemset>
                                            </xf:select1>
                                            &#160;
                                            <xf:trigger>
                                                <xf:label>delete</xf:label>
                                                <xf:action>
                                                    <xf:delete at="index('r-statetags')[position()]"></xf:delete>                                 
                                                </xf:action>
                                            </xf:trigger>                                  
                                        </xf:repeat>                                       
                                        <xf:trigger>
                                            <xf:label>add tag</xf:label>
                                            <xf:action>
                                                <xf:insert ev:event="DOMActivate" nodeset="./tags/child::*" at="last()" position="after" origin="instance('i-tags')/tags/tag"/>
                                            </xf:action>
                                        </xf:trigger>
                                    </xf:group>
                                    
                                </xf:group>
                                
                                <xf:trigger>
                                    <xf:label>Save</xf:label>
                                    <xf:action>
                                        <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                        <xf:delete nodeset="instance()/state[{$ATTR}]/tags/tag[last() > 1]" at="last()" />
                                        <!-- remove the tags node if there is jus the template tag we insert -->
                                        <xf:delete nodeset="instance()/state[{$ATTR}]/tags[string-length(tag/text()) &lt; 2]" />
                                        <xf:send submission="s-add"/>
                                        <xf:insert nodeset="instance()/state[{$ATTR}]/tags/child::*" at="last()" position="after" origin="instance('i-tags')/tags/tag" />
                                    </xf:action>                                
                                </xf:trigger>   
                                <hr/>
                                <br/>
                                <h1>Manage Transitions</h1>
                                <div style="width:100%;" class="clearfix">
                                    <div style="float:left;width:60%;">
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th>transition name</th>
                                                <th>source(s)</th>
                                                <th>destination</th>
                                            </tr>
                                            {local:transition-to-from($DOCNAME, $NODENAME)}
                                        </table> 
                                        <div id="popup" style="display:none;">
                                            <div id="popupcontent" class="popupcontent"></div>
                                        </div>                                           
                                        <div style="margin-top:15px;"/>                                           
                                        <a class="button-link popup" href="transition-add.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;from={$NODENAME}">add transition</a>                                 
                                    </div>                                   
                                </div>
                                <hr/>
                                <br/>
                                <h1>Manage Permissions</h1>
                                <div style="width:100%;" class="clearfix">
                                    <div style="float:left;width:60%;">

                                        <table class="listingTable" style="width:100%;">
                                            <thead>
                                                <tr>
                                                    <th>Roles</th>        
                                                    <th>View</th>
                                                    <th>Edit</th>
                                                    <th>Delete</th>
                                                    <th>Add</th>
                                                </tr>
                                            </thead>
                                            <tbody id="r-attrs" xf:repeat-nodeset="instance()/facet[@name eq 'public']/allow/roles/role">
                                                <tr>
                                                    <td id="foo" class="one" style="color:steelblue;font-weight:bold;">
                                                        <xf:output ref="."></xf:output>
                                                    </td>
                                                    <td class="permView">
                                                        <xf:input id="input1" ref="input1/value" incremental="true">
                                                            <xf:label>a checkbox</xf:label>
                                                            <xf:hint>a Hint for this control</xf:hint>
                                                            <xf:help>help for input1</xf:help>
                                                            <xf:alert>invalid</xf:alert>
                                                        </xf:input>
                                                    </td>
                                                    <td class="three" style="color:blue;">
                                                        <xf:output ref="item3"></xf:output>
                                                    </td>
                                                    <td class="four" style="color:blue;">
                                                        <xf:output ref="item4"></xf:output>
                                                    </td>
                                                    <td class="five" style="color:blue;">
                                                        <xf:output ref="item5"></xf:output>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        
                                        </table>   
                                        <xf:group appearance="bf:horizontalTable">
                                            <xf:trigger>
                                                <xf:label>insert</xf:label>
                                                <xf:action>
                                                    <xf:insert nodeset="instance('i-items')/items"></xf:insert>
                                                </xf:action>
                                            </xf:trigger>
                                            
                                            <xf:trigger>
                                                <xf:label>delete</xf:label>
                                                <xf:action>
                                                    <xf:delete nodeset="instance('i-items')/items[index('r-attrs')]"></xf:delete>
                                                </xf:action>
                                            </xf:trigger>
                                        </xf:group>
                                        
                                        <div style="margin-top:15px;"/>                                           
                                        <a class="button-link popup" href="transition-add.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;from={$NODENAME}">add permission</a>                                 
                                    </div>                                   
                                </div>                                
                                
                            </div>                       
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>        
};

declare
function workflow:state-add($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none">
                 <xf:model id="master">
                    {
                        (: if its a new workflow meaning its not saved as yet :)
                        if(doc-available($appconfig:CONFIGS-FOLDER || "/workflows/" || $DOCNAME || ".xml")) then
                            <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                        else
                            <xf:instance id="i-workflow" src="{$workflow:REST-CXT-MODELTMPL}/workflow.xml"/>
                    }

                    <xf:instance id="i-alltags" src="{$workflow:REST-CXT-MODELTMPL}/_tags.xml"/>

                    <xf:instance id="i-tags" src="{$workflow:REST-CXT-MODELTMPL}/tags.xml"/>

                    <xf:instance id="i-state" xmlns="">
                        <data>
                            <state permissions_from_state="" id="" title="" version="false">
                                <tags originAttr="tags">
                                    <tag/>
                                </tags>
                                <facet ref=""/>
                            </state>                        
                        </data>
                    </xf:instance>

                    <xf:bind nodeset="instance()/state[last()]">
                        <xf:bind nodeset="@id" type="xf:string" required="true()" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and count(instance()/state/@id) eq count(distinct-values(instance()/state/@id))" />
                        <!--xf:bind nodeset="tags/tag" type="xf:string" required="true()" constraint="count(instance()/state[last()]/tags/tag) eq count(distinct-values(instance()/state[last()]/tags/tag)) and string-length(.) &gt; 1" /-->
                        <xf:bind nodeset="@version" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
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
                            <xf:message level="ephemeral">Workflow state added successfully</xf:message>
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
                        <!-- insert the tags for this workflow -->
                        <xf:insert nodeset="instance()/child::*" at="1" position="before" origin="instance('i-tags')/tags" />                    
                        <xf:insert nodeset="instance()/child::*" at="last()" position="after" origin="instance('i-state')/state" />
                        <xf:setfocus control="state-title" />
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <a href="workflow.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}#tabstates">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>              
                <h1>state | <xf:output value="instance()/state[last()]/@title" class="transition-inline"/></h1>
                <br/>                
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:90%;">
                            <div style="width:100%;">
                                <xf:group ref="instance()/state[last()]" appearance="bf:horizontalTable"> 
                                    <xf:group appearance="bf:verticalTable">     
                                        <xf:input id="state-title" ref="@title" incremental="true">
                                            <xf:label>Title</xf:label>
                                            <xf:hint>enter title of the state</xf:hint>
                                            <xf:help>... and no spaces in between words</xf:help>
                                            <xf:alert>enter more than 3 characters...</xf:alert>
                                        </xf:input>                                     
                                        <xf:input id="state-id" ref="@id" incremental="true">
                                            <xf:label>ID</xf:label>
                                            <xf:hint>enter id of the new state</xf:hint>
                                            <xf:help>... and no spaces in between words or non-alphabets other than _</xf:help>
                                            <xf:alert>unique / not too short / lower-case a-z / use underscore to avoid spaces</xf:alert>
                                        </xf:input>                                     
                                        <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                            <xf:label>Permission from state</xf:label>
                                           <xf:hint>where to derive permissions for state</xf:hint>
                                           <xf:help>select one</xf:help>
                                            <xf:itemset nodeset="instance()/state[xs:string(data(./@id)) ne xs:string(data(instance()/state[last()]/@id))]/@id">
                                                <xf:label ref="."></xf:label>
                                                <xf:value ref="."></xf:value>
                                            </xf:itemset>
                                        </xf:select1>   
                                        <xf:input id="state-version" ref="@version">
                                            <xf:label>Version</xf:label>
                                            <xf:hint>support versioning</xf:hint>
                                        </xf:input>   
                                    </xf:group>
                                    <xf:group appearance="bf:verticalTable">
                                        <xf:repeat id="r-statetags" nodeset="./tags/tag[position() != last()]" appearance="compact">
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:label>tags</xf:label>
                                                <xf:hint>a Hint for this control</xf:hint>
                                                <xf:alert>invalid: empty or non-unique tags</xf:alert>
                                                <xf:hint>tags should be unique</xf:hint>   
                                                <xf:itemset nodeset="instance('i-alltags')/tag">
                                                    <xf:label ref="."></xf:label>                                       
                                                    <xf:value ref="."></xf:value>
                                                </xf:itemset>
                                            </xf:select1>
                                            &#160;
                                            <xf:trigger>
                                                <xf:label>delete</xf:label>
                                                <xf:action>
                                                    <xf:delete at="index('r-statetags')[position()]"></xf:delete>                                 
                                                </xf:action>
                                            </xf:trigger>                                  
                                        </xf:repeat>                                       
                                        <xf:trigger>
                                            <xf:label>add tag</xf:label>
                                            <xf:action>
                                                <xf:insert nodeset="./tags/tag"></xf:insert>
                                            </xf:action>
                                        </xf:trigger>
                                    </xf:group>
                                    
                                </xf:group>
                                
                                <xf:trigger>
                                    <xf:label>Save</xf:label>
                                    <xf:action>
                                        <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                        <!-- removes any tag node thats empty -->
                                        <xf:delete nodeset="instance()/tags/tag[string-length(.) &lt; 2]" />
                                        <xf:send submission="s-add"/>
                                    </xf:action>                                
                                </xf:trigger>   
                                <hr/>
                                <br/>
                                <h1>Manage Transitions</h1>
                                <div style="width:100%;height:200px;">
                                    <div style="float:left;width:60%;">
                                        <table class="listingTable" style="width:100%;">
                                            <tr>                      			 
                                                <th>transition name</th>
                                                <th>source</th>
                                                <th>destination</th>
                                            </tr>
                                            {local:transition-to-from($DOCNAME, "NULL")}
                                        </table> 
                                        <div id="popup" style="display:none;">
                                            <div id="popupcontent" class="popupcontent"></div>
                                        </div>                                           
                                        <div style="margin-top:15px;"/>                                           
                                        <a class="button-link popup" href="transition-add.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr=ONE&amp;from=TWO">add transition</a>                                 
                                    </div>                                   
                                </div>
                                
                            </div>                       
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>        
};


declare
function workflow:transition-add($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("from",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none;">
                <xf:model>         
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                    
                    <xf:instance id="i-conditions" src="{$workflow:REST-BC-LIVE}/workflows/_conditions.xml"/>                     

                    <xf:instance id='i-transition' xmlns="">
                        <data>
                           <transition title="" condition="" require_confirmation="false" trigger="manual" order="0"  note="Add a note">
                              <sources originAttr="source">
                                 <source/>
                              </sources>
                              <destinations originAttr="destination">
                                 <destination/>
                              </destinations>
                              <roles originAttr="roles">
                                 <role/>
                              </roles>
                           </transition>                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-globalroles" xmlns="">
                        <data>
                            <roles originAttr="roles">
                                <role>CommitteeMember</role>
                                <role>Minister</role>
                                <role>Owner</role>
                                <role>Clerk.HeadClerk</role>
                                <role>Signatory</role>
                                <role>Anonymous</role>
                                <role>MP</role>
                                <role>Authenticated</role>
                                <role>Speaker</role>
                                <role>PoliticalGroupMember</role>
                                <role>Admin</role>
                                <role>Government</role>
                                <role>Clerk.QuestionClerk</role>
                                <role>Translator</role>
                                <role>Clerk</role>
                                <role>ALL</role>
                            </roles>                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-originrole" xmlns="">
                        <data>
                            <roles>
                               <role>ALL</role>                               
                            </roles>
                        </data>
                    </xf:instance>                     
                    
                    <xf:bind nodeset="instance()/transition[last()]">
                        <xf:bind id="b-title" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind id="b-order" nodeset="@order" type="xf:integer" required="true()" constraint="(. &lt; 100) and (. &gt; 0)" />
                        <xf:bind nodeset="@trigger" type="xf:string" required="true()" />
                        <xf:bind nodeset="@require_confirmation" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
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
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >
                        <xf:setvalue ref="instance('i-transition')/transition/sources/source" value="'{$NODENAME}'"/>
                        <xf:insert nodeset="instance()/transition" at="last()" position="after" origin="instance('i-transition')/transition" />                    
                    </xf:action>
                </xf:model>
            </div>
            <div style="width: 100%; height: 100%;">
                <a href="state.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;node={$NODENAME}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>    
                <div style="width:100%;margin-top:10px;">               
                    <xf:group ref="instance()/transition[last()]" appearance="bf:horizontalTable">                    
                        <xf:label><h1>transition | <xf:output value="@title" class="transition-inline"/></h1></xf:label>
                        <xf:label><h3>{$NODENAME} &#8594; </h3></xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>type transition title</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input> 
                            <xf:range ref="@order" start="1" step="1" end="100" incremental="true">
                                <xf:label>Order</xf:label>
                                <xf:hint>ordering used on display</xf:hint>
                                <xf:alert>Invalid number.</xf:alert>
                                <xf:help>Enter an integer between 1 and 100 </xf:help>      
                            </xf:range>                        
                            <xf:output bind="b-order">
                                <xf:label/>                                
                            </xf:output> 
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                
                                <xf:itemset nodeset="instance()/state[xs:string(data(./@id)) ne '{$NODENAME}']/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                              
                            <xf:select1 ref="@trigger" appearance="minimal" incremental="true">
                                <xf:label>Triggered</xf:label>
                                <xf:hint>how this transition is triggered</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:item>
                                    <xf:label>by system</xf:label>
                                    <xf:value>system</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>manually</xf:label>
                                    <xf:value>manual</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>automatically</xf:label>
                                    <xf:value>automatic</xf:value>
                                </xf:item>                                
                            </xf:select1>                            
                            <xf:select1 ref="@condition" appearance="minimal" incremental="true">
                                <xf:label>Condition</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance('i-conditions')/condition">
                                <xf:label ref="."></xf:label>
                                <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                                <xf:message ev:event="xforms-valid" level="ephemeral">condition is valid.</xf:message>                             
                            </xf:select1>                              
                            <xf:input id="transition-confirm" ref="@require_confirmation">
                                <xf:label>Require&#160;confirmation</xf:label>
                                <xf:hint>support confirmation when making a transition</xf:hint>
                            </xf:input>                                
                            <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                <xf:label>Permission from state</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1> 
                        </xf:group>
                        
                        <xf:group appearance="bf:verticalTable" style="width:20%">
                            <xf:label><h3>roles</h3></xf:label>                                     
                            <table class="fieldModes">
                               <thead>
                                   <tr>                                
                                       <th colspan="2"/>                               
                                   </tr>
                               </thead>                                    
                               <tbody id="r-transitionattrs" xf:repeat-nodeset="roles/role[position()!=last()]" startindex="1">
                                   <tr>                                
                                       <td>
                                            <xf:select1 ref="." appearance="minimal" incremental="true">
                                                <xf:label>select a role</xf:label>
                                                <xf:alert>duplicates or invalid role options</xf:alert>
                                                <xf:itemset nodeset="instance('i-globalroles')/roles/role">
                                                    <xf:label ref="."></xf:label>
                                                    <xf:value ref="."></xf:value>
                                                </xf:itemset>
                                            </xf:select1>                                                         
                                       </td>                                           
                                       <td style="color:red;width:50px;height:30px;">&#160;</td>                            
                                   </tr>
                               </tbody>
                            </table>    
                            <xf:group appearance="minimal">                                   
                                <table>                              
                                   <tbody>
                                       <tr>                                
                                           <td>
                                                <xf:trigger>
                                                   <xf:label>add role</xf:label>
                                                   <xf:action>
                                                       <xf:insert nodeset="roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                                   </xf:action>
                                                </xf:trigger>                                       
                                           </td>                                           
                                           <td>                                           
                                                <xf:trigger>
                                                    <xf:label>remove</xf:label>
                                                    <xf:action ev:event="DOMActivate">
                                                        <xf:delete nodeset="roles/role[last()>1]" at="index('r-transitionattrs')"/>
                                                        <xf:insert nodeset="roles/role[last()=1]" at="1" position="before"/>
                                                        <xf:setfocus control="r-viewfieldattrs"/>
                                                    </xf:action> 
                                                </xf:trigger>  
                                           </td>                            
                                       </tr>
                                   </tbody>
                                </table>
                            </xf:group>
                        </xf:group>                                                
                    
                    </xf:group>
                     
                    <hr/>
                    <xf:trigger>
                        <xf:label>add transition</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                            <xf:send submission="s-add"/>
                        </xf:action>                                
                    </xf:trigger>                    
                </div>
            </div>
        </div>
};

declare
function workflow:transition-edit($node as node(), $model as map(*)) {
    let $TYPE := xs:string(request:get-parameter("type",""))
    let $DOCNAME := xs:string(request:get-parameter("doc",""))
    let $DOCPOS := xs:integer(request:get-parameter("pos",0))
    let $NODENAME := xs:string(request:get-parameter("from",""))
    let $NODEPOS := xs:string(request:get-parameter("nodepos",""))
    let $ATTR := xs:string(request:get-parameter("attr",""))
    return
    	<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
            <div style="display:none;">
                <xf:model>         
                    <xf:instance id="i-workflow" src="{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml"/>
                    
                    <xf:instance id="i-conditions" src="{$workflow:REST-BC-LIVE}/workflows/_conditions.xml"/>                     

                    <xf:instance id="i-originrole" src="{$workflow:REST-CXT-MODELTMPL}/roles.xml"/>

                    <xf:instance id='i-transition' xmlns="">
                        <data>
                           <transition title="" condition="" require_confirmation="false" trigger="manual" order="0"  note="Add a note">
                              <sources originAttr="source">
                                 <source/>
                              </sources>
                              <destinations originAttr="destination">
                                 <destination/>
                              </destinations>
                              <roles originAttr="roles">
                                 <role/>
                              </roles>
                           </transition>                        
                        </data>
                    </xf:instance>

                    <xf:instance id="i-globalroles" xmlns="">
                        <data>
                            <roles originAttr="roles">
                                <role>CommitteeMember</role>
                                <role>Minister</role>
                                <role>Owner</role>
                                <role>Clerk.HeadClerk</role>
                                <role>Signatory</role>
                                <role>Anonymous</role>
                                <role>MP</role>
                                <role>Authenticated</role>
                                <role>Speaker</role>
                                <role>PoliticalGroupMember</role>
                                <role>Admin</role>
                                <role>Government</role>
                                <role>Clerk.QuestionClerk</role>
                                <role>Translator</role>
                                <role>Clerk</role>
                                <role>ALL</role>
                            </roles>                        
                        </data>
                    </xf:instance>                   
                    
                    <xf:bind nodeset="instance()/transition[{$NODEPOS}]">
                        <xf:bind id="b-title" nodeset="@title" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind id="b-order" nodeset="@order" type="xf:integer" required="true()" constraint="((. &lt; 100) and (. &gt; 0)) or (. = 0)" />
                        <xf:bind id="b-destination" nodeset="destinations/destination" type="xf:string" required="true()" constraint="xs:string(.) ne '{$NODENAME}'" />
                        <xf:bind nodeset="roles/role" type="xf:string" required="true()" constraint="count(instance()/transition[{$NODEPOS}]/roles/role) eq count(distinct-values(instance()/transition[{$NODEPOS}]/roles/role))" />
                        <xf:bind nodeset="@trigger" type="xf:string" required="true()" />
                        <xf:bind nodeset="@require_confirmation" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$workflow:REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>
                    
                    <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
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
                            <xf:message level="ephemeral">Transition changes updated successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>
                    
                    <xf:submission id="s-delete" method="put" replace="none" ref="instance()">
                        <xf:resource value="'{$workflow:REST-BC-LIVE}/workflows/{$DOCNAME}.xml'"/>
    
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
                            <xf:message level="ephemeral">Transition deleted successfully</xf:message>
                            <script type="text/javascript">
                                document.location.href = 'state.html?type={$TYPE}&#38;amp;doc={$DOCNAME}&#38;amp;pos={$DOCPOS}&#38;amp;attr={$ATTR}&#38;amp;node={$NODENAME}';
                            </script> 
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>Transition information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>                    

                    <xf:action ev:event="xforms-ready" >    
                        <xf:action if="not(empty(instance()/transition[{$NODEPOS}]/roles))">
                            <xf:message level="ephemeral">appended a template &lt;role/&gt; node</xf:message>
                            <xf:insert nodeset="instance()/transition[{$ATTR}]/roles/child::*" at="last()" position="after" origin="instance('i-originrole')/roles/role" /> 
                        </xf:action>                       
                        <xf:action if="empty(instance()/transition[{$NODEPOS}]/tags)">
                            <xf:message level="ephemeral">added &lt;roles/&gt; node</xf:message>
                            <xf:insert nodeset="instance()/transition[{$NODEPOS}]/child::*" at="last()" position="after" origin="instance('i-originrole')/roles" />
                        </xf:action>                      
                    </xf:action>
                </xf:model>
            </div>
            <div style="width: 100%; height: 100%;">
                <a href="state.html?type={$TYPE}&amp;doc={$DOCNAME}&amp;pos={$DOCPOS}&amp;attr={$ATTR}&amp;node={$NODENAME}">
                    <img src="resources/images/back_arrow.png" title="back to workflow states" alt="back to workflow states"/>
                </a>
                <br/>    
                <div style="width:100%;margin-top:10px;">               
                    <xf:group ref="instance()/transition[{$NODEPOS}]" appearance="bf:horizontalTable">                    
                        <xf:label><h1>transition | <xf:output value="@title" class="transition-inline"/></h1></xf:label>
                        <xf:label>{local:arrow-direction($DOCNAME,$NODEPOS,$NODENAME)}</xf:label>
                        <xf:group appearance="bf:verticalTable" style="width:70%">
                            <xf:label><h3>properties</h3></xf:label>
                            <xf:input id="transition-id" bind="b-title" incremental="true">
                                <xf:label>Transition Title</xf:label>
                                <xf:hint>transition name</xf:hint>
                                <xf:help>... and no spaces in between words</xf:help>
                                <xf:alert>enter more than 3 characters...</xf:alert>
                            </xf:input> 
                            <xf:range ref="@order" start="1" step="1" end="100" incremental="true">
                                <xf:label>Order</xf:label>
                                <xf:hint>ordering used on display</xf:hint>
                                <xf:alert>Invalid number. Valid range 1 &lt;&gt; 100</xf:alert>
                                <xf:help>Enter an integer between 1 and 100 </xf:help>      
                            </xf:range>                        
                            <xf:output bind="b-order">
                                <xf:label/>                                
                            </xf:output>     
                            <xf:select1 ref="destinations/destination" appearance="minimal" incremental="true">
                                <xf:label>Destination</xf:label>
                                <xf:hint>select a destination</xf:hint>
                                <xf:alert>destination cannot be blank or same as source</xf:alert>                                   
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1>                               
                            <xf:select1 ref="@trigger" appearance="minimal" incremental="true">
                                <xf:label>Triggered</xf:label>
                                <xf:hint>how this transition is triggered</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:item>
                                    <xf:label>by system</xf:label>
                                    <xf:value>system</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>manually</xf:label>
                                    <xf:value>manual</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>automatically</xf:label>
                                    <xf:value>automatic</xf:value>
                                </xf:item>                                
                            </xf:select1>                            
                            <xf:select1 ref="@condition" appearance="minimal" incremental="true">
                                <xf:label>Condition</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance('i-conditions')/condition">
                                <xf:label ref="."></xf:label>
                                <xf:value ref="@name"></xf:value>
                                </xf:itemset>
                                <xf:message ev:event="xforms-valid" level="ephemeral">condition is valid.</xf:message>                             
                            </xf:select1>                              
                            <xf:input id="transition-confirm" ref="@require_confirmation">
                                <xf:label>Require&#160;confirmation</xf:label>
                                <xf:hint>support confirmation when making a transition</xf:hint>
                            </xf:input>                                
                            <xf:select1 ref="@permissions_from_state" appearance="minimal" incremental="true">
                                <xf:label>Permission from state</xf:label>
                                <xf:hint>where to derive permissions for state</xf:hint>
                                <xf:help>select one</xf:help>
                                <xf:itemset nodeset="instance()/state/@id">
                                    <xf:label ref="."></xf:label>
                                    <xf:value ref="."></xf:value>
                                </xf:itemset>
                            </xf:select1> 
                        </xf:group>    

                        <xf:group appearance="bf:verticalTable" style="width:20%">
                            <xf:label><h3>roles</h3></xf:label>  
                            <xf:repeat id="r-transitionattrs" nodeset="roles/role[position()!=last()]" startindex="1" appearance="compact">
                                <xf:select1 ref="." appearance="minimal" incremental="true" class="xmediumWidth">
                                    <xf:label>select a role</xf:label>
                                    <xf:help>help for roles</xf:help>
                                    <xf:alert>invalid: cannot have duplicates</xf:alert>
                                    <xf:itemset nodeset="instance('i-globalroles')/roles/role">
                                        <xf:label ref="."></xf:label>
                                        <xf:value ref="."></xf:value>
                                    </xf:itemset>
                                </xf:select1>
                                <xf:trigger>
                                    <xf:label>delete</xf:label>
                                    <xf:action>
                                        <xf:delete at="index('r-transitionattrs')[position()]"></xf:delete>
                                    </xf:action>
                                </xf:trigger>                                         
                            </xf:repeat>
                            <br/>
                            <xf:group appearance="minimal">
                                <xf:trigger>
                                   <xf:label>add role</xf:label>
                                   <xf:action>
                                       <xf:insert nodeset="roles/role" at="last()" position="after" origin="instance('i-originrole')/roles/role"/>
                                   </xf:action>
                                </xf:trigger>     
                            </xf:group>
                        </xf:group>                                                
                    </xf:group>
                     
                    <hr/>
                    <xf:group appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>update transition</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                                
                        </xf:trigger>
                        <xf:group appearance="bf:verticalTable">                      
                             <xf:switch>
                                <xf:case id="delete">
                                   <!-- don't display the delete trigger unless we have at lease one person -->
                                   <xf:trigger ref="instance()/transition[{$NODEPOS}]">
                                      <xf:label>delete transition</xf:label>
                                      <xf:action ev:event="DOMActivate">
                                         <xf:toggle case="confirm" />
                                      </xf:action>
                                   </xf:trigger>
                                </xf:case>
                                <xf:case id="confirm">
                                   <h2>Are you sure you want to delete this transition?</h2>
                                   <!--div id="content-for-deletion">
                                      <p>transition name: <xf:output ref="instance()/transition[{$NODEPOS}]/@title" /></p>
                                   </div-->
                                   <xf:group appearance="bf:horizontalTable">
                                       <xf:trigger>
                                          <xf:label>Delete</xf:label>
                                          <xf:action ev:event="DOMActivate">
                                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                            <xf:delete nodeset="instance()/transition[{$NODEPOS}]"/>
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
        </div>
};