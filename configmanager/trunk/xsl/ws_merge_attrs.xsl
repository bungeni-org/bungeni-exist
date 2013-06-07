<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
    -->
    <xsl:import href="merge_tags.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <!-- 
        remove empty workspace states 
        http://stackoverflow.com/questions/11539910/remove-parent-node-if-a-child-node-is-empty
    -->
    <xsl:template match="state[not(tab[not(@roles = '')])]"/>
    <xsl:template match="tab">
        <tab>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
        </tab>
    </xsl:template> 
    <!-- remove empty workspace tabs -->
    <xsl:template match="tab[normalize-space(@roles) = '']"/>
    <xsl:template match="*[@originAttr]"/>
    <xsl:template match="workspace/@name"/>
</xsl:stylesheet>