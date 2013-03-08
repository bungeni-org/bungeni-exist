<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Anthony</xd:p>
            <xd:p> Members of parliament from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="listing-tab"/>
    <xsl:param name="item-listing-rel-base"/>
    <xsl:param name="chamber"/>  
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <i18n:text key="list-t-members">Members of Parliament(nt)</i18n:text>
                </h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="tabbernav">
                    <xsl:for-each select="/docs/paginator/tags/tag">
                        <li>
                            <xsl:if test="@id eq $listing-tab">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <a href="{$chamber}/{$item-listing-rel-base}?tab={@id}">
                                <i18n:translate>
                                    <i18n:text key="{@id}">nt({1})</i18n:text>
                                    <i18n:param>
                                        <xsl:value-of select="@count"/>
                                    </i18n:param>
                                </i18n:translate>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <div id="doc-downloads"/>
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
                        <div id="toggle-i18n" class="hide">
                            <span id="i-compress">
                                <i18n:text key="compress">▼&#160;compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">►&#160;expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">▼&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
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
        <ul id="list-toggle" class="ls-row clear">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <li>
            <a href="{$chamber}/member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:membership/bu:lastName,', ', bu:ontology/bu:membership/bu:firstName)"/>
            </a>
            <div class="struct-ib">/ <xsl:value-of select="bu:ontology/bu:membership/bu:group/bu:type/bu:value"/> / <xsl:value-of select="bu:ontology/bu:chamber/bu:fullName"/>
            </div>
            <span class="tgl-pad-right">▼</span>
            <div class="doc-toggle">
                <div style="min-height:110px;">
                    <p class="imgonlywrap photo-listing" style="float:left;">
                        <xsl:variable name="img_hash" select="ref/bu:ontology/bu:image/bu:imageHash"/>
                        <img src="image?hash={$img_hash}&amp;name={concat(bu:ontology/bu:membership/bu:lastName,'_', bu:ontology/bu:membership/bu:firstName)}" alt="Photo of M.P" align="left"/>
                    </p>
                    <div class="block">
                        <span class="labels">id:</span>
                        <span>
                            <xsl:value-of select="$docIdentifier"/>
                        </span>
                    </div>
                    <div class="block">
                        <span class="labels">elected/nominated:</span>
                        <span>
                            <xsl:value-of select="if (bu:ontology/bu:membership/bu:memberElectionType/@showAs) then                                 data(bu:ontology/bu:membership/bu:memberElectionType/@showAs) else                                  bu:ontology/bu:membership/bu:memberElectionType/bu:value"/>
                        </span>
                    </div>
                    <div class="block">
                        <span class="labels">
                            <i18n:text key="date-start">start date(nt)</i18n:text>:</span>
                        <span>
                            <xsl:value-of select="format-date(bu:ontology/bu:membership/bu:startDate,$date-format,'en',(),())"/>
                        </span>
                    </div>
                    <div class="block">
                        <xsl:choose>
                            <xsl:when test="kwic">
                                <xsl:apply-templates select="kwic"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(bu:ontology/bu:membership/bu:notes,0,360)"/>...                           
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
                <div class="clear"/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="kwic">
        <xsl:copy-of select="child::*"/>
    </xsl:template>
</xsl:stylesheet>