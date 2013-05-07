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
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-qryall" select="/docs/paginator/qryAll"/>
    <xsl:variable name="input-qryexact" select="/docs/paginator/qryExact"/>
    <xsl:variable name="input-qryhas" select="/docs/paginator/qryHas"/>
    <xsl:template match="docs">
        <xsl:variable name="ver_id" select="version"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:text>Search results for&#160;</xsl:text>
                    “<span class="quoted-qry">
                        <xsl:value-of select="string-join(($input-qryall,$input-qryexact,$input-qryhas),' ')"/>
                    </span>”                    
                </h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="tabbernav">
                    <li class="active">
                        <a href="#">
                            <i18n:text key="search-results">search results(nt)</i18n:text>
                            <xsl:text>&#160;(</xsl:text>
                            <xsl:value-of select="paginator/count"/>
                            <xsl:text>)</xsl:text>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:if test="paginator/count cast as xs:integer gt 1">
                            <xsl:apply-templates select="paginator"/>
                        </xsl:if>
                    </div>
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div id="toggle-i18n" class="hide">
                            <span id="i-compress">
                                <i18n:text key="compress">►&#160;compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">▼&#160;expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">▼&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
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
    <xsl:template match="doc" mode="renderui">
        <xsl:variable name="chamber-type" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="doc-type" select="bu:ontology/@for"/>
        <xsl:variable name="doc-sub-type" select="bu:ontology/child::*/bu:docType/bu:value"/>
        <xsl:variable name="docIdentifier">
            <xsl:choose>
                <xsl:when test="bu:ontology/child::*/@uri">
                    <xsl:value-of select="bu:ontology/child::*/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/child::*/@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <span class="tgl-pad-right">▼&#160;&#160;</span>
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/bu:owner/bu:person/@showAs">
                    <xsl:variable name="base-path">
                        <xsl:choose>
                            <xsl:when test="$doc-sub-type eq 'Event'">
                                <!-- an event of some document -->
                                <xsl:value-of select="concat(lower-case(bu:ontology/bu:event/bu:eventOf/bu:head/bu:type/bu:value),'-event')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(lower-case($doc-sub-type),'-text')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <a href="{$chamber-type}/{$base-path}?uri={$docIdentifier}" id="{$docIdentifier}">
                        <!--!+FIX_THIS (ao, 11-Apr-2012) shortName / shortTitle since there is ongoing 
                            transition to use shortTitle but not yet applied to all document types currently 
                            only on document type event -->
                        <xsl:value-of select="(bu:ontology/child::*/bu:shortName,bu:ontology/child::*/bu:title)"/>
                    </a>
                    <div class="struct-ib">
                        <xsl:value-of select="bu:ontology/bu:chamber/bu:type/@showAs"/>
                    </div> / 
                    sponsored by <xsl:value-of select="bu:ontology/bu:document/bu:owner/bu:person/@showAs"/>
                </xsl:when>
                <xsl:when test="bu:ontology[@for eq 'membership']">
                    <a href="{$chamber-type}/member?uri={bu:ontology/bu:membership/bu:referenceToUser/@uri}" id="{$docIdentifier}">
                        <xsl:value-of select="concat(bu:ontology/bu:membership/bu:title,'. ',bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                    </a>
                    <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                    &#160;-&#160;
                    <i> group type</i>&#160;<xsl:value-of select="bu:ontology/child::*/bu:docType/bu:value"/>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$chamber-type}/{lower-case($doc-sub-type)}-text?uri={$docIdentifier}" id="{$docIdentifier}">
                        <xsl:value-of select="bu:ontology/child::*/bu:fullName"/>
                    </a>
                    <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                    &#160;-&#160;
                    <i> group type</i>&#160;<xsl:value-of select="bu:ontology/child::*/bu:docType/bu:value"/>
                </xsl:otherwise>
            </xsl:choose>
            <div class="doc-toggle">
                <div class="search-subh">
                    <xsl:value-of select="format-dateTime(bu:ontology/child::*/bu:statusDate,$datetime-format,'en',(),())"/>
                    &#160;-&#160;
                    <i>status</i>&#160;<xsl:value-of select="bu:ontology/child::*/bu:status/bu:value"/>
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