<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
  
    <xsl:template match="@roles">
        <xsl:element name="roles">
            <xsl:attribute name="originAttr">roles</xsl:attribute>
            <xsl:for-each select="tokenize(normalize-space(.), '\s+')">
                <role>
                    <xsl:value-of select="."/>
                </role>
            </xsl:for-each>
            <!-- !+NOTE blank role not shown but used as template node in XForms -->
            <role>ALL</role>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>