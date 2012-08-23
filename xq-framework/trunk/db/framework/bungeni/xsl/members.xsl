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
    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <i18n:text key="list-t-members">Members of Parliament(nt)</i18n:text>
                </h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="tabbernav">
                    <li class="active">
                        <a href="#">
                            <i18n:text key="list-tab-cur">current(nt)</i18n:text>
                            <xsl:text>&#160;(</xsl:text>
                            <xsl:value-of select="paginator/count"/>
                            <xsl:text>)</xsl:text>
                        </a>
                    </li>
                    <li>
                        <a href="#">
                            <i18n:translate>
                                <i18n:text key="former">former ({1})</i18n:text>
                                <i18n:param>
                                    <xsl:value-of select="@count"/>
                                </i18n:param>
                            </i18n:translate>
                        </a>
                    </li>
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
                                <i18n:text key="compress">- compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">+ expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">- <i18n:text key="compress">compress all(nt)</i18n:text>
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
            <xsl:apply-templates mode="renderui">
                <xsl:sort select="bu:ontology/bu:membership/bu:firstName" order="ascending"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <li>
            <a href="member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:membership/bu:salutation,'. ',bu:ontology/bu:membership/bu:lastName,', ', bu:ontology/bu:membership/bu:firstName)"/>
            </a>
            <div class="struct-ib">/ <xsl:value-of select="bu:ontology/bu:membership/bu:group/bu:type/bu:value"/> / <xsl:value-of select="bu:ontology/bu:legislature/bu:shortName"/>
            </div>
            <span>-</span>
            <div class="doc-toggle">
                <div style="min-height:110px;">
                    <p class="imgonlywrap photo-listing" style="float:left;">
                        <xsl:variable name="img_uuid" select="ref/bu:ontology/bu:image/bu:imageUuid"/>
                        <xsl:choose>
                            <xsl:when test="ref/bu:ontology/bu:image and doc-available(concat('../../../bungeni-atts/',$img_uuid))">
                                <img src="../../bungeni-atts/{$img_uuid}" alt="Place Holder for M.P Photo" align="left"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="assets/images/placeholder.jpg" alt="No Photo Available" align="left"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:startDate),$date-format,'en',(),())"/>
                        </span>
                    </div>
                    <div class="block">
                        <span class="labels">
                            <i18n:text key="email">short bio(nt)</i18n:text>:</span>
                        <span>
                            <xsl:value-of select="substring(bu:ontology/bu:membership/bu:description,0,360)"/>...
                        </span>
                    </div>
                </div>
                <div class="clear"/>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>