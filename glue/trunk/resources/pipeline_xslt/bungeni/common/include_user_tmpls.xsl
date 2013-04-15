<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="include_tmpls.xsl" />
    
    <xsl:template match="field[@name='active_p'][not(parent::member)]">
        <activeStatus isA="TLCTerm">
            <value type="xs:string">
            <xsl:variable name="field_active" select="." />
            <xsl:choose >
                <xsl:when test="$field_active eq 'A'">active</xsl:when>
                <xsl:when test="$field_active eq 'I'">inactive</xsl:when>
                <xsl:otherwise>deceased</xsl:otherwise>
            </xsl:choose>
            </value>
        </activeStatus>
    </xsl:template>

    <xsl:template match="field[@name='active_p'][parent::member]">
        <activeStatus isA="TLCTerm">
            <value type="xs:string">
                <xsl:variable name="field_active" select="." />
                <xsl:choose >
                    <xsl:when test="$field_active eq 'True'">active</xsl:when>
                    <xsl:otherwise>inactive</xsl:otherwise>
                </xsl:choose>
            </value>
        </activeStatus>
    </xsl:template>
    
    <xsl:template match="field[@name='first_name']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>firstName</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>   
    
    <xsl:template match="field[@name='last_name']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>lastName</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>  
    
    <!-- !+COMMON
    <xsl:template match="field[@name='user_id']">
        <userId type="xs:integer">
            <xsl:value-of select="." />
        </userId>
    </xsl:template>    
    -->
    
    <!-- !+COMMON
    <xsl:template match="field[@name='description']">
        <description>
            <xsl:value-of select="." />
        </description>
    </xsl:template>   
    -->
    
    <xsl:template match="field[@name='gender']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">gender</xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    <xsl:template match="field[@name='marital_status']">
        <xsl:call-template name="renderTLCTermString">
            <xsl:with-param name="elementName">maritalStatus</xsl:with-param>
        </xsl:call-template>
    </xsl:template>   
    
    <xsl:template match="field[@name='date_of_birth']">
        <dateOfBirth type="xs:date">
            <xsl:value-of select="." />
        </dateOfBirth>
    </xsl:template>  
    
    <!-- !+COMMON
    <xsl:template match="field[@name='title'][parent::owner or parent::contenttype[@name='user']]">
        <title type="xs:string">
            <xsl:value-of select="." />
        </title>
    </xsl:template>  
    -->
    
    <xsl:template match="field[@name='salutation']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>salutation</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>         
    
    <xsl:template match="field[@name='birth_country']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>birthCountry</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='current_nationality']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>nationality</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>    
    
    
    
    <xsl:template match="field[@name='national_id']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>nationalId</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
        
    </xsl:template>   
    
    <xsl:template match="field[@name='login']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>login</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>    
    
    
    <xsl:template match="field[@name='salt']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>salt</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>    
    
    <xsl:template match="field[@name='email']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>email</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>  
    
    <xsl:template match="field[@name='birth_nationality']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>birthNationality</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>    
    
    
    <xsl:template match="image">
        <image isA="TLCObject">
            <xsl:apply-templates />
        </image>
    </xsl:template>       
    
    <!-- !+COMMON
    <xsl:template match="field[@name='saved_file']">
        <savedFile type="xs:string">
            <xsl:value-of select="." />
        </savedFile>
    </xsl:template>  
    -->
    
    <xsl:template match="field[@name='img_hash']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>imageHash</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    <xsl:template match="user_addresses">
        <addresses>
            <xsl:apply-templates />
        </addresses>
    </xsl:template>    
    
    <xsl:template match="user_address">
        <xsl:call-template name="address" />
    </xsl:template>   
    
    <!-- !+COMMON
    <xsl:template match="field[@name='status']">
        <addressStatus type="xs:string">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="." />
        </addressStatus>
    </xsl:template>    
    -->
    
    <xsl:template match="field[@name='city']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>city</xsl:text>
            </xsl:with-param>
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
    
    <xsl:template match="field[@name='phone']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>phone</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>      
    
    <xsl:template match="field[@name='street']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>street</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>   
    
    <xsl:template match="field[@name='fax']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>fax</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>      
    
    <xsl:template match="field[@name='zipcode']">
        <xsl:call-template name="renderStringElement">
            <xsl:with-param name="elementName">
                <xsl:text>zipCode</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    <xsl:template match="field[@name='principal_id']">
        <principalId type="xs:integer" key="true">
            <xsl:value-of select="." />
        </principalId>
    </xsl:template>
    
    
</xsl:stylesheet>