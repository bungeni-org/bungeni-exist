<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:param name="version"/>
    <xsl:template name="doc-item" match="doc">
        <xsl:variable name="ver-uri" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
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
                <xsl:with-param name="ver-uri" select="$ver-uri"/>
            </xsl:call-template>
            <!-- Renders tab-feature to the view -->
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:choose>
                        <xsl:when test="$version eq 'true'">
                            <xsl:value-of select="concat($doc-type,'-ver')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$doc-type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="uri">
                    <xsl:choose>
                        <xsl:when test="$version eq 'true'">
                            <xsl:value-of select="$ver-uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$doc-uri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="tab-path">text</xsl:with-param>
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
                    <!-- If there is a versions node in this document, there are
                        rendered at this juncture -->
                    <xsl:call-template name="doc-item-versions">
                        <xsl:with-param name="ver-uri" select="$ver-uri"/>
                        <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                        <xsl:with-param name="doc-uri" select="$doc-uri"/>
                    </xsl:call-template>
                    <!-- The header information on the documents -->
                    <xsl:call-template name="doc-item-preface">
                        <xsl:with-param name="doc-type" select="$doc-type"/>
                    </xsl:call-template>
                    <!-- The body section of the document -->
                    <xsl:call-template name="doc-item-body">
                        <xsl:with-param name="ver-uri" select="$ver-uri"/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- DOC-ITEM-TITLE -->
    <xsl:template name="doc-item-title">
        <xsl:param name="ver-uri"/>
        <div id="title-holder" class="theme-lev-1-only">
            <h1 id="doc-title-blue">
                <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                <!-- If its a version and not a main document... add version title below main title -->
                <xsl:if test="$version eq 'true'">
                    <br/>
                    <span class="doc-sub-title-red">Version - <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-uri]/bu:statusDate,$datetime-format,'en',(),())"/>
                    </span>
                </xsl:if>
            </h1>
        </div>
    </xsl:template>    
    
    
    <!-- DOC-ITEM-VERSIONS -->
    <xsl:template name="doc-item-versions">
        <xsl:param name="ver-uri"/>
        <xsl:param name="doc-type"/>
        <xsl:param name="doc-uri"/>
        <xsl:if test="$version eq 'true'">
            <div class="rounded-eigh tab_container hanging-menu">
                <ul class="doc-versions">
                    <li>
                        <a href="{$doc-type}/text?uri={$doc-uri}">current</a>
                    </li>
                    <xsl:variable name="total_versions" select="count(bu:ontology/bu:document/bu:versions/bu:version)"/>
                    <xsl:for-each select="bu:ontology/bu:document/bu:versions/bu:version">
                        <xsl:sort select="bu:statusDate" order="descending"/>
                        <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                        <li>
                            <xsl:choose>
                                            <!-- if current URI is equal to this versions URI -->
                                <xsl:when test="$ver-uri eq @uri">
                                    <span>version-<xsl:value-of select="$cur_pos"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="{lower-case($doc-type)}/version/text?uri={@uri}">
                                                    Version-<xsl:value-of select="$cur_pos"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    <!-- DOC-ITEM-PREFACE -->
    <xsl:template name="doc-item-preface">
        <xsl:param name="doc-type"/>
        <h3 id="doc-heading" class="doc-headers">
            <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS -->
            KENYA PARLIAMENT
        </h3>
        <h4 id="doc-item-desc" class="doc-headers">
            <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
        </h4>
        <!-- Call document item number -->
        <xsl:call-template name="doc-item-number">
            <xsl:with-param name="doc-type" select="$doc-type"/>
        </xsl:call-template>
        <!-- Call sponsor where applicable -->
        <xsl:call-template name="doc-item-sponsor"/>
        
        <!-- Call secondary sponsors where applicable -->
        <xsl:call-template name="doc-item-sponsors"/>
    </xsl:template>
    
    <!-- DOC-ITEM-NUMBER -->
    <xsl:template name="doc-item-number">
        <xsl:param name="doc-type"/>
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey camel-txt">
            <i18n:text key="doc-{lower-case($doc-type)}">Bill(nt)</i18n:text>&#160;<i18n:text key="number">Number(nt)</i18n:text>: 
            <xsl:value-of select="bu:ontology/bu:document/bu:itemNumber"/>
        </h4>
    </xsl:template>
    
    <!-- DOC-ITEM-SPONSOR -->
    <xsl:template name="doc-item-sponsor">
        <h4 id="doc-item-desc2" class="doc-headers-darkgrey camel-txt">
            <i18n:text key="pri-sponsor">primary sponsor(nt)</i18n:text>: <i>
                <a href="member?uri={bu:ontology/bu:document/bu:owner/bu:person/@href}">
                    <xsl:value-of select="bu:ontology/bu:document/bu:owner/bu:person/@showAs"/>
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
                            <a href="member?uri={bu:person/@href}">
                                <xsl:value-of select="bu:person/@showAs"/>
                            </a>
                        </i>
                        <xsl:if test="position() &lt; last()">,</xsl:if>
                        &#160;
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
        <xsl:param name="ver-uri"/>
        <xsl:variable name="ref-audit" select="substring-after(bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-uri]/bu:refersToAudit/@href,'#')"/>
        <xsl:variable name="render-doc" select="if ($version eq 'true') then                         bu:ontology/bu:document/bu:audits/bu:audit[@id=$ref-audit]                          else                         bu:ontology/bu:document                         "/>
        <h4 class="doc-status">
            <span>
                <b class="camel-txt">
                    <i18n:text key="last-event">Last Event(nt)</i18n:text>:</b>
            </span>
            <span>
                <xsl:value-of select="$render-doc/bu:status"/>
            </span>
            <span>
                <b class="camel-txt">
                    <i18n:text key="date-on">Date(nt)</i18n:text>:</b>
            </span>
            <span>
                <xsl:value-of select="format-dateTime($render-doc/bu:statusDate,$datetime-format,'en',(),())"/>
            </span>
        </h4>
        <div id="doc-content-area">
            <div>
                <xsl:choose>
                    <xsl:when test="matches($render-doc/bu:body/text(),'&lt;')">
                        <xsl:copy-of select="fringe"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$render-doc/bu:body"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>