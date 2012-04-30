<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Apr 17, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Generic templates for viewing group documents</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    
    <!--PARAMS 
        
        Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="version"/>
    <xsl:template name="grp-item" match="doc">
        <xsl:variable name="ver-id" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/@type"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <!-- Group Document Title -->
            <xsl:call-template name="doc-item-title"/>
            <!-- Renders tab-feature to the view -->
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="uri">
                    <xsl:value-of select="$doc-uri"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">profile</xsl:with-param>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <!-- The header information on the group documents -->
                    <xsl:call-template name="doc-item-preface"/>
                    
                    <!-- Call status info and body -->
                    <xsl:call-template name="doc-item-body"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- DOC_ITEM-TITLE -->
    <xsl:template name="doc-item-title">
        <div id="title-holder" class="theme-lev-1-only">
            <h1 id="doc-title-blue">
                <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
            </h1>
        </div>
    </xsl:template>
    
    <!-- DOC-ITEM_PREFACE -->
    <xsl:template name="doc-item-preface">
        <xsl:param name="doc-type"/>
        <h3 id="doc-heading" class="doc-headers">
            KENYA PARLIAMENT
        </h3>
        <h4 id="doc-item-desc" class="doc-headers">
            <xsl:value-of select="bu:ontology/bu:group/bu:shortName"/>
        </h4>
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
            <i18n:text key="language">language(nt)</i18n:text>: 
            <i>
                <xsl:value-of select="bu:ontology/bu:bungeni/bu:language"/>
            </i>
        </h4>
    </xsl:template>
    
    <!-- DOC-ITEM-SPONSOR -->
    <xsl:template name="doc-item-sponsor">
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey camel-txt">
            <i18n:text key="pri-sponsor">primary sponsor(nt)</i18n:text>: <i>
                <a href="member?uri={bu:ontology/bu:legislativeItem/bu:owner/@href}">
                    <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:owner/@showAs"/>
                </a>
            </i>
        </h4>
    </xsl:template>
    
    <!-- DOC-ITEM-SIGNATORIES -->
    <xsl:template name="doc-item-sponsors">
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
            <i18n:text key="sponsors">Sponsors(nt)</i18n:text>: ( 
            <xsl:choose>
                <!-- check whether we have signatories or not -->
                <xsl:when test="bu:ontology/bu:signatories">
                    <xsl:for-each select="bu:ontology/bu:signatories/bu:signatory">
                        <i>
                            <a href="member?uri={@href}">
                                <xsl:value-of select="@showAs"/>
                            </a>
                        </i>
                        <xsl:if test="position() &lt; last()">,</xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text key="none">None(nt)</i18n:text>
                </xsl:otherwise>
            </xsl:choose> 
            )
        </h4>
    </xsl:template>
    
    
    <!-- DOC-ITEM-BODY -->
    <xsl:template name="doc-item-body">
        <div class="doc-status">
            <span>
                <b>
                    <i18n:text key="acronym">acronym(nt)</i18n:text>:</b>
            </span>
            <span>
                <xsl:value-of select="bu:ontology/bu:group/bu:shortName"/>
            </span>
            <span>
                <b>
                    <i18n:text key="date-start">start date(nt)</i18n:text>:</b>
            </span>
            <span>
                <xsl:value-of select="format-date(bu:ontology/bu:group/bu:startDate,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
            </span>
        </div>
        <div id="doc-content-area">
            <div>
                <xsl:copy-of select="bu:ontology/bu:legislature/bu:description"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>