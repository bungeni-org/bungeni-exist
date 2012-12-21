<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    <!-- What does this parameter do ? -->
    <xsl:param name="fname"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ui">
        <xsl:copy>
            <!-- Option to pass-in the form-id as a parameter from XQuery -->
            <xsl:variable name="wfname">
                <xsl:choose>
                    <xsl:when test="not($fname)">
                        <xsl:variable name="filename" select="tokenize(base-uri(),'/')"/>
                        <xsl:variable name="wfname" select="tokenize($filename[last()],'\.')"/>
                        <xsl:value-of select="$wfname[1]"/>
                    </xsl:when>
                    <!-- XQuery transform passed in a param -->
                    <xsl:when test="$fname">
                        <xsl:value-of select="$fname"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="name" select="$wfname"/>
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