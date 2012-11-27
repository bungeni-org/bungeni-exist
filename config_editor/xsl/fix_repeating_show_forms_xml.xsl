<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" />
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="show[following-sibling::show]">
        <xsl:variable name="next-show" select="following-sibling::show" />
        <show>
            <xsl:attribute name="modes">
                <xsl:value-of select="concat(data(@modes), ' ', data($next-show/@modes))" />
            </xsl:attribute>
        </show>
    </xsl:template>
    
    <xsl:template match="show[preceding-sibling::show]" />
    
    
</xsl:stylesheet>