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
    <xsl:param name="address_type"/>
    <xsl:template match="doc">
        <xsl:variable name="onto-type">
            <xsl:choose>
                <xsl:when test="$address_type eq 'Membership'">
                    <xsl:value-of select="bu:ontology/bu:membership/bu:docType/bu:value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/bu:docType/bu:value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc-type">
            <xsl:choose>
                <xsl:when test="$address_type eq 'Membership'">
                    <xsl:value-of select="$address_type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/bu:docType/bu:value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc-uri">
            <xsl:choose>
                <xsl:when test="$address_type eq 'Membership'">
                    <xsl:value-of select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/@uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="contact-name">
            <xsl:choose>
                <xsl:when test="$address_type eq 'Membership'">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName, ' (',bu:ontology/bu:membership/bu:title,')')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/bu:shortName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="contact-name-title">
            <xsl:choose>
                <xsl:when test="$address_type eq 'Membership'">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:salutation,', ',bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div id="main-wrapper">
            <div id="title-holder">
                <h1 class="title">
                    <xsl:choose>
                        <xsl:when test="$address_type eq 'Membership'">
                            <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">contacts</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section" class="blocks">
                    <xsl:for-each select="ref/bu:ontology">
                        <xsl:sort select="bu:address/bu:logicalAddressType" order="descending"/>
                        <a id="mTag{bu:address/bu:addressId}" href="#" class="togglers" onClick="toggleOnly('{bu:address/bu:postalAddressType}{bu:address/bu:addressId}',this.id,'{bu:address/bu:logicalAddressType}');return false;">
                            ▼<xsl:value-of select="bu:address/bu:logicalAddressType"/>
                        </a>
                        <div id="{bu:address/bu:postalAddressType}{bu:address/bu:addressId}" class="toggle address-info">
                            <div class="address-block">
                                <address>
                                    <strong>
                                        <xsl:value-of select="$contact-name"/>
                                    </strong>
                                    <br/>
                                    <bu:street type="xs:string">address</bu:street>, room <bu:groupId type="xs:integer">4</bu:groupId>
                                    <br/>
                                    <xsl:value-of select="bu:address/bu:city"/>, <xsl:value-of select="bu:address/bu:countryId"/>&#160;<xsl:value-of select="bu:address/bu:zipCode"/>
                              &#160;<xsl:value-of select="bu:address/bu:postalAddressType/@showAs"/>&#160;<bu:addressId type="xs:integer">4</bu:addressId>
                                    <br/>
                                    <abbr title="Phone">Phone:</abbr>
                                    <xsl:value-of select="bu:address/bu:phone"/>
                                    <br/>
                                    <abbr title="Fax">Fax:</abbr>
                                    <xsl:value-of select="bu:address/bu:fax"/>
                                </address>
                                <address>
                                    <strong>
                                        <xsl:value-of select="$contact-name-title"/>
                                    </strong>
                                    <br/>
                                    <a href="mailto:#">
                                        <xsl:value-of select="bu:address/bu:email"/>
                                    </a>
                                </address>
                            </div>
                            <div class="clear"/>
                            <div class="mem-desc">
                                <xsl:copy-of select="bu:ontology/bu:membership/bu:notes/child::node()" copy-namespaces="no"/>
                            </div>
                        </div>
                        <br/>
                    </xsl:for-each>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>