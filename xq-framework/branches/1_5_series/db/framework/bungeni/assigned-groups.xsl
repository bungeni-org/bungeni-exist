<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="version"/>
    <xsl:template match="document">
        <xsl:variable name="ver_id" select="version"/>
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
                        <span style="color:#b22b14">Version - <xsl:value-of select="format-dateTime(primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version[@uri=$ver_uri]/bu:statusDate,$datetime-format,'en',(),())"/>
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
            </xsl:call-template>
            <div style="float:right;width:400px;height:18px;">
                <div id="doc-downloads">
                    <ul class="ls-downloads">
                        <li>
                            <a href="#" title="get as RSS feed" class="rss">
                                <em>RSS</em>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div style="width:700px;margin: 0 auto;text-align:center">
                        <xsl:choose>
                            <xsl:when test="boolean(secondary/bu:committee/bu:fullName)">
                                <table class="listing timeline tbl-tgl">
                                    <tr>
                                        <th>name</th>
                                        <th>start date</th>
                                        <th>status date</th>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span>
                                                <xsl:value-of select="secondary/bu:committee/bu:fullName"/>
                                            </span>
                                        </td>
                                        <td>
                                            <span>
                                                <xsl:value-of select="secondary/bu:legislature/bu:statusDate"/>
                                            </span>
                                        </td>
                                        <td>
                                            <span>
                                                <xsl:value-of select="secondary/bu:group/bu:startDate"/>
                                            </span>
                                        </td>
                                    </tr>
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