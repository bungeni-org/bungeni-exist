<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:variable name="input-qrystr" select="/docs/paginator/qryStr"/>
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    Search Results “<span class="quoted-qry">
                        <xsl:value-of select="$input-qrystr"/>
                    </span>”
                </h1>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <!-- render the paginator -->
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:apply-templates select="paginator"/>
                        <div id="search-n-sort" class="search-bar">
                            <!-- listing search removed -->
                        </div>
                    </div>
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div class="toggler-list" id="expand-all">- compress all</div>
                    </div>                    
                    <!-- render the actual listing-->
                    <xsl:apply-templates select="legis"/>
                    <xsl:apply-templates select="groups"/>
                    <xsl:apply-templates select="members"/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    
    <!-- Include the paginator generator -->
    <xsl:include href="paginator.xsl"/>
    
    <!-- legislative items -->
    <xsl:template match="legis">
        <ul id="list-toggle" class="ls-row clear">
            <xsl:if test="not(none)">
                <xsl:apply-templates mode="renderui1"/>
            </xsl:if>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui1">
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
            <a href="{lower-case(bu:ontology/bu:document/bu:docType/bu:value)}-text?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
            </a>
            &#160;›&#160;
            <a class="van-light" href="member?uri={bu:ontology/bu:document/bu:owner/bu:person/@href}" id="{bu:ontology/bu:document/bu:owner/bu:person/@href}">
                <xsl:attribute name="title">Primary Sponsor</xsl:attribute>
                <xsl:value-of select="bu:ontology/bu:document/bu:owner/bu:person/@showAs"/>
            </a>
            <span>-</span>
            <div class="doc-toggle">
                <div class="search-subh">
                    <xsl:value-of select="format-dateTime(bu:ontology/child::*/bu:statusDate,$datetime-format,'en',(),())"/>
                    &#160;-&#160;
                    <i>status</i>&#160;<xsl:value-of select="bu:ontology/child::*/bu:status/bu:value"/>
                </div>
                <br/>
                <div class="black-full">
                    <xsl:value-of select="substring(bu:ontology/bu:document/bu:body,0,320)"/> ...               
                </div>
            </div>
        </li>
    </xsl:template>
    
    
    <!-- groups items -->
    <xsl:template match="groups">
        <ul id="list-toggle" class="ls-row" style="clear:both">
            <xsl:if test="not(none)">
                <xsl:apply-templates mode="renderui2"/>
            </xsl:if>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui2">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:group/@uri"/>
        <li>
            <a href="{lower-case(bu:ontology/bu:group/bu:docType/bu:value)}-text?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
            </a>
            <div class="struct-ib">/ <xsl:value-of select="bu:ontology/bu:legislature/bu:parentGroup/bu:shortName"/>
            </div>
            <span>-</span>
            <div class="doc-toggle">
                <div class="search-subh">
                    <i>start date</i>&#160;<xsl:value-of select="format-date(bu:ontology/bu:group/bu:startDate, '[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
                    &#160;-&#160;
                    <i>status</i>&#160;<xsl:value-of select="bu:ontology/child::*/bu:status/bu:value"/>
                </div>
                <br/>
                <div class="black-full">
                    <xsl:value-of select="substring(bu:ontology/bu:group/bu:description,0,320)"/> ...               
                </div>
            </div>
        </li>
    </xsl:template> 
    
    <!-- members items -->
    <xsl:template match="members">
        <ul id="list-toggle" class="ls-row clear">
            <xsl:if test="not(none)">
                <xsl:apply-templates mode="renderui3"/>
            </xsl:if>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui3">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <li>
            <a href="member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:membership/bu:titles,'. ',bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
            </a>
            <div class="struct-ib">/ Constitutency / Party</div>
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
                        <td class="labels">gender:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:membership/bu:gender"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">date of birth:</td>
                        <td>
                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:dateOfBirth),$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:membership/bu:status"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>