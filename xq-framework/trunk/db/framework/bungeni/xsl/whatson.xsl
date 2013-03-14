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
    <xsl:param name="meeting-type"/>
    <xsl:param name="whatson-view"/>
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>    
    
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>
    <xsl:variable name="label" select="/docs/paginator/i18nlabel"/>
    <xsl:key name="titleName" match="bu:shortName" use="./text()"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()                 [not(self::bu:shortName)]|bu:shortName[generate-id() = generate-id(key('titleName', ./text())[1])]"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!--
        MAIN RENDERING TEMPLATE
    -->
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder">
                <ul id="utility-nav">
                    <xsl:for-each select="/docs/paginator/whatsonviews/whatsonview">
                        <li>
                            <xsl:if test="@id eq $whatson-view">
                                <xsl:attribute name="class">selected</xsl:attribute>
                            </xsl:if>
                            <a href="{$chamber}/whatson?tab={$listing-tab}&amp;showing={@id}&amp;mtype={$meeting-type}">
                                <i18n:text key="{@id}">whatsonview(nt)</i18n:text>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <!-- Renders tabs -->
            <div id="tab-menu" class="ls-tabs">
                <ul class="tabbernav">
                    <xsl:for-each select="/docs/paginator/tags/tag">
                        <li>
                            <xsl:if test="@id eq $listing-tab">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <a href="{$chamber}/whatson?tab={@id}">
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
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="uri">null</xsl:with-param>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">             
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header whatson-filter">
                        <form method="GET" action="{$chamber}/whatson" id="ui_search" name="search_sort" autocomplete="off">
                            <i18n:text key="meeting-type">meeting type(nt)</i18n:text>: 
                            <!-- call the filters -->
                            <input name="tab" type="hidden" value="{$listing-tab}"/>
                            <input name="showing" type="hidden" value="{$whatson-view}"/>
                            <select name="mtype" id="mtype">
                                <xsl:for-each select="/docs/paginator/meetingtypes/meetingtype">
                                    <xsl:choose>
                                        <xsl:when test=". eq $meeting-type">
                                            <option value="{.}" selected="selected">
                                                <i18n:text key="{.}">
                                                    <xsl:value-of select="."/>(nt)</i18n:text>
                                            </option>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <option value="{.}">
                                                <i18n:text key="{.}">
                                                    <xsl:value-of select="."/>(nt)</i18n:text>
                                            </option>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </select>
                            <!--input value="i18n(btn-submit,submit)" type="submit"/-->
                        </form>
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
                                            <i18n:text key="compress">▼&#160;compress all(nt)</i18n:text>
                                        </span>
                                        <span id="i-expand">
                                            <i18n:text key="expand">►&#160;expand all(nt)</i18n:text>
                                        </span>
                                    </div>
                                    <div class="toggler-list" id="expand-all">▼&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
                                    </div>
                                </div>
                            </xsl:if>
                            <xsl:apply-templates select="alisting"/>
                        </div>
                        <div class="right">
                            <p id="range-cal"/>
                            <form class="whatson-form" id="whatson-filter-form" name="whatson_filter_form" method="GET" action="whatson">
                                <input type="hidden" value="{$listing-tab}" name="tab"/>
                                <input type="hidden" value="{$meeting-type}" name="mtype"/>
                                <input type="hidden" value="none" name="showing"/>
                                <input type="hidden" value="{substring-before(//range/start,'T')}" name="f" id="hidden-start"/>
                                <input type="hidden" value="{substring-before(//range/end,'T')}" name="t" id="hidden-end"/>
                                <br/>
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
                        <i18n:text key="{$whatson-view}">on selected view(nt)</i18n:text>&#160;-
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
                <xsl:when test="@title = ''">
                    <xsl:text>unknown documents</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@title"/>
                </xsl:otherwise>
            </xsl:choose>
            <span class="tgl-pad-right">▼&#160;</span>
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
                <a href="{$chamber}/sitting?uri={@sitting}" title="i18n(sittinglink,go to sitting-nt)">
                    <xsl:value-of select="format-dateTime(bu:startDate,'[F] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                </a>
            </div>
            <div class="right">
                <xsl:variable name="subDocIdentifier" select="bu:sourceItem/@href"/>
                <xsl:variable name="doc-type" select="bu:sourceItem/bu:refersTo/bu:type/bu:value"/>
                <xsl:variable name="eventOf" select="bu:ontology/bu:document/bu:eventOf/bu:type/bu:value"/>
                <a href="{$chamber}/{lower-case($doc-type)}-text?uri={$subDocIdentifier}">
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </a>
                <p class="truncate">
                    <xsl:value-of select="bu:scheduleItem/bu:title"/>
                </p>
            </div>
            <div class="clear"/>
            <br/>
        </div>
    </xsl:template>
    <xsl:template match="ref" mode="render-by-date">
        <div class="schedule-block">
            <div class="left">
                <a href="{$chamber}/sitting?uri={@sitting}" title="i18n(sittinglink,go to sitting-nt)">
                    <xsl:choose>
                        <xsl:when test=".[preceding-sibling::ref/bu:startDate/text() = bu:startDate/text()]"/>
                        <xsl:otherwise>
                            <xsl:value-of select="format-dateTime(bu:startDate,'[h]:[m]:[s] [P,2-2]','en',(),())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
            <div class="right">
                <xsl:choose>
                    <xsl:when test="bu:scheduleItem">
                        <ul class="scheduling">
                            <li>
                                <xsl:choose>
                                    <xsl:when test=".[preceding-sibling::ref/bu:shortName/text() = bu:shortName/text()]"/>
                                    <xsl:otherwise>
                                        <xsl:value-of select="bu:shortName"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="bu:venue ne ''">
                                    &#160;<i>at</i>&#160;<xsl:value-of select="bu:venue"/>
                                </xsl:if>
                            </li>
                            <xsl:for-each select="bu:scheduleItem">
                                <xsl:variable name="subDocIdentifier" select="bu:sourceItem/bu:refersTo/@href"/>
                                <li>
                                    <xsl:variable name="doc-type" select="bu:sourceItem/bu:refersTo/bu:type/bu:value"/>
                                    <xsl:variable name="eventOf" select="bu:sourceItem/bu:eventOf/bu:type/bu:value"/>
                                    <a class="truncate" href="{$chamber}/{lower-case($doc-type)}-text?uri={$subDocIdentifier}">
                                        <xsl:value-of select="bu:title"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="bu:shortName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
        <div class="clear"/>
        <br/>
    </xsl:template>
</xsl:stylesheet>