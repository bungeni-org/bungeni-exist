<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Workspace XML to a more usable XML format
    -->
    <xsl:include href="split_attr_roles.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workspace">
        <xsl:copy>
            <xsl:variable name="fname" select="tokenize(base-uri(),'/')"/>
            <xsl:variable name="wfname" select="tokenize($fname[last()],'\.')"/>
            <xsl:attribute name="name" select="$wfname[1]"/>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@roles"/> 
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="@*"/>
    
</xsl:stylesheet>