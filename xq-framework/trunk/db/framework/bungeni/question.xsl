<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 03, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Question item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc_uri" select="bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">question</xsl:with-param>
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
                    <h3 id="doc-heading" class="doc-headers">
                        KENYA PARLIAMENT
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Introduced by: <i>
                            <a href="member?uri={$doc_uri}">
                                <xsl:value-of select="concat(bu:legislativeItem/bu:owner/bu:field[@name='first_name'],' ', bu:legislativeItem/bu:owner/bu:field[@name='last_name'])"/>
                            </a>
                        </i>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Moved by: ( 
                        <xsl:choose>
                            <xsl:when test="bu:itemsignatories/bu:itemsignatorie ne null">
                                <xsl:for-each select=".//bu:itemsignatories/bu:itemsignatorie">
                                    <i>
                                        <a href="member?uri={concat('/ke/parliament/2011-03-02/user/', bu:field[@name='user_id'])}">
                                            <xsl:value-of select="concat(bu:field[@name='first_name'],' ', bu:field[@name='last_name'])"/>
                                        </a>
                                    </i>, 
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                None
                            </xsl:otherwise>
                        </xsl:choose> )
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>Status:</b>
                        </span>
                        <span>
                            <xsl:value-of select="bu:legislativeItem/bu:status"/>
                        </span>
                        <span>
                            <b>Status Date:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-date(bu:bungeni/bu:parliament/@date,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="bu:legislativeItem/bu:body"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>