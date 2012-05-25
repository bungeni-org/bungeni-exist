<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:template match="doc">
        <xsl:variable name="ver-id" select="version"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
        <xsl:variable name="ver-uri" select="bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-id]/@uri"/>
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
        <div id="main-wrapper">
            <span id="popout-close" class="hide">
                <i18n:text key="close">close(nt)</i18n:text>
            </span>
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                </h1>
                <h1 id="doc-title-red-left">
                    <xsl:if test="$version eq 'true'">
                        <span class="bu-red">Version - <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-uri]/bu:activeDate,$datetime-format,'en',(),())"/>
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
                            <xsl:value-of select="$ver-uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$doc-uri"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="tab-path">attachments</xsl:with-param>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
            </xsl:call-template>
            <div id="region-content" class="has-popout rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="blocks">
                        <div class="list-block">
                            <b>
                                <i18n:text key="docid">Doc Id(nt)</i18n:text>
                            </b> : <xsl:value-of select="bu:ontology/bu:document/bu:registryNumber"/>
                        </div>
                        <xsl:if test="$version ne 'true'">
                            <div id="block1" class="list-block">
                                <div>
                                    <span class="tgl tgl-wrap">-</span>
                                    <a href="#1">
                                        <i18n:text key="versions">versions(nt)</i18n:text>
                                    </a>
                                </div>
                                <div class="doc-toggle opened">
                                    <table class="listing timeline tbl-tgl">
                                        <tr>
                                            <th>
                                                <i18n:text key="status">status(nt)</i18n:text>
                                            </th>
                                            <th>
                                                <i18n:text key="tab-desc">description(nt)</i18n:text>
                                            </th>
                                            <th>
                                                <i18n:text key="tab-date">date(nt)</i18n:text>
                                            </th>
                                        </tr>
                                        <xsl:for-each select="bu:ontology/bu:document/bu:versions/bu:version">
                                            <xsl:sort select="bu:activeDate" order="descending"/>
                                            <tr>
                                                <td>
                                                    <span>
                                                        <xsl:value-of select="bu:procedureType/bu:value"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span>
                                                        <a href="{lower-case($doc-type)}/version/text?uri={@uri}">
                                                            <xsl:value-of select="bu:auditAction/bu:value"/>&#160;<xsl:value-of select="bu:sequence"/>
                                                        </a>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span>
                                                        <xsl:value-of select="format-dateTime(bu:activeDate,$datetime-format,'en',(),())"/>
                                                    </span>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                        <xsl:if test="bu:ontology/bu:document/bu:workflowEvents/bu:workflowEvent">
                            <div id="block2" class="list-block">
                                <div>
                                    <span class="tgl tgl-wrap">-</span>
                                    <a href="#1">
                                        <i18n:text key="events">events(nt)</i18n:text>
                                    </a>
                                </div>
                                <div class="doc-toggle opened">
                                    <ul class="ls-row">
                                        <xsl:for-each select="bu:ontology/bu:document/bu:workflowEvents/bu:workflowEvent">
                                            <xsl:sort select="bu:statusDate" order="descending"/>
                                            <li>
                                                <a href="popout?uri={@href}" rel="{lower-case($doc-type)}/event?uri={@href}" onclick="return false;">
                                                    <xsl:value-of select="bu:shortTitle"/>
                                                </a>
                                                <div class="struct-ib"> / <xsl:value-of select="format-dateTime(bu:statusDate,$datetime-format,'en',(),())"/>
                                                </div>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </div>
                        </xsl:if>
                        <div id="block3" class="list-block">
                            <div>
                                <span class="tgl tgl-wrap">-</span>
                                <a href="#1">
                                    <i18n:text key="attachedfiles">attached files(nt)</i18n:text>
                                </a>
                            </div>
                            <div class="doc-toggle opened">
                                <table class="listing timeline">
                                    <tr>
                                        <th>
                                            <i18n:text key="tab-file-title">file title(nt)</i18n:text>
                                        </th>
                                        <th>
                                            <i18n:text key="tab-type">type(nt)</i18n:text>
                                        </th>
                                        <th>
                                            <i18n:text key="tab-date">date(nt)</i18n:text>
                                        </th>
                                    </tr>
                                    <xsl:for-each select="bu:ontology/bu:attachments/bu:attachment">
                                        <xsl:sort select="bu:statusDate" order="descending"/>
                                        <tr>
                                            <td>
                                                <a href="download?uri={$doc-uri}&amp;att={bu:attachmentId}">
                                                    <xsl:value-of select="bu:name"/>
                                                </a>
                                            </td>
                                            <td>
                                                <span>
                                                    <xsl:value-of select="bu:mimetype/bu:value"/>
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