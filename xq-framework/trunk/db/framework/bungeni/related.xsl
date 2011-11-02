<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 1, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill related items from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
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
                <xsl:with-param name="tab-path">related</xsl:with-param>
                <xsl:with-param name="uri" select="./bu:bill/@uri"/>
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
                    <ul class="ls-row" id="list-toggle-wide" style="font-size:0.9em;">
                        <li>
                            <div style="padding-left:2px;">
                                <b>Doc Id</b> : 
                                <xsl:value-of select=".//bu:bill/@uri"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding:-2px;">
                                <b>Parliament</b> : 
                                <xsl:value-of select="./bu:bungeni/bu:parliament/@href"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Session Year</b> : 
                                <xsl:value-of select="substring-before(./bu:bungeni/bu:parliament/@date,'-')"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Session Num</b> : 
                                <xsl:value-of select="./bu:bill/bu:legislativeItemId"/>
                            </div>
                        </li>
                        <li>
                            <div style="width:100%;">
                                <span class="tgl" style="margin-right:10px">+</span>
                                <a href="#1">Assigned Groups</a>
                            </div>
                            <div class="doc-toggle">
                                <table class="tbl-tgl" style="width:99%;float:none;margin:0px auto 0 auto;text-align:center">
                                    <tr>
                                        <td class="fbottom" style="text-align-left;">Committee</td>
                                        <td class="fbottom">Start Date</td>
                                        <td class="fbottom">End Date</td>
                                        <td class="fbottom">Due Date</td>
                                    </tr>
                                    <tr>
                                        <td class="fall" style="text-align-left;">Committee P_01</td>
                                        <td class="fall">Aug 17, 2009</td>
                                        <td class="fall">Sep 28, 2010</td>
                                        <td class="fall">Jan 17, 2012</td>
                                    </tr>
                                    <tr>
                                        <td class="fall" style="text-align-left;">Committee P_01</td>
                                        <td class="fall">Aug 17, 2009</td>
                                        <td class="fall">Sep 28, 2010</td>
                                        <td class="fall">Jan 17, 2012</td>
                                    </tr>
                                    <tr>
                                        <td class="fall" style="text-align-left;">Committee P_01</td>
                                        <td class="fall">Aug 17, 2009</td>
                                        <td class="fall">Sep 28, 2010</td>
                                        <td class="fall">Jan 17, 2012</td>
                                    </tr>
                                </table>
                            </div>
                        </li>
                        <li>
                            <div style="width:100%;">
                                <span class="tgl" style="margin-right:10px">+</span>
                                <a href="#1">Versions</a>
                            </div>
                            <div class="doc-toggle">
                                <table class="tbl-tgl" style="width:99%;float:none;margin:10px auto 0 auto;text-align:center">
                                    <tr>
                                        <td class="fall" style="text-align-left;">Status</td>
                                        <td class="fall">Type</td>
                                        <td class="fall">Title</td>
                                        <td class="fall">From</td>
                                        <td class="fall">To</td>
                                    </tr>
                                    <xsl:for-each select=".//bu:versions/bu:version">
                                        <tr>
                                            <td class="fall" style="text-align-left;">
                                                <xsl:value-of select="bu:status"/>
                                            </td>
                                            <td class="fall">parliament</td>
                                            <td class="fall">Member</td>
                                            <td class="fall">Jan 18, 2001</td>
                                            <td class="fall">May 18, 2011</td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>