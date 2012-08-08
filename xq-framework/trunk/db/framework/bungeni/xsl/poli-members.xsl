<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:template match="doc">
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/bu:docType/bu:value"/>
        <xsl:variable name="doc_uri" select="bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="uri">
                    <xsl:value-of select="$doc_uri"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">members</xsl:with-param>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="doc-table-wrapper">
                        <xsl:choose>
                            <xsl:when test="bu:ontology/bu:members/bu:member">
                                <table class="tbl-tgl">
                                    <tr>
                                        <td class="fbtd">
                                            <a>name</a>
                                        </td>
                                        <td class="fbtd">
                                            <a>start</a>
                                        </td>
                                        <td class="fbtd">
                                            <a>end</a>
                                        </td>
                                        <td class="fbtd">
                                            <a>type</a>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="bu:ontology/bu:members/bu:member/bu:membershipType[bu:value eq 'political_group_member']/ancestor::bu:member">
                                        <xsl:sort select="bu:document/bu:statusDate" order="descending"/>
                                        <tr class="items">
                                            <td class="fbt bclr">
                                                <a href="member?uri={bu:person/@href}">
                                                    <xsl:value-of select="bu:person/@showAs"/>
                                                </a>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-date(xs:date(bu:startDate),$date-format,'en',(),())"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-date(xs:date(bu:endDate),$date-format,'en',(),())"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:membershipType"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="txt-center">
                                    <i18n:text key="none">none(nt)</i18n:text>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>