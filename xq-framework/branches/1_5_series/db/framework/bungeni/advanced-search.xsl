<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
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
    <xsl:template match="docs">
        <xsl:variable name="ver_id" select="version"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <xsl:text>Search results for&#160;</xsl:text>
                    <!-- Capitalize the first letter -->
                    s</h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <li class="active">
                        <a href="#">
                            <xsl:text>search results (</xsl:text>
                            <xsl:value-of select="paginator/count"/>
                            <xsl:text>)</xsl:text>
                        </a>
                    </li>
                    <li>
                        <a href="#">
                            <xsl:text>archived</xsl:text>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="s/rss" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this page listing" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:apply-templates select="paginator"/>
                    </div>
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div id="toggle-i18n" style="display:none;">
                            <span id="i-compress">
                                <i18n:text key="compress">- compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">+ expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">-&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
                        </div>
                    </div>                    
                    <!-- 
                        !+LISTING_GENERATOR
                        render the actual listing
                    -->
                    <xsl:apply-templates select="alisting"/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- Include the paginator generator -->
    <xsl:include href="paginator.xsl"/>    
    
    <!-- 
        !+LISTING_GENERATOR
        Listing generator template 
    -->
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row clear">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="nodes" mode="renderui">
        <xsl:variable name="doc-type" select="bu:ontology/@type"/>
        <xsl:variable name="doc-sub-type" select="bu:ontology/child::*/@type"/>
        <xsl:variable name="docIdentifier" select="bu:ontology/child::*/@uri"/>
        <li>
            <span>-</span>
            <a href="?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/child::*/bu:shortName"/>
            </a> sponsored by                             
            <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:owner/@showAs"/>
            <div class="doc-toggle">
                <div class="search-subh">
                    <xsl:value-of select="format-dateTime(bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                    &#160;-&#160;
                    <i>status</i>&#160;<xsl:value-of select="bu:ontology/bu:legislativeItem/bu:status"/>
                </div>
                <div class="search-snippet">
                    <xsl:apply-templates select="kwic"/>
                </div>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="kwic">
        <xsl:copy-of select="child::*"/>
    </xsl:template>
</xsl:stylesheet>