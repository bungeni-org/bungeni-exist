<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Anthony Oduor
        25 Jun 2013
        Transforms from ConfigManager format into proper Bungeni Notification XML
    -->
    <xsl:output indent="yes" omit-xml-declaration="yes" method="xml"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="notifications">
        <xsl:element name="notifications">
            <xsl:for-each-group select="notify" group-by="@roles">
                <xsl:variable name="as-name" select="current-grouping-key()"/>
                <xsl:if test="normalize-space(@onstate) ne ''">
                    <xsl:element name="notify">
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
                    </xsl:element>
                </xsl:if>
                <xsl:if test="normalize-space(@afterstate) ne ''">
                    <xsl:element name="notify">
                        <xsl:attribute name="roles">
                            <xsl:for-each select="current-group()">
                                <xsl:value-of select="tokenize(@roles, '\s+')"/>
                            </xsl:for-each>
                        </xsl:attribute>
                        <xsl:attribute name="afterstate">
                            <xsl:for-each select="current-group()">
                                <xsl:value-of select="tokenize(@afterstate, '\s+')"/>
                            </xsl:for-each>
                        </xsl:attribute>
                        <xsl:if test="normalize-space(@time) ne ''">
                            <xsl:attribute name="time">
                                <xsl:for-each select="current-group()">
                                    <xsl:value-of select="tokenize(@time, '\s+')"/>
                                </xsl:for-each>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
                <xsl:apply-templates select="@* | node()"/>
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