<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 2, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Ashok Hariharan</xd:p>
            <xd:p>
            This XSLT reads the ui-config.xml for the application and provides helper functions for rendering
            tabs, menus and also renders configurabel search dropdowns
            Common Configuration variables used in XSLTs - simply include this at the beginning of your XSLT
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- THE BELOW SETTINGS DONT WORK CORRECTLY YET -->
    <xsl:variable name="fw-config" select="document('/exist/rest/db/framework/config.xml')"/>
    <xsl:variable name="default-app" select="$fw-config//fw-config/@default-app/text()"/>
    <!-- <xsl:variable name="ui-config" select="$fw-config//fw-config/apps/app[@name eq $default-app]/ui-config/text()" /> -->
    <!-- !+FIX_THIS hardcoded config file name , maybe OK since we are within the application and the application knows about its config -->
    <xsl:variable name="ui-config" select="string('ui-config.xml')"/>
    <xsl:variable name="date-format" select="document($ui-config)/ui/format[@type='date']/text()"/>
    <xsl:variable name="datetime-format" select="document($ui-config)/ui/format[@type='datetime']/text()"/>
    
    <!-- FUNCTIONS -->
    
    <!-- 
        XSLT Function to get sub navigation from ui-config.xml 
        This can be used in a XSL for-each loop to iterate through a sub-navigation
    -->
    <xsl:function name="xqcfg:get_sub_nav">
        <xsl:param name="main-nav"/>
        <xsl:call-template name="get_sub_nav">
            <xsl:with-param name="top-level" select="$main-nav"/>
        </xsl:call-template>
    </xsl:function>
    
    <!-- XSLT Function to get tabs for a specific tab group from ui-config.xml 
          This can be used in a XSL for-each loop to iterate through a set of tabs
        -->
    <xsl:function name="xqcfg:get_tab">
        <xsl:param name="tab-group"/>
        <xsl:call-template name="get_tab">
            <xsl:with-param name="tab-name" select="$tab-group"/>
        </xsl:call-template>
    </xsl:function>
    
    <!-- XSLT Function to get searchin configuration for a documen type from ui-config.xml 
        This can be used in a XSL for-each loop to iterate through a set of searchin elements
    -->
    <xsl:function name="xqcfg:get_searchin">
        <xsl:param name="doctype"/>
        <xsl:call-template name="get_searchin">
            <xsl:with-param name="doctype" select="$doctype"/>
        </xsl:call-template>
    </xsl:function>
    
    <!-- XSLT Function to get order by configuraiton for a documen type from ui-config.xml 
        This can be used in a XSL for-each loop to iterate through a set of orderby elements
    -->
    <xsl:function name="xqcfg:get_orderby">
        <xsl:param name="doctype"/>
        <xsl:call-template name="get_orderby">
            <xsl:with-param name="doctype" select="$doctype"/>
        </xsl:call-template>
    </xsl:function>
    

    <!--
        Accessor Template used by get_sub_nav function to access submenu information from configuration
        -->
    <xsl:template name="get_sub_nav">
        <xsl:param name="top-level"/>
        <xsl:copy-of select="document($ui-config)/ui/menugroups/menu/submenu[@for=$top-level]"/>
    </xsl:template>    
    

    <!--
        Accessor Template used by get_tab function to access submenu information from configuration
    -->
    <xsl:template name="get_tab">
        <xsl:param name="tab-name"/>
        <xsl:sequence select="document($ui-config)/ui/tabgroups/tabs[@name=$tab-name]"/>
    </xsl:template>
    
    <!--
    
    Accessor templates for getting orderby and searchin configurations
    
    <ui>
    ...
    <doctypes>
        <doctype name="bill">
            <orderbys>
                <orderby value="st_date_oldest" order="asc">status date [oldest]</orderby>
                <orderby value="st_date_newest" order="desc">status date [newest]</orderby>
            </orderbys>
            <searchins>
                <searchin value="title">Title</searchin>
                <searchin value="body">Body</searchin>
            </searchins>
        </doctype>
    </doctypes>
    ...
    </ui>
    -->
    <xsl:template name="get_searchin">
        <xsl:param name="doctype"/>
        <xsl:sequence select="document($ui-config)/ui/doctypes/doctype[@name eq $doctype]/searchins"/>
    </xsl:template>
    <xsl:template name="get_orderby">
        <xsl:param name="doctype"/>
        <xsl:sequence select="document($ui-config)/ui/doctypes/doctype[@name eq $doctype]/orderbys"/>
    </xsl:template>
</xsl:stylesheet>