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
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc-type" select="bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:membership/bu:referenceToUser/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="concat(bu:membership/bu:firstName,' ', bu:membership/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">offices</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
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
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="mem-table-wrapper">
                            (baked)
                            <table class="tbl-tgl">
                                <tr>
                                    <td class="fbtd">office</td>
                                    <td class="fbtd">type</td>
                                    <td class="fbtd">title</td>
                                    <td class="fbtd">from</td>
                                    <td class="fbtd">to</td>
                                </tr>
                                <tr class="items">
                                    <td class="fbt bclr">XIV-PARL - Bungeni Parliament</td>
                                    <td class="fbt bclr">parliament</td>
                                    <td class="fbt bclr">member</td>
                                    <td class="fbt bclr">February 23, 2011</td>
                                    <td class="fbt bclr">March 14, 2012</td>
                                </tr>
                                <tr class="items">
                                    <td class="fbt bclr">Com_02 - Parliamentary Committee P1_02</td>
                                    <td class="fbt bclr">committee</td>
                                    <td class="fbt bclr">chairperson</td>
                                    <td class="fbt bclr">February 23, 2011</td>
                                    <td class="fbt bclr">March 14, 2012</td>
                                </tr>
                                <tr class="items">
                                    <td class="fbt bclr">PolGrup_02 - Political Group P1_02 </td>
                                    <td class="fbt bclr">political-group</td>
                                    <td class="fbt bclr">secretary</td>
                                    <td class="fbt bclr">February 23, 2011</td>
                                    <td class="fbt bclr">March 14, 2012</td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>