<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 18, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Version for Parliamentary Document from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:param name="version-uri"/>
    <xsl:param name="epub"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
        <xsl:variable name="chamber" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
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
        <xsl:variable name="uriParameter">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/@uri">
                    <xsl:text>uri</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>internal-uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="moevent-uri" select="bu:ontology/bu:document/bu:owner/bu:person/@href"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:if test="bu:ontology/bu:document/bu:progressiveNumber">#<xsl:value-of select="bu:ontology/bu:document/bu:progressiveNumber"/>:</xsl:if>
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </h1>
            </div>
            <xsl:if test="$epub ne 'true'">
                <!-- 
                    !+FIX_THIS (ao, 7th-May-2012) This can be enabled if we decide to have events on 
                    their own tab.
                -->
                <xsl:call-template name="doc-tabs">
                    <xsl:with-param name="tab-group" select="$doc-type"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                    <xsl:with-param name="uri-type" select="$uriParameter"/>
                    <xsl:with-param name="tab-path">versions</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <div id="doc-downloads"/>
            </xsl:if>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <xsl:if test="$epub ne 'true'">
                        <xsl:call-template name="doc-versions">
                            <xsl:with-param name="version-uri" select="$version-uri"/>
                            <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                            <xsl:with-param name="doc-uri" select="$doc-uri"/>
                            <xsl:with-param name="uriParameter" select="$uriParameter"/>
                            <xsl:with-param name="chamber" select="$chamber"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:variable name="render-doc" select="bu:ontology/bu:document/bu:versions/bu:version[@uri=$version-uri]"/>
                    <h3 id="doc-heading" class="doc-headers">
                        <xsl:value-of select="bu:ontology/bu:chamber/bu:type/@showAs"/>
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="$render-doc/bu:title"/>
                    </h4>
                    <p class="doc-status inline-centered">
                        <span>
                            <b>
                                <i18n:text key="last-event">Last Event(nt)</i18n:text>:</b>
                        </span>
                        &#160;
                        <span>
                            <xsl:value-of select="if($render-doc/bu:status/@showAs) then $render-doc/bu:status/@showAs else $render-doc/bu:status/bu:value"/>
                        </span>
                        &#160;
                        <span>
                            <b>
                                <i18n:text key="status">Status(nt)</i18n:text>&#160;<i18n:text key="date-on">Date(nt)</i18n:text>:</b>
                        </span>
                        &#160;
                        <span>
                            <xsl:value-of select="format-dateTime($render-doc/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </p>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="$render-doc/bu:body"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- DOC-VERSIONS -->
    <xsl:template name="doc-versions">
        <xsl:param name="version-uri"/>
        <xsl:param name="doc-type"/>
        <xsl:param name="doc-uri"/>
        <xsl:param name="chamber"/>
        <xsl:param name="uriParameter"/>
        <xsl:variable name="total_versions" select="count(bu:ontology/bu:document/bu:versions/bu:version)"/>
        <div class="doc-views-section">
            <form onsubmit="redirectTo();">
                <label for="eventText" class="inline">
                    There are <xsl:value-of select="$total_versions"/> versions:
                </label>
                <div class="inline">
                    <select name="{$uriParameter}" id="eventText">
                        <xsl:for-each select="bu:ontology/bu:document/bu:versions/bu:version">
                            <xsl:sort select="bu:statusDate" order="descending"/>
                            <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                            <option value="{@uri}">
                                <xsl:if test="$version-uri eq @uri">
                                    <!-- if current URI is equal to this versions URI -->
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="concat(bu:title,' (',format-dateTime(bu:statusDate,$datetime-format,'en',(),()),')')"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="inline">
                    <input type="submit" id="submit" value="Go"/>
                </div>
            </form>
        </div>
    </xsl:template>
</xsl:stylesheet>