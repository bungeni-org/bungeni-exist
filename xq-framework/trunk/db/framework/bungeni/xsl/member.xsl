<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 6, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Member item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>
    <xsl:param name="epub"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="user-uri" select="bu:ontology/bu:membership/bu:referenceToUser/bu:refersTo/@href"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:referenceToUser/bu:firstName,' ', bu:ontology/bu:membership/bu:referenceToUser/bu:lastName,', ',ref/bu:ontology/bu:user/bu:title)"/>
                </h1>
            </div>
            <xsl:if test="$epub ne 'true'">
                <xsl:call-template name="mem-tabs">
                    <xsl:with-param name="tab-group">
                        <xsl:value-of select="$doc-type"/>
                    </xsl:with-param>
                    <xsl:with-param name="tab-path">member</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="uri" select="$user-uri"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <div id="doc-downloads">
                    <ul class="ls-downloads">
                        <li>
                            <a href="{$chamber}/member/pdf?uri={$doc-uri}" title="get PDF document" class="pdf">
                                <em>PDF</em>
                            </a>
                        </li>
                        <li>
                            <a href="{$chamber}/member/xml?uri={$doc-uri}" title="get raw xml output" class="xml">
                                <em>XML</em>
                            </a>
                        </li>
                    </ul>
                </div>
            </xsl:if>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section" class="blocks">
                    <div class="mem-profile">
                        <div class="mem-photo mem-top-left">
                            <p class="imgonlywrap">
                                <xsl:variable name="img_hash">
                                    <xsl:choose>
                                        <xsl:when test="ref/bu:ontology/bu:image/bu:imageHash">
                                            <xsl:value-of select="ref/bu:ontology/bu:image/bu:imageHash"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>none</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <img src="image?hash={$img_hash}&amp;name={concat(bu:ontology/bu:membership/bu:referenceToUser/bu:lastName,'_', bu:ontology/bu:membership/bu:referenceToUser/bu:firstName)}" alt="Photo of M.P" align="left"/>
                            </p>
                        </div>
                        <div class="mem-top-right">
                            <div id="doc-main-section" class="mem-details">
                                <div class="list-inline">
                                    <div class="inline-label">
                                        <i18n:text key="elected/nominated">elected/nominated</i18n:text>:
                                    </div>
                                    <xsl:value-of select="if (bu:ontology/bu:membership/bu:memberElectionType/@showAs) then                                             data(bu:ontology/bu:membership/bu:memberElectionType/@showAs) else                                              bu:ontology/bu:membership/bu:memberElectionType/bu:value"/>
                                </div>
                                <div class="list-inline">
                                    <div class="inline-label">
                                        <i18n:text key="Election/Nomination Date">Election/Nomination Date</i18n:text>:
                                    </div>
                                    <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:electionNominationDate),$date-format,'en',(),())"/>
                                </div>
                                <div class="list-inline">
                                    <div class="inline-label">
                                        <i18n:text key="Start Date">Start Date</i18n:text>:
                                    </div>
                                    <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:startDate),$date-format,'en',(),())"/>
                                </div>
                                <div class="list-inline">
                                    <div class="inline-label">
                                        <i18n:text key="Language">Language</i18n:text>:
                                    </div>
                                    <xsl:value-of select="bu:ontology/bu:membership/@xml:lang"/>
                                </div>
                                <xsl:if test="bu:ontology/bu:membership/bu:representations/bu:representation">
                                    <div class="list-inline">
                                        <div class="inline-label">
                                            <i18n:text key="representation">representation</i18n:text>:
                                        </div>
                                        <xsl:value-of select="string-join(bu:ontology/bu:membership/bu:representations/bu:representation/@showAs,' » ')"/>
                                    </div>
                                </xsl:if>
                                <xsl:if test="bu:ontology/bu:membership/bu:party">
                                    <div class="list-inline">
                                        <div class="inline-label">
                                            <i18n:text key="Political Party">Political Party</i18n:text>:
                                        </div>
                                        <xsl:choose>
                                            <xsl:when test="bu:ontology/bu:membership/bu:party/@showAs">
                                                <xsl:value-of select="bu:ontology/bu:membership/bu:party/@showAs"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="bu:ontology/bu:membership/bu:party"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </xsl:if>
                            </div>
                        </div>
                    </div>
                    <div class="clear"/>
                    <div class="mem-desc">
                        <xsl:copy-of select="bu:ontology/bu:membership/bu:notes/child::node()" copy-namespaces="no"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>