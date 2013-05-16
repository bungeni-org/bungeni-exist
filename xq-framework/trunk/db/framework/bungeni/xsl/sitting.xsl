<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 22, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Sitting item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    <xsl:param name="epub"/>
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:sitting/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:sitting/@uri"/>
        <xsl:variable name="chamber" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="mover_uri" select="bu:ontology/bu:legislativeItem/bu:owner/@href"/>
        <xsl:variable name="j-obj" select="json"/>
        <div id="main-wrapper">
            <div id="uri" class="hide">
                <xsl:value-of select="$doc-uri"/>
            </div>
            <div id="title-holder">
                <h1 class="title">
                    <i18n:text key="Sitting">Sitting(nt)</i18n:text>:&#160;                  
                    <xsl:value-of select="bu:ontology/bu:sitting/bu:shortName"/>
                    -&#160;<xsl:value-of select="if (bu:ontology/bu:sitting/bu:activityType/@showAs) then                          data(bu:ontology/bu:sitting/bu:activityType/@showAs) else                          bu:ontology/bu:sitting/bu:activityType/bu:value"/>                      
                    <!-- If its a version and not a main document... add version title below main title -->
                </h1>
            </div>
            <xsl:if test="$epub ne 'true'">
                <xsl:call-template name="doc-tabs">
                    <xsl:with-param name="tab-group">
                        <xsl:value-of select="$doc-type"/>
                    </xsl:with-param>
                    <xsl:with-param name="tab-path">sitting</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <div id="doc-downloads"/>
            </xsl:if>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <h3 id="doc-heading" class="doc-headers">
                        <xsl:value-of select="bu:ontology/bu:chamber/bu:type/@showAs"/>
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="bu:ontology/bu:sitting/bu:shortName"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                        <i18n:text key="sitting-activity">sitting activity(nt)</i18n:text>: <i>
                            <xsl:value-of select="if (bu:ontology/bu:sitting/bu:activityType/@showAs) then                                  data(bu:ontology/bu:sitting/bu:activityType/@showAs) else                                  bu:ontology/bu:sitting/bu:activityType/bu:value"/>
                        </i>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                        <i18n:text key="sitting-convocation">sitting convocation(nt)</i18n:text>: <i>
                            <xsl:value-of select="if (bu:ontology/bu:sitting/bu:convocationType/@showAs) then                                  data(bu:ontology/bu:sitting/bu:convocationType/@showAs) else                                  bu:ontology/bu:sitting/bu:convocationType/bu:value"/>
                        </i>
                    </h4>
                    <div class="txt-center">
                        <span>
                            <b class="camel-txt">
                                <i18n:text key="sitting-venue">Venue(nt)</i18n:text>:</b>&#160;
                        </span>
                        <span>
                            <xsl:value-of select="bu:ontology/bu:sitting/bu:venue/bu:shortName"/>
                        </span>
                        <span>
                            &#160;<b class="camel-txt">
                                <i18n:text key="date-on">Type(nt)</i18n:text>:</b>&#160;
                        </span>
                        <span>
                            <xsl:value-of select="format-dateTime(bu:ontology/bu:sitting/bu:startDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <xsl:choose>
                            <xsl:when test="ref/bu:ontology">
                                <table class="doc-tbl-details">
                                    <xsl:for-each select="ref/bu:ontology">
                                        <xsl:variable name="subDocIdentifier">
                                            <xsl:choose>
                                                <xsl:when test="bu:document/@uri">
                                                    <xsl:value-of select="bu:document/@uri"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="bu:document/@internal-uri"/>
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
                                        <tr>
                                            <td>
                                                <xsl:variable name="doc-type" select="bu:document/bu:docType/bu:value"/>
                                                <xsl:variable name="eventOf" select="bu:document/bu:eventOf/bu:type/bu:value"/>
                                                <xsl:choose>
                                                    <xsl:when test="$doc-type eq 'Heading'">
                                                        <xsl:value-of select="bu:document/bu:title"/>
                                                    </xsl:when>
                                                    <xsl:when test="$doc-type = 'Event'">
                                                        <xsl:variable name="event-href" select="bu:document/@uri"/>
                                                        <a href="{lower-case($eventOf)}-event?uri={$event-href}">
                                                            <xsl:value-of select="bu:document/bu:title"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="{concat($chamber,'/')}{lower-case($doc-type)}-text?{$uriParameter}={$subDocIdentifier}">
                                                            <xsl:value-of select="bu:document/bu:title"/>
                                                        </a>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="txt-center">
                                    <i18n:text key="no-items">no scheduled items(nt)</i18n:text>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>