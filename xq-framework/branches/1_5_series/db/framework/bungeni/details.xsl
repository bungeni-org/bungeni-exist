<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 1, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Document related items from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>      
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
         document as opposed to main document. -->
    <xsl:param name="serverport"/>
    <xsl:param name="version"/>
    <xsl:template match="document">
        <xsl:variable name="server_port" select="serverport"/>
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="ver_uri" select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_id]/@uri"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    <xsl:if test="$version eq 'true'">
                        <br/>
                        <span style="color:#b22b14">
                            <i18n:text key="tab-t-version">Version(nt)</i18n:text> - <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
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
                <xsl:with-param name="tab-path">related</xsl:with-param>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="server-port" select="$server_port"/>
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc_uri"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="list-block">
                        <div class="block-label">
                            <i18n:text key="docid">Doc Id(nt)</i18n:text>
                        </div>
                        <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:registryNumber"/>
                    </div>
                    <div class="list-block">
                        <div class="block-label">
                            <i18n:text key="parliament">Parliament(nt)</i18n:text>
                        </div>
                        <xsl:value-of select="primary/bu:ontology/bu:bungeni/bu:parliament/@href"/>
                    </div>
                    <div class="list-block">
                        <div class="block-label">
                            <i18n:text key="session-yr">Session Year(nt)</i18n:text>
                        </div>
                        <xsl:value-of select="substring-before(primary/bu:ontology/bu:bungeni/bu:parliament/@date,'-')"/>
                    </div>
                    <div class="list-block">
                        <div class="block-label">
                            <i18n:text key="session-no">Session Number(nt)</i18n:text>
                        </div>
                        <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:legislativeItemId"/>
                    </div>
                    <ul class="ls-row" id="list-toggle-wide">
                        <li>
                            <div style="width:100%;">
                                <span class="tgl" style="margin-right:10px">-</span>
                                <a href="#1">
                                    <i18n:text key="tab-profile">umbo(nt)</i18n:text>
                                </a>
                            </div>
                            <div class="doc-toggle open">
                                <table class="doc-tbl-details">
                                    <tr>
                                        <td class="labels">
                                            <i18n:text key="submit-date">submission date(nt)</i18n:text>:</td>
                                        <td>
                                            <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels lower-txt">
                                            <i18n:text key="typeofdoc">type of(nt)</i18n:text>&#160;<i18n:text key="doc-{$doc-type}">document(nt)</i18n:text> :</td>
                                        <td>Private Notice</td>
                                    </tr>
                                    <tr>
                                        <td class="labels">
                                            <i18n:text key="resp-type">response type(nt)</i18n:text> :</td>
                                        <td>Written</td>
                                    </tr>
                                    <tr>
                                        <td class="labels">
                                            <i18n:text key="ministry">ministry(nt)</i18n:text>:</td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="primary/bu:ontology/bu:document[@type='question']">
                                                    <xsl:value-of select="concat(primary/bu:ontology/bu:ministry/bu:shortName,' - ',primary/bu:ontology/bu:ministry/bu:fullName)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(secondary/bu:ontology//bu:ministry/bu:shortName,' - ',secondary/bu:ontology//bu:ministry/bu:fullName)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels">
                                            <i18n:text key="admit-date">admission date(nt)</i18n:text>:</td>
                                        <td>May 18, 2011</td>
                                    </tr>
                                    <tr>
                                        <td class="labels">
                                            <i18n:text key="registry-no">registry number(nt)</i18n:text>:</td>
                                        <td>
                                            <xsl:value-of select="output/bu:ontology/bu:legislativeItem/bu:registryNumber"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </li>
                        <!-- if question type show ministry summary -->
                        <xsl:if test="primary/bu:ontology/bu:document[@type='question']">
                            <li>
                                <div style="width:100%;">
                                    <span class="tgl" style="margin-right:10px">-</span>
                                    <a href="#1">
                                        <i18n:text key="summary">summary(nt)</i18n:text>
                                    </a>
                                </div>
                                <div class="doc-toggle open">
                                    <xsl:copy-of select="primary/bu:ontology/bu:ministry/bu:field[@name='description']"/>
                                </div>
                            </li>
                        </xsl:if>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>