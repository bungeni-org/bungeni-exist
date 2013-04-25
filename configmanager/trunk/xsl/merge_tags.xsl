<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template name="merge_tags">
        <xsl:param name="elemOriginAttr"/>
        <!-- by default does not echo empty -->
        <xsl:param name="checkEmptyAttribute" select="1"/>
        <xsl:variable name="attrName" select="$elemOriginAttr/@originAttr"/>
        <!-- check if there are any non empty child elements -->
        <xsl:choose>
            <xsl:when test="$checkEmptyAttribute eq 0">
                <!-- do not check for empty attribute -->
                <xsl:call-template name="emit-attribute">
                    <xsl:with-param name="attrName" select="$attrName"/>
                    <xsl:with-param name="elemOriginAttr" select="$elemOriginAttr"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$elemOriginAttr/*[. ne '']">
                    <xsl:call-template name="emit-attribute">
                        <xsl:with-param name="attrName" select="$attrName"/>
                        <xsl:with-param name="elemOriginAttr" select="$elemOriginAttr"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="emit-attribute">
        <xsl:param name="attrName"/>
        <xsl:param name="elemOriginAttr"/>
        <xsl:attribute name="{$attrName}">
            <xsl:for-each select="$elemOriginAttr/*">
                <xsl:choose>
                    <!-- Remove 'ALL' role which does not have to be written back -->
                    <xsl:when test=". eq 'ALL'"/>
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