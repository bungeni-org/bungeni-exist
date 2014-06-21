<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Anthony Oduor
        21 Jun 2013
        Transforms Bungeni Notification XML to a more usable XML format on the ConfigManager
    -->
    <xsl:output indent="yes"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="notifications">
        <xsl:element name="notifications">
            <xsl:for-each-group select="notify" group-by="@roles">
                <xsl:element name="notify">
                    <xsl:variable name="as-name" select="current-grouping-key()"/>
                    <xsl:attribute name="roles">
                        <xsl:for-each select="current-group()">
                            <xsl:value-of select="tokenize(@roles, '\s+')"/>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:attribute name="onstate">
                        <xsl:for-each select="current-group()">
                            <xsl:value-of select="tokenize(concat(@onstate,' '),'\s+')"/>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:attribute name="afterstate">
                        <xsl:for-each select="current-group()">
                            <xsl:value-of select="tokenize(@afterstate, '\s+')"/>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:attribute name="time">
                        <xsl:for-each select="current-group()">
                            <xsl:value-of select="tokenize(@time, '\s+')"/>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:apply-templates select="@roles" mode="preserve"/>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template> 
    
    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>