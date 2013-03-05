<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"
    xmlns:xbf="http://bungeni.org/xslt/functions" exclude-result-prefixes="xs bctype" version="2.0">

    <!-- INCLUDE FUNCTIONS -->
    <xsl:include href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl"/>
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_tmpls.xsl" />
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 11, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Anthony</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <!-- these are input parameters to the transformation a-->
    
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_params.xsl" />
    
    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:function name="xbf:parse-date">
        <xsl:param name="input-date"/>
        <xsl:variable name="arrInputDate" select="tokenize($input-date,'\s+')"/>
        <xsl:sequence select="concat($arrInputDate[1],'T',$arrInputDate[2])"/>
    </xsl:function>

    <xsl:template match="contenttype">

        <xsl:variable name="parl-info" select="concat('/',$country-code,'/',$for-parliament,'/')"/>
        
        <!-- this identifies the type of group committee, parliament etc .-->
        <xsl:variable name="bungeni-debaterecord-type" select="@name"/>
        <!-- we map internal group type names to configured mapped name types -->
        <xsl:variable name="group-element-name"
            select="bctype:get_content_type_element_name($bungeni-debaterecord-type, $type-mappings)"/>
        <xsl:variable name="content-type-uri-name"
            select="bctype:get_content_type_uri_name($bungeni-debaterecord-type, $type-mappings)"/>

        <xsl:variable name="debate_record_id" select="field[@name='debate_record_id']"/>

        <ontology for="debateRecord">
            <debateRecord id="bungeniDebateRecord" isA="TLCConcept">
                <xsl:attribute name="for" select="$group-element-name"/>

                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="field[@name='language']"/>
                </xsl:attribute>

                <!-- !+URI_GENERATOR,!+FIX_THIS(ah,nov-2011) use ontology uri
                    for group since its non-document entity -->
                <xsl:attribute name="uri"
                    select="concat('/ontology',$parl-info,$content-type-uri-name,'/',$debate_record_id)"/>

                <xsl:attribute name="id" select="$debate_record_id"/>

                <xsl:call-template name="incl_origin">
                    <xsl:with-param name="parl-id" select="$parliament-id" />
                    <xsl:with-param name="parl-identifier" select="$parliament-identifier" />
                </xsl:call-template>
                
                <docType isA="TLCTerm">
                    <value type="xs:string">
                        <xsl:value-of select="$content-type-uri-name"/>
                    </value>
                </docType>

                <xsl:copy-of
                    select="field[ @name='parent_group_id' or 
                    @name='debate_record_id' or 
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
                    venue | 
                    reports"/>

                <xsl:copy-of select="sitting | permissions | contained_groups"/>
            </debateRecord>
            
            <xsl:call-template name="incl_legislature">
                <xsl:with-param name="leg-uri" select="$legislature-uri" />
                <xsl:with-param name="leg-election-date" select="$legislature-election-date" />
                <xsl:with-param name="leg-identifier" select="$legislature-identifier" />
            </xsl:call-template>
            
            
            <legislature isA="TLCConcept" href="{$for-parliament}">
                <electionDate type="xs:date" select="{$parliament-election-date}"/>
                <xsl:copy-of
                    select="field[  
                    @name='short_name' or 
                    @name='parliament_id' or 
                    @name='type' or 
                    @name='dissolution_date' or 
                    @name='results_date' or 
                    @name='status_date' ] | agenda_items | parent_group | group"
                />
            </legislature>
            <bungeni id="bungeniMeta" showAs="Bungeni Specific info" isA="TLCObject">
                <xsl:attribute name="id" select="$parliament-id"/>
                <xsl:copy-of select="field[  
                    @name='language' ]"/>
                <xsl:copy-of select="tags"/>
            </bungeni>

            <!--    !+FIX_THIS (ao, jan 2012. Some address documents for individuals like clerk dont have 'type' field and 
                this broke the pipeline processor
                
                <xsl:element name="{$group-element-name}">
                <xsl:attribute name="isA">TLCOrganization</xsl:attribute>
                <xsl:attribute name="refersTo" select="concat('#', $debate_record_id)" />
                </xsl:element>
            -->
            <custom>
                <xsl:copy-of select="$type-mappings"/>
                <bungeni_grp_type>
                    <xsl:value-of select="$bungeni-debaterecord-type"/>
                </bungeni_grp_type>
            </custom>
        </ontology>
    </xsl:template>

</xsl:stylesheet>
