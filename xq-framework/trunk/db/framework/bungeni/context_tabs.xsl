<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:nav="http://www.bungeni/org/eXistPortal" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs nav" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Tabs on a Documents</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <nav:tabs>
        <nav:tab>text</nav:tab>
        <nav:tab>timeline</nav:tab>
        <nav:tab>attachments</nav:tab>
    </nav:tabs>
    <xsl:template name="doc-tabs" match="nav:tabs">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:for-each select="document('')/*/nav:tabs/nav:tab">
                    <xsl:choose>
                        <xsl:when test=". = $tab">
                            <li class="active">
                                <a href="{$tab}?doc={$uri}#">
                                    <xsl:value-of select="."/>
                                </a>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <a href="{.}?doc={$uri}">
                                    <xsl:value-of select="."/>
                                </a>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
</xsl:stylesheet>