<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template name="incl_legislature">
        <xsl:param name="leg-uri"></xsl:param>
        <xsl:param name="leg-election-date"></xsl:param>
        <xsl:param name="leg-identifier"></xsl:param>
        <legislature isA="TLCConcept" href="{$leg-uri}">
            <electionDate type="xs:date" select="{$leg-election-date}" />
            <identifier type="xs:string" key="true"><xsl:value-of select="$leg-identifier" /></identifier>
        </legislature>
    </xsl:template>
    
    
    <xsl:template name="incl_origin">
        <xsl:param name="parl-id"></xsl:param>
        <xsl:param name="parl-identifier"></xsl:param>
        <xsl:if test="$parl-id">
            <origin>
                <internalID type="xs:string" key="true"><xsl:value-of select="$parl-id" /></internalID>
                <identifier type="xs:string" isA="TLCTerm"><xsl:value-of select="$parl-identifier" /></identifier>
            </origin>
        </xsl:if>    
    </xsl:template>
    
</xsl:stylesheet>