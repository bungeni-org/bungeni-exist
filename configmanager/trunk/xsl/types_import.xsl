<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    <!-- types.xml importer -->
    
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="doc[not(@descriptor)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="descriptor" select="@name" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="event[not(@descriptor)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="descriptor" select="@name" />
            <xsl:apply-templates />
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="doc[not(@workflow)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="workflow" select="@name" />
            <xsl:apply-templates />
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="event[not(@workflow)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="workflow" select="@name" />
            <xsl:apply-templates />
            
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="doc[not(@archetype)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="archetype" select="string('doc')" />
            <xsl:apply-templates />
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="event[not(@archetype)]">
        <xsl:copy>
            <xsl:copy-of select="@*[. ne '']"/>
            <xsl:attribute name="archetype" select="string('event')" />
            <xsl:apply-templates />
            
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:stylesheet>