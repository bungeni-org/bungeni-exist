<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- converts bungeni workflow to dotML -->
    
    <xsl:output indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="workflow">
        <graph file-name="{@name}" rankdir="LR" title="{@title}\n{@description}">
            <node id="start" label="Start" fontsize="9" fontname="Arial" />
            <xsl:apply-templates />
        </graph>
    </xsl:template>
    
    <xsl:template match="state">
        <node id="{@id}" label="{@title}" fontsize="9" fontname="Arial" />
    </xsl:template>
    
    
    <xsl:template match="transition">
            <!-- if the source is blank, we map it to the "start" node -->
            <xsl:variable name="from">
                <xsl:choose>
                    <xsl:when test="sources/source">
                        <xsl:value-of select="sources/source" />                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>start</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>  
            <xsl:variable name="title">
                  <xsl:value-of select="@title" />
            </xsl:variable>
            <xsl:variable name="constraint">
                <xsl:value-of select="@condition" />
            </xsl:variable>
            <xsl:for-each select="destinations/destination">
                <xsl:variable name="to" select="." />
                <edge from="{$from}" to="{$to}" label="{$title}" fontname="Arial" fontsize="9" >
                    <xsl:if test="$constraint ne ''">
                        <xsl:attribute name="constraint" select="$constraint" />
                    </xsl:if>
                </edge>
            </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="*[not(self::workflow) and not(self::transition) and not(self::state)]" />
    
</xsl:stylesheet>