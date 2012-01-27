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
    <xsl:template match="document">
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/@type"/>
        <xsl:variable name="doc-sub-type" select="primary/documentType"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="primary/bu:ontology/bu:legislature/bu:fullName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-sub-type"/>
                </xsl:with-param>
                <xsl:with-param name="uri">
                    <xsl:value-of select="$doc_uri"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">profile</xsl:with-param>
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
                    <h3 id="doc-heading" class="doc-headers">
                        KENYA PARLIAMENT
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Language: 
                        <i>
                            <xsl:value-of select="primary/bu:ontology/bu:bungeni/bu:language"/>
                        </i>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b>Acronym:</b>
                        </span>
                        <span>
                            <xsl:value-of select="primary/bu:ontology/bu:legislature/bu:shortName"/>
                        </span>
                        <span>
                            <b>Start Date:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-date(primary/bu:ontology/bu:group/bu:startDate,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <div>
                            <xsl:copy-of select="primary/bu:ontology/bu:legislature/bu:description"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>