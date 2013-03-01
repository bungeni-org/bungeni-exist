<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="include_tmpls.xsl" />
    
    <xsl:template match="field[@name='acronym']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">
                <xsl:text>acronym</xsl:text>
            </xsl:with-param>
        </xsl:call-template> 
    </xsl:template>      
    
    <xsl:template match="field[@name='quorum']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>quorom</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='group_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>groupId</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='parent_group_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>parentGroupId</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='group_continuity']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">groupContinuity</xsl:with-param>
        </xsl:call-template>
    </xsl:template> 
    
    <xsl:template match="field[@name='num_members']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>numMembers</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    <xsl:template match="field[@name='sub_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">subType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='committee_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>committeeId</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    <xsl:template match="field[@name='start_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>startDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    

    <xsl:template match="field[@name='end_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>endDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>    
    
    <xsl:template match="field[@name='min_num_members']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>minNumMembers</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='num_researchers']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">
                <xsl:text>numResearchers</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='group_principal_id']">
        <groupPrincipalId isA="TLCReference">
            <value type="xs:string">
                <xsl:value-of select="." />                
            </value>
        </groupPrincipalId>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='identifier']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">
                <xsl:text>identifier</xsl:text>
            </xsl:with-param>
        </xsl:call-template> 
    </xsl:template>     
    

    <xsl:template match="group_addresses">
        <groupAddresses>
            <xsl:apply-templates />    
        </groupAddresses>
    </xsl:template>      
    
    <xsl:template match="group_address[parent::group_addresses]">
        <groupAddress isA="TLCObject">
            <xsl:apply-templates />
        </groupAddress>
    </xsl:template>      
    
    <xsl:template match="members">
        <members id="groupMembers">
            <xsl:apply-templates />
        </members>
    </xsl:template>
    
    <xsl:template match="member[parent::members]">
        <member isA="TLCObject">
            <xsl:apply-templates />
        </member>
    </xsl:template>

  <!-- !+FIX_THIS parent group templates to be done -->

    <xsl:template match="parent_group">
        <xsl:if test="not(normalize-space(.))">
            <parentGroup>
                <xsl:apply-templates />
            </parentGroup>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>