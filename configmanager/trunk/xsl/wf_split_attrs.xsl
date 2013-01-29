<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Workflow XML to a more usable XML format
        Update: currently updated to bungeni_custom r10268
    -->
    <xsl:include href="split_attr_tags.xsl"/>
    <xsl:include href="split_attr_roles.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:param name="docname"/>
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <xsl:copy>
            <!-- Option to pass-in the form-id as a parameter from XQuery -->
            <xsl:variable name="wfname">
                <xsl:choose>
                    <xsl:when test="not($docname)">
                        <xsl:variable name="filename" select="tokenize(base-uri(),'/')"/>
                        <xsl:variable name="wfname" select="tokenize($filename[last()],'\.')"/>
                        <xsl:value-of select="$wfname[1]"/>
                    </xsl:when>
                    <!-- XQuery transform passed in a param -->
                    <xsl:when test="$docname">
                        <xsl:variable name="wfname" select="tokenize($docname[last()],'\.')"/>
                        <xsl:value-of select="$wfname[1]"/>
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
    <xsl:template mode="preserve" match="@tags | @roles | @source | @destination | @permission_actions"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <!-- 
        !+NOTE (ao, 13th Dec 2012)
        Adding an empty @permissions_from_state and @order attributes for XForms
        XForms cannot provide a control for a node/attribute that do not provide 
        the node/attribute in the first place. This has to be replicated on entire document.
    -->
    <xsl:template match="state">
        <xsl:copy>
            <xsl:if test="not(@permissions_from_state)">
                <xsl:attribute name="permissions_from_state"/>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="transition">
        <xsl:copy>
            <xsl:if test="not(@order)">
                <xsl:attribute name="order">0</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@require_confirmation)">
                <xsl:attribute name="require_confirmation">false</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
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