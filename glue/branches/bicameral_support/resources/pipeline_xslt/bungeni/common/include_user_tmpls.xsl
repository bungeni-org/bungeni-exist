<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="field[@name='active_p']">
        <status>
            <xsl:variable name="field_active" select="." />
            <xsl:choose >
                <xsl:when test="$field_active eq 'A'">active</xsl:when>
                <xsl:otherwise>inactive</xsl:otherwise>
            </xsl:choose>
        </status>
    </xsl:template>
    
    <xsl:template match="field[@name='first_name']">
        <firstName>
            <xsl:value-of select="." />
        </firstName>
    </xsl:template>   
    
    <xsl:template match="field[@name='last_name']">
        <lastName>
            <xsl:value-of select="." />
        </lastName>
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
        <gender isA="TLCTerm">
            <xsl:if test="@displayAs">
                <xsl:attribute name="showAs">
                    <xsl:value-of select="@displayAs" />
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </gender>
    </xsl:template>   
    
    <xsl:template match="field[@name='marital_status']">
        <maritalStatus isA="TLCTerm">
            <xsl:if test="@displayAs">
                <xsl:attribute name="showAs">
                    <xsl:value-of select="@displayAs" />
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </maritalStatus>
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
        <salutation type="xs:string">
            <xsl:value-of select="." />
        </salutation>
    </xsl:template>         
    
    <xsl:template match="field[@name='birth_country']">
        <birthCountry type="xs:string">
            <xsl:value-of select="." />
        </birthCountry>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='current_nationality']">
        <currentNationality type="xs:string">
            <xsl:value-of select="."/>
        </currentNationality>
    </xsl:template>    
    
    
    
    <xsl:template match="field[@name='national_id']">
        <nationalId type="xs:string">
            <xsl:value-of select="." />
        </nationalId>
    </xsl:template>   
    
    <xsl:template match="field[@name='login']">
        <login type="xs:string">
            <xsl:value-of select="." />
        </login>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='salt']">
        <salt type="xs:string">
            <xsl:value-of select="." />
        </salt>
    </xsl:template>    
    
    <xsl:template match="field[@name='email']">
        <email type="xs:string">
            <xsl:value-of select="." />
        </email>
    </xsl:template>  
    
    <xsl:template match="field[@name='birth_nationality']">
        <birthNationality type="xs:string">
            <xsl:value-of select="." />
        </birthNationality>
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
        <imageHash type="xs:string">
            <xsl:value-of select="." />
        </imageHash>
    </xsl:template>
    
    <xsl:template match="user_addresses">
        <userAddresses>
            <xsl:apply-templates />
        </userAddresses>
    </xsl:template>    
    
    <xsl:template match="user_address">
        <userAddress isA="TLCObject">
            <xsl:apply-templates />
        </userAddress>
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
        <city type="xs:string">
            <xsl:value-of select="."/>
        </city>
    </xsl:template>
    
    
    <xsl:template match="field[@name='postal_address_type']">
        <postalAddressType type="xs:string">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </postalAddressType>
    </xsl:template>
    
    <xsl:template match="field[@name='logical_address_type']">
        <logicalAddressType type="xs:string">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </logicalAddressType>
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
    
    <xsl:template match="field[@name='fax']">
        <fax type="xs:string">
            <xsl:value-of select="."/>
        </fax>
    </xsl:template>      
    
    <xsl:template match="field[@name='zipcode']">
        <zipCode type="xs:integer">
            <xsl:value-of select="."/>
        </zipCode>
    </xsl:template>
    
    
</xsl:stylesheet>