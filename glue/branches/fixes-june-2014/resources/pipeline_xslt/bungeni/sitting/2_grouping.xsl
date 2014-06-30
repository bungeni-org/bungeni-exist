<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_users.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_identity.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_common.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_user_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_group_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_memb_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_pi_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_sitting_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_suppress.xsl"/>
    
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 24, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    
    <xsl:template match="custom" />
    
    <!--
    <xsl:template match="field[@name='venue_id']">
        <venueId type="xs:integer">
            <xsl:value-of select="." />
        </venueId>
    </xsl:template>     
    
    <xsl:template match="field[@name='report_id']">
        <reportId type="xs:integer">
            <xsl:value-of select="." />
        </reportId>
    </xsl:template>     
    
    <xsl:template match="field[@name='meeting_type']">
        <meetingType isA="TLCObject">
            <value isA="TLCTerm">
                <xsl:attribute name="showAs" select="@displayAs"/>
                <xsl:value-of select="." />                
            </value>
        </meetingType>
    </xsl:template>
    
    <xsl:template match="field[@name='item_type']">
        <itemType isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="bctypes:get_content_type_uri_name(., $type-mappings)" />                
            </value>
        </itemType>
    </xsl:template>    
    
    <xsl:template match="field[@name='convocation_type']">
        <convocationType isA="TLCObject">
            <value isA="TLCTerm">
                <xsl:attribute name="showAs" select="@displayAs"/>
                <xsl:value-of select="." />                
            </value>
        </convocationType>
    </xsl:template>
    
    <xsl:template match="field[@name='activity_type']">
        <activityType isA="TLCProcess">
            <value isA="TLCTerm">
                <xsl:attribute name="showAs" select="@displayAs"/>
                <xsl:value-of select="." />                
            </value>
        </activityType>
    </xsl:template>
    
    <xsl:template match="field[@name='type']">
        <type isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="." />                
            </value>
        </type>
    </xsl:template>      
    
    <xsl:template match="field[@name='user_id']">
        <userId type="xs:integer">
            <xsl:value-of select="." />
        </userId>
    </xsl:template> 
    
    <xsl:template match="field[@name='sitting_id']">
        <sittingId type="xs:integer">
            <xsl:value-of select="." />
        </sittingId>
    </xsl:template>     

    
    
    
    <xsl:template match="field[@name='group_sitting_id']">
        <groupSittingId type="xs:integer">
            <xsl:value-of select="." />
        </groupSittingId>
    </xsl:template>
    
    <xsl:template match="field[@name='planned_order']">
        <plannedOrder type="xs:integer">
            <xsl:value-of select="." />
        </plannedOrder>
    </xsl:template>
    
    <xsl:template match="field[@name='proportional_representation']">
        <proportionalRepresentation  type="xs:boolean">
            <xsl:value-of select="." />
        </proportionalRepresentation>
    </xsl:template>  
    -->
</xsl:stylesheet>