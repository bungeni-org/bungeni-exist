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
    <xsl:param name="attachment-uri"/>
    <xsl:template match="doc">
        <xsl:variable name="attachment-uri" select="attachment"/>
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
            <div id="title-holder">
                <a class="big-dbl-arrow" title="go back to {lower-case($doc-type)} documents" href="{lower-case($doc-type)}-documents?uri={$doc-uri}">«&#160;</a>
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </h1>
                <h2 class="sub-title">
                    <xsl:value-of select="bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:title"/>
                </h2>
            </div>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="rounded-eigh tab_container hanging-menu">
                        <ul class="doc-versions">
                            <xsl:if test="bu:ontology/bu:document[@uri, @internal-uri]">
                                <li>
                                    <a href="{lower-case($doc-type)}-text?uri={$doc-uri}">
                                        <i18n:text key="doc-{lower-case($doc-type)}">main(nt)</i18n:text>
                                    </a>
                                </li>
                            </xsl:if>
                            <xsl:variable name="total_versions" select="count(ref/bu:ontology/bu:document)"/>
                            <xsl:for-each select="bu:ontology/bu:attachments/bu:attachment">
                                <xsl:sort select="bu:statusDate" order="descending"/>
                                <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                                <li>
                                    <xsl:choose>
                                        <!-- if current URI is equal to this versions URI -->
                                        <xsl:when test="$attachment-uri eq @href">
                                            <span>
                                                <i18n:text key="doc-attachment">annex(nt)</i18n:text> -<xsl:value-of select="$cur_pos"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a href="{lower-case($doc-type)}-attachment?uri={@href}">
                                                <i18n:text key="doc-attachment">annex(nt)</i18n:text> -<xsl:value-of select="$cur_pos"/>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <h3 id="doc-heading" class="doc-headers hang-left-titles">
                        <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS --> BUNGENI
                        PARLIAMENT </h3>
                    <h4 id="doc-item-desc" class="doc-headers hang-left-titles">
                        <xsl:value-of select="bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:title"/>
                    </h4>
                    <p class="inline-centered">
                        <span>
                            <b>
                                <i18n:text key="last-event">last event(nt)</i18n:text>:</b>
                        </span>
                        &#160;                         
                        <span>
                            <xsl:value-of select="bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:status/bu:value"/>
                        </span>
                        &#160;                         
                        <span>
                            <b>
                                <i18n:text key="status">Status(nt)</i18n:text>
                                &#160;<i18n:text key="date-on">Date(nt)</i18n:text>:</b>
                        </span>
                        &#160;                         
                        <span>
                            <xsl:value-of select="format-dateTime(bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </p>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:description"/>
                        </div>
                        <!-- TO_BE_REVIEWED -->
                    </div>
                    <p class="inline-centered">
                        download:&#160;
                        <a href="download?uri={$doc-uri}&amp;att={bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:attachmentId}">
                            <xsl:value-of select="bu:ontology/bu:attachments/bu:attachment[@href=$attachment-uri]/bu:name"/>
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>