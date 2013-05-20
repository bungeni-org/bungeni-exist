<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> May 15, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Votes and proceedings</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    
    <!--PARAMS -->
    <xsl:param name="epub"/>
    <xsl:param name="serverport"/>
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
                <xsl:with-param name="tab-path">votes</xsl:with-param>
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
            <div id="region-content" class="has-popout rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <ul id="list-toggle" class="ls-timeline clear">
                        <xsl:for-each select="ref/item">
                            <xsl:sort select="bu:statusDate" order="descending"/>
                            <li>
                                <a href="{$chamber}/sitting?uri={bu:sitting/@uri}">
                                    <xsl:value-of select="format-dateTime(bu:startDate,'[F], [D1o] [MNn,*-3], [Y]','en',(),())"/> - <xsl:value-of select="bu:venue/bu:shortName"/>
                                </a>
                                <ul id="list-toggle" class="ls-timeline clear">
                                    <xsl:for-each select="bu:scheduleItem/bu:votes/bu:vote">
                                        <xsl:sort select="bu:voteId" order="ascending"/>
                                        <li>
                                            <div class="struct-ib truncate">
                                                <xsl:if test="bu:question">
                                                    <span class="vote-question">
                                                        <span class="timeline-action">
                                                            <i18n:text key="Question">question</i18n:text>: </span>
                                                        <xsl:value-of select="bu:question"/>
                                                    </span>
                                                </xsl:if>
                                                <span class="vote-outcome {bu:outcome/bu:value}">
                                                    <xsl:choose>
                                                        <xsl:when test="bu:outcome/@showAs">
                                                            <xsl:value-of select="bu:outcome/@showAs"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="bu:outcome/bu:value"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                <xsl:value-of select="bu:issueItem"/> /  
                                                <i>
                                                    <xsl:choose>
                                                        <xsl:when test="bu:voteType/@showAs">
                                                            <xsl:value-of select="bu:voteType/@showAs"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="bu:voteType/bu:value"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </i> on 
                                                <xsl:choose>
                                                    <xsl:when test="bu:majorityType/@showAs">
                                                        <xsl:value-of select="bu:majorityType/@showAs"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="bu:majorityType/bu:value"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:if test="bu:time">
                                                    &#160;/ 
                                                    <xsl:value-of select="bu:time"/>
                                                </xsl:if>
                                            </div>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>