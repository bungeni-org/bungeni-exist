<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>

    <!-- DOCUMENTATION -->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 5, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>
                
                Search legislative items from Bungeni

                    
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
        <document>
         <output> 
            <bu:ontology .../>
    
         </output>
         <referenceInfo>
            <ref>
            </ref>
         </referenceInfo>
    </alisting>
    </docs>
    -->
    <!-- INPUT PARAMETERS -->

    <!-- +SORT_ORDER(ah,nov-2011) pass the sort ordr into the XSLT-->
    <xsl:param name="sortby"/>

    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>

    <!--
        MAIN RENDERING TEMPLATE
        -->
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <xsl:text>Search results in&#160;</xsl:text>
                    <!-- Capitalize the first letter -->
                    <xsl:value-of select="concat(upper-case(substring($input-document-type, 1, 1)), substring($input-document-type, 2))"/>s</h1>
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
                        <a href="{$input-document-type}s/rss" title="get as RSS feed" class="rss">
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
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:apply-templates select="paginator"/>
                        <div id="search-n-sort" class="search-bar" style="display:inline;">
                            <xsl:variable name="searchins" select="xqcfg:get_searchin($input-document-type)"/>
                            <xsl:variable name="orderbys" select="xqcfg:get_orderby($input-document-type)"/>
                            <xsl:if test="$searchins and $orderbys">
                                <form method="GET" action="search" id="ui_search" name="search_sort" autocomplete="off">
                                    <input type="hidden" name="type" value="{$input-document-type}"/>
                                    <label class="search_for" for="search_for">Search text:&#160;</label>
                                    <dl id="sb_box" class="dropdown">
                                        <dt>
                                            <input id="search_for" name="q" class="search_for" type="text" value="{paginator/searchString}"/>
                                            <a style="display:inline" href="#"/>
                                        </dt>
                                        <dd>
                                            <ul class="sb_dropdown">
                                                <li class="sb_filter">Filter your search</li>
                                                <li>
                                                    <input type="checkbox" name="all" value="on"/>
                                                    <label for="all">
                                                        <b>Entire Document</b>
                                                    </label>
                                                </li>
                                                <xsl:for-each select="$searchins/searchin">
                                                    <li>
                                                        <input type="checkbox" name="{@value}" value="on">
                                                            <!-- Title is set as the default search area -->
                                                            <xsl:if test="@value eq 'on'">
                                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                                            </xsl:if>
                                                        </input>
                                                        <label for="{@value}">
                                                            <xsl:value-of select="./text()"/>
                                                        </label>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </dd>
                                    </dl>
                                    <div style="display:inline;">
                                        <label for="search_in">sort by:</label>
                                        <select name="s" id="sort_by">
                                            <xsl:for-each select="$orderbys/orderby">
                                                <option value="{@value}">
                                                    <xsl:value-of select="./text()"/>
                                                </option>
                                            </xsl:for-each>
                                        </select>
                                        <input value="search" type="submit"/>
                                    </div>
                                </form>
                            </xsl:if>
                        </div>
                    </div>
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div class="toggler-list" id="expand-all">- compress all</div>
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


    <!-- 
    !+LISTING_GENERATOR
    Listing generator template 
    -->
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row clear">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui">
        <xsl:variable name="docIdentifier" select="output/bu:ontology/bu:legislativeItem/@uri"/>
        <li>
            <a href="{$listing-url-prefix}?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="output/bu:ontology/bu:legislativeItem/bu:shortName"/>
            </a>
            <span>-</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <tr>
                        <td class="labels">id:</td>
                        <td>
                            <xsl:value-of select="output/bu:ontology/bu:legislativeItem/bu:registryNumber"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">primary sponsor:</td>
                        <td>
                            <a href="member?uri={output/bu:ontology/bu:legislativeItem/bu:owner/@href}" id="{output/bu:ontology/bu:legislativeItem/bu:owner/@href}">
                                <xsl:value-of select="output/bu:ontology/bu:legislativeItem/bu:owner/@showAs"/>
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">last event:</td>
                        <td>
                            <xsl:value-of select="output/bu:ontology/bu:legislativeItem/bu:status"/>
                            &#160;&#160;<b>on:</b>&#160;&#160;
                            <xsl:value-of select="format-dateTime(output/bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">submission date:</td>
                        <td>
                            <xsl:value-of select="format-date(output/bu:ontology/bu:bungeni/bu:parliament/@date,$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">ministry:</td>
                        <td>
                            <xsl:value-of select="referenceInfo/ref/bu:ministry/bu:shortName"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>