<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Workflow XML to a more usable XML format
        -->
    <xsl:output indent="yes"/>
    <xsl:param name="docname"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <xsl:copy>
            <xsl:attribute name="document-name" select="$docname"/>
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
    <xsl:template mode="preserve" match="@tags | @roles | @source | @destination | @permission_actions"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="@tags">
        <xsl:element name="tags">
            <xsl:attribute name="originAttr">tags</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <tag>
                    <xsl:value-of select="."/>
                </tag>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@roles">
        <xsl:element name="roles">
            <xsl:attribute name="originAttr">roles</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <role>
                    <xsl:value-of select="."/>
                </role>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@source">
        <xsl:element name="sources">
            <xsl:attribute name="originAttr">source</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <source>
                    <xsl:value-of select="."/>
                </source>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@destination">
        <xsl:element name="destinations">
            <xsl:attribute name="originAttr">destination</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <destination>
                    <xsl:value-of select="."/>
                </destination>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@permission_actions">
        <xsl:element name="permActions">
            <xsl:attribute name="originAttr">permission_actions</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <permAction>
                    <xsl:value-of select="."/>
                </permAction>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>