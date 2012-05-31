<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bun="http://exist.bungeni.org/bun" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:param name="item-listing-rel-base"/>

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
                    <i18n:text key="list-t-{lower-case($label)}">legis-items(nt)</i18n:text>
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
                            <a href="{$item-listing-rel-base}?tab={@id}">
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
                <xsl:with-param name="doc-type" select="lower-case($input-document-type)"/>
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
        <!--div border="0" style="border-style:none !important;height:18px;width:18px;background:transparent url(assets/bungeni/images/breadcrumbs.png) no-repeat left -197px"/-->
        <li>
            <a href="{$listing-url-prefix}?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
            </a>
            &#160;›&#160;
            <a style="color:#1f34fd" href="member?uri={bu:ontology/bu:document/bu:owner/bu:person/@href}" id="{bu:ontology/bu:document/bu:owner/bu:person/@href}">
                <xsl:attribute name="title">Primary Sponsor</xsl:attribute>
                <xsl:value-of select="bu:ontology/bu:document/bu:owner/bu:person/@showAs"/>
            </a>
            <span>-</span>
            <div class="doc-toggle">
                <div class="black-full">
                    <xsl:value-of select="substring(bu:ontology/bu:document/bu:body,0,320)"/> ...               
                </div>
                <div class="grey-full">
                    <span>
                        <xsl:value-of select="bu:ontology/bu:document/bu:status/bu:value"/>
                    </span>
                    <span>
                        on                         
                        <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                    </span>
                    &#160;
                    <span style="vertical-align:0;line-height:1em !important;padding:0;margin:0px;">·</span>
                    &#160;  
                    <span>
                        presented as <xsl:value-of select="bu:ontology/bu:document/bu:docSubType/bu:value"/>&#160;<xsl:value-of select="lower-case($input-document-type)"/>
                    </span>
                </div>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>