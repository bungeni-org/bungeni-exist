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
    <xsl:template match="descriptor" priority="1">
        <xsl:copy>
            <xsl:if test="not(@label)">
                <xsl:attribute name="label"/>
            </xsl:if>
            <xsl:if test="not(@container_label)">
                <xsl:attribute name="container_label"/>
            </xsl:if>
            <xsl:if test="not(@sort_on)">
                <xsl:attribute name="sort_on"/>
            </xsl:if>
            <xsl:if test="not(@sort_dir)">
                <xsl:attribute name="sort_dir"/>
            </xsl:if>
            <xsl:if test="not(@name)">
                <xsl:attribute name="name" select="replace(tokenize(base-uri(),'/')[last()], '.xml', '')" />
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="field" priority="3">
        <xsl:copy>
            <!-- 
                !+NOTE (ao, 22nd March 2013) ensure all fields have
                have a @vocabulary attribute by putting blank one on those 
                that don't have.
            -->
            <xsl:if test="not(field/@vocabulary)">
                <xsl:attribute name="vocabulary"/>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <modes>
                <xsl:apply-templates select="node()"/>
            </modes>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="container">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:if test="not(@name)">
                <xsl:attribute name="name" />
            </xsl:if>
            <xsl:if test="not(@note)">
                <xsl:attribute name="note" />
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>