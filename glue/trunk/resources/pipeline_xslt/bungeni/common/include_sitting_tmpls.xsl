<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="include_tmpls.xsl"/>
    
    <xsl:template match="item_schedule[parent::item_schedule]">
        <schedule>
            <xsl:apply-templates />
        </schedule>
    </xsl:template>    
    
    <xsl:template match="field[@name='item_uri']">
        <bungeniUri type="xs:anyURI">
            <xsl:value-of select="." />
        </bungeniUri>
    </xsl:template>
    
    <xsl:template match="field[@name='item_title']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName" >title</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='planned_order']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName" >plannedOrder</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='real_order']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName" >realOrder</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='schedule_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">scheduleId</xsl:with-param>
            <xsl:with-param name="key">true</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='item_mover']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">scheduleId</xsl:with-param>
            <xsl:with-param name="key">
                <xsl:value-of select="true()" />
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    
    <!--
        <bu:field name="item_uri">/bungeni/ke/bill/2013-03-04
        13:18:33.157998/15:7-bill/en@/main</bu:field>
        <bu:sittingId key="true" type="xs:integer">12</bu:sittingId>
        <bu:field name="item_title">#4: Bi98709870987ll - cosignatory - scheduling first
        reading AS_01</bu:field>
        <bu:field name="planned_order">1</bu:field>
        <bu:itemvotes/>
        <bu:field name="item_type">bill</bu:field>
        <bu:field name="schedule_id">17</bu:field>
        <bu:field name="real_order">1</bu:field>
        <bu:field name="item_mover">Mrs member AS_01</bu:field>
        <bu:itemId type="xs:integer"/>69<bu:discussions>
        
    -->
    
    <xsl:template match="item_schedule[child::item_schedule]">
        <schedules>
            <xsl:apply-templates />
        </schedules>
    </xsl:template>
    
    <xsl:template match="itemdiscussions">
        <discussions>
            <xsl:apply-templates />
        </discussions>
    </xsl:template>
    
    <xsl:template match="itemdiscussion">
        <discussion>
            <xsl:apply-templates />
        </discussion>
    </xsl:template>
    
    <xsl:template match="field[@name='sitting_id'][parent::sitting]">
        <sittingId key="true" type="xs:integer">
            <xsl:apply-templates />
        </sittingId>
    </xsl:template>
    
    <xsl:template match="field[@name='sitting_id'][parent::item_schedule]" />
    
</xsl:stylesheet>