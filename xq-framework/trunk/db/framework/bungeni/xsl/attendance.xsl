<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> May 10, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Attendance Records</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>     
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="serverport"/>
    <xsl:param name="epub"/>
    <xsl:param name="chamber-id"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:sitting/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:sitting/@uri"/>
        <xsl:variable name="chamber" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="mover_uri" select="bu:ontology/bu:legislativeItem/bu:owner/@href"/>
        <div id="main-wrapper">
            <div id="uri" class="hide">
                <xsl:value-of select="$doc-uri"/>
            </div>
            <div id="title-holder">
                <h1 class="title">
                    <i18n:text key="Sitting">Sitting(nt)</i18n:text>:&#160;                  
                    <xsl:value-of select="bu:ontology/bu:sitting/bu:shortName"/>
                    &#160;<xsl:value-of select="if (bu:ontology/bu:sitting/bu:activityType/@showAs) then                          concat(' - ',data(bu:ontology/bu:sitting/bu:activityType/@showAs)) else                          bu:ontology/bu:sitting/bu:activityType/bu:value"/>                      
                    <!-- If its a version and not a main document... add version title below main title -->
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="tab-path">attendance</xsl:with-param>
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="has-popout rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <xsl:choose>
                        <xsl:when test="bu:ontology/bu:sitting/bu:attendanceRecords/bu:attendanceRecord">
                            <ul id="list-toggle" class="ls-timeline clear">
                                <xsl:for-each select="bu:ontology/bu:sitting/bu:attendanceRecords/bu:attendanceRecord">
                                    <xsl:sort select="bu:statusDate" order="descending"/>
                                    <li>
                                        <div class="struct-ib truncate">
                                            <span class="timeline-action">
                                                <xsl:choose>
                                                    <xsl:when test="bu:attendanceType/@showAs">
                                                        <xsl:value-of select="bu:attendanceType/@showAs"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="bu:attendanceType/bu:value"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>:</span>
                                            <xsl:value-of select="concat(bu:member/bu:firstName,' ', bu:member/bu:lastName,', ',bu:member/bu:title)"/>
                                            &#160;                                 
                                            <xsl:variable name="status">
                                                <xsl:choose>
                                                    <xsl:when test="bu:status/@showAs">
                                                        <xsl:value-of select="bu:status/@showAs"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="bu:status/bu:value"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            &#160;
                                            <div class="struct-ib">
                                                <cite title="{$status}">
                                                    <xsl:value-of select="format-dateTime(./bu:statusDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                                                </cite>
                                            </div>
                                        </div>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text key="No items found">no attendance record(nt)</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>