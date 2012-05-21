<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bun="http://exist.bungeni.org/bun" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    
    <!-- DOCUMENTATION -->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 5, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>
                Lists legis-items from Bungeni 
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--
        
        THE INPUT DOCUMENT LOOKS LIKE THIS 
        
        <docs>
        <paginator>
        <count>3</count>
        <documentType>bill</documentType>
        <listingUrlPrefix>bill/text</listingUrlPrefix>
        <offset>3</offset>
        <limit>3</limit>
        </paginator>
        <alisting>
        <doc>
        <bu:ontology .../>
        <ref>
        <bu:ontology/>
        </ref>
        </doc>
        </alisting>
        </docs>
    -->
    <!-- INPUT PARAMETERS -->
    
    <!-- +SORT_ORDER(ah,nov-2011) pass the sort ordr into the XSLT-->
    <xsl:param name="sortby"/>
    <xsl:param name="listing-tab"/>
    <xsl:param name="whatson-view"/>
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>
    <xsl:variable name="label" select="/docs/paginator/i18nlabel"/>
    
    <!--
        MAIN RENDERING TEMPLATE
    -->
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <ul id="nav">
                    <xsl:for-each select="/docs/paginator/whatsonviews/whatsonview">
                        <li>
                            <xsl:if test="@id eq $whatson-view">
                                <xsl:attribute name="class">selected</xsl:attribute>
                            </xsl:if>
                            <a href="?tab={$listing-tab}&amp;showing={@id}">
                                <i18n:text key="{@id}">whatsonview(nt)</i18n:text>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <!-- Renders tabs -->
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <xsl:for-each select="/docs/paginator/tags/tag">
                        <li>
                            <xsl:if test="@id eq $listing-tab">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <a href="?tab={@id}">
                                <i18n:text key="{@id}">tab(nt)</i18n:text>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>            
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">listings</xsl:with-param>
                <xsl:with-param name="doc-type" select="$input-document-type"/>
                <xsl:with-param name="uri">null</xsl:with-param>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header">
                        filter by: 
                        <!-- call the filters -->
                        <select>
                            <option value="plenary">plenary</option>
                            <option value="comm">committee</option>
                            <option value="jcomm">joint committee</option>
                        </select>
                    </div>
                    <!-- only show multiple compress when more than one item is available -->
                    <xsl:if test="count(/docs/alisting/doc) gt 1">
                        <div id="toggle-wrapper" class="clear toggle-wrapper">
                            <div id="toggle-i18n" class="hide">
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
                    </xsl:if>
                    <!-- 
                        !+LISTING_GENERATOR
                        render the actual listing
                    -->
                    <xsl:apply-templates select="alisting"/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    
    <!-- 
        !+LISTING_GENERATOR
        Listing generator template 
    -->
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row clear">
            <li>
                <xsl:variable name="docIdentifier">
                    <xsl:choose>
                        <xsl:when test="doc/bu:ontology/bu:document/@uri">
                            <xsl:value-of select="doc/bu:ontology/bu:document/@uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="doc/bu:ontology/bu:document/@internal-uri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="doc/bu:ontology">
                    <a href="sitting?uri={bu:groupsitting/@uri}">
                        <xsl:value-of select="format-dateTime(bu:groupsitting/bu:startDate,'[D1o] [MNn,*-3], [Y]','en',(),())"/>
                    </a>
                    <span>-</span>
                    <div class="doc-toggle">
                        <div class="sitting-block">
                            <div class="schedule-block">
                                <div class="left">time</div>
                                <div class="right">business</div>
                            </div>
                            <xsl:apply-templates select="parent::node()" mode="renderui"/>
                        </div>
                        <table class="doc-tbl-details"/>
                    </div>
                    <div style="clear:none;height:10px;"/>
                </xsl:for-each>
            </li>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui">
        <div class="schedule-block">
            <div class="left">
                <xsl:value-of select="format-dateTime(bu:ontology/bu:groupsitting/bu:startDate,'[h]:[m]:[s] [P,2-2]','en',(),())"/>
            </div>
            <div class="right">
                <ul class="scheduling">
                    <li>
                        <xsl:value-of select="bu:ontology/bu:legislature/bu:shortName"/>
                    </li>
                    <xsl:for-each select="ref/bu:ontology">
                        <xsl:variable name="subDocIdentifier">
                            <xsl:choose>
                                <xsl:when test="bu:document/@uri">
                                    <xsl:value-of select="bu:document/@uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="bu:document/@internal-uri"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <li>
                            <xsl:variable name="doc-type" select="bu:document/bu:docType/bu:value"/>
                            <xsl:variable name="eventOf" select="bu:document/bu:eventOf/bu:type/bu:value"/>
                            <xsl:choose>
                                <xsl:when test="$doc-type eq 'Heading'">
                                    <xsl:value-of select="bu:document/bu:shortTitle"/>
                                </xsl:when>
                                <xsl:when test="$doc-type = 'Event'">
                                    <xsl:variable name="event-href" select="bu:document/@uri"/>
                                    <a href="{lower-case($eventOf)}/event?uri={$event-href}">
                                        <xsl:value-of select="bu:document/bu:shortTitle"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="{lower-case($doc-type)}/text?uri={$subDocIdentifier}">
                                        <xsl:value-of select="bu:document/bu:shortTitle"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <div class="clear"/>
            <br/>
        </div>
    </xsl:template>
</xsl:stylesheet>