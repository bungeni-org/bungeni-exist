<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="func_dates.xsl" />
    <xsl:import href="func_content_types.xsl" />
    
    
    
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
    
    <xsl:template match="field[@name='date_audit']">
        <auditDate type="xs:dateTime">
            <xsl:variable name="audit_date" select="." />
            <xsl:value-of select="bdates:parse-date($audit_date)" />
        </auditDate>
    </xsl:template> 
    
    
    
    <xsl:template match="field[@name='audit_id']">
        <auditId type="xs:integer">
            <xsl:value-of select="." />
        </auditId>
    </xsl:template>   
    
    
    
    <xsl:template match="field[@name='seq']">
        <sequence type="xs:integer"><xsl:value-of select="." /></sequence>    
    </xsl:template>
    
    <xsl:template match="field[@name='date_active']">
        <activeDate type="xs:dateTime">
            <xsl:variable name="active_date" select="." />
            <xsl:value-of select="bdates:parse-date($active_date)" />
        </activeDate>
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
            <value isA="TLCTerm">
                <xsl:value-of select="field[@name='value']" />
            </value>
        </responseType>
    </xsl:template>
    
    
    <xsl:template match="field[@name='response_text']">
        <responseText>
            <xsl:apply-templates />
        </responseText>
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
        <xsl:if test=". ne 'None'">
            <progressiveNumber type="xs:integer"><xsl:value-of select="." /></progressiveNumber>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="field[@name='item_id']">
        <itemId type="xs:integer">
            <xsl:value-of select="." />
        </itemId>
    </xsl:template>     
    
    
    
    <xsl:template match="field[@name='registry_number']">
        <registryNumber type="xs:string">
            <xsl:value-of select="." />
        </registryNumber>
    </xsl:template>    
    
    <xsl:template match="field[@name='change_id']">
        <changeId type="xs:string">
            <xsl:value-of select="." />
        </changeId>
    </xsl:template>    
    
    <xsl:template match="field[@name='manual']">
        <manual>
            <xsl:value-of select="." />
        </manual>
    </xsl:template>     
    
    
    <xsl:template match="field[@name='long_title']">
        <longTitle type="xs:string">
            <xsl:value-of select="." />
        </longTitle>
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
        <xsl:if test=". ne 'None'">
            <changeNote type="xs:string">
                <xsl:value-of select="." />
            </changeNote>
        </xsl:if>
    </xsl:template>   
    
    
    <xsl:template match="field[@name='response_type']">
        <docResponseType isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </docResponseType>
    </xsl:template>   
    
    
    <xsl:template match="field[@name='head_id']">
        <headId type="xs:integer">
           <xsl:value-of select="." />
        </headId>
    </xsl:template>   
    
</xsl:stylesheet>