<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Form XML (ui , custom) to a more usable XML format
    -->
    <xsl:include href="split_attr_roles.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:param name="fname"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
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
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template> 
    

    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@modes | @roles"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="@modes">
        <xsl:element name="modes">
            <xsl:attribute name="originAttr">modes</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <mode>
                    <xsl:value-of select="."/>
                </mode>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>