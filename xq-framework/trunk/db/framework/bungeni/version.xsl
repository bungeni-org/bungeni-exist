<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 6, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="document">
        <xsl:variable name="ver_uri" select="version"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/@uri"/>
        <xsl:variable name="mover_uri" select="primary/bu:ontology/bu:legislativeItem/bu:owner/@href"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue" style="text-align:right">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    <br/>
                    <span style="color:#b22b14">Version - <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
                    </span>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <!-- +VERSIONS we override the tabgroup name here by appending 
                    "-ver" to the the document type name. Usually the document 
                    type name is used for the tab group and the tab groups for 
                    the versions of a document type use the document type name 
                    suffixed with a -ver -->
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="concat($doc-type,'-ver')"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">text</xsl:with-param>
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
                    <div class="rounded-eigh tab_container" style="clear:both;width:110px;height:auto;float:right;display:inline;position:relative;top:0px;right:10px;">
                        <ul class="doc-versions">
                            <li>
                                <a href="{primary/bu:ontology/bu:document/@type}/text?uri={primary/bu:ontology/bu:legislativeItem/@uri}">current</a>
                            </li>
                            <xsl:variable name="total_versions" select="count(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version)"/>
                            <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version">
                                <xsl:sort select="bu:statusDate" order="descending"/>
                                <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                                <li>
                                    <xsl:choose>
                                        <!-- if current URI is equal to this versions URI -->
                                        <xsl:when test="$ver_uri eq @uri">
                                            <span>version-<xsl:value-of select="$cur_pos"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a href="{$doc-type}/version/text?uri={@uri}">
                                                version-<xsl:value-of select="$cur_pos"/>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <h3 id="doc-heading" class="doc-headers" style="margin-left:110px;clear:none;float:none">
                        <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS -->
                        KENYA PARLIAMENT
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers" style="margin-left:110px;clear:none;float:none;">
                        <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:shortName"/>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>Status:</b>
                        </span>
                        <span>
                            <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:status"/>
                        </span>
                        <span>
                            <b>Status Date:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:body"/>
                        </div>
                        <!-- TO_BE_REVIEWED -->
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>