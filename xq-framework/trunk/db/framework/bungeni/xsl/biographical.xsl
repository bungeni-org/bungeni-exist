<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:param name="chamber"/>
    <xsl:param name="chamber-id"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/bu:referenceToUser/bu:refersTo/@href"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:referenceToUser/bu:firstName,' ', bu:ontology/bu:membership/bu:referenceToUser/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">offices</xsl:with-param>
                <xsl:with-param name="chamber" select="concat($chamber,'/')"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Name">Name(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="concat(ref/bu:ontology/bu:user/bu:title,' ',ref/bu:ontology/bu:user/bu:firstName,' ', ref/bu:ontology/bu:user/bu:lastName)"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Salutation">salutation(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="bu:ontology/bu:membership/bu:salutation"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Gender">Gender(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="if (bu:ontology/bu:membership/bu:gender/@showAs) then                                             data(bu:ontology/bu:membership/bu:gender/@showAs) else                                              bu:ontology/bu:membership/bu:gender"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Country of Birth">birth country(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:birthCountry"/>
                        </div>
                        <xsl:if test="ref/bu:ontology/bu:user/bu:maritalStatus/@showAs">
                            <div class="list-block">
                                <div class="block-label">
                                    <i18n:text key="Marital Status">Marital Status(nt):</i18n:text>:
                                </div>
                                <xsl:value-of select="ref/bu:ontology/bu:user/bu:maritalStatus/@showAs"/>
                            </div>
                        </xsl:if>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Date of Birth">date of birth(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:dateOfBirth),$date-format,'en',(),())"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Nationality at Birth">Nationality at Birth(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:birthNationality"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="Current Nationality">Current Nationality(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:currentNationality"/>
                        </div>
                        <div class="list-block">
                            <div class="block-label">
                                <i18n:text key="National Id">National Id(nt):</i18n:text>:
                            </div>
                            <xsl:value-of select="ref/bu:ontology/bu:user/bu:nationalId"/>
                        </div>
                    </div>
                    <div class="clear"/>
                    <div class="mem-desc">
                        <xsl:copy-of select="ref/bu:ontology/bu:user/bu:description/child::node()" copy-namespaces="no"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>