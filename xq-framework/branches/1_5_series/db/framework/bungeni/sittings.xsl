<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 21, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>List sittings from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- +SORT_ORDER(ah,nov-2011) pass the sort ordr into the XSLT-->
    <xsl:param name="sortby"/>
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <i18n:text key="list-t-sittings">Sittings(s)</i18n:text>
                </h1>
            </div>
            <div id="doc-downloads">
                <ul class="ls-downloads">
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
                    <!-- render the paginator -->
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:apply-templates select="paginator"/>
                        <div id="search-n-sort" class="search-bar">
                            <xsl:variable name="searchins" select="xqcfg:get_searchin($input-document-type)"/>
                            <xsl:variable name="orderbys" select="xqcfg:get_orderby($input-document-type)"/>
                            <xsl:if test="$searchins and $orderbys">
                                <div id="search-form"/>
                            </xsl:if>
                        </div>
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
                    <!-- render the actual listing-->
                    <xsl:apply-templates select="alisting"/>
                </div>
            </div>
        </div>
    </xsl:template>

    
    <!-- Include the paginator generator -->
    <xsl:include href="paginator.xsl"/>
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row" style="clear:both">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui">
        <xsl:variable name="docIdentifier" select="sitting/bu:ontology/bu:groupsitting/@uri"/>
        <li>
            <a href="sitting?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="sitting/bu:ontology/bu:legislature/bu:shortName"/>
            </a>
            <div style="display:inline-block;">/ ( <xsl:value-of select="format-dateTime(sitting/bu:ontology/bu:groupsitting/bu:startDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                <b>↔</b>
                <xsl:value-of select="format-dateTime(sitting/bu:ontology/bu:groupsitting/bu:endDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/> )
            </div>
            <span>-</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <xsl:for-each select="sitting_items/bu:ontology">
                        <xsl:variable name="subDocIdentifier" select="bu:legislativeItem/@uri"/>
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="bu:document/@type eq 'heading'">
                                        • <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        • <a href="{bu:document/@type}/text?uri={$subDocIdentifier}">
                                            <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>