<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill changes from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template name="formatDate">
        <xsl:param name="dateTime"/>
        <xsl:variable name="date" select="substring-before($dateTime, 'T')"/>
        <xsl:variable name="year" select="substring-before($date, '-')"/>
        <xsl:variable name="month" select="substring-before(substring-after($date, '-'), '-')"/>
        <xsl:variable name="day" select="substring-after(substring-after($date, '-'), '-')"/>
        <xsl:value-of select="concat($day, '-', $month, '-', $year)"/>
    </xsl:template>
    <xsl:template name="formatTime">
        <xsl:param name="dateTime"/>
        <xsl:value-of select="substring-after($dateTime, 'T')"/>
    </xsl:template>
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc_uri" select=".//bu:bill/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select=".//bu:bill/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">legislativeitems</xsl:with-param>
                <xsl:with-param name="tab-path">timeline</xsl:with-param>
                <xsl:with-param name="uri" select="./bu:bill/@uri"/>
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
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div style="width:700px;margin: 0 auto;">
                        <table class="listing timeline tbl-tgl">
                            <tr>
                                <th>type</th>
                                <th>description</th>
                                <th>date</th>
                            </tr>
                            <xsl:for-each select=".//bu:changes/bu:change">
                                <xsl:variable name="action" select="./bu:field[@name='action']"/>
                                <xsl:variable name="content_id" select="./bu:field[@name='change_id']"/>
                                <xsl:variable name="version_uri" select="concat('/ontology/bill/versions/',$content_id)"/>
                                <tr>
                                    <td>
                                        <span>
                                            <xsl:value-of select="$action"/>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:choose>
                                                <xsl:when test="$action = 'new-version'">
                                                    <a href="bill?doc={$version_uri}">
                                                        <xsl:value-of select="./bu:field[@name='description']"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="./bu:field[@name='description']"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:value-of select="format-dateTime(./bu:field[@name='date_active'],                                                                         '[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]',                                                                         'en',                                                                          (),())"/>
                                        </span>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>