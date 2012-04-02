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
    <xsl:param name="address_type"/>
    <xsl:template match="doc">
        <xsl:variable name="onto-type" select="bu:ontology/@type"/>
        <xsl:variable name="doc-type">
            <xsl:choose>
                <xsl:when test="$address_type eq 'membership'">
                    <xsl:value-of select="$address_type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/@type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc_uri">
            <xsl:choose>
                <xsl:when test="$address_type eq 'membership'">
                    <xsl:value-of select="bu:ontology/bu:membership/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/@uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:choose>
                        <xsl:when test="$address_type eq 'membership'">
                            <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                        </xsl:when>
                        <xsl:when test="$onto-type eq 'group'">
                            <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="bu:ontology/bu:legislature/bu:fullName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">contacts</xsl:with-param>
                <xsl:with-param name="uri" select="$doc_uri"/>
                <xsl:with-param name="excludes" select="exlude/tab"/>
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
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-profile">
                        <xsl:choose>
                            <xsl:when test="ref/bu:ontology">
                                <table class="tbl-tgl">
                                    <tr>
                                        <td class="fbtd">
                                            <i18n:text key="addr-type">addr type(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-post-type">postal addr type(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-city">city(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-zip">zip code(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-country">country(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-phone">phone number(s)(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-fax">fax number(s)(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="addr-email">email(nt)</i18n:text>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="ref/bu:ontology">
                                        <xsl:sort select="bu:descriptors/bu:statusDate" order="descending"/>
                                        <tr class="items">
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/@type"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:postalAddressType"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:city"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:zipCode"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:countryId"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:phone"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:fax"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:address/bu:email"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="txt-center">
                                    <i18n:text key="none">none(nt)</i18n:text>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>