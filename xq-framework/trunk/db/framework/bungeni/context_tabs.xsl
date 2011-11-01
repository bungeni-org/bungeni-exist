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
    
    <!-- Start Tab Configurations -->
    <nav:doc>
        <nav:tab>text</nav:tab>
        <nav:tab>timeline</nav:tab>
        <nav:tab>related</nav:tab>
        <nav:tab>attachments</nav:tab>
    </nav:doc>
    <nav:member>
        <nav:tab>member</nav:tab>
        <nav:tab>info</nav:tab>
        <nav:tab>office-held</nav:tab>
        <nav:tab>parl-activities</nav:tab>
        <nav:tab>contacts</nav:tab>
    </nav:member>
    <!-- End Tab Configurations -->
    <xsl:template name="doc-tabs" match="nav:tabs">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <xsl:param name="title"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:call-template name="tab-generator">
                    <xsl:with-param name="tab" select="$tab"/>
                    <xsl:with-param name="uri" select="$uri"/>
                    <xsl:with-param name="title">text default</xsl:with-param>
                    <xsl:with-param name="for">document('')/*/nav:doc/nav:tab</xsl:with-param>
                </xsl:call-template>
            </ul>
        </div>
    </xsl:template>
    <xsl:template name="mem-tabs" match="nav:tabs">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <xsl:param name="title"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:call-template name="tab-generator">
                    <xsl:with-param name="tab" select="$tab"/>
                    <xsl:with-param name="uri" select="$uri"/>
                    <xsl:with-param name="title">members of parliament</xsl:with-param>
                    <xsl:with-param name="for" select="document('')/*/nav:member/nav:tab"/>
                </xsl:call-template>
            </ul>
        </div>
    </xsl:template>
    <xsl:template name="tab-generator">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <xsl:param name="title"/>
        <xsl:param name="for"/>
        <xsl:for-each select="document('')/*/nav:doc/nav:tab">
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
    </xsl:template>
</xsl:stylesheet>