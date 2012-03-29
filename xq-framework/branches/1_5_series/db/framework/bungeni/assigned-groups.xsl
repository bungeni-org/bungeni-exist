<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Parliamentary Item Assigned Groups from Bungeni</xd:p>
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
        <xsl:variable name="ver_id" select="version"/>
        <xsl:variable name="server_port" select="serverport"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="ver_uri" select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_id]/@uri"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                    <!-- If its a version and not a main document... add version title below main title -->
                    <xsl:if test="$version eq 'true'">
                        <br/>
                        <span class="bu-red">Version - <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
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
                <xsl:with-param name="tab-path">assigned</xsl:with-param>
                <xsl:with-param name="excludes" select="exlude/tab"/>
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
                    <div class="doc-table-wrapper">
                        <xsl:choose>
                            <xsl:when test="primary//bu:item_assignments">
                                <table class="tbl-tgl">
                                    <tr>
                                        <td class="fbtd lower-txt">
                                            <i18n:text key="doc-committee">committee(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="date-start">start date(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="date-end">end date(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="date-due">due date(nt)</i18n:text>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="primary//bu:item_assignments">
                                        <xsl:sort select="bu:item_assignment/bu:startDate" order="descending"/>
                                        <tr class="items">
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:item_assignment/bu:groupId"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-date(bu:item_assignment/bu:startDate,$date-format,'en',(),())"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-date(bu:item_assignment/bu:startDate,$date-format,'en',(),())"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:item_assignment/bu:groupId"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                no assigned groups                                 
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>