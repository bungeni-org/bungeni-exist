<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"
    xmlns:bstrings="http://www.bungeni.org/xml/strings/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="func_content_types.xsl" />
    <xsl:import href="func_strings.xsl" />
    <xsl:import href="include_tmpls.xsl"/>
    
    
    <xsl:template match="sa_events">
       <xsl:if test="normalize-space(.) ne ''">
        <workflowEvents>
            <xsl:apply-templates mode="parent_is_events" />
        </workflowEvents>
       </xsl:if>    
    </xsl:template>
    
    
    
    <xsl:template match="sa_events[parent::document]">
        <xsl:if test="normalize-space(.) ne ''">
        <workflowEvents id="documentEvents">
            <xsl:apply-templates mode="parent_is_events" />
        </workflowEvents>
        </xsl:if>     
    </xsl:template>
    
    
    
    <xsl:template match="sa_event" mode="parent_is_events">
        <workflowEvent 
            isA="TLCEvent"
            showAs="{field[@name='title']}" 
            >
            <xsl:apply-templates />
        </workflowEvent>
    </xsl:template>
    
    <xsl:template match="audits[parent::document]">
        <audits id="documentAudits">
            <xsl:apply-templates />
        </audits>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='action']">
        <auditAction isA="TLCEvent">
            <value type="xs:string">
                <xsl:value-of select="." />
            </value>
        </auditAction>
    </xsl:template>
    
    <xsl:template match="change[parent::audit]">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- generic matcher for extended fields -->
    <xsl:template match="*[starts-with(name(), '_vp_')]">
        <xsl:variable name="ext-field-value" select="data(field[@name='value'])" />
        <xsl:variable name="ext-field-name" select="data(field[@name='name'])" />
       <xsl:variable name="ccase-name" select="bstrings:uscorename-to-camel-case($ext-field-name)" />
        <xsl:element name="{$ccase-name}">
            <xsl:attribute name="type">xs:string</xsl:attribute>
            <xsl:value-of select="$ext-field-value" />
        </xsl:element>
    </xsl:template>
    

    <xsl:template match="field[@name='audit_id'][parent::audit] | field[@name='audit_id'][parent::change[parent::changes]] | field[@name='audit_id'][parent::version]">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">auditId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>   
    
    <xsl:template match="field[@name='audit_id'][parent::change[parent::audit]]" />
        
    
    
    
    <xsl:template match="field[@name='seq']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">sequence</xsl:with-param>
        </xsl:call-template>   
        
    </xsl:template>
    
    <xsl:template match="changes[parent::document]">
        <changes id="documentChanges">
            <xsl:apply-templates />
        </changes>
    </xsl:template>
    
    
    <xsl:template match="field[@name='procedure']">
        <procedureType isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </procedureType>
    </xsl:template>
    
    <xsl:template match="_vp_response_type">
        <responseType isA="TLCTerm">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <value type="xs:string">
                <xsl:value-of select="field[@name='value']" />
            </value>
        </responseType>
    </xsl:template>
    
    
    <xsl:template match="field[@name='response_text']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">responseText</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>
    
    
    <xsl:template match="field[@name='att_hash']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">attachmentHash</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>
    
    
    <xsl:template match="field[@name='doc_type']">
        <docSubType isA="TLCTerm">
            <xsl:if test="@displayAs">
                <xsl:attribute name="showAs" select="@displayAs"/>
            </xsl:if>
            <value type="xs:string"><xsl:value-of select="." /></value>
        </docSubType>
    </xsl:template>    
    
    <xsl:template match="field[@name='type_number']" >
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">progressiveNumber</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>
    
    <xsl:template match="field[@name='item_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">itemId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>     
    
    
    
    <xsl:template match="field[@name='registry_number']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">registryNumber</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>    
    
    <xsl:template match="field[@name='change_id']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">changeId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>    
    
    <xsl:template match="field[@name='manual']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">manual</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>     
    
    
    <xsl:template match="field[@name='long_title']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">longTitle</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>  
    
    
    
    <xsl:template match="field[@name='audit_type']">
        <auditFor isA="TLCTerm">
            <value type="xs:string">
                <xsl:variable name="type-mappings" select="//custom/value" />
                <xsl:value-of select="bctypes:get_content_type_element_name(., $type-mappings)" />
            </value>
        </auditFor>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='mimetype']">
        <mimetype isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </mimetype>
    </xsl:template>   
    
    <xsl:template match="field[@name='note']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">changeNote</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>   
    
    
    <xsl:template match="field[@name='response_type']">
        <docResponseType isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </docResponseType>
    </xsl:template>   
    
    
    <xsl:template match="field[@name='head_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">headId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>   
    
    <xsl:template match="field[@name='event_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>eventDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    
    <xsl:template match="field[@name='submission_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>submissionDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    <xsl:template match="field[@name='uri']">
        <bungeniUri type="xs:anyURI">
            <xsl:value-of select="." />
        </bungeniUri>
    </xsl:template>
    
    <xsl:template match="field[@name='coverage']">
         <xsl:call-template name="renderStringElement">
             <xsl:with-param name="elementName">coverage</xsl:with-param>
         </xsl:call-template>   
    </xsl:template>
    
    
    <xsl:template match="field[@name='subject']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">subject</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>
    
    
    <xsl:template match="field[@name='ministry_submit_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>ministrySubmittedDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>   

    <xsl:template match="field[@name='admissible_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>admissibleDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    
    <xsl:template match="item_signatories">
       <signatories id="documentSignatories">
        <xsl:apply-templates />
       </signatories>
    </xsl:template>
    
    
    <xsl:template match="item_signatory">
       <signatory>
           <xsl:attribute name="id">
               <xsl:variable name="signatory_id" select="field[@name='signatory_id']" />
               <xsl:value-of select="concat('signatory-', $signatory_id)" />
           </xsl:attribute>
        <xsl:apply-templates />
       </signatory>
    </xsl:template>
    
    <xsl:template match="attachments">
        <attachments id="documentAttachments">
            <xsl:apply-templates />
        </attachments>
    </xsl:template>
    
    <xsl:template match="attachment[parent::attachments]">
        <attachment>
            <xsl:attribute name="id">
                <xsl:variable name="attachment_id" select="field[@name='attachment_id']" />
                <xsl:value-of select="concat('attachment-', $attachment_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </attachment>
    </xsl:template>   
</xsl:stylesheet>