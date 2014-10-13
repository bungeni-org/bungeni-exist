<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:param name="parliament-info" />
    <xsl:param name="type-mappings" />
    
    <xsl:variable name="bungeni-type" select="/contenttype/field[@name='type']" />
    <xsl:variable name="principal-name" select="/contenttype/field[@name='principal_name']" />
    
    <xsl:variable name="country-code" >
        <xsl:value-of select="$parliament-info/parliaments/countryCode" />
    </xsl:variable>
   
    <xsl:variable name="legislature" select="$parliament-info/parliaments/parliament[@id = '0']" />
    
    <xsl:variable name="legislature-identifier">
        <xsl:value-of select="$legislature/identifier" />
    </xsl:variable>

    <xsl:variable name="legislature-start-date">
        <xsl:value-of select="$legislature/startDate" />
    </xsl:variable>
    
    <xsl:variable name="legislature-election-date">
        <xsl:value-of select="$legislature/electionDate" />
    </xsl:variable>

    <xsl:variable name="uri-base"
        select="concat('/ontology/', $country-code)" />

    <xsl:variable name="legislature-type-name"
        select="string('Legislature')" />

    <xsl:variable name="parliament-type-name"
        select="string('Chamber')" />
    
    
    <xsl:variable name="legislature-uri" 
        select="concat('/', $legislature-type-name,'/', $legislature-identifier)" />
    
    <xsl:variable name="legislature-full-uri"
        select="concat($uri-base, $legislature-uri)" /> 
    
    <xsl:variable name="origin-parliament">
        <xsl:value-of select="/contenttype/field[@name='origin_chamber']" />    
    </xsl:variable>
    
    <xsl:variable name="is_in_legislature">
        <xsl:choose>
            <xsl:when test="/contenttype/parent_group/field[@name='type'][. eq 'legislature']">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="current-parliament" 
        select="$parliament-info/parliaments/parliament[@id eq $origin-parliament]" />
    
    <xsl:variable name="parliament-id">
        <xsl:choose>
            <xsl:when test="$bungeni-type eq 'legislature'">
                <xsl:value-of select="xs:string('NOT_APPLICABLE')" />
            </xsl:when>
            <xsl:when test="$bungeni-type eq 'chamber'">
                <xsl:value-of select="$principal-name" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$is_in_legislature eq 'true'">
                        <!-- this must be in legislature -->
                        <xsl:value-of select="$parliament-info/parliaments/parliament[@id eq '0']/identifier" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$current-parliament/@id" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="parliament-identifier">
        <xsl:choose>
            <xsl:when test="$bungeni-type eq 'legislature'">
                <xsl:value-of select="xs:string('NOT_APPLICABLE')" />
            </xsl:when>
            <xsl:when test="$bungeni-type eq 'chamber'">
                <xsl:value-of select="$principal-name" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                   <xsl:when test="$is_in_legislature eq 'true'">
                       <xsl:value-of select="$parliament-info/parliaments/parliament[@id eq '0']/identifier" />
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="$current-parliament/identifier" />
                   </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable> 
    
    <xsl:variable name="parliament-uri">
        <xsl:value-of select="concat(
            '/', $parliament-type-name, 
            '/',$parliament-identifier
            )" />
    </xsl:variable>
    
    <xsl:variable name="parliament-full-uri">
       <xsl:choose>
           <xsl:when test="$is_in_legislature eq 'true'">
               <xsl:value-of select="$legislature-full-uri" />
           </xsl:when>
           <xsl:otherwise>
               <xsl:value-of select="concat(
                   $legislature-full-uri, 
                   $parliament-uri
                   )" />
           </xsl:otherwise>
       </xsl:choose> 
    </xsl:variable>
    
    <xsl:variable name="for-parliament">
        <xsl:value-of select="$current-parliament/forParliament" />
    </xsl:variable>
    
    <xsl:variable name="parliament-election-date">
        <xsl:value-of select="$current-parliament/electionDate" />
    </xsl:variable>
    
    <xsl:variable name="parliament-type">
        <xsl:value-of select="$current-parliament/type" />
    </xsl:variable>
    
    <xsl:variable name="parliament-type-display">
        <xsl:value-of select="$current-parliament/type/@displayAs" />
    </xsl:variable>
    
    
    
</xsl:stylesheet>
