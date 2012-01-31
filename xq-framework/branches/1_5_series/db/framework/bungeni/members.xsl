<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <i18n:text key="list-t-members">Members of Parliament(nt)</i18n:text>
                </h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
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
                            <i18n:text key="archive">archived(nt)</i18n:text>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="#" title="print this page listing" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                </ul>
            </div>
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
                        <div id="toggle-i18n" style="display:none;">
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
        <ul id="list-toggle" class="ls-row" style="clear:both">
            <xsl:apply-templates mode="renderui">
                <xsl:sort select="bu:ontology/bu:user/bu:firstName" order="ascending"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="output" mode="renderui">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:user/@uri"/>
        <li>
            <a href="member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:user/bu:titles,'. ',bu:ontology/bu:user/bu:firstName,' ', bu:ontology/bu:user/bu:lastName)"/>
            </a>
            <div style="display:inline-block;">/ Constitutency / Party</div>
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
                            <i18n:text key="gender">gender(nt)</i18n:text>:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:user/bu:gender"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">
                            <i18n:text key="dob">date of birth(nt)</i18n:text>:</td>
                        <td>
                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:user/bu:dateOfBirth),$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">
                            <i18n:text key="status">status(nt)</i18n:text>:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:user/bu:status"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>