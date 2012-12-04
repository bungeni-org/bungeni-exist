<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:import href="merge_tags.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <workflow>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./tags"/>
            </xsl:call-template>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./permActions"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*|node()"/>
        </workflow>
    </xsl:template>
    <xsl:template match="state">
        <state>
            <xsl:if test="./tags">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./tags"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </state>
    </xsl:template>
    <xsl:template match="allow | deny">
        <xsl:element name="{name()}">
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="transition">
        <xsl:element name="transition">
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./sources"/>
            </xsl:call-template>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./destinations"/>
            </xsl:call-template>
            <xsl:if test="./roles">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./roles"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="permActions[@originAttr] | roles[@originAttr]  | sources[@originAttr] | destinations[@originAttr] | tags[@originAttr]"/>
</xsl:stylesheet>