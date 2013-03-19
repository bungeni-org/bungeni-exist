<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    
    <!-- Generic templates applied to document views -->
    <xsl:import href="tmpl-grp-generic.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 16, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Political-group item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">profile</xsl:with-param>
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="mem-photo mem-top-left">
                            <xsl:variable name="img_hash" select="bu:ontology/bu:group/bu:logoData/bu:imageHash"/>
                            <p class="imgonlywrap">
                                <xsl:choose>
                                    <xsl:when test="bu:ontology/bu:group/bu:logoData and doc-available(concat('../../../bungeni-atts/',$img_hash))">
                                        <img src="../../bungeni-atts/{$img_hash}" alt="Group Logo" align="left"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <img src="assets/images/group.png" alt="Place Holder for Group Logo" align="left"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                        </div>
                        <div class="mem-top-right">
                            <table class="mem-tbl-details">
                                <tr>
                                    <td class="labels fbt">
                                        <b>
                                            <i18n:text key="language">language(nt)</i18n:text>:</b>
                                    </td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:ontology/bu:group/@xml:lang"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">
                                        <b>
                                            <i18n:text key="status">status(nt)</i18n:text>:</b>
                                    </td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:ontology/bu:group/bu:status"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">
                                        <b>
                                            <i18n:text key="acronym">acronym(nt)</i18n:text>:</b>
                                    </td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:ontology/bu:group/bu:shortName"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">
                                        <b>
                                            <i18n:text key="date-start">start date(nt)</i18n:text>:</b>
                                    </td>
                                    <td class="fbt">
                                        <xsl:value-of select="format-date(bu:ontology/bu:group/bu:startDate,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div class="clear"/>
                    <div class="mem-desc">
                        <xsl:copy-of select="bu:ontology/bu:group/bu:description"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>