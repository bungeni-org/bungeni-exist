<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 1, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Document related items from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="document">
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">related</xsl:with-param>
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
                    <ul class="ls-row" id="list-toggle-wide" style="font-size:0.9em;">
                        <li>
                            <div style="padding-left:2px;">
                                <b>Doc Id</b> : <xsl:value-of select=".//bu:legislativeItem/@uri"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding:-2px;">
                                <b>Parliament</b> : <xsl:value-of select="bu:bungeni/bu:parliament/@href"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Session Year</b> : <xsl:value-of select="substring-before(bu:bungeni/bu:parliament/@date,'-')"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Session Num</b> : <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:legislativeItemId"/>
                            </div>
                        </li>
                        <li>
                            <div style="width:100%;">
                                <span class="tgl" style="margin-right:10px">+</span>
                                <a href="#1">Events</a>
                            </div>
                            <div class="doc-toggle">
                                <table class="tbl-tgl" style="width:99%;float:none;margin:10px auto 0 auto;text-align:center">
                                    <tr>
                                        <td class="fall" style="text-align:left;padding:5px;">description</td>
                                        <td class="fall">date</td>
                                    </tr>
                                    <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent">
                                        <xsl:sort select="@date" order="descending"/>
                                        <tr>
                                            <td class="fall" style="text-align:left;padding:5px;">
                                                <a href="event?uri={@href}">
                                                    <xsl:value-of select="@showAs"/>
                                                </a>
                                            </td>
                                            <td class="fall">
                                                <xsl:value-of select="format-dateTime(@date,$datetime-format,'en',(),())"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>