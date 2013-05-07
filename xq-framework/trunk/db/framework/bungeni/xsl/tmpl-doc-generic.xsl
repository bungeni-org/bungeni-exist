<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Apr 16, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Generic templates for viewing documents</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>   
    
    <!--PARAMS 
        Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="epub"/>
    <xsl:param name="chamber-id"/>
    <xsl:param name="version"/>
    <xsl:param name="version-uri"/>
    <xsl:template name="doc-item" match="doc">
        <xsl:variable name="ver-uri" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
        <xsl:variable name="chamber" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="versions">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/bu:versions/bu:version">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc-uri">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/@uri">
                    <xsl:value-of select="bu:ontology/bu:document/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:document/@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mover-uri" select="bu:ontology/bu:owner/bu:person/@href"/>
        <div id="main-wrapper">
            <!-- Document Title -->
            <xsl:call-template name="doc-item-title">
                <xsl:with-param name="doc-uri" select="$doc-uri"/>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="ver-uri" select="$ver-uri"/>
                <xsl:with-param name="chamber" select="$chamber"/>
            </xsl:call-template>
            <xsl:if test="$epub ne 'true'">
                <!-- Renders tab-feature to the view -->
                <xsl:call-template name="doc-tabs">
                    <xsl:with-param name="tab-group" select="$doc-type"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                    <xsl:with-param name="tab-path">text</xsl:with-param>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="excludes" select="exclude/tab"/>
                </xsl:call-template>
                <!-- Renders the document download types -->
                <xsl:call-template name="doc-formats">
                    <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                    <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                    <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                </xsl:call-template>
            </xsl:if>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <!-- doc-versions -->
                    <xsl:if test="$versions = true()">
                        <xsl:call-template name="doc-versions">
                            <xsl:with-param name="version-uri" select="$version-uri"/>
                            <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                            <xsl:with-param name="doc-uri" select="$doc-uri"/>
                            <xsl:with-param name="chamber" select="$chamber"/>
                        </xsl:call-template>
                    </xsl:if>
                    <!-- Document Emblem -->
                    <xsl:call-template name="doc-item-emblem"/>                    
                    <!-- The header information on the documents -->
                    <xsl:call-template name="doc-item-preface">
                        <xsl:with-param name="doc-type" select="$doc-type"/>
                        <xsl:with-param name="chamber" select="$chamber"/>
                    </xsl:call-template>
                    <!-- The body section of the document -->
                    <xsl:call-template name="doc-item-body">
                        <xsl:with-param name="ver-uri" select="$ver-uri"/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- DOC-ITEM-EMBLEM -->
    <xsl:template name="doc-item-emblem">
        <img class="parl-emblem" src="assets/images/emblem.png" alt="emblem"/>
    </xsl:template>    

    <!-- DOC-ITEM-TITLE -->
    <xsl:template name="doc-item-title">
        <xsl:param name="doc-type"/>
        <xsl:param name="doc-uri"/>
        <xsl:param name="ver-uri"/>
        <xsl:param name="chamber"/>
        <div id="title-holder">
            <h1 class="title">
                <xsl:if test="bu:ontology/bu:document/bu:progressiveNumber">#<xsl:value-of select="bu:ontology/bu:document/bu:progressiveNumber"/>:</xsl:if>
                <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
            </h1>
        </div>
    </xsl:template>
    
    <!-- DOC-ITEM-PREFACE -->
    <xsl:template name="doc-item-preface">
        <xsl:param name="doc-type"/>
        <xsl:param name="chamber"/>
        <h3 id="doc-heading" class="doc-headers">
            <xsl:value-of select="bu:ontology/bu:chamber/bu:type/@showAs"/>
        </h3>
        <h4 id="doc-item-desc" class="doc-headers">
            <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
        </h4>
        <!-- Call document item number -->
        <xsl:call-template name="doc-item-number">
            <xsl:with-param name="doc-type" select="$doc-type"/>
        </xsl:call-template>
        <!-- Call sponsor where applicable -->
        <xsl:call-template name="doc-item-sponsor">
            <xsl:with-param name="chamber" select="$chamber"/>
        </xsl:call-template>
        
        <!-- Call secondary sponsors where applicable -->
        <xsl:call-template name="doc-item-sponsors">
            <xsl:with-param name="chamber" select="$chamber"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- DOC-ITEM-NUMBER -->
    <xsl:template name="doc-item-number">
        <xsl:param name="doc-type"/>
        <xsl:if test="bu:ontology/bu:document/bu:progressiveNumber">
            <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                <i18n:text key="number">number(nt)</i18n:text>: 
                <xsl:value-of select="bu:ontology/bu:document/bu:progressiveNumber"/>
            </h4>
        </xsl:if>
    </xsl:template>
    
    <!-- DOC-ITEM-SPONSOR -->
    <xsl:template name="doc-item-sponsor">
        <xsl:param name="chamber"/>
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
            <i18n:text key="pri-sponsor">primary sponsor(nt)</i18n:text>: <i>
                <a href="{$chamber}/member?uri={bu:ontology/bu:document/bu:owner/bu:person/@href}">
                    <xsl:value-of select="bu:ontology/bu:document/bu:owner/bu:person/@showAs"/>
                </a>
            </i>
        </h4>
    </xsl:template>
    
    <!-- DOC-ITEM-SIGNATORIES -->
    <xsl:template name="doc-item-sponsors">
        <xsl:param name="chamber"/>
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
            <i18n:text key="sponsors">sponsors(nt)</i18n:text>: ( 
            <xsl:choose>
                <!-- check whether we have signatories or not -->
                <xsl:when test="bu:ontology/bu:signatories">
                    <xsl:for-each select="bu:ontology/bu:signatories/bu:signatory[bu:status/bu:value eq 'consented'][bu:person/@href ne ancestor::bu:ontology/bu:document/bu:owner/bu:person/@href]">
                        <i>
                            <a href="{$chamber}/member?uri={bu:person/@href}" title="{bu:status/@showAs}">
                                <xsl:value-of select="bu:person/@showAs"/>
                            </a>
                        </i>
                        <xsl:if test="position() &lt; last()">,</xsl:if>
                        &#160;
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text key="none">none(nt)</i18n:text>
                </xsl:otherwise>
            </xsl:choose> 
            )
        </h4>
    </xsl:template>
    
    
    <!-- DOC-ITEM-BODY -->
    <xsl:template name="doc-item-body">
        <xsl:param name="ver-uri"/>
        <xsl:variable name="ref-audit" select="substring-after(bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-uri]/bu:refersToAudit/@href,'#')"/>
        <xsl:variable name="render-doc" select="if($version = 'true') then bu:ontology/bu:document else bu:ontology/bu:document/bu:versions/bu:version[@uri=$version-uri]"/>
        <p class="inline-centered">
            <span>
                <b>
                    <i18n:text key="last-event">last event(nt)</i18n:text>:</b>
            </span>
            &#160;           
            <span>
                <xsl:value-of select="if (data($render-doc/bu:status/@showAs)) then data($render-doc/bu:status/@showAs) else $render-doc/bu:status/bu:value"/>
            </span>
            &#160;
            <span>
                <b>
                    <i18n:text key="date-on">date(nt)</i18n:text>:</b>
            </span>
            &#160;
            <span>
                <xsl:value-of select="format-dateTime($render-doc/bu:statusDate,$datetime-format,'en',(),())"/>
            </span>
        </p>
        <div id="doc-content-area">
            <div>
                <xsl:choose>
                    <xsl:when test="$render-doc/bu:description">
                        <xsl:copy-of select="$render-doc/bu:description/child::node()"/>
                    </xsl:when>
                    <xsl:when test="matches($render-doc/bu:body/text(),'&lt;')">
                        <xsl:copy-of select="fringe"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$render-doc/bu:body/child::node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
    
    <!-- DOC-VERSIONS -->
    <xsl:template name="doc-versions">
        <xsl:param name="version-uri"/>
        <xsl:param name="doc-type"/>
        <xsl:param name="doc-uri"/>
        <xsl:param name="chamber"/>
        <xsl:variable name="total_versions" select="count(bu:ontology/bu:document/bu:versions/bu:version)"/>
        <div class="doc-views-section">
            <form onsubmit="redirectTo();">
                <label for="eventText" class="inline">
                    There are <xsl:value-of select="$total_versions"/> versions:
                </label>
                <div class="inline">
                    <select name="uri" id="eventText">
                        <option value="{$doc-uri}">
                            -- <i18n:text key="doc-{$doc-type}">main document(nt)</i18n:text> --
                        </option>
                        <xsl:for-each select="bu:ontology/bu:document/bu:versions/bu:version">
                            <xsl:sort select="bu:statusDate" order="descending"/>
                            <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                            <option value="{@uri}">
                                <xsl:if test="$version-uri eq @uri">
                                    <!-- if current URI is equal to this versions URI -->
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="concat(bu:title,' (',format-dateTime(bu:statusDate,$datetime-format,'en',(),()),')')"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="inline">
                    <input type="submit" name="submit" id="submit" value="Go"/>
                </div>
            </form>
        </div>
    </xsl:template>
</xsl:stylesheet>