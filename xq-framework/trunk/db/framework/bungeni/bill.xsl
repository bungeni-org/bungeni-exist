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
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc_uri" select=".//bu:bill/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select=".//bu:bill/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="uri" select="$doc_uri"/>
                <xsl:with-param name="tab">text</xsl:with-param>
            </xsl:call-template>
            <div style="float:right;width:400px;height:18px;">
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
                    </ul>
                </div>
            </div>
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <h3 id="doc-heading" class="doc-headers">
                        <xsl:value-of select=".//bu:bill/bu:shortName"/>
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select=".//docTitle[@id='ActTitle']"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Introduced by: <i>
                            <a href="{$doc_uri}">
                                <xsl:value-of select="concat(.//bu:bill/bu:owner/bu:field[@name='first_name'],' ', .//bu:bill/bu:owner/bu:field[@name='last_name'])"/>
                            </a>
                        </i>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>Status:</b>
                        </span>
                        <span>
                            <xsl:value-of select=".//bu:bill/bu:status"/>
                        </span>
                        <span>
                            <b>Status Date:</b>
                        </span>
                        <span>
                            <xsl:value-of select=".//bu:bungeni/bu:parliament/@date"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <xsl:value-of select="//docTitle[@refersTo='#TheActLongTitle']"/>
                        <ul>
                            <xsl:for-each select="//section">
                                <li>
                                    <xsl:value-of select="heading"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                        <div>
                            <xsl:copy-of select=".//bu:bill/bu:body"/>
                        </div>
                        <!-- TO_BE_REVIEWED -->
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>