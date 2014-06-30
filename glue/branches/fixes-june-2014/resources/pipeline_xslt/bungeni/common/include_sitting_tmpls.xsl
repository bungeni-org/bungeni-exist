<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="include_tmpls.xsl"/>
    <xsl:include href="func_content_types.xsl" />    
    
    <xsl:variable name="parliament-full-uri" select="//custom/parliament-full-uri" />
    <xsl:variable name="type-mappings" select="//custom/value" />  
    
    <xsl:template match="item_schedule[parent::item_schedule]">
        <scheduleItem>
            <xsl:attribute name="id">
                <xsl:variable name="schedule_id" select="field[@name='schedule_id']" />
                <xsl:value-of select="concat('schedule-',$schedule_id)" />
            </xsl:attribute>
            <xsl:variable name="item-type">
                <xsl:variable name="item_type" select="field[@name='item_type']" />
                <xsl:value-of select="bctype:get_content_type_uri_name($item_type, $type-mappings)" />
            </xsl:variable>
            <xsl:variable name="item_id" select="field[@name='item_id']" />
            <sourceItem isA="TLCObject" >
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
    
    <xsl:template match="itemvotes">
        <votes>
            <xsl:attribute name="id">
                <xsl:variable name="schedule_id" select="parent::item_schedule/field[@name='schedule_id']" />
                <xsl:value-of select="concat('votes-',$schedule_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </votes>
    </xsl:template>
    
    <xsl:template match="itemvote">
        <vote>
            <xsl:attribute name="id">
                <xsl:variable name="vote_id" select="child::field[@name='vote_id']"></xsl:variable>
                <xsl:variable name="schedule_id" select="ancestor::item_schedule/field[@name='schedule_id']"></xsl:variable>
                <xsl:value-of select="concat('schedule-', $schedule_id, '-', 'vote-', $vote_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </vote>
    </xsl:template>
    
    
    <xsl:template match="field[@name='votes_against']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">votesAgainst</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='votes_for']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">votesFor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='cast_votes']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">castVotes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='votes_abstained']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">abstainedVotes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template match="field[@name='eligible_votes']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">eligibleVotes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='issue_item']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">issueItem</xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    <xsl:template match="field[@name='issue_sub_item']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">issueSubItem</xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    <xsl:template match="field[@name='document_uri']">
        <xsl:call-template name="renderUriElement">
            <xsl:with-param name="elementName">documentUri</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='result']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">outcome</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='majority_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">majorityType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='question']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">question</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='time']">
        <time type="xs:time">
            <xsl:value-of select="." />
        </time>
    </xsl:template>
    
    <xsl:template match="field[@name='vote_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">voteId</xsl:with-param>
            <xsl:with-param name="key">true</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template match="field[@name='vote_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">voteType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='attendance_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">attendanceType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='activity_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">activityType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='item_type']" />
    
    <xsl:template match="field[@name='active']">
        <active type="xs:boolean">
            <xsl:choose>
                <xsl:when test=". eq 'True'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </active>
    </xsl:template>
    
    <xsl:template match="field[@name='type_document']">
        <typeDocument type="xs:boolean">
            <xsl:choose>
                <xsl:when test=". eq 'True'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </typeDocument>
    </xsl:template>    
    
    <xsl:template match="field[@name='type_heading']">
        <typeHeading type="xs:boolean">
            <xsl:choose>
                <xsl:when test=". eq 'True'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </typeHeading>
    </xsl:template>   
    
    <xsl:template match="field[@name='is_type_text_record']">
        <isTypeTextRecord type="xs:boolean">
            <xsl:choose>
                <xsl:when test=". eq 'True'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </isTypeTextRecord>
    </xsl:template>      
    
    <xsl:template match="field[@name='real_item_type']">
        <xsl:call-template name="renderUriElement">
            <xsl:with-param name="elementName">realItemType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>    
    
    <xsl:template match="field[@name='item_uri']">
        <xsl:call-template name="renderUriElement">
            <xsl:with-param name="elementName">bungeniUri</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='item_title']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName" >title</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='planned_order']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">plannedOrder</xsl:with-param>
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
        <scheduleItems id="bungeniScheduleItems">
            <xsl:apply-templates />
        </scheduleItems>
    </xsl:template>
    
    <xsl:template match="itemdiscussions">
      <xsl:if test="normalize-space(.) ne ''">  
        <discussions>
            <xsl:attribute name="id">
                <xsl:variable name="schedule_id" select="parent::item_schedule/field[@name='schedule_id']" />
                <xsl:value-of select="concat('discussion-', $schedule_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </discussions>
      </xsl:if>   
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
       <reports id="bungeniReports">
        <xsl:apply-templates />
       </reports>
    </xsl:template>
    
    <xsl:template match="report[parent::reports]">
        <xsl:apply-templates select="child::report"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="report[parent::report]">
        <report>
            <xsl:attribute name="id">
                <xsl:value-of select="concat('report-', parent::report/field[@name='report_id'])" />
            </xsl:attribute>
            <xsl:attribute name="href" select="concat(
                $parliament-full-uri, '/',
                bctype:get_content_type_uri_name(field[@name='type'], $type-mappings), '/',
                field[@name='doc_id']
                )" />
            <xsl:apply-templates select="parent::report/field[@name='report_id']" />
            <xsl:apply-templates />
        </report>
    </xsl:template>
    
    <xsl:template match="field[@name='meeting_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">meetingType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='convocation_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">convocationType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name='venue_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">venueId</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='report_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">reportId</xsl:with-param>
            <xsl:with-param name="key">true</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template match="field[@name='sitting_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">sittingId</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='member_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">memberId</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    

    <xsl:template match="field[@name='sitting_id'][parent::item_schedule]" />


</xsl:stylesheet>