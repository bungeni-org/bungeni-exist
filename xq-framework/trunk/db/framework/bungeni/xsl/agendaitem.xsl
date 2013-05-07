<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">


    <!-- Generic templates applied to document views -->
    <xsl:import href="tmpl-doc-generic.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 6, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Agenda item document item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:template match="doc">
        <xsl:call-template name="doc-item"/>
    </xsl:template>   
    
    <!-- N/A - Empty/Customize the default the below render template(s) -->
    <xsl:template name="doc-item-number">
        <xsl:param name="doc-type"/>
    </xsl:template>
    <xsl:template name="doc-item-sponsor">
        <xsl:param name="chamber"/>
    </xsl:template>
    <xsl:template name="doc-item-sponsors">
        <xsl:param name="chamber"/>
    </xsl:template>
</xsl:stylesheet>