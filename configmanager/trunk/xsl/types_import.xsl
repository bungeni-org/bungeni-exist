<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    <!-- types.xml importer -->
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="doc | event">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:if test="not(@descriptor)">
                <xsl:attribute name="descriptor" select="@name"/>
            </xsl:if>
            <xsl:if test="not(@workflow)">
                <xsl:attribute name="workflow" select="@name"/>
            </xsl:if>
            <xsl:if test="not(@archetype)">
                <xsl:attribute name="archetype" select="string('doc')"/>
            </xsl:if>
            <xsl:if test="not(@label)">
                <xsl:attribute name="label" select="@name"/>
            </xsl:if>
            <xsl:if test="not(@container_label)">
                <xsl:attribute name="container_label" select="concat(@name, 's')"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>