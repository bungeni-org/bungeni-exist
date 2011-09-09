<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 14, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> ashok</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="html" />
    
    <xsl:param name="searchin" />
    <xsl:param name="searchfor" select="'Civil'"></xsl:param>
    <xsl:param name="q" select="'Civil'"></xsl:param>
    
    <xsl:variable name="resultsCount" select="count(//docs/doc)"></xsl:variable>
    
    <xsl:template match="docs">
        <div>
        <input type="hidden" name="qfield" id="adsearch-qfield" value="{$q}" />
        <div class="summary-results" id="adv-summary">
            <span class="title-summary">Result Groups</span>
            <xsl:call-template name="tocYear" />
            <xsl:call-template name="tocCat" />
        </div>
        <div class="search-results" id="adv-rs">
         <span class="results-desc">Found matches in <xsl:value-of select="$resultsCount" /> acts</span>
            <xsl:apply-templates />
        </div>
        </div>    
    </xsl:template>
    
    
    <xsl:template name="tocCat">
        <div id="toc-cat">
            <span class="title-toc">GOK Category</span>
            <ul class="cat">
                <xsl:for-each-group select=".//doc" group-by="category/@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <li>
                        <xsl:if test="position() = last()">
                            <xsl:attribute name="class">last</xsl:attribute>
                        </xsl:if>
                        <a href="#"><xsl:value-of select="current-grouping-key()" /><xsl:text> </xsl:text>(<xsl:value-of select="count(current-group())" />)</a>
                    </li>
                </xsl:for-each-group>
            </ul>
        </div>
    </xsl:template>
    
    
    <xsl:template name="tocYear">
        <div id="toc-year">
            <span class="title-toc">Year/Month</span>
            <ul class="year">
                <xsl:for-each-group select=".//doc" group-by="date/year">
                    <xsl:sort select="current-grouping-key()"/>
                    <li>
                        <xsl:if test="position() = last()">
                                <xsl:attribute name="class">last</xsl:attribute>
                        </xsl:if>
                        <xsl:variable name="current-year"><xsl:value-of select="current-grouping-key()"></xsl:value-of></xsl:variable>
                        <xsl:variable name="search-href-prefix">
                            <xsl:text>ftsearch.xql?</xsl:text>
                            <xsl:text>searchfor=</xsl:text><xsl:value-of select="$searchfor" />
                            <xsl:text>&amp;</xsl:text>
                            <xsl:text>searchin=</xsl:text><xsl:value-of select="$searchin" />
                        </xsl:variable>
                        <xsl:variable name="search-href-prefix-yy"><xsl:value-of select="$search-href-prefix" />&amp;restrictyy=<xsl:value-of select="$current-year"></xsl:value-of></xsl:variable>
                        <a href="#" onClick="javascript:filterYear({$current-year});return false;">
                            <xsl:copy-of select="current-grouping-key()"/>(<xsl:value-of select="count(current-group())"/>)
                        </a>
                        <ul class="months">
                            <xsl:for-each-group select="current-group()" group-by="date/month">
                                <xsl:sort select="current-grouping-key()"/>
                                <li class="last">
                                    <xsl:variable name="month-name">
                                        <xsl:call-template name="strDate">
                                            <xsl:with-param name="month">
                                                <xsl:value-of select="current-grouping-key()"/>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="match-count">
                                        <xsl:value-of select="count(current-group())"/>
                                    </xsl:variable>
                                    <xsl:variable name="current-month"><xsl:value-of select="current-grouping-key()" /></xsl:variable>
                                    <xsl:variable name="search-href-prefix-mm"><xsl:value-of select="$search-href-prefix-yy" />&amp;restrictmm=<xsl:value-of select="$current-month"></xsl:value-of></xsl:variable>
                                    <a href="#" onClick="javascript:filterMonth({$current-year},{$current-month}); return false;"><xsl:value-of select="$month-name" /><xsl:text> </xsl:text>(<xsl:value-of select="$match-count" />)</a>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                    </li>
                </xsl:for-each-group>
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template name="strDate">
        <xsl:param name="month"/>
        <xsl:choose>
            <xsl:when test="$month=1">January</xsl:when>
            <xsl:when test="$month=2">February</xsl:when>
            <xsl:when test="$month=3">March</xsl:when>
            <xsl:when test="$month=4">April</xsl:when>
            <xsl:when test="$month=5">May</xsl:when>
            <xsl:when test="$month=6">June</xsl:when>
            <xsl:when test="$month=7">July</xsl:when>
            <xsl:when test="$month=8">August</xsl:when>
            <xsl:when test="$month=9">September</xsl:when>
            <xsl:when test="$month=10">October</xsl:when>
            <xsl:when test="$month=11">November</xsl:when>
            <xsl:when test="$month=12">December</xsl:when>
            <xsl:otherwise>INVALID MONTH</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
 
    <xsl:template match="doc">
        <div class="search-result">
           <span class="capno"><xsl:value-of select="number" /></span>
           <a target="_blank" href="actviewhilite.xql?actid={@actid}&amp;searchfor={$searchfor}&amp;searchin={$searchin}" title="click to view : {title}"><xsl:value-of select="title" /></a>
           <div class="result-matches">
            <span class="lbl-result-matches">Found <xsl:value-of select="count(./child::p)" /> instance(s) of <xsl:value-of select="$searchfor" /> in <xsl:value-of select="$searchin" /></span>
           <div class="result-matches-list">
           <xsl:apply-templates select="p[1]" mode="results" />
           </div>
           </div>
        </div>
    </xsl:template>

    <xsl:template match="p" mode="results">
        <p>
        <xsl:copy-of select="./child::node()" copy-namespaces="no"/>
        </p>
    </xsl:template>
</xsl:stylesheet>
