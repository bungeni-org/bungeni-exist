<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:include href="context_downloads.xsl"/>
    <xsl:param name="serverport"/>
    <xsl:template match="document">
        <xsl:variable name="server_port" select="serverport"/>
        <xsl:variable name="doc-type" select="primary/bu:ontology/bu:document/@type"/>
        <xsl:variable name="doc_uri" select="primary/bu:ontology/bu:legislativeItem/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">timeline</xsl:with-param>
                <xsl:with-param name="uri" select="$doc_uri"/>
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
                        <table class="listing timeline tbl-tgl">
                            <tr>
                                <th>
                                    <i18n:text key="tab-type">type(nt)</i18n:text>
                                </th>
                                <th>
                                    <i18n:text key="tab-desc">description(nt)</i18n:text>
                                </th>
                                <th>
                                    <i18n:text key="tab-date">date(nt)</i18n:text>
                                </th>
                            </tr>
                            <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:changes/bu:change">
                                <xsl:sort select="./bu:field[@name='date_active']" order="descending"/>
                                <xsl:variable name="action" select="./bu:action"/>
                                <xsl:variable name="content_id" select="./bu:changeId"/>
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
                                                    <xsl:variable name="new_ver_id" select="bu:changeId"/>
                                                    <a href="{//primary/bu:ontology/bu:document/@type}/text?uri={//primary/bu:ontology/bu:legislativeItem/@uri}{//primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version/bu:field[@name=$new_ver_id]//@uri}">
                                                        <xsl:value-of select="bu:description"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="bu:description"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:value-of select="format-dateTime(bu:field[@name='date_active'],'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
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