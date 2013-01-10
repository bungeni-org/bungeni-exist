<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@tags">
        <xsl:element name="tags">
            <xsl:attribute name="originAttr">tags</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <tag>
                    <xsl:value-of select="."/>
                </tag>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>