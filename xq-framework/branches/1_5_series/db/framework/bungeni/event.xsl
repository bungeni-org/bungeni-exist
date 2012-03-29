<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 18, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Event for Parliamentary Document from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="document">
        <xsl:variable name="event_uri" select="event"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/@uri"/>
        <xsl:variable name="moevent_uri" select="primary/bu:ontology/bu:legislativeItem/bu:owner/@href"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue" style="text-align:right">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    <br/>
                    <span style="color:#b22b14">
                        <xsl:value-of select="secondary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    </span>
                </h1>
            </div>
            <ul class="ls-doc-tabs"/>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="#" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this document" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as ODT document" class="odt">
                            <em>ODT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as RTF document" class="rtf">
                            <em>RTF</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="rounded-eigh tab_container hanging-menu">
                        <ul class="doc-versions">
                            <xsl:if test="primary/bu:ontology/bu:legislativeItem/@uri">
                                <li>
                                    <a href="{primary/bu:ontology/bu:document/@type}/text?uri={primary/bu:ontology/bu:legislativeItem/@uri}">
                                        <i18n:text key="list-tab-cur">current(nt)</i18n:text>
                                    </a>
                                </li>
                            </xsl:if>
                            <xsl:variable name="total_versions" select="count(primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent)"/>
                            <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent">
                                <xsl:sort select="bu:statusDate" order="descending"/>
                                <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                                <li>
                                    <xsl:choose>
                                        <!-- if current URI is equal to this versions URI -->
                                        <xsl:when test="$event_uri eq @href">
                                            <span>
                                                <i18n:text key="doc-event">event(nt)</i18n:text> -<xsl:value-of select="$cur_pos"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a href="{$doc-type}/event?uri={@href}">
                                                <i18n:text key="doc-event">event(nt)</i18n:text> -<xsl:value-of select="$cur_pos"/>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <h3 id="doc-heading" class="doc-headers hang-left-titles">
                        <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS --> KENYA
                        PARLIAMENT </h3>
                    <h4 id="doc-item-desc" class="doc-headers hang-left-titles">
                        <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent[@href=$event_uri]/bu:shortName"/>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>
                                <i18n:text key="last-event">Last Event(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="secondary/bu:ontology/bu:legislativeItem/bu:status"/>
                        </span>
                        <span>
                            <b>
                                <i18n:text key="status">Status(nt)</i18n:text>
                                &#160;<i18n:text key="date-on">Date(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-dateTime(secondary/bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="secondary/bu:ontology/bu:legislativeItem/bu:body"/>
                        </div>
                        <!-- TO_BE_REVIEWED -->
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>