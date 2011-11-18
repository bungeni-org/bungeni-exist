<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:nav="http://www.bungeni/org/eXistPortal" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs nav" version="2.0">
    <xsl:import href="config.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Tabs on a Documents</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:template name="doc-tabs">
        <xsl:param name="tab-group"/>
        <xsl:param name="tab-path"/>
        <xsl:param name="uri"/>
        <xsl:call-template name="tab-generator">
            <xsl:with-param name="group" select="$tab-group"/>
            <xsl:with-param name="tab" select="$tab-path"/>
            <xsl:with-param name="uri" select="$uri"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="mem-tabs">
        <xsl:param name="tab-group"/>
        <xsl:param name="tab-path"/>
        <xsl:param name="uri"/>
        <xsl:call-template name="tab-generator">
            <xsl:with-param name="group" select="$tab-group"/>
            <xsl:with-param name="tab" select="$tab-path"/>
            <xsl:with-param name="uri" select="$uri"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="tab-generator">
        <xsl:param name="group"/>
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:for-each select="xqcfg:get_tab($group)/tab">
                    <xsl:choose>
                        <xsl:when test="@id = $tab">
                            <li class="active">
                                <a href="{@path}?uri={$uri}#">
                                    <xsl:value-of select="./title"/>
                                </a>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <a href="{@path}?uri={$uri}">
                                    <xsl:value-of select="./title"/>
                                </a>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
</xsl:stylesheet>