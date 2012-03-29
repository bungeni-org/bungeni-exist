<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 14, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>List committees from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- +SORT_ORDER(ah,nov-2011) pass the sort ordr into the XSLT-->
    <xsl:param name="sortby"/>
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="input-fullqrystr" select="/docs/paginator/fullQryStr"/>
    <xsl:variable name="input-qrystr" select="/docs/paginator/qryStr"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    Search Results Summary “<span class="quoted-qry">
                        <xsl:value-of select="$input-qrystr"/>
                    </span>”
                </h1>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="search-summary" class="acts">
                    <!-- render the paginator -->
                    <div class="list-header">
                        <div id="search-n-sort" class="search-bar">
                            <!-- listing search removed -->
                        </div>
                    </div>                 
                    <!-- render the actual listing-->
                    <xsl:apply-templates select="legis"/>
                    <xsl:apply-templates select="groups"/>
                    <xsl:apply-templates select="members"/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- legislative items -->
    <xsl:template match="legis">
        <div class="global-preview-head">
            <a href="?scope=legis&amp;{$input-fullqrystr}">See all results from legislative items (found <xsl:value-of select="count"/>) <big class="r-prompts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="document" mode="renderui1"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui1" priority="3">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:legislativeItem/@uri"/>
        <li>
            <a href="{bu:ontology/bu:document/@type}/text?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:shortName"/>
            </a>
        </li>
    </xsl:template>
    
    <!-- group items -->
    <xsl:template match="groups">
        <div class="global-preview-head">
            <a href="?scope=groups&amp;{$input-fullqrystr}">See all results from group items (found <xsl:value-of select="count"/>) <big class="r-prompts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="document" mode="renderui2"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui2">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:group/@uri"/>
        <li>
            <a href="{bu:ontology/bu:group/@type}/profile?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:legislature/bu:fullName"/>
            </a>
        </li>
    </xsl:template>  
    
    <!-- members items -->
    <xsl:template match="members">
        <div class="global-preview-head">
            <a href="?scope=members&amp;{$input-fullqrystr}">See all results from members items (found <xsl:value-of select="count"/>) <big class="r-promts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="document" mode="renderui3"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui3">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:membership/@uri"/>
        <li>
            <a href="member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:membership/bu:titles,'. ',bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
            </a>
        </li>
    </xsl:template>
</xsl:stylesheet>