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
                            <a href="whatson?tab={$listing-tab}&amp;showing={@id}">
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
                            <a href="whatson?tab={@id}">
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
                        <i18n:text key="filter-by">filter by(nt)</i18n:text>: 
                        <!-- call the filters -->
                        <select>
                            <option value="plenary">plenary</option>
                            <option value="comm">committee</option>
                            <option value="jcomm">joint committee</option>
                        </select>
                    </div>
                    <!-- 
                        !+LISTING_GENERATOR
                        render the actual listing
                    -->
                    <div class="whatson-wrapper">
                        <div class="left">
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
                            <xsl:apply-templates select="alisting"/>
                        </div>
                        <div class="right">
                            <p id="range-cal"/>
                            <form class="whatson-form" id="whatson-filter-form" name="whatson_filter_form" method="GET" action="whatson">
                                <input type="hidden" value="{$listing-tab}" name="tab"/>
                                <input type="hidden" value="none" name="showing"/>
                                <input type="hidden" value="{substring-before(//range/start,'T')}" name="f" id="hidden-start"/>
                                <input type="hidden" value="{substring-before(//range/end,'T')}" name="t" id="hidden-end"/>
                                <div class="indent schedule-block note">
                                    <i18n:text key="range-cal-tip">Click twice: The beginning and end date to filter within(nt)</i18n:text>
                                </div>
                                <br/>
                                <br/>
                                <div class="indent schedule-block">
                                    <div class="left">
                                        <i18n:text key="date-from">from(nt)</i18n:text>: </div>
                                    <div class="right">
                                        <input type="text" value="{format-date(xs:date(substring-before(//range/start,'T')),'[F], [MNn,*-3] [D1o], [Y]','en',(),())}" disabled="disabled" name="q" id="range-cal-start" class="indent text search_for"/>
                                    </div>
                                </div>
                                <div class="indent schedule-block">
                                    <div class="left">
                                        <i18n:text key="date-to">to(nt)</i18n:text>: </div>
                                    <div class="right">
                                        <input type="text" value="{format-date(xs:date(substring-before(//range/end,'T')),'[F], [MNn,*-3] [D1o], [Y]','en',(),())}" disabled="disabled" name="q" id="range-cal-end" class="indent text search_for"/>
                                    </div>
                                </div>
                                <br/>
                                <input type="submit" value="i18n(btn-filter, filter[nt])" class="indent" id="whatson-filter-btn"/>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    
    <!-- 
        !+LISTING_GENERATOR
        Listing generator template 
    -->
    <xsl:template match="alisting">
        <div class="hide">
            <span id="range-start">
                <xsl:value-of select="substring-before(range/start,'T')"/>
            </span>
            <span id="range-end">
                <xsl:value-of select="substring-before(range/end,'T')"/>
            </span>
        </div>
        <ul id="list-toggle" class="ls-row clear">
            <xsl:choose>
                <xsl:when test="doc/ref">
                    <xsl:apply-templates select="doc" mode="groupings"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="center-txt">
                        <i18n:text key="nosittings">no sittings(nt)</i18n:text>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="groupings">
        <li>
            <xsl:choose>
                <xsl:when test="$listing-tab eq 'sittings'">
                    <xsl:value-of select="format-date(@title,'[F], [D1o] [MNn,*-3], [Y]','en',(),())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@title"/>
                </xsl:otherwise>
            </xsl:choose>
            <span>-</span>
            <div class="doc-toggle">
                <div class="sitting-block">
                    <xsl:choose>
                        <xsl:when test="$listing-tab eq 'sittings'">
                            <div class="schedule-block">
                                <div class="left header">
                                    <i18n:text key="whatson-time">time(nt)</i18n:text>
                                </div>
                                <div class="right header">
                                    <i18n:text key="whatson-business">business(nt)</i18n:text>
                                </div>
                            </div>
                            <xsl:apply-templates mode="render-by-date"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="render-by-itemtype"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <table class="doc-tbl-details"/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="ref" mode="render-by-itemtype">
        <div class="schedule-block">
            <div class="left">
                <a href="sitting?uri={@sitting}" title="i18n(sittinglink,go to sitting-nt)">
                    <xsl:value-of select="format-dateTime(bu:startDate,'[F] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                </a>
            </div>
            <div class="right">
                <xsl:variable name="subDocIdentifier">
                    <xsl:choose>
                        <xsl:when test="bu:ontology/bu:document/@uri">
                            <xsl:value-of select="bu:ontology/bu:document/@uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="bu:ontology/bu:document/@internal-uri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
                <xsl:variable name="eventOf" select="bu:ontology/bu:document/bu:eventOf/bu:type/bu:value"/>
                <xsl:choose>
                    <xsl:when test="$doc-type eq 'Heading'">
                        <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                    </xsl:when>
                    <xsl:when test="$doc-type = 'Event'">
                        <xsl:variable name="event-href" select="bu:document/@uri"/>
                        <a href="{lower-case($eventOf)}/event?uri={$event-href}">
                            <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{lower-case($doc-type)}/text?uri={$subDocIdentifier}">
                            <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>  
                (<xsl:value-of select="bu:shortName"/>)
            </div>
            <div class="clear"/>
            <br/>
        </div>
    </xsl:template>
    <xsl:template match="ref" mode="render-by-date">
        <div class="schedule-block">
            <div class="left">
                <a href="sitting?uri={@sitting}" title="i18n(sittinglink,go to sitting-nt)">
                    <xsl:value-of select="format-dateTime(bu:startDate,'[h]:[m]:[s] [P,2-2]','en',(),())"/>
                </a>
            </div>
            <div class="right">
                <ul class="scheduling">
                    <li>
                        <xsl:value-of select="bu:ontology/bu:legislature/bu:shortName"/>
                    </li>
                    <xsl:for-each select="bu:ontology">
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