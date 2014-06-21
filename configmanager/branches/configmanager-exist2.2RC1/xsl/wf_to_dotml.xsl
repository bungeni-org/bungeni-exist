<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.martin-loetzsch.de/DOTML" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <!-- converts bungeni workflow to dotML -->
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="workflow">
        <graph ranksep="0.1" nodesep="0.1" file-name="{@name}" rankdir="TB" title="{@title}\n{@description}">
            <node id="start" label="Start" fontsize="9" fontname="Arial"/>
            <xsl:apply-templates/>
        </graph>
    </xsl:template>
    <xsl:template match="state">
        <node id="{@id}" label="{@title}" fontsize="9" fontname="Arial"/>
    </xsl:template>
    <xsl:template match="transition">
            <!-- if the source is blank, we map it to the "start" node -->
        <!--
            <xsl:variable name="to">
                <xsl:choose>
                    <xsl:when test="destinations/destination">
                        <xsl:value-of select="sources/source" />                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>start</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>  
        -->
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="@condition[. ne '']">
                    <xsl:value-of select="concat(@title, '\n', 'constraint=', @condition)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="to" select="destinations/destination"/>
        <xsl:choose>
            <xsl:when test="sources/source">
                <xsl:for-each select="sources/source">
                    <xsl:variable name="from" select="."/>
                    <xsl:choose>
                        <xsl:when test="$from eq ''">
                            <edge from="start" to="{$to}" label="{$title}" fontname="Arial" fontsize="9"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <edge from="{$from}" to="{$to}" label="{$title}" fontname="Arial" fontsize="9"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <edge from="start" to="{$to}" label="{$title}" fontname="Arial" fontsize="9"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*[not(self::workflow) and not(self::transition) and not(self::state)]"/>
</xsl:stylesheet>