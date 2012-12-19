<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:custom="http://bungeni-exist.googlecode.com/custom_functions"
    exclude-result-prefixes="xsl custom"
    version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:include href="merge_tags.xsl" />
    <xsl:output indent="yes" />
    <xsl:strip-space elements="*" /> 
    
    
    <xsl:function name="custom:__get_modes_from_group">
        <xsl:param name="nodes" />
        <xsl:for-each select="$nodes">
            <xsl:value-of select="local-name()"></xsl:value-of>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="custom:get_modes_from_group">
        <xsl:param name="cur-group"></xsl:param>
        <xsl:value-of select="normalize-space(
            string-join(
                 custom:__get_modes_from_group($cur-group), 
                 ' '
                )
            )" />
    </xsl:function>
    
    <xsl:function name="custom:__get_roles_from_group">
        <xsl:param name="nodes" />
        <xsl:for-each select="$nodes">
            <xsl:value-of select="./roles/role"></xsl:value-of>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="custom:get_roles_from_group">
        <xsl:param name="cur-group"></xsl:param>
        <xsl:value-of select="normalize-space(
                string-join(
                    distinct-values(custom:__get_roles_from_group($cur-group)), 
                    ' '
                )
            )" />
    </xsl:function>
    
    
    
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
            <xsl:for-each-group select="./*[@show='true']" group-by="roles/role/text()">
                <show>
                    <xsl:attribute name="modes" select="custom:get_modes_from_group(current-group())" />
                    <xsl:variable name="roles-for-mode" select="custom:get_roles_from_group(current-group())" />
                    <xsl:if test="$roles-for-mode ne 'ALL'"> 
                        <xsl:attribute name="roles" select="custom:get_roles_from_group(current-group())" />
                    </xsl:if>
                </show>
            </xsl:for-each-group>
            <xsl:for-each-group select="./*[@show='false']" group-by="roles/role/text()">
                <hide>
                    <xsl:attribute name="modes" select="custom:get_modes_from_group(current-group())" />
                    <xsl:variable name="roles-for-mode" select="custom:get_roles_from_group(current-group())" />
                    <xsl:if test="$roles-for-mode ne 'ALL'"> 
                        <xsl:attribute name="roles" select="custom:get_roles_from_group(current-group())" />
                    </xsl:if>
                </hide>
            </xsl:for-each-group>
            
        </xsl:copy>
        
    </xsl:template>
    <xsl:template match="*[@originAttr]"></xsl:template>
    
</xsl:stylesheet>