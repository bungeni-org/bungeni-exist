<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="include_tmpls.xsl"/>
    
    <xsl:template match="field[@name='country_id']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">country</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    <xsl:template match="field[@name='address_id']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">addressId</xsl:with-param>
        </xsl:call-template>
    </xsl:template> 
    
    
    <xsl:template match="field[@name='city']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">city</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    <xsl:template match="field[@name='fax']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">fax</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    <xsl:template match="field[@name='country_name']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">countryName</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template match="field[@name='numcode']">
        <xsl:call-template name="renderIntegerElement">
            <xsl:with-param name="elementName">numericCode</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    
    
    <xsl:template match="field[@name='iso_name']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">isoName</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    <xsl:template match="field[@name='iso3']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">iso3Code</xsl:with-param>
        </xsl:call-template>
    </xsl:template>  
    
    <xsl:template match="field[@name='phone']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">phone</xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='street']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">street</xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='postal_address_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">postalAddressType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="field[@name='logical_address_type']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">logicalAddressType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template match="field[@name='zipcode']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">zipCode</xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    
</xsl:stylesheet>