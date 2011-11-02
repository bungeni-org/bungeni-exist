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
        <nav:tab>
            <nav:title>text</nav:title>
            <nav:path>text</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>timeline</nav:title>
            <nav:path>timeline</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>related</nav:title>
            <nav:path>related</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>attached files</nav:title>
            <nav:path>attachments</nav:path>
        </nav:tab>
    </nav:doc>
    <nav:member>
        <nav:tab>
            <nav:title>member</nav:title>
            <nav:path>member</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>information</nav:title>
            <nav:path>info</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>offices held</nav:title>
            <nav:path>offices-held</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>parliament activities</nav:title>
            <nav:path>parl-activities</nav:path>
        </nav:tab>
        <nav:tab>
            <nav:title>contacts</nav:title>
            <nav:path>contacts</nav:path>
        </nav:tab>
    </nav:member>
    <!-- End Tab Configurations -->
    <xsl:template name="doc-tabs" match="nav:tabs">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:for-each select="document('')/*/nav:doc/nav:tab">
                    <xsl:call-template name="tab-generator">
                        <xsl:with-param name="tab" select="$tab"/>
                        <xsl:with-param name="uri" select="$uri"/>
                    </xsl:call-template>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template name="mem-tabs" match="nav:tabs">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <div id="tab-menu" class="ls-tabs">
            <ul class="ls-doc-tabs">
                <xsl:for-each select="document('')/*/nav:member/nav:tab">
                    <xsl:call-template name="tab-generator">
                        <xsl:with-param name="tab" select="$tab"/>
                        <xsl:with-param name="uri" select="$uri"/>
                    </xsl:call-template>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template name="tab-generator">
        <xsl:param name="tab"/>
        <xsl:param name="uri"/>
        <xsl:choose>
            <xsl:when test="./nav:path = $tab">
                <li class="active">
                    <a href="{$tab}?doc={$uri}#">
                        <xsl:value-of select="./nav:title"/>
                    </a>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <a href="{./nav:path}?doc={$uri}">
                        <xsl:value-of select="./nav:title"/>
                    </a>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>