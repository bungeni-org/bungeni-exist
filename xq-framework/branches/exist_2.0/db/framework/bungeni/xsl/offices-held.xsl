<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
                <xsl:with-param name="tab-path">offices</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div id="toggle-i18n" class="hide">
                            <span id="i-compress">
                                <i18n:text key="compress">▼&#160;compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">►&#160;expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">▼&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
                        </div>
                    </div>
                    <ul id="list-toggle" class="ls-row clear">
                        <li>
                            XIV-PARL - Bungeni Parliament
                            <div class="struct-ib">&#160;/ parliament
                            </div>
                            <span class="tgl-pad-right">▼</span>
                            <div class="doc-toggle">
                                <div style="min-height:50px;">
                                    <div class="block">
                                        <span class="labels">
                                            from:</span>
                                        <span>
                                            February 23, 2011
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            to:</span>
                                        <span>
                                            March 14, 2012
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            title:</span>
                                        <span>
                                            Chairperson
                                        </span>
                                    </div>
                                </div>
                                <div class="clear"/>
                            </div>
                        </li>
                        <li>
                            Com_02 - Parliamentary Committee P1_02
                            <div class="struct-ib">&#160;/ committee
                            </div>
                            <span class="tgl-pad-right">▼</span>
                            <div class="doc-toggle">
                                <div style="min-height:50px;">
                                    <div class="block">
                                        <span class="labels">
                                            from:</span>
                                        <span>
                                            February 23, 2011
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            to:</span>
                                        <span>
                                            March 14, 2012
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            title:</span>
                                        <span>
                                            Chairperson
                                        </span>
                                    </div>
                                </div>
                                <div class="clear"/>
                            </div>
                        </li>
                        <li>
                            Com_02 - Parliamentary Committee P1_02
                            <div class="struct-ib">&#160;/ committee
                            </div>
                            <span class="tgl-pad-right">▼</span>
                            <div class="doc-toggle">
                                <div style="min-height:50px;">
                                    <div class="block">
                                        <span class="labels">
                                            from:</span>
                                        <span>
                                            February 23, 2011
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            to:</span>
                                        <span>
                                            March 14, 2012
                                        </span>
                                    </div>
                                    <div class="block">
                                        <span class="labels">
                                            title:</span>
                                        <span>
                                            Chairperson
                                        </span>
                                    </div>
                                </div>
                                <div class="clear"/>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>