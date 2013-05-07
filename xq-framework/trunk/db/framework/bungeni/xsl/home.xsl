<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    
    <!-- Generic templates applied to document views -->
    <xsl:import href="tmpl-grp-generic.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Sept 11, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Home/Goverment page</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:group/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:if test="bu:ontology">
                        <xsl:value-of select="bu:ontology/bu:group/bu:origin/bu:identifier"/>                   
                        &#160;|&#160;
                    </xsl:if>
                    <i18n:text key="welcome">Welcome Home(nt)</i18n:text>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="tab-path">profile</xsl:with-param>
                <xsl:with-param name="chamber" select="concat(bu:ontology/bu:group/bu:origin/bu:identifier,'/')"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <xsl:if test="bu:ontology">
                <div id="region-content" class="rounded-eigh tab_container" role="main">
                    <div id="doc-main-section">
                        <div id="doc-main-section">
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="parl-fullname">full name(nt)</i18n:text>:
                                </div>
                                <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                            </div>
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="language">language(nt)</i18n:text>:
                                </div>
                                <xsl:value-of select="bu:ontology/bu:group/@xml:lang"/>
                            </div>
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="status">status(nt)</i18n:text>:
                                </div>
                                <xsl:value-of select="bu:ontology/bu:group/bu:status"/>
                            </div>
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="parl-shortname">short name(nt)</i18n:text>:
                                </div>
                                <xsl:value-of select="bu:ontology/bu:group/bu:shortName"/>
                            </div>
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="parl-start-date">election date(nt)</i18n:text>:
                                </div>
                                <xsl:value-of select="format-date(bu:ontology/bu:legislature/bu:electionDate/@select,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
                            </div>
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="parl-power-date">in power from(nt)</i18n:text>:
                                </div>
                                <!--xsl:value-of select="format-date(bu:ontology/bu:group/bu:startDate,$date-format, 'en', (),())"/-->
                            </div>
                        </div>
                        <div class="clear"/>
                        <div class="mem-desc">
                            <xsl:copy-of select="bu:ontology/bu:group/bu:description"/>
                        </div>
                    </div>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>