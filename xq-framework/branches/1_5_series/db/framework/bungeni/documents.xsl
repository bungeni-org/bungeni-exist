<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill attachments from Bungeni</xd:p>
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
                <xsl:with-param name="tab-path">attachments</xsl:with-param>
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
                    <div class="blocks" style="width:100%;margin: 0 auto;">
                        <div class="list-block">
                            <b>Doc Id</b> : <xsl:value-of select="primary/bu:ontology/bu:legislativeItem/bu:registryNumber"/>
                        </div>
                        <xsl:if test="$version ne 'true'">
                            <div id="block1" class="list-block">
                                <div style="width:100%;">
                                    <span class="tgl" style="margin-right:10px">-</span>
                                    <a href="#1">versions</a>
                                </div>
                                <div class="doc-toggle opened">
                                    <table class="listing timeline tbl-tgl">
                                        <tr>
                                            <th>status</th>
                                            <th>description</th>
                                            <th>date</th>
                                        </tr>
                                        <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:versions/bu:version">
                                            <xsl:sort select="bu:statusDate" order="descending"/>
                                            <xsl:variable name="action" select="bu:status"/>
                                            <xsl:variable name="content_id" select="bu:field[@name='change_id']"/>
                                            <xsl:variable name="version_uri" select="concat('/ontology/bill/versions/',$content_id)"/>
                                            <tr>
                                                <td>
                                                    <span>
                                                        <xsl:value-of select="$action"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span>
                                                        <a href="{//primary/bu:ontology/bu:document/@type}/version/text?uri={@uri}">
                                                            <xsl:value-of select="bu:shortName"/>
                                                        </a>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span>
                                                        <xsl:value-of select="format-dateTime(bu:statusDate,$datetime-format,'en',(),())"/>
                                                    </span>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                        <xsl:if test="primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent">
                            <div id="block2" class="list-block">
                                <div style="width:100%;">
                                    <span class="tgl" style="margin-right:10px">-</span>
                                    <a href="#1">Events</a>
                                </div>
                                <div class="doc-toggle opened">
                                    <ul class="ls-row">
                                        <xsl:for-each select="primary/bu:ontology/bu:legislativeItem/bu:wfevents/bu:wfevent">
                                            <xsl:sort select="@date" order="descending"/>
                                            <li>
                                                <a href="{//primary/bu:ontology/bu:document/@type}/event?uri={@href}">
                                                    <xsl:value-of select="@showAs"/>
                                                </a>
                                                <div style="display:inline-block;"> / <xsl:value-of select="format-dateTime(@date,$datetime-format,'en',(),())"/>
                                                </div>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </div>
                        </xsl:if>
                        <div id="block3" class="list-block">
                            <div style="width:100%;">
                                <span class="tgl" style="margin-right:10px">-</span>
                                <a href="#1">attached files</a>
                            </div>
                            <div class="doc-toggle opened">
                                <table class="listing timeline">
                                    <tr>
                                        <th>file title</th>
                                        <th>type</th>
                                        <th>date</th>
                                    </tr>
                                    <xsl:for-each select="primary/bu:ontology/bu:attached_files/bu:attached_file">
                                        <xsl:sort select="bu:statusDate" order="descending"/>
                                        <tr>
                                            <td>
                                                <span>
                                                    <xsl:value-of select="bu:field[@name='file_title']"/>
                                                </span>
                                            </td>
                                            <td>
                                                <span>
                                                    <xsl:value-of select="bu:field[@name='file_mimetype']"/>
                                                </span>
                                            </td>
                                            <td>
                                                <span>
                                                    <xsl:value-of select="format-dateTime(./bu:statusDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>