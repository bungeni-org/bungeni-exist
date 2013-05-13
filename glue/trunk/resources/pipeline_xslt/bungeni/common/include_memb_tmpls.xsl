<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="include_tmpls.xsl" />
    
    <xsl:template match="field[@name='membership_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">membershipId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>    
    
    <xsl:template match="field[@name='title_type_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">designationDefinitionId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>  
    
    <xsl:template match="field[@name='member_title_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">designationId</xsl:with-param>
        </xsl:call-template>   
    </xsl:template>  
    
    
    <!-- this has the bungeni "type" name and is standardized across all documents -->
    <xsl:template match="field[@name='member_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='election_nomination_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>electionNominationDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='election_date']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>electionDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='election_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">memberElectionType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='party']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">party</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='user_unique']">
        <userUnique type="xs:boolean" showAs="{data(@displayAs)}">
            <xsl:variable name="user_unique">
                <xsl:value-of select="." />
            </xsl:variable>
            <xsl:value-of select="lower-case($user_unique)" />
        </userUnique>
    </xsl:template>  
    
    <xsl:template match="field[@name='sort_order']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">sortOrder</xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    <xsl:template match="field[@name='title_name']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">titleName</xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    <xsl:template match="member_titles">
        <designations>
            <xsl:apply-templates />
        </designations>
    </xsl:template>    
    
    <xsl:template match="member_title">
        <designation isA="TLCRole">
            <xsl:apply-templates />
        </designation>
    </xsl:template>

    <xsl:template match="title_type">
        <desiginationDefinition isA="TLCTerm">
            <xsl:apply-templates />
        </desiginationDefinition>
    </xsl:template>    
    
    
    <xsl:template match="representation">
        <representations id="memberRepresentation">
            <xsl:apply-templates />
        </representations>
    </xsl:template>
    
    <xsl:template match="field[@name='representation']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">representation</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
    
    <xsl:template match="titletypes">
        <desiginationDefinitions>
            <xsl:apply-templates />
        </desiginationDefinitions>
    </xsl:template>    
    
    <xsl:template match="titletype">
        <desiginationDefinition isA="TLCTerm">
            <xsl:apply-templates />
        </desiginationDefinition>
    </xsl:template>    
    -->
    
    <xsl:template match="title_type[parent::member_title]" >
        <xsl:apply-templates />
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>