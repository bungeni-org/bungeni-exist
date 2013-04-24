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
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">minutes</xsl:with-param>
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
            </xsl:call-template>
            <div id="region-content" class="has-popout rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <ul id="list-toggle" class="ls-timeline clear">
                        <xsl:for-each select="ref/bu:discussions/bu:discussion">
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
                                <xsl:value-of select="format-dateTime(bu:chronoTime,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                                <div class="struct-ib">
                                    <xsl:copy-of select="bu:body/child::node()"/>
                                </div>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>