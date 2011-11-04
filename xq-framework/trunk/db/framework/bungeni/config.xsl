<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 2, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Ashok Hariharan</xd:p>
            <xd:p>Common Configuration variables used in XSLTs - simply include this at the beginning of your XSLT</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="ui-config" select="string('ui-config.xml')"/>
    <xsl:variable name="date-format" select="document($ui-config)/ui/format[@type='date']/text()"/>
    <xsl:variable name="datetime-format" select="document($ui-config)/ui/format[@type='datetime']/text()"/>
    <!-- sub-menu nav -->
    <xsl:function name="xqcfg:get_sub_nav">
        <xsl:param name="main-nav"/>
        <xsl:call-template name="get_menu_tree">
            <xsl:with-param name="top-level" select="$main-nav"/>
        </xsl:call-template>
    </xsl:function>
    <xsl:template name="get_menu_tree">
        <xsl:param name="top-level"/>
        <xsl:copy-of select="document($ui-config)/ui/menugroups/menu/submenu[@for=$top-level]"/>
    </xsl:template>    
    <!-- tab-menu nav -->
    <xsl:function name="xqcfg:get_tab">
        <xsl:param name="tab-group"/>
        <xsl:call-template name="get_tab">
            <xsl:with-param name="tab-name" select="$tab-group"/>
        </xsl:call-template>
    </xsl:function>
    <xsl:template name="get_tab">
        <xsl:param name="tab-name"/>
        <xsl:sequence select="document($ui-config)/ui/tabgroups/tabs[@name=$tab-name]"/>
    </xsl:template>
</xsl:stylesheet>