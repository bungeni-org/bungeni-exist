<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 03, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Question item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="serverport"/>
    <xsl:param name="version"/>
    <xsl:template match="doc">
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/@type"/>
        <xsl:variable name="ver_uri" select="bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_id]/@uri"/>
        <xsl:variable name="doc_uri" select="bu:ontology/bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:shortName"/>
                    
                    <!-- If its a version and not a main document... add version title below main title -->
                    <xsl:if test="$version eq 'true'">
                        <br/>
                        <span class="doc-sub-title-red">Version - <xsl:value-of select="format-dateTime(bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </xsl:if>
                </h1>
            </div>
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
                            <xsl:value-of select="$ver_uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$doc_uri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="tab-path">text</xsl:with-param>
                <xsl:with-param name="excludes" select="exlude/tab"/>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc_uri"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <xsl:if test="$version eq 'true'">
                        <div class="rounded-eigh tab_container hanging-menu">
                            <ul class="doc-versions">
                                <li>
                                    <a href="{bu:ontology/bu:document/@type}/text?uri={bu:ontology/bu:legislativeItem/@uri}">current</a>
                                </li>
                                <xsl:variable name="total_versions" select="count(bu:ontology/bu:legislativeItem/bu:versions/bu:version)"/>
                                <xsl:for-each select="bu:ontology/bu:legislativeItem/bu:versions/bu:version">
                                    <xsl:sort select="bu:statusDate" order="descending"/>
                                    <xsl:variable name="cur_pos" select="($total_versions - position())+1"/>
                                    <li>
                                        <xsl:choose>
                                        <!-- if current URI is equal to this versions URI -->
                                            <xsl:when test="$ver_uri eq @uri">
                                                <span>version-<xsl:value-of select="$cur_pos"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <a href="{$doc-type}/version/text?uri={@uri}">
                                                Version-<xsl:value-of select="$cur_pos"/>
                                                </a>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </xsl:if>
                    <h3 id="doc-heading" class="doc-headers">
                        KENYA PARLIAMENT
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:shortName"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                        <i18n:text key="doc-{$doc-type}">Question(nt)</i18n:text>&#160;<i18n:text key="number">Number(nt)</i18n:text>: 
                        <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:itemNumber"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey camel-txt">
                        <i18n:text key="pri-sponsor">primary sponsor(nt)</i18n:text>: <i>
                            <a href="member?uri={bu:ontology/bu:legislativeItem/bu:owner/@href}">
                                <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:owner/@showAs"/>
                            </a>
                        </i>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey camel-txt">
                        <i18n:text key="sponsors">sponsors(nt)</i18n:text>: ( 
                        <xsl:choose>
                            <!-- check whether we have signatories or not -->
                            <xsl:when test="bu:ontology/bu:signatories/bu:signatory">
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
                    <xsl:variable name="render-doc" select="if ($version eq 'true') then                                   bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]                                  else                                   bu:ontology/bu:legislativeItem                                "/>
                    <div class="doc-status">
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
                    </div>
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
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>