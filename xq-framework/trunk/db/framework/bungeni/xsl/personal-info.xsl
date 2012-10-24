<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> MP Personal Information from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">info</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="member/xml?uri={$doc-uri}" title="get raw xml output" class="xml">
                            <em>XML</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="mem-photo mem-top-left">
                            <xsl:variable name="img_hash" select="ref/bu:ontology/bu:image/bu:imageHash"/>
                            <p class="imgonlywrap">
                                <xsl:choose>
                                    <xsl:when test="ref/bu:ontology/bu:image and doc-available(concat('../../../bungeni-atts/',$img_hash))">
                                        <img src="../../bungeni-atts/{ref/bu:ontology/bu:image/bu:imageHash}" alt="Place Holder for M.P Photo" align="left"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <img src="assets/images/placeholder.jpg" alt="Place Holder for M.P Photo" align="left"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                        </div>
                        <div class="mem-top-right">
                            <table class="mem-tbl-details">
                                <tr>
                                    <td class="labels fbt">birth country:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="ref/bu:ontology/bu:user/bu:birthCountry"/>
                                    </td>
                                </tr>
                                <xsl:if test="ref/bu:ontology/bu:user/bu:maritalStatus/@name">
                                    <tr>
                                        <td class="labels fbottom">
                                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:maritalStatus/@name"/>:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:maritalStatus/@term"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <tr>
                                    <td class="labels fbottom">date of birth:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:dateOfBirth),$date-format,'en',(),())"/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="clear"/>
                <div class="mem-desc">
                    <xsl:copy-of select="bu:ontology/bu:membership/bu:description/child::node()" copy-namespaces="no"/>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>