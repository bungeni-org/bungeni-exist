<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_dates.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 17, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> Ashok</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <!-- These values are set in first input which is grouping_Level1 -->        
    <xsl:variable name="doc-uri" select="data(/ontology/document/@uri)" />
    <xsl:variable name="internal-doc-uri" select="data(/ontology/document/@internal-uri)" />
    
    <xsl:variable name="uri">
        <xsl:choose>
            <!-- if doc uri exists -->
            <xsl:when test="normalize-space($doc-uri) != ''">
                <xsl:value-of select="$doc-uri"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$internal-doc-uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="permissions[parent::change]">
        <xsl:variable name="parent-change-sequence-id"><xsl:value-of select="parent::change/auditId" /></xsl:variable> 
        <permissions id="change-permissions-{$parent-change-sequence-id}">
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    <xsl:template match="permissions[parent::version]">
        <xsl:variable name="parent-version-sequence-id"><xsl:value-of select="parent::version/sequence" /></xsl:variable> 
        <permissions id="version-permissions-{$parent-version-sequence-id}">
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    <xsl:template match="permissions[parent::attachment]">
        <xsl:variable name="parent-att-id"><xsl:value-of select="parent::attachment/attachmentId" /></xsl:variable> 
        <permissions id="attachment-permissions-{$parent-att-id}">
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    
    <xsl:template match="change[parent::changes/parent::document]">
        <xsl:variable name="change-xml-id" select="data(auditId)" />
        <change id="document-change-{$change-xml-id}">
            <refersToAudit>
                <xsl:attribute name="href"
                    select="concat('#document-audit-', $change-xml-id)" />
            </refersToAudit>
            <xsl:apply-templates />
        </change>
    </xsl:template>
    
    
    <xsl:template match="audit[parent::audits/parent::document]">
        <xsl:variable name="audit-xml-id" select="data(auditId)" />
        <audit id="document-audit-{$audit-xml-id}">
            <xsl:apply-templates />
        </audit>
    </xsl:template>
    
    
    <xsl:template match="version[parent::versions/parent::document]">
        <xsl:variable name="version-xml-id" select="data(auditId)">
        </xsl:variable>
        <xsl:copy>
            <xsl:attribute name="id" select="concat('document-version-',$version-xml-id)" />
            <xsl:attribute name="uri" select="concat($uri, '@', data(auditDate))" />
            <refersToAudit>
                <xsl:attribute name="href"
                    select="concat('#document-audit-', $version-xml-id)" />
            </refersToAudit>
            <refersToChange>
                <xsl:attribute name="href"
                    select="concat('#document-change-', $version-xml-id)" />
            </refersToChange>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
    
    
   <!-- The content of the workflow event is duplicated here the href points to the full 
       document -->
   <xsl:template match="workflowEvent">
       <xsl:copy>
           <xsl:variable name="event-docid" select="data(docId)" />
           <xsl:variable name="event-type" select="child::type/value" />
           <xsl:variable name="type-mappings" select="//custom/value" />
           <xsl:variable name="event-uri-name" 
               select="bctypes:get_content_type_uri_name($event-type, $type-mappings)" 
           />
           <xsl:variable name="legislature-full-uri" select="/custom/legislature-full-uri" />
           <xsl:attribute name="href">
               <xsl:value-of select="concat($internal-doc-uri, '/', $event-uri-name,'/', $event-docid)" />
           </xsl:attribute>
           <xsl:attribute name="isA" select="string('TLCEvent')" />
           <xsl:apply-templates />
       </xsl:copy>
   </xsl:template>
    
    
   <xsl:template match="custom" />
    
</xsl:stylesheet>