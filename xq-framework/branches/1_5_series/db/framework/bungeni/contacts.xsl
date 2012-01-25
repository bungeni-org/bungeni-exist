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
    <xsl:param name="address_type"/>
    <xsl:template match="document">
        <xsl:variable name="doc-type">
            <xsl:choose>
                <xsl:when test="$address_type eq 'user'">
                    <xsl:value-of select="$address_type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="primary/bu:ontology/bu:group/@type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc_uri">
            <xsl:choose>
                <xsl:when test="$address_type eq 'user'">
                    <xsl:value-of select="primary/bu:ontology/bu:user/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="primary/bu:ontology/bu:group/@uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:choose>
                        <xsl:when test="$address_type eq 'user'">
                            <xsl:value-of select="concat(primary/bu:ontology/bu:user/bu:firstName,' ', primary/bu:ontology/bu:user/bu:lastName)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="primary/bu:ontology/bu:legislature/bu:fullName"/>
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
                            <xsl:when test="secondary/bu:ontology">
                                <table class="tbl-tgl">
                                    <tr>
                                        <td class="fbtd">addr type</td>
                                        <td class="fbtd">postal addr type</td>
                                        <td class="fbtd">city</td>
                                        <td class="fbtd">zip code</td>
                                        <td class="fbtd">country</td>
                                        <td class="fbtd">phone number(s)</td>
                                        <td class="fbtd">fax number(s)</td>
                                        <td class="fbtd">email</td>
                                    </tr>
                                    <xsl:for-each select="secondary/bu:ontology">
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
                                <div style="text-align:center;">None</div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>