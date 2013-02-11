<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
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
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="user-uri" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName,', ',ref/bu:ontology/bu:user/bu:title)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">member</xsl:with-param>
                <xsl:with-param name="uri" select="$user-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="member/pdf?uri={$doc-uri}" title="get PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                    <li>
                        <a href="member/xml?uri={$doc-uri}" title="get raw xml output" class="xml">
                            <em>XML</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="toggle-i18n" class="hide">
                <span id="m-collapse">
                    <i18n:text key="collapse-membership"> membership information(nt)</i18n:text>
                </span>
                <span id="m-expand">
                    <i18n:text key="expand-membership"> membership information(nt)</i18n:text>
                </span>
                <span id="p-collapse">
                    <i18n:text key="collapse-personal"> personal information(nt)</i18n:text>
                </span>
                <span id="p-expand">
                    <i18n:text key="expand-personal"> personal information(nt)</i18n:text>
                </span>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section" class="blocks">
                    <a id="mTag" href="#" class="togglers" onClick="toggleAndChangeText('membership-info',this.id,'m-');return false;">
                        ▼<i18n:text key="expand-membership">&#160; membership information(nt)</i18n:text>
                    </a>
                    <div id="membership-info" class="toggle">
                        <div class="mem-profile">
                            <div class="mem-photo mem-top-left">
                                <p class="imgonlywrap">
                                    <xsl:variable name="img_hash" select="ref/bu:ontology/bu:image/bu:imageHash"/>
                                    <img src="image?hash={$img_hash}&amp;name={concat(bu:ontology/bu:membership/bu:lastName,'_', bu:ontology/bu:membership/bu:firstName)}" alt="Photo of M.P" align="left"/>
                                </p>
                            </div>
                            <div class="mem-top-right">
                                <table class="mem-tbl-details">
                                    <tr>
                                        <td class="labels fbottom">elected/nominated:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="if (bu:ontology/bu:membership/bu:memberElectionType/@showAs) then                                             data(bu:ontology/bu:membership/bu:memberElectionType/@showAs) else                                              bu:ontology/bu:membership/bu:memberElectionType/bu:value"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">election/nomination date:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:electionNominationDate),$date-format,'en',(),())"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">start date:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:membership/bu:startDate),$date-format,'en',(),())"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">language:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="bu:ontology/bu:membership/@xml:lang"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">constituency:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="bu:ontology/bu:membership/bu:constituency/@name"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">province:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="bu:ontology/bu:membership/bu:province/@name"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">region:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="bu:ontology/bu:membership/bu:region/@name"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="labels fbottom">political party:</td>
                                        <td class="fbt">
                                            <xsl:value-of select="bu:ontology/bu:membership/bu:party/@showAs"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="clear"/>
                        <div class="mem-desc">
                            <xsl:copy-of select="bu:ontology/bu:membership/bu:notes/child::node()" copy-namespaces="no"/>
                        </div>
                    </div>
                    <div class="clear"/>
                    <a id="pTag" href="#" class="togglers" onClick="toggleAndChangeText('personal-info',this.id,'p-');return false;">
                        ►&#160;<i18n:text key="collapse-personal">&#160; personal information(nt)</i18n:text>
                    </a>
                    <div id="personal-info" class="toggle" style="display:none;">
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
        </div>
    </xsl:template>
</xsl:stylesheet>