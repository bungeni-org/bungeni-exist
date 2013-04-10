<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="workflow">
        <xsl:element name="workflow">
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="permActions" />
            <xsl:for-each-group select="facet[starts-with(@name, 'global_')]" group-by="@name">
                <xsl:variable name="facet-name" select="current-grouping-key()" />
                <facet name="{$facet-name}">
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates  />
                    </xsl:for-each>
                </facet>
            </xsl:for-each-group>
            <xsl:apply-templates select="*[not(name() eq 'facet') and not(name() eq 'permActions')]|text()|processing-instruction()|comment()" />
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>