xquery version "3.0";

import module namespace adm = "http://exist.bungeni.org/adm" at "admin.xqm";

(:
i18n Editor subform XForm
:)
declare namespace request = "http://exist-db.org/xquery/request";

let $lang := xs:string(request:get-parameter("cat",'new'))

return

<div xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
    <xf:model id="catalogue" ev:event="xforms-revalidate" ev:defaultAction="cancel">
        <xf:instance xmlns="" id="default">
            <catalogue>
                <msg key="">new msg string</msg>
            </catalogue>
        </xf:instance>
        <xf:bind id="b-msg-key" nodeset="@key" type="xs:string"/>
        <xf:bind id="b-msg" nodeset="." type="xs:string"/>
        <xf:submission id="s-load-self" resource="{concat('../../i18n/collection_',$lang,'.xml')}" replace="instance" method="get">
            <xf:message ev:event="xforms-submit-done" level="ephemeral">[{$lang}] catalogue loaded for editing</xf:message>
            <xf:action ev:event="xforms-submit-error">
                <xf:message level="ephemeral">Error - Loading catalogue</xf:message>
            </xf:action>
        </xf:submission>
        <xf:submission id="s-save-catalogue" resource="{concat('../../i18n/collection_',$lang,'.xml')}" replace="none" method="put">
            <xf:message ev:event="xforms-submit-done" level="ephemeral">[{$lang}] catalogue saved</xf:message>
            <xf:action ev:event="xforms-submit-error">
                <xf:message level="ephemeral">Sorry - your update failed.</xf:message>
            </xf:action>
        </xf:submission>
        <xf:send ev:event="xforms-ready" submission="s-load-self"/>
    </xf:model>
    <!-- subform to edit loaded route -->
    <xf:group appearance="full" class="subform-pane">
        <xf:action ev:event="betterform-variable-changed" ev:observer="ui-config"/>
        <xf:repeat id="messages" nodeset="msg">        
            <!--xf:label id="editing-subform">Add language catalogue</xf:label>
            <xf:input bind="b-msg-key">
                <xf:hint>Name that will be shown on left listing</xf:hint>
                <xf:help>This is what will be name field on the HTML form.</xf:help>
                <xf:label>Name</xf:label>
            </xf:input>
            <xf:input bind="b-msg">
                <xf:hint>Internal ID</xf:hint>
                <xf:help>Mainly used by function that creates the tabs at runtime.</xf:help>
                <xf:label>Unique ID</xf:label>
            </xf:input-->        
            <xf:input ref=".">
                <xf:label id="lbl-b-msg">
                    <xf:output id="lbl-b-msgstrg" ref="@key" incremental="true">
                        <xf:hint>a Hint for this control</xf:hint>
                        <xf:help>help for output1</xf:help>
                        <xf:alert>invalid</xf:alert>
                    </xf:output>
                </xf:label>
            </xf:input>            
        </xf:repeat>
        <xf:group appearance="minimal" class="configsTriggerGroup buttons-pane">
            <xf:trigger class="configsSubTrigger buttons-inline">
                <xf:label>add a message string</xf:label>
                <xf:hint>Add a new message string to above list.</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">New Message String Form Added...</xf:message>
                    <xf:insert nodeset="msg[last()]" at="last()" origin="instance('default')/msg[last()]" ev:event="DOMActivate"/>
                </xf:action>
            </xf:trigger>
            <xf:trigger class="configsSubTrigger">
                <xf:label>delete selected</xf:label>
                <xf:hint>Delete the Selected row in a form.</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Deleting selected message string...</xf:message>
                    <xf:delete nodeset="msg" at="index('messages')" ev:event="DOMActivate"/>
                </xf:action>
            </xf:trigger>
            →   
            <!--xf:trigger appearance="triggerMiddleColumn">
                <xf:label>apply changes</xf:label>
                <xf:hint>Click apply to update the document with all changes made</xf:hint>
                <xf:delete nodeset="orderby/@default"/>
                <xf:insert nodeset="orderby[last()]" ev:event="DOMActivate"/>
                <xf:send submission="s-update-catalogue"/>
            </xf:trigger-->
            <xf:trigger class="configsSubTrigger">
                <xf:label>save catalogue changes</xf:label>
                <xf:hint>Save all your changes back to the configuratiuon document</xf:hint>
                <xf:action>
                    <xf:message level="ephemeral">Saving Document...</xf:message>
                    <xf:send submission="s-save-catalogue"/>
                </xf:action>
            </xf:trigger>
        </xf:group>
    </xf:group>
    <br/>
    <br/>
</div>