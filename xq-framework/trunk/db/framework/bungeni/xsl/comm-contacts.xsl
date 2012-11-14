<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 16, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Committee item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:group/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:group/@uri"/>
        <xsl:variable name="short-name" select="bu:ontology/bu:group/bu:shortName"/>
        <xsl:variable name="full-name" select="bu:ontology/bu:group/bu:fullName"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 class="title">
                    <xsl:value-of select="bu:ontology/bu:group/bu:fullName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="uri">
                    <xsl:value-of select="$doc-uri"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">contacts</xsl:with-param>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads"/>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section" class="blocks">
                    <xsl:for-each select="bu:ontology/bu:group/bu:groupAddresses/bu:groupAddress">
                        <xsl:sort select="bu:statusDate" order="descending"/>
                        <a id="mTag{bu:addressId}" href="#" class="togglers" onClick="toggleOnly('{bu:postalAddressType}{bu:addressId}',this.id,'{bu:logicalAddressType}');return false;">
                            ▼<xsl:value-of select="bu:logicalAddressType"/>
                        </a>
                        <div id="{bu:postalAddressType}{bu:addressId}" class="toggle address-info">
                            <div class="address-block">
                                <address>
                                    <strong>
                                        <xsl:value-of select="$short-name"/>
                                    </strong>
                                    <br/>
                                    <bu:street type="xs:string">address</bu:street>, room <bu:groupId type="xs:integer">4</bu:groupId>
                                    <br/>
                                    <xsl:value-of select="bu:city"/>, <xsl:value-of select="bu:countryId"/>&#160;<xsl:value-of select="bu:zipCode"/>
                              &#160;<xsl:value-of select="bu:postalAddressType/@showAs"/>&#160;<bu:addressId type="xs:integer">4</bu:addressId>
                                    <br/>
                                    <abbr title="Phone">Phone:</abbr>
                                    <xsl:value-of select="bu:phone"/>
                                    <br/>
                                    <abbr title="Fax">Fax:</abbr>
                                    <xsl:value-of select="bu:fax"/>
                                </address>
                                <address>
                                    <strong>
                                        <xsl:value-of select="$full-name"/>
                                    </strong>
                                    <br/>
                                    <a href="mailto:#">
                                        <xsl:value-of select="bu:email"/>
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