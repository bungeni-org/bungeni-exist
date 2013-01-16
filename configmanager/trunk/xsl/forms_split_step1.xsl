<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ui">
        <xsl:copy>
            <!-- xsl:apply-templates select="@*" mode="preserve" /-->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="field" priority="3">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <modes>
                <xsl:apply-templates select="node()"/>
            </modes>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>