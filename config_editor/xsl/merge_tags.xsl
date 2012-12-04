<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template name="merge_tags">
        <xsl:param name="elemOriginAttr"/>
        <xsl:variable name="attrName" select="$elemOriginAttr/@originAttr"/>
        <xsl:attribute name="{$attrName}">
            <xsl:for-each select="$elemOriginAttr/*">
                <xsl:choose>
                    <xsl:when test="position() eq last()">
                        <xsl:value-of select="concat(., '')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(., ' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>