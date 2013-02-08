<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xs" version="2.0">
    
    <!-- Generic templates applied to document views -->
    <xsl:import href="tmpl-doc-generic.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 10, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Publication Report item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:template match="doc">
        <xsl:call-template name="doc-item"/>
    </xsl:template>
    
    <!-- DOC-ITEM-PREFACE -->
    <xsl:template name="doc-item-preface">
        <xsl:param name="doc-type"/>
        <h3 id="doc-heading" class="doc-headers">
            <!-- !#FIX_THIS WHEN WE HAVE PARLIAMENTARY INFO DOCUMENTS -->
            BUNGENI PARLIAMENT
        </h3>
        <h4 id="doc-item-desc" class="doc-headers">REPORT</h4>
        <!-- Call document item number -->
        <xsl:call-template name="doc-item-number">
            <xsl:with-param name="doc-type" select="$doc-type"/>
        </xsl:call-template>
        <!-- Call sponsor where applicable -->
        <xsl:call-template name="doc-item-sponsor"/>
        
        <!-- Call secondary sponsors where applicable -->
        <xsl:call-template name="doc-item-sponsors"/>
    </xsl:template>
    <xsl:template name="doc-item-sponsors"/>
    <xsl:template name="doc-item-number">
        <xsl:param name="doc-type"/>
    </xsl:template>
    <xsl:template name="doc-item-body">
        <xsl:param name="ver-uri"/>
        <xsl:variable name="render-doc" select="bu:ontology/bu:document"/>
        <div id="report-content-area">
            <span>
                <b>
                    <i18n:text key="last-event">last event(nt)</i18n:text>:</b>
            </span>
            &#160;           
            <span>
                <xsl:value-of select="if (data($render-doc/bu:status/@showAs)) then data($render-doc/bu:status/@showAs) else $render-doc/bu:status/bu:value"/>
            </span>
            <br/>
            <span>
                <b>
                    <i18n:text key="date-on">date(nt)</i18n:text>:</b>
            </span>
            &#160;
            <span>
                <xsl:value-of select="format-dateTime($render-doc/bu:statusDate,$datetime-format,'en',(),())"/>
            </span>
            <div>
                <xsl:copy-of select="$render-doc/bu:body/div/child::*"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>