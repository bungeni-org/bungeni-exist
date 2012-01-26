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
                
                Lists bills from Bungeni

                    
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
        <div id="main-wrapper" class="bun:translate?lang=sw&amp;catalogues=/db/framework/i18n">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <i18n:text key="qnsList">Liste of&#160;</i18n:text>
                    <!-- Capitalize the first letter -->
                    <xsl:value-of select="concat(upper-case(substring($input-document-type, 1, 1)), substring($input-document-type, 2))"/>s</h1>
                <div style="border:1px solid red;width:200px;">
                    <i18n:text key="business">testbiz</i18n:text>
                </div>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <li class="active">
                        <a href="#">
                            <xsl:text>under consideration (</xsl:text>
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