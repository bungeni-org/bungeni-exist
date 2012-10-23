<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:param name="epub"/>
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
            <!--
                !+NOTES see popout.xsl why this is disabled for now
            -->
            <!--span id="popout-close" class="hide">
                <i18n:text key="close">close(nt)</i18n:text>
            </span-->
            <div id="title-holder">
                <xsl:if test="$version eq 'true'">
                    <a class="big-dbl-arrow" title="go back to {lower-case($doc-type)} documents" href="{lower-case($doc-type)}-documents?uri={$doc-uri}">«&#160;</a>
                </xsl:if>
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:document/bu:title"/>
                </h1>
                <h2 class="sub-title">
                    <xsl:if test="$version eq 'true'">
                        Version - <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:versions/bu:version[@uri=$ver-uri]/bu:activeDate,$datetime-format,'en',(),())"/>
                    </xsl:if>
                </h2>
            </div>
            <xsl:if test="$epub ne 'true'">
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
                    <xsl:with-param name="doc-type" select="lower-case($doc-type)"/>
                    <xsl:with-param name="uri" select="$doc-uri"/>
                </xsl:call-template>
            </xsl:if>
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
                                    <b>
                                        <i18n:text key="versions">versions(nt)</i18n:text>
                                    </b>
                                </div>
                                <div class="doc-toggle opened">
                                    <ul class="ls-row">
                                        <xsl:for-each select="bu:ontology/bu:document/bu:versions/bu:version">
                                            <xsl:sort select="bu:activeDate" order="descending"/>
                                            <li>
                                                <a href="{lower-case($doc-type)}-version/text?uri={@uri}">
                                                    <xsl:value-of select="bu:auditAction/bu:value"/>&#160;<xsl:value-of select="bu:sequence"/>
                                                </a>
                                                <div class="struct-ib"> / 
                                                    <xsl:variable name="procedureType">
                                                        <xsl:choose>
                                                            <xsl:when test="bu:procedureType/bu:value eq 'm'">
                                                                <xsl:text>modified</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="bu:procedureType/bu:value eq 'a'">
                                                                <xsl:text>added</xsl:text>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="bu:procedureType/bu:value"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    <xsl:value-of select="$procedureType"/>
                                                    / <xsl:value-of select="format-dateTime(bu:activeDate,$datetime-format,'en',(),())"/>
                                                </div>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </div>
                        </xsl:if>
                        <xsl:if test="ref/bu:ontology/bu:document">
                            <div id="block2" class="list-block">
                                <div>
                                    <span class="tgl tgl-wrap">-</span>
                                    <b>
                                        <i18n:text key="events">events(nt)</i18n:text>
                                    </b>
                                </div>
                                <div class="doc-toggle opened">
                                    <ul class="ls-row">
                                        <xsl:for-each select="ref/bu:ontology/bu:document">
                                            <xsl:sort select="bu:statusDate" order="descending"/>
                                            <li>
                                                <!--a href="{lower-case($doc-type)}-event?uri={@uri}">
                                                    <xsl:value-of select="bu:title"/>
                                                </a-->
                                                <a href="popout?uri={@uri}" rel="{lower-case($doc-type)}-event?uri={@uri}" onclick="return false;">
                                                    <xsl:value-of select="bu:title"/>
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
                                <b>
                                    <i18n:text key="attachedfiles">attached files(nt)</i18n:text>
                                </b>
                            </div>
                            <div class="doc-toggle opened">
                                <ul class="ls-row">
                                    <xsl:for-each select="bu:ontology/bu:attachments/bu:attachment">
                                        <li>
                                            <a href="download?uri={$doc-uri}&amp;att={bu:attachmentId}">
                                                <xsl:value-of select="bu:name"/>
                                            </a>
                                            <div class="struct-ib"> (<xsl:value-of select="bu:mimetype/bu:value"/>) / <xsl:value-of select="format-dateTime(./bu:statusDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                                            </div>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>