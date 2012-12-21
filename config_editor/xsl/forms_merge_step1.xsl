<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:custom="http://bungeni-exist.googlecode.com/custom_functions" exclude-result-prefixes="xsl custom" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:include href="merge_tags.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ui/@name"/>
    <xsl:template match="ui">
        <ui>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*|node()"/>
        </ui>
    </xsl:template>
    <xsl:template match="*[@originAttr]"/>
    <xsl:template match="roles[parent::view] | roles[parent::edit] | roles[parent::add] | roles[parent::listing]">
        <roles>
            <xsl:value-of select="string-join(data(./role), ' ')"/>
        </roles>
    </xsl:template>
</xsl:stylesheet>