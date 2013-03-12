<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="func_dates.xsl"/>
    
    <!-- This File includes ONLY callable templates and should NOT include matcher templates -->
    
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
    
    <xsl:template name="renderDateElement">
        <xsl:param name="elementName" />
        <xsl:variable name="val-normalized" select="normalize-space(.)" />
        <xsl:if test="$val-normalized ne ''">
            <xsl:if test="$val-normalized ne 'None'">
                <xsl:element name="{$elementName}">
                    <xsl:attribute name="type">
                        <xsl:text>xs:dateTime</xsl:text>
                    </xsl:attribute>
                    <xsl:variable name="date_value" select="." />
                    <xsl:value-of select="bdates:parse-date($date_value)" />
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template> 
    
    
    <xsl:template name="renderStringElement">
        <xsl:param name="elementName" />
        <xsl:variable name="nsp" select="normalize-space(.)" />
        <xsl:if test="$nsp ne ''">
            <xsl:if test="$nsp ne 'None'">
                <xsl:element name="{$elementName}">
                    <xsl:attribute name="type">
                        <xsl:text>xs:string</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:if>
        </xsl:if>  
    </xsl:template>
    
    <xsl:template name="renderUriElement">
        <xsl:param name="elementName" />
        <xsl:variable name="nsp" select="normalize-space(.)" />
        <xsl:if test="$nsp ne ''">
            <xsl:if test="$nsp ne 'None'">
                <xsl:element name="{$elementName}">
                    <xsl:attribute name="type">
                        <xsl:text>xs:anyURI</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:if>
        </xsl:if>  
    </xsl:template>
    
    

    <xsl:template name="renderIntegerElement">
        <xsl:param name="elementName" />
        <xsl:param name="key" select="string('false')" />
        <xsl:variable name="nsp" select="normalize-space(.)" />
        <xsl:if test="$nsp ne ''">
            <xsl:if test="$nsp ne 'None'">
                <xsl:element name="{$elementName}">
                    <xsl:if test="$key eq 'true'">
                        <xsl:attribute name="key">
                            <xsl:text>true</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="type">
                        <xsl:text>xs:integer</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:if>
        </xsl:if>  
    </xsl:template>
    
    
    
    <xsl:template name="renderTLCTermString">
        <xsl:param name="elementName" />
        <xsl:variable name="nsp" select="normalize-space(.)" />
        <xsl:if test="$nsp ne ''">
            <xsl:element name="{$elementName}">
                <xsl:attribute name="isA">TLCTerm</xsl:attribute>
                <xsl:if test="@displayAs">
                    <xsl:attribute name="showAs"><xsl:value-of select="@displayAs" /></xsl:attribute>
                </xsl:if>
                <value type="xs:string">
                    <xsl:value-of select="." />
                </value>            
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template name="address">
        <address isA="TLCObject">
            <xsl:attribute name="id">
                <xsl:variable name="address_id" select="field[@name='address_id']" />
                <xsl:value-of select="concat('address-', $address_id)" />
            </xsl:attribute>
            <xsl:apply-templates />
        </address>
    </xsl:template>
    
    
</xsl:stylesheet>