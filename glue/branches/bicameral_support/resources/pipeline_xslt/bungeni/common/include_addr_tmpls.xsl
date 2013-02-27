<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    
    <xsl:template match="field[@name='country_id']">
        <countryId type="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="."/>                
            </value>
        </countryId>
    </xsl:template>  
    
    <xsl:template match="field[@name='address_id']">
        <addressId type="xs:integer">
            <xsl:value-of select="."/>
        </addressId>
    </xsl:template> 
    
    
    <xsl:template match="field[@name='city']">
        <city type="xs:string">
            <xsl:value-of select="."/>
        </city>
    </xsl:template>  
    
    <xsl:template match="field[@name='fax']">
        <fax type="xs:string">
            <xsl:value-of select="."/>
        </fax>
    </xsl:template>  
    
    <xsl:template match="field[@name='country_name']">
        <countryName type="xs:string">
            <xsl:value-of select="." />
        </countryName>
    </xsl:template>
    
    
    <xsl:template match="field[@name='numcode']">
        <numericCode type="xs:integer">
            <xsl:value-of select="." />
        </numericCode>
    </xsl:template>  
    
    
    
    <xsl:template match="field[@name='iso_name']">
        <isoName type="xs:string">
            <xsl:value-of select="." />
        </isoName>
    </xsl:template>  
    
    <xsl:template match="field[@name='iso3']">
        <iso3Code type="xs:string">
            <xsl:value-of select="." />
        </iso3Code>
    </xsl:template>  
    
    <xsl:template match="field[@name='phone']">
        <phone type="xs:string">
            <xsl:value-of select="."/>
        </phone>
    </xsl:template>      
    
    <xsl:template match="field[@name='street']">
        <street type="xs:string">
            <xsl:value-of select="."/>
        </street>
    </xsl:template>      
    
    <xsl:template match="field[@name='postal_address_type']">
        <postalAddressType isA="TLCTerm">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </postalAddressType>
    </xsl:template>
    
    <xsl:template match="field[@name='logical_address_type']">
        <logicalAddressType isA="TLCTerm">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </logicalAddressType>
    </xsl:template>      
    
    <xsl:template match="field[@name='zipcode']">
        <zipCode type="xs:integer">
            <xsl:value-of select="."/>
        </zipCode>
    </xsl:template>      
    
    
</xsl:stylesheet>