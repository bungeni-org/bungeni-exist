<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bun="http://exist.bungeni.org/bun" xmlns:an="http://www.akomantoso.org/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
                <h1 id="doc-title-blue-center">
                    <i18n:text key="listing">List of&#160;</i18n:text>
                    <!-- Capitalize the first letter -->
                    <i18n:text key="list-t-{$label}">legis-items(nt)</i18n:text>
                </h1>
            </div>
            <!-- Renders listings tabs -->
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <xsl:for-each select="/docs/paginator/tags/tag">
                        <li>
                            <xsl:if test="@id eq $listing-tab">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <a href="?tab={@id}">
                                <i18n:translate>
                                    <i18n:text key="{@id}">Text to translate with ({1})</i18n:text>
                                    <i18n:param>
                                        <xsl:value-of select="@count"/>
                                    </i18n:param>
                                </i18n:translate>
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
                        <div class="toggler-list" id="expand-all">-&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
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
        <xsl:variable name="docIdentifier" select="an:akomaNtoso/child::*/an:meta/an:identification/an:FRBRWork/an:FRBRuri/@value"/>
        <li>
            <a href="{$listing-url-prefix}?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="an:akomaNtoso/child::*/an:preface//an:docTitle"/>
            </a>
            <span>-</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <tr>
                        <td class="labels">id:</td>
                        <td>
                            <xsl:value-of select="$docIdentifier"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">
                            <i18n:text key="pri-sponsor">primary sponsor(nt)</i18n:text>:</td>
                        <td>
                            <a href="member?uri={bu:ontology/bu:legislativeItem/bu:owner/@href}" id="{bu:ontology/bu:legislativeItem/bu:owner/@href}">
                                <xsl:value-of select="an:akomaNtoso/child::*/an:meta/an:references/an:TLCPerson/@showAs"/>
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">
                            <i18n:text key="assent-date">date of assent</i18n:text>:</td>
                        <td>
                            <xsl:value-of select="format-date(an:akomaNtoso/child::*/an:meta/an:identification/an:FRBRWork/an:FRBRdate/@date,$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">
                            <i18n:text key="ministry">ministry(nt)</i18n:text>:</td>
                        <td>
                            <xsl:value-of select="ref/bu:ministry/bu:shortName"/>
                        </td>
                    </tr>
                    <xsl:if test="bu:ontology/bu:question/bu:item_assignments">
                        <tr>
                            <td class="labels">
                                <i18n:text key="assignedto">assigned to(nt)</i18n:text>:</td>
                            <td>
                                <a href="#" id="{bu:ontology/bu:legislativeItem/bu:owner/@href}">
                                    <xsl:value-of select="bu:ontology/bu:question/bu:group/@isA"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>