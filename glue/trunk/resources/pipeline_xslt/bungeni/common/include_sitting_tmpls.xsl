<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="include_tmpls.xsl"/>
    <xsl:include href="func_content_types.xsl" />    
    
    
    <xsl:template match="item_schedule[parent::item_schedule]">
        <scheduleItem>
            <xsl:attribute name="id">
                <xsl:variable name="schedule_id" select="field[@name='schedule_id']" />
                <xsl:value-of select="concat('schedule-',$schedule_id)" />
            </xsl:attribute>
            <xsl:variable name="parliament-full-uri" select="//custom/parliament-full-uri" />
            <xsl:variable name="type-mappings" select="//custom/value" />
            <xsl:variable name="item-type">
                <xsl:variable name="item_type" select="field[@name='item_type']" />
                <xsl:value-of select="bctype:get_content_type_uri_name($item_type, $type-mappings)" />
            </xsl:variable>
            <xsl:variable name="item_id" select="field[@name='item_id']" />
            <sourceItem isA="TLCObject" href="{concat($parliament-full-uri, '/', $item-type, '/', $item_id )}" >
                <refersTo isA="TLCReference" href="{concat($parliament-full-uri, '/', $item-type, '/', $item_id )}" >
                    <type isA="TLCTerm">
                        <value type="xs:string">
                            <xsl:value-of select="$item-type" />
                        </value>
                    </type>
                </refersTo>
            </sourceItem>
            <xsl:apply-templates />
        </scheduleItem>
    </xsl:template>    
    
    <xsl:template match="field[@name='item_type']" />
    
    <xsl:template match="field[@name='active']">
        <active type="xs:boolean">
            <xsl:choose>
                <xsl:when test=". eq 'True'">
                    true
                </xsl:when>
                <xsl:otherwise>
                    false
                </xsl:otherwise>
            </xsl:choose>
        </active>
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
    
    
    
    <xsl:template match="field[@name='item_mover']" />
    
    
    
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
        <scheduleItems>
            <xsl:apply-templates />
        </scheduleItems>
    </xsl:template>
    
    <xsl:template match="itemdiscussions">
        <discussions>
            <xsl:apply-templates />
        </discussions>
    </xsl:template>
    
    <xsl:template match="itemdiscussion">
        <discussion>
            <xsl:attribute name="id">
                <xsl:variable name="discussion_id" select="field[@name='discussion_id']" />
                <xsl:value-of select="concat('discussion-', $discussion_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </discussion>
    </xsl:template>
    
    <xsl:template match="field[@name='discussion_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">discussionId</xsl:with-param>
            <xsl:with-param name="key">true</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='sitting_id'][parent::sitting]">
        <sittingId key="true" type="xs:integer">
            <xsl:apply-templates />
        </sittingId>
    </xsl:template>
    
    <xsl:template match="sa_attendance[child::sa_attendance]">
        <attendanceRecords>
            <xsl:apply-templates />
        </attendanceRecords>
    </xsl:template>
    
    <xsl:template match="sa_attendance[parent::sa_attendance]">
        <attendanceRecord>
            <xsl:apply-templates />
        </attendanceRecord>
    </xsl:template>
    
    <xsl:template match="reports">
       <reports>
        <xsl:apply-templates />
       </reports>
    </xsl:template>
    
    <xsl:template match="report[parent::reports]">
        <report>
            <xsl:apply-templates />
        </report>
    </xsl:template>
    
    <xsl:template match="report[parent::report]">
        <reportInfo>
            <xsl:apply-templates />
        </reportInfo>
    </xsl:template>
    
    
    

    <xsl:template match="field[@name='sitting_id'][parent::item_schedule]" />


</xsl:stylesheet>