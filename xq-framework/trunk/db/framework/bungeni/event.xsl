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
    <xsl:template match="doc">
        <xsl:variable name="event-uri" select="event"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/@uri">
                    <xsl:value-of select="bu:ontology/bu:document/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:document/@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="moevent-uri" select="bu:ontology/bu:document/bu:owner/bu:person/@href"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-red-left">
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </h1>
                <h1 id="doc-title-blue">
                    <span class="doc-sub-blue">
                        <xsl:value-of select="ref/bu:ontology/bu:document/bu:title"/>
                    </span>
                </h1>
            </div>
            <!-- 
               !+FIX_THIS (ao, 7th-May-2012) This can be enabled if we decide to have events on 
               their own tab.
            -->
            <!--xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="tab-path">attachments</xsl:with-param>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template-->
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
                            <xsl:if test="bu:ontology/bu:document/@uri">
                                <li>
                                    <a href="{lower-case($doc-type)}-text?uri={$doc-uri}">
                                        <i18n:text key="list-tab-cur">current(nt)</i18n:text>
                                    </a>
                                </li>
                            </xsl:if>
                            <xsl:variable name="total_versions" select="count(bu:ontology/bu:document/bu:workflowEvents/bu:workflowEvent)"/>
                            <xsl:for-each select="bu:ontology/bu:document/bu:workflowEvents/bu:workflowEvent">
                                <xsl:sort select="bu:statusDate" order="descending"/>
                                <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                                <li>
                                    <xsl:choose>
                                        <!-- if current URI is equal to this versions URI -->
                                        <xsl:when test="$event-uri eq @href">
                                            <span>
                                                <i18n:text key="doc-event">event(nt)</i18n:text> -<xsl:value-of select="$cur_pos"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a href="{lower-case($doc-type)}-event?uri={@href}">
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
                        <xsl:value-of select="bu:ontology/bu:documents/bu:workflowEvents/bu:workflowEvent[@href=$event-uri]/bu:title"/>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>
                                <i18n:text key="last-event">Last Event(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="ref/bu:ontology/bu:document/bu:status/bu:value"/>
                        </span>
                        <span>
                            <b>
                                <i18n:text key="status">Status(nt)</i18n:text>
                                &#160;<i18n:text key="date-on">Date(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-dateTime(ref/bu:ontology/bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="ref/bu:ontology/bu:document/bu:body"/>
                        </div>
                        <!-- TO_BE_REVIEWED -->
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>