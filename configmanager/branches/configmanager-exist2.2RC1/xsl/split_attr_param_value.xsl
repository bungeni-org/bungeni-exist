<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@value[parent::parameter]">
        <xsl:element name="values">
            <xsl:attribute name="originAttr">value</xsl:attribute>
            <xsl:for-each select="tokenize(normalize-space(.), '\s+')">
                <value>
                    <xsl:value-of select="."/>
                </value>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>