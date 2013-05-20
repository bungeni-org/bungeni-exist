<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 16, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Committee item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>
    <xsl:param name="epub"/>
    <xsl:template match="doc">
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                </h1>
            </div>
            <xsl:if test="$epub ne 'true'">
                <xsl:call-template name="doc-tabs">
                    <xsl:with-param name="tab-group">
                        <xsl:value-of select="$doc-type"/>
                    </xsl:with-param>
                    <xsl:with-param name="uri">
                        <xsl:value-of select="$doc-uri"/>
                    </xsl:with-param>
                    <xsl:with-param name="tab-path">staff</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <div id="doc-downloads"/>
            </xsl:if>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <xsl:if test="$epub ne 'true'">
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
                    </xsl:if>
                    <ul id="list-toggle" class="ls-row clear">
                        <xsl:for-each select="bu:ontology/bu:members/bu:member/bu:type[bu:value eq 'committee_staff']/ancestor::bu:member">
                            <xsl:sort select="bu:statusDate" order="descending"/>
                            <li>
                                <xsl:value-of select="bu:person/@showAs"/>
                                <div class="struct-ib">&#160;/ 
                                    <i18n:text key="{bu:activeStatus/bu:value}">
                                        <xsl:value-of select="bu:activeStatus/bu:value"/>
                                    </i18n:text>
                                </div>
                                <span class="tgl-pad-right">▼</span>
                                <div class="doc-toggle">
                                    <div style="min-height:110px;">
                                        <div class="list-inline">
                                            <div class="inline-label">
                                                <i18n:text key="date-start">start date(nt)</i18n:text>:
                                            </div>
                                            <xsl:value-of select="format-date(xs:date(bu:startDate),$date-format,'en',(),())"/>
                                        </div>
                                        <xsl:if test="bu:endDate">
                                            <div class="list-inline">
                                                <div class="inline-label">
                                                    <i18n:text key="date-end">end date(nt)</i18n:text>:
                                                </div>
                                                <xsl:value-of select="format-date(xs:date(bu:endDate),$date-format,'en',(),())"/>
                                            </div>
                                        </xsl:if>
                                    </div>
                                    <div class="clear"/>
                                </div>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>