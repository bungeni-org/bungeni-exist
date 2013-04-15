<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"    
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bctype"
    version="2.0">
    
    <!-- INCLUDE FUNCTIONS -->
    <xsl:include href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />    
    <xsl:include href="resources/pipeline_xslt/bungeni/common/func_dates.xsl" />    
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_tmpls.xsl" />
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 24, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- these are input parameters to the transformation a-->
    <!-- these are input parameters to the transformation a-->
    
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_params.xsl" />
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="contenttype">
        
        <!-- this identifies the type of group committee, parliament etc .-->
        <xsl:variable name="bungeni-content-type" select="@name" />
        <!-- we map internal group type names to configured mapped nam types -->
        <xsl:variable name="group-element-name" select="bctype:get_content_type_element_name($bungeni-content-type, $type-mappings)" />
        <xsl:variable name="content-type-uri-name" select="bctype:get_content_type_uri_name($bungeni-content-type, $type-mappings)" />        
        <xsl:variable name="group_id" select="field[@name='group_id']" />
        
        <xsl:variable name="group-type" select="group/field[@name='type']" />
        <xsl:variable name="group-type-uri-name" select="bctype:get_content_type_uri_name($group-type, $type-mappings)" />
        
        <xsl:variable name="group-identifier" select="group/field[@name='identifier']" />
        <xsl:variable name="group-uri">
            <xsl:choose>
                <xsl:when test="$group-type eq 'parliament'">
                    <xsl:value-of select="$parliament-full-uri" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($parliament-full-uri, '/', $group-type-uri-name, '/', $group-identifier)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="start-date" select="bdates:parse-date(field[@name='start_date'])" />
        <xsl:variable name="end-date" select="bdates:parse-date(field[@name='end_date'])" />
        
        <!--xsl:variable name="sitting-session" select="concat(
            bdates:parse-date(field[@name='start_date']),';',
            xbf:parse-date(field[@name='end_date']))" -->
        <xsl:variable name="sitting_id" select="field[@name='sitting_id']" />
        <ontology for="sitting">
            <sitting id="bungeniSitting" isA="TLCConcept">
                <xsl:attribute name="for" select="$group-element-name" />
                
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="field[@name='language']" />
                </xsl:attribute>                 
                
                <xsl:attribute name="uri" >
                    <xsl:value-of select="concat(
                        $group-uri, 
                        '/', 
                        $content-type-uri-name, 
                        '/', 
                        $start-date,
                        '/',
                        $end-date
                        )" /> 
                </xsl:attribute>
                

                <xsl:attribute name="internal-uri" >
                    <xsl:value-of select="concat(
                        $group-uri, 
                        '/', 
                        $content-type-uri-name, 
                        '/', 
                        $sitting_id
                        )" /> 
                </xsl:attribute>
                
                <xsl:attribute name="unique-id">
                    <xsl:choose>
                        <xsl:when test="$group-type eq 'parliament'">
                            <xsl:value-of select="concat(
                                $legislature-type-name, '.', $legislature-identifier, 
                                '-', 
                                $parliament-type-name, '.', $parliament-id, 
                                '-',
                                $content-type-uri-name, '.', $sitting_id
                                )" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(
                                $legislature-type-name, '.', $legislature-identifier, 
                                '-', 
                                $parliament-type-name, '.', $parliament-id, 
                                '-',
                                $group-type-uri-name, '.', $group_id, 
                                '-',
                                $content-type-uri-name, '.', $sitting_id
                                )" />
                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                <sittingOf isA="TLCObject">
                    <refersTo isA="TLCReference"  href="{$group-uri}">
                        <type isA="TLCTerm">
                            <value type="xs:string">
                                <xsl:value-of select="$group-type-uri-name" />
                            </value>
                        </type>
                    </refersTo>
                </sittingOf>
 
                <xsl:call-template name="incl_origin">
                    <xsl:with-param name="parl-id" select="$parliament-id" />
                    <xsl:with-param name="parl-identifier" select="$parliament-identifier" />
                </xsl:call-template>
                
                <docType isA="TLCTerm">
                    <value type="xs:string"><xsl:value-of select="$content-type-uri-name" /></value>
                </docType> 

                <!-- inject a type field so the type parameter gets rendered -->
                <field name="type"><xsl:value-of select="$bungeni-content-type" /></field>
                
                <xsl:copy-of select="field[ 
                    @name='short_name' or 
                    @name='sitting_id' or
                    @name='parent_group_id' or 
                    @name='min_num_members' or 
                    @name='num_researchers' or 
                    @name='num_members' or 
                    @name='quorum' or 
                    @name='start_date' or 
                    @name='end_date' or 
                    @name='venue_id' or 
                    @name='meeting_type' or 
                    @name='convocation_type' or 
                    @name='activity_type' or 
                    @name='status' or 
                    @name='election_date' ] | 
                    group_addresses | 
                    item_schedule | 
                    item_discussions |
                    venue |
                    permissions |
                    reports |
                    sa_attendance
                    " 
                />
                
            </sitting>
            
            <xsl:call-template name="incl_legislature">
                <xsl:with-param name="leg-uri" select="$legislature-full-uri" />
                <xsl:with-param name="leg-election-date" select="$legislature-election-date" />
                <xsl:with-param name="leg-identifier" select="$legislature-identifier" />
            </xsl:call-template>
            <xsl:call-template name="incl_chamber">
                <xsl:with-param name="parl-uri" select="$parliament-full-uri" />
                <xsl:with-param name="parl-id" select="$parliament-id" />
                <xsl:with-param name="elect-date" select="$parliament-election-date" />
                <xsl:with-param name="country-code" select="$country-code" />
                <xsl:with-param name="type" select="$parliament-type" />
                <xsl:with-param name="type-display" select="$parliament-type-display" />
            </xsl:call-template>
            
            <!--
            <chamber isA="TLCConcept" href="{$parliament-full-uri}">
                <electionDate type="xs:date" select="{$parliament-election-date}"></electionDate>
                <xsl:copy-of select="field[  
                    @name='short_name' or 
                    @name='parliament_id' or 
                    @name='type' or 
                    @name='dissolution_date' or 
                    @name='results_date' or 
                    @name='status_date' ] | agenda_items | parent_group | group" 
                />             
            </chamber>
            -->
            <bungeni id="bungeniMeta" showAs="Bungeni Specific info" isA="TLCObject">
                <xsl:attribute name="id" select="$parliament-id"/>
                <xsl:copy-of select="field[  
                    @name='language' ]" 
                />
                <xsl:copy-of select="tags" />
            </bungeni> 
            
            <!--    !+FIX_THIS (ao, jan 2012. Some address documents for individuals like clerk dont have 'type' field and 
                this broke the pipeline processor
                
                <xsl:element name="{$group-element-name}">
                <xsl:attribute name="isA">TLCOrganization</xsl:attribute>
                <xsl:attribute name="refersTo" select="concat('#', $group_id)" />
                </xsl:element>
            -->
            <custom>
                <xsl:copy-of select="$type-mappings" />
                <bungeni_doc_type>
                    <xsl:value-of select="$bungeni-content-type"/>
                </bungeni_doc_type>
                <uri-base><xsl:value-of select="$uri-base" /></uri-base>
                <legislature-uri><xsl:value-of select="$legislature-uri" /></legislature-uri>
                <parliament-uri><xsl:value-of select="$parliament-uri" /></parliament-uri>
                <legislature-full-uri><xsl:value-of select="$legislature-full-uri" /></legislature-full-uri>
                <parliament-full-uri><xsl:value-of select="$parliament-full-uri" /></parliament-full-uri>
            </custom>            
        </ontology>
    </xsl:template>
    
</xsl:stylesheet>