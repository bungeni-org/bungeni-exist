<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:variable name="current-view" select="/docs/paginator/currentView"/>
    <xsl:variable name="input-fullqrystr" select="/docs/paginator/fullQryStr"/>
    <xsl:variable name="input-qrystr" select="/docs/paginator/qryStr"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
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
                        <!-- Only show block that has results -->
                    <xsl:if test="legis/doc">
                        <xsl:apply-templates select="legis"/>
                    </xsl:if>
                    <xsl:if test="groups/doc">
                        <xsl:apply-templates select="groups"/>
                    </xsl:if>
                    <xsl:if test="members/doc">
                        <xsl:apply-templates select="members"/>
                    </xsl:if>
                    <xsl:if test="not(legis/doc) and not(groups/doc) and not(members/doc)">
                        <i18n:text key="No items found">no items found(nt)</i18n:text>
                    </xsl:if>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- legislative items -->
    <xsl:template match="legis">
        <div class="global-preview-head">
            <a href="{$current-view}?scope=legis&amp;{$input-fullqrystr}">See all results from legislative items (found <xsl:value-of select="count"/>) <big class="r-prompts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="doc" mode="renderui1"/>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui1" priority="3">
        <xsl:variable name="chamber-type" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="docIdentifier">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/@uri">
                    <xsl:value-of select="bu:ontology/bu:document/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:document/@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:variable name="eventOf" select="bu:ontology/bu:event/bu:eventOf/bu:head/bu:type/bu:value"/>
            <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
            <xsl:choose>
                <xsl:when test="$doc-type = 'Event'">
                    <xsl:variable name="event-href" select="bu:ontology/bu:document/@internal-uri"/>
                    <a href="{$chamber-type}/{lower-case($eventOf)}-event?uri={$event-href}" id="{$docIdentifier}">
                        <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$chamber-type}/{lower-case($doc-type)}-text?uri={$docIdentifier}" id="{$docIdentifier}">
                        <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    
    <!-- group items -->
    <xsl:template match="groups">
        <div class="global-preview-head">
            <a href="{$current-view}?scope=groups&amp;{$input-fullqrystr}">See all results from group documents (found <xsl:value-of select="count"/>) <big class="r-prompts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="doc" mode="renderui2"/>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui2">
        <xsl:variable name="chamber-type" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:group/@uri"/>
        <li>
            <a href="{$chamber-type}/{lower-case(bu:ontology/bu:group/bu:docType/bu:value)}-text?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
            </a>
        </li>
    </xsl:template>  
    
    <!-- members items -->
    <xsl:template match="members">
        <div class="global-preview-head">
            <a href="{$current-view}?scope=members&amp;{$input-fullqrystr}">See all results from members profiles (found <xsl:value-of select="count"/>) <big class="r-promts">»</big>
            </a>
        </div>
        <ul class="ls-row global-preview-summary">
            <xsl:apply-templates select="doc" mode="renderui3"/>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui3">
        <xsl:variable name="chamber-type" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <li>
            <a href="{$chamber-type}/member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:membership/bu:title,'. ',bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
            </a>
        </li>
    </xsl:template>
</xsl:stylesheet>