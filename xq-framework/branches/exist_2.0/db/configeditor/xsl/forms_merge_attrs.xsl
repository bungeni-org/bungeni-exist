<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
        -->
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ui/@name"/>
    <xsl:template match="ui">
        <ui>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*|node()"/>
        </ui>
    </xsl:template>
    <xsl:template match="show | hide">
        <xsl:element name="{name()}">
            <xsl:if test="./modes">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./modes"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="./roles">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./roles"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*[@originAttr]"/>
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