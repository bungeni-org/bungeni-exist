<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill changes from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    
    <!--PARAMS -->
    <xsl:param name="epub"/>
    <xsl:param name="serverport"/>
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>
    <xsl:template match="doc">
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
        <div id="main-wrapper">
            <xsl:if test="$epub ne 'true'">
                <span id="popout-close" class="hide">
                    <i18n:text key="close">close(nt)</i18n:text>
                </span>
            </xsl:if>
            <div id="title-holder" class="theme-lev-1-only">
                <h1 class="title">
                    <xsl:if test="bu:ontology/bu:document/bu:progressiveNumber">#<xsl:value-of select="bu:ontology/bu:document/bu:progressiveNumber"/>:</xsl:if>
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </h1>
            </div>
            <xsl:if test="$epub ne 'true'">
                <xsl:call-template name="doc-tabs">
                    <xsl:with-param name="tab-group">
                        <xsl:value-of select="$doc-type"/>
                    </xsl:with-param>
                    <xsl:with-param name="tab-path">timeline</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                    <xsl:with-param name="uri-type" select="$uriParameter"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <!-- Renders the document download types -->
                <xsl:call-template name="doc-formats">
                    <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                    <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                </xsl:call-template>
            </xsl:if>
            <div id="region-content" class="has-popout rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <xsl:choose>
                        <xsl:when test="ref/bu:ontology">
                            <ul id="list-toggle" class="ls-timeline clear">
                                <xsl:for-each select="ref/timeline">
                                    <xsl:sort select="bu:document/bu:statusDate" order="descending"/>
                                    <li>
                                        <xsl:variable name="timeline-type">
                                            <xsl:choose>
                                                <xsl:when test="bu:auditFor/bu:value">
                                                    <i18n:text key="cate-document">document</i18n:text>
                                                </xsl:when>
                                                <xsl:when test="bu:auditAction/bu:value">
                                                    <xsl:value-of select="bu:auditAction/bu:value"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="bu:type/bu:value"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div class="struct-ib truncate">
                                            <xsl:variable name="eventOf" select="bu:document/bu:eventOf/bu:head/bu:type/bu:value"/>
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
                                            <xsl:variable name="show-status">
                                                <xsl:choose>
                                                    <xsl:when test="bu:status/@showAs">
                                                        <xsl:value-of select="bu:status/@showAs"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="bu:status/bu:value"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="bu:type/bu:value eq 'event' and @href ne ''">
                                                    <!--a href="{lower-case($doc-type)}-event?uri={@href}">
                                                        <xsl:value-of select="bu:title"/>
                                                        </a-->
                                                    <span class="timeline-action">
                                                        <xsl:value-of select="$show-status"/>:</span>
                                                    <a href="{$chamber}/popout?uri={@href}" rel="{lower-case($doc-type)}-event?uri={@href}" onclick="return false;">
                                                        <xsl:value-of select="bu:title"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="bu:type/bu:value eq 'event_response' and @href ne ''">
                                                    <span class="timeline-action">
                                                        <xsl:value-of select="$show-status"/>:</span>
                                                    <a href="{$chamber}/popout?uri={@href}" rel="{lower-case($doc-type)}-eventresponse?uri={@href}" onclick="return false;">
                                                        <xsl:value-of select="bu:title"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="bu:type/bu:value eq 'annex' and bu:auditFor/bu:value">
                                                    <a href="{lower-case($doc-type)}-attachment?uri={$doc-uri}@/{bu:auditFor/bu:value}{bu:attachmentId}">
                                                        <xsl:value-of select="bu:title"/>
                                                    </a>:
                                                    <i18n:text key="download">download(nt)</i18n:text>&#160;<a href="download?uri={$doc-uri}&amp;att={bu:attachmentId}">
                                                        <xsl:value-of select="bu:name"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="bu:auditAction/bu:value">
                                                    <span class="timeline-action">
                                                        <xsl:value-of select="$show-status"/>:
                                                    </span>
                                                    <xsl:choose>
                                                        <xsl:when test="bu:changeNote">
                                                            <a href="{$chamber}/bill-versions?uri={@uri}">
                                                                <xsl:value-of select="bu:changeNote"/>
                                                            </a>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <a href="{$chamber}/bill-versions?uri={@uri}">
                                                                <i18n:text key="New Version">new version(nt)</i18n:text>
                                                            </a>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <span class="timeline-action">
                                                        <xsl:value-of select="bu:status/bu:value"/>:</span>
                                                    <xsl:value-of select="bu:title"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            &#160;/ 
                                            <xsl:value-of select="lower-case($timeline-type)"/> /
                                            <xsl:value-of select="format-dateTime(bu:chronoTime,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
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
    </xsl:template>
</xsl:stylesheet>