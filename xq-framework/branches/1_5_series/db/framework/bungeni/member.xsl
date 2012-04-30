<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 6, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Member item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc-type" select="@type"/>
        <xsl:variable name="doc_uri" select="bu:membership/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="concat(bu:membership/bu:firstName,' ', bu:membership/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">member</xsl:with-param>
                <xsl:with-param name="uri" select="$doc_uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="member/pdf?uri={$doc_uri}" title="get PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                    <li>
                        <a href="member/xml?uri={$doc_uri}" title="get raw xml output" class="xml">
                            <em>XML</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="mem-photo mem-top-left">
                            <p class="imgonlywrap">
                                <img src="assets/bungeni/images/presidente.jpg" alt="The Speaker"/>
                            </p>
                        </div>
                        <div class="mem-top-right">
                            <table class="mem-tbl-details">
                                <tr>
                                    <td class="labels fbt">name:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="concat(bu:membership/bu:titles,' ',bu:membership/bu:firstName,' ', bu:membership/bu:lastName)"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">elected/nominated:</td>
                                    <td class="fbt">unknown</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">election/nomination date:</td>
                                    <td class="fbt">unknown</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">start date:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:legislature/bu:startDate"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">language:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:membership/bu:language"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">constituency:</td>
                                    <td class="fbt">unknown</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">province:</td>
                                    <td class="fbt">unknown</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">region:</td>
                                    <td class="fbt">unknown</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">political party:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="bu:legislature/bu:fullName"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">notes:</td>
                                    <td class="fbt">
                                        <xsl:copy-of select="bu:membership/bu:description"/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>