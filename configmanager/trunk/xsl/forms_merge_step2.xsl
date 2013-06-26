<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:custom="http://bungeni-exist.googlecode.com/custom_functions" exclude-result-prefixes="xsl custom" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:output indent="yes" omit-xml-declaration="no"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*[. ne '']"/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="custom:__get_modes_from_group">
        <xsl:param name="nodes"/>
        <xsl:for-each select="$nodes">
            <xsl:value-of select="local-name()"/>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="custom:get_modes_from_group">
        <xsl:param name="cur-group"/>
        <xsl:value-of select="normalize-space(             string-join(              custom:__get_modes_from_group($cur-group),              ' '                 )             )"/>
    </xsl:function>
    <xsl:function name="custom:__get_roles_from_group">
        <xsl:param name="nodes"/>
        <xsl:for-each select="$nodes">
            <xsl:value-of select="./roles"/>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="custom:get_roles_from_group">
        <xsl:param name="cur-group"/>
        <xsl:value-of select="replace(normalize-space(             string-join(                 distinct-values(custom:__get_roles_from_group($cur-group)),                 ' '                 )             ),' ALL','')"/>
    </xsl:function>
    
    
    
    <!--
        Example :
        
        <show modes="add edit" />
        <show modes="listing" roles="Clerk" />
        <show modes="view" roles="MP" />
        
    -->
    <xsl:template match="field">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="./*[@show='true']" group-by="./roles/text()">
                <show>
                    <xsl:attribute name="modes" select="custom:get_modes_from_group(current-group())"/>
                    <xsl:variable name="roles-for-mode" select="custom:get_roles_from_group(current-group())"/>
                    <xsl:if test="$roles-for-mode ne 'ALL'">
                        <xsl:attribute name="roles" select="custom:get_roles_from_group(current-group())"/>
                    </xsl:if>
                </show>
            </xsl:for-each-group>
            <xsl:for-each-group select="./*[@show='false']" group-by="./roles/text()">
                <xsl:if test="not(parent::node()//@derived)">
                    <hide>
                        <xsl:attribute name="modes" select="custom:get_modes_from_group(current-group())"/>
                        <xsl:variable name="roles-for-mode" select="custom:get_roles_from_group(current-group())"/>
                        <xsl:if test="$roles-for-mode ne 'ALL'">
                            <xsl:attribute name="roles" select="custom:get_roles_from_group(current-group())"/>
                        </xsl:if>
                    </hide>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- suppress empty vocabulary, sort_on and derived attributes -->
    <xsl:template match="@vocabulary">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="vocabulary" select="."/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@sort_on">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="sort_on" select="."/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@derived">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="derived" select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>