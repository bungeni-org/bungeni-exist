<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> MP Personal Information from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">activities</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-table-wrapper">
                        <xsl:choose>
                            <xsl:when test="ref/bu:ontology">
                                <div id="toggle-wrapper" class="clear toggle-wrapper">
                                    <div id="toggle-i18n" class="hide">
                                        <span id="i-compress">
                                            <i18n:text key="compress">▼&#160;compress all(nt)</i18n:text>
                                        </span>
                                        <span id="i-expand">
                                            <i18n:text key="expand">►&#160;expand all(nt)</i18n:text>
                                        </span>
                                    </div>
                                    <div class="toggler-list" id="expand-all">▼&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
                                    </div>
                                </div>
                                <ul id="list-toggle" class="ls-row clear">
                                    <xsl:for-each select="ref/bu:ontology">
                                        <xsl:sort select="bu:document/bu:statusDate" order="descending"/>
                                        <li>
                                            <xsl:value-of select="format-dateTime(bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                                            <div class="struct-ib">&#160;/ 
                                                
                                                <xsl:variable name="eventOf" select="bu:document/bu:eventOf/bu:type/bu:value"/>
                                                <xsl:variable name="doc-uri">
                                                    <xsl:choose>
                                                        <xsl:when test="bu:document/@uri">
                                                            <xsl:value-of select="bu:document/@uri"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="bu:document/@internal-uri"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="doc-type" select="bu:document/bu:docType/bu:value"/>
                                                <xsl:choose>
                                                    <xsl:when test="$doc-type = 'Event'">
                                                        <xsl:variable name="event-href" select="bu:document/@uri"/>
                                                        <a href="{lower-case($eventOf)}-event?uri={$event-href}">
                                                            <xsl:value-of select="bu:document/bu:title"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="{lower-case($doc-type)}-text?uri={$doc-uri}">
                                                            <xsl:value-of select="bu:document/bu:title"/>
                                                        </a>
                                                    </xsl:otherwise>
                                                </xsl:choose> / 
                                                <xsl:value-of select="bu:document/bu:docType/bu:value"/>
                                            </div>
                                            <span class="tgl-pad-right">▼</span>
                                            <div class="doc-toggle">
                                                <div style="min-height:50px;">
                                                    <div class="block grey-full">
                                                        <span class="labels">
                                                            <i18n:text key="relation">relation(nt)</i18n:text>:</span>
                                                        <span>
                                                            <xsl:choose>
                                                                <xsl:when test="$doc-uri = data(bu:document/bu:owner/bu:person/@href)">
                                                                    owner
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    sponsor
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                    </div>
                                                    <div class="block grey-full">
                                                        <span class="labels">
                                                            <i18n:text key="status">status(nt)</i18n:text>:</span>
                                                        <span>
                                                            <xsl:value-of select="if (data(bu:document/bu:status/@showAs)) then data(bu:document/bu:status/@showAs) else bu:document/bu:status/bu:value"/>
                                                        </span>
                                                    </div>
                                                </div>
                                                <div class="clear"/>
                                            </div>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text key="none">none(nt)</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>