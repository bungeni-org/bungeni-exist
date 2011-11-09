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
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc-type" select="bu:metadata/@type"/>
        <xsl:variable name="doc_uri" select="bu:user/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="concat(bu:user/bu:field[@name='first_name'],' ', bu:user/bu:field[@name='last_name'])"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">activities</xsl:with-param>
                <xsl:with-param name="uri" select="$doc_uri"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="#" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this document" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as ODT document" class="odt">
                            <em>ODT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as RTF document" class="rtf">
                            <em>RTF</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="mem-photo mem-top-left">
                            <p class="imgonlywrap">
                                <img width="150" height="200" src="assets/bungeni/images/mp.jpg" alt="The Speaker"/>
                            </p>
                        </div>
                        <div class="mem-top-right">
                            <table class="mem-tbl-details">
                                <tr>
                                    <td class="labels fbt">name:</td>
                                    <td class="fbt">
                                        <xsl:value-of select="concat(bu:user/bu:field[@name='titles'],'. ',bu:user/bu:field[@name='first_name'],' ', .//bu:user/bu:field[@name='last_name'])"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">elected/nominated:</td>
                                    <td class="fbt">nominated</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">election/nomination date:</td>
                                    <td class="fbt">15 Feb 2011</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">start date:</td>
                                    <td class="fbt">22 Feb 2011</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">language:</td>
                                    <td class="fbt">English</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">constituency:</td>
                                    <td class="fbt">Constituency P1_01</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">province:</td>
                                    <td class="fbt">Province P1_01</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">region:</td>
                                    <td class="fbt">Region P1_01</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">political party:</td>
                                    <td class="fbt">Party P1_01</td>
                                </tr>
                                <tr>
                                    <td class="labels fbottom">notes:</td>
                                    <td class="fbt">
                                        <xsl:copy-of select="bu:user/bu:description"/>
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