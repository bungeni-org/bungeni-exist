<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    
    <!-- Generic templates applied to document views -->
    <xsl:import href="tmpl-grp-generic.xsl"/>
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
    <xsl:template match="doc">
        
        <!-- Call the generic group renderer -->
        <xsl:call-template name="grp-item"/>
    </xsl:template>
    
    <!-- Add local-template overrides here -->
    <!-- GRP-ITEM-BODY -->
    <xsl:template name="doc-item-body">
        <h4 class="doc-status">
            <span>
                <b>
                    <i18n:text key="status">status(nt)</i18n:text>:&#160;</b>
            </span>
            <span>
                <i18n:text key="bu:ontology/bu:group/bu:status/@showAs">
                    <xsl:value-of select="bu:ontology/bu:group/bu:status/@showAs"/>
                </i18n:text>&#160;
            </span>
            <span>
                <b>
                    <i18n:text key="date-start">start date(nt)</i18n:text>:&#160;</b>
            </span>
            <span>
                <xsl:value-of select="format-date(bu:ontology/bu:group/bu:startDate,'[D1o] [MNn,*-3], [Y]', 'en', (),())"/>
            </span>
        </h4>
        <div id="doc-content-area">
            <div>
                <xsl:copy-of select="bu:ontology/bu:group/bu:description"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>