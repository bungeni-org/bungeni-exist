<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> MP Personal Information from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="activities">
        <xsl:variable name="doc-type" select="member/bu:ontology/bu:metadata/@type"/>
        <xsl:variable name="doc_uri" select="member/bu:ontology/bu:user/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="concat(member/bu:ontology/bu:user/bu:field[@name='first_name'],' ', member/bu:ontology/bu:user/bu:field[@name='last_name'])"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">activities</xsl:with-param>
                <xsl:with-param name="uri" select="$doc_uri"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="#" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this document" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as ODT document" class="odt">
                            <em>ODT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as RTF document" class="rtf">
                            <em>RTF</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-top-right" style="text-align:center;width:100%;">
                        <xsl:choose>
                            <xsl:when test="docs/bu:ontology">
                                <table class="tbl-tgl" style="width:90%;float:none;margin:20px auto 0 auto;text-align:left;">
                                    <tr>
                                        <td class="fbtd">type</td>
                                        <td class="fbtd">title</td>
                                        <td class="fbtd">status</td>
                                        <td class="fbtd">submission date</td>
                                    </tr>
                                    <xsl:for-each select="docs/bu:ontology">
                                        <xsl:sort select="bu:legislativeItem/bu:statusDate" order="descending"/>
                                        <tr class="items">
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:document/@type"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <a href="{bu:document/@type}/text?uri={bu:legislativeItem/@uri}">
                                                    <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                                                </a>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:legislativeItem/bu:status"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-dateTime(bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                None
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>