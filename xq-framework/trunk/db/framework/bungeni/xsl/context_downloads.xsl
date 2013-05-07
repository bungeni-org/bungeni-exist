<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:nav="http://www.bungeni/org/eXistPortal" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs nav" version="2.0">
    <xsl:import href="config.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 14, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Document download formats</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:template name="doc-formats">
        <xsl:param name="render-group"/>
        <xsl:param name="doc-type"/>
        <xsl:param name="chamber"/>
        <xsl:param name="uri"/>
        <xsl:call-template name="formats-renderer">
            <xsl:with-param name="render-group" select="$render-group"/>
            <xsl:with-param name="doc-type" select="$doc-type"/>
            <xsl:with-param name="chamber" select="$chamber"/>
            <xsl:with-param name="uri" select="$uri"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="formats-renderer">
        <xsl:param name="render-group"/>
        <xsl:param name="doc-type"/>
        <xsl:param name="chamber"/>
        <xsl:param name="uri"/>
        <div id="doc-downloads">
            <ul class="ls-downloads">
                <xsl:for-each select="xqcfg:get_downloadgroups($render-group)/format">
                    <xsl:choose>
                        <xsl:when test="$uri eq 'null'">
                            <li>
                                <a href="{$chamber}{$doc-type}s/{@type}" class="{@type}" title="{text()}">
                                    <em>
                                        <xsl:value-of select="upper-case(@type)"/>
                                    </em>
                                </a>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <a href="{$chamber}{$doc-type}/{@type}?uri={$uri}" class="{@type}" title="{text()}">
                                    <em>
                                        <xsl:value-of select="upper-case(@type)"/>
                                    </em>
                                </a>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
</xsl:stylesheet>