<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:include href="merge_tags.xsl" />
    <xsl:output indent="yes" />
    <xsl:strip-space elements="*" /> 
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="ui/@name"></xsl:template>
    
    <xsl:template match="ui">
        <ui>
            
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles" />
            </xsl:call-template>
            
            <xsl:apply-templates select="@*|node()"/>
            
        </ui>
    </xsl:template>
    
    <xsl:template match="field">
        <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:variable name="show-modes" select="data(./*[@show='true']/local-name())" />     
        <xsl:variable name="show-roles" select="data(distinct-values(./*[@show='true']/roles/role))" />     
        <xsl:variable name="hide-modes" select="data(./*[@show='false']/local-name())" />     
        <xsl:variable name="hide-roles" select="data(distinct-values(./*[@show='false']/roles/role))" />
        <xsl:if test="$show-modes != ''">
            <show modes="{$show-modes}">
                <xsl:choose>
                    <xsl:when test="contains($show-roles, 'ALL')">
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="roles" select="$show-roles" />
                    </xsl:otherwise>
                </xsl:choose>
            </show>
        </xsl:if>
        <xsl:if test="$hide-modes != ''">
            <hide modes="{$hide-modes}">
                <xsl:choose>
                    <xsl:when test="contains($hide-roles, 'ALL')">
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="roles" select="$hide-roles" />
                    </xsl:otherwise>
                </xsl:choose>
            </hide>
        </xsl:if>
        </xsl:copy>
        
    </xsl:template>
    <xsl:template match="*[@originAttr]"></xsl:template>
    
</xsl:stylesheet>