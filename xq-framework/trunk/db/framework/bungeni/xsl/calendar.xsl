<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 22, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Sitting item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_downloads.xsl"/> 
    <!-- Parameter from Bungeni.xqm denoting this as version of a parliamentary 
        document as opposed to main document. -->
    <xsl:param name="serverport"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology//bu:groupsitting/bu:docType/bu:value"/>
        <xsl:variable name="doc_uri" select="bu:ontology/bu:groupsitting/@uri"/>
        <xsl:variable name="mover_uri" select="bu:ontology/bu:document/bu:owner/bu:person/@href"/>
        <xsl:variable name="j-obj" select="json"/>
        <div id="main-wrapper">
            <div id="uri" class="hide">
                <xsl:value-of select="$doc_uri"/>
            </div>
            <div id="title-holder">
                <h1 class="title">
                    <i18n:text key="doc-calendar">Calendar(nt)</i18n:text>                     
                    <!-- If its a version and not a main document... add version title below main title -->
                </h1>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" style="padding:0;" role="main">
                <div id="doc-calendar-holder" class="dhtmlx_calendar_exist">
                    <div id="scheduler_here" class="dhx_cal_container" style="width:auto; height:100%;">
                        <div class="dhx_cal_navline">
                            <div class="dhx_cal_prev_button">&#160;</div>
                            <div class="dhx_cal_next_button">&#160;</div>
                            <div class="dhx_cal_today_button"/>
                            <div class="dhx_cal_date"/>
                            <div class="dhx_cal_tab" name="day_tab" style="right:204px;"/>
                            <div class="dhx_cal_tab" name="week_tab" style="right:140px;"/>
                            <div class="dhx_cal_tab" name="month_tab" style="right:76px;"/>
                            <div class="dhx_cal_tab" name="year_tab" style="right:280px;"/>
                        </div>
                        <div class="dhx_cal_header"/>
                        <div class="dhx_cal_data"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>