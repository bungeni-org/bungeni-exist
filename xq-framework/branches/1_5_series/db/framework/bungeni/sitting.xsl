<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 22, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Sitting item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_downloads.xsl"/> 
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="serverport"/>
    <xsl:template match="document">
        <xsl:variable name="server_port" select="serverport"/>
        <xsl:variable name="doc-type" select="sitting/bu:ontology/@type"/>
        <xsl:variable name="doc_uri" select="sitting/bu:ontology/bu:groupsitting/@uri"/>
        <xsl:variable name="mover_uri" select="sitting/bu:ontology/bu:legislativeItem/bu:owner/@href"/>
        <xsl:variable name="j-obj" select="json"/>
        <div id="main-wrapper">
            <div id="uri" style="display:none;">
                <xsl:value-of select="$doc_uri"/>
            </div>
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <i18n:text key="doc-{$doc-type}">Sitting(nt)</i18n:text>:&#160;                  
                    <xsl:value-of select="sitting/bu:ontology/bu:legislature/bu:shortName"/>
                    -&#160;<xsl:value-of select="sitting/bu:ontology/bu:groupsitting/bu:activityType"/>                      
                    <!-- If its a version and not a main document... add version title below main title -->
                </h1>
            </div>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="server-port" select="$server_port"/>
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc_uri"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <h3 id="doc-heading" class="doc-headers">
                        <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS -->
                        KENYA PARLIAMENT
                    </h3>
                    <h4 id="doc-item-desc" class="doc-headers">
                        <xsl:value-of select="sitting/bu:ontology/bu:legislature/bu:shortName"/>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                        <i18n:text key="sitting-activity">sitting activity(nt)</i18n:text>: <i>
                            <xsl:value-of select="sitting/bu:ontology/bu:groupsitting/bu:activityType"/>
                        </i>
                    </h4>
                    <h4 id="doc-item-desc2" class="doc-headers-darkgrey">
                        <i18n:text key="sitting-convocation">sitting convocation(nt)</i18n:text>: <i>
                            <xsl:value-of select="sitting/bu:ontology/bu:groupsitting/bu:convocationType"/>
                        </i>
                    </h4>
                    <div class="doc-status">
                        <span>
                            <b class="camel-txt">
                                <i18n:text key="sitting-venue">Venue(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="sitting/bu:ontology/bu:groupsitting/bu:venue/bu:shortName"/>
                        </span>
                        <span>
                            <b class="camel-txt">
                                <i18n:text key="date-on">Type(nt)</i18n:text>:</b>
                        </span>
                        <span>
                            <xsl:value-of select="format-dateTime(sitting/bu:ontology/bu:groupsitting/bu:startDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <table class="doc-tbl-details">
                            <xsl:for-each select="sitting_items/bu:ontology">
                                <xsl:variable name="subDocIdentifier" select="bu:legislativeItem/@uri"/>
                                <tr>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="bu:document/@type eq 'heading'">
                                                <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <a href="{bu:document/@type}/text?uri={$subDocIdentifier}">
                                                    <xsl:value-of select="bu:legislativeItem/bu:shortName"/>
                                                </a>
                                            </xsl:otherwise>
                                        </xsl:choose>
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