<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="func_dates.xsl" />
    
    <xsl:template match="field[@name='language']">
        <language type="xs:string" showAs="{data(@displayAs)}">
            <xsl:value-of select="." />
        </language>
    </xsl:template>  
    
    
    <xsl:template match="field[@name='parliament_id']">
        <parliamentId key="true" type="xs:integer">
            <xsl:value-of select="." />
        </parliamentId>
    </xsl:template>  
    
    <xsl:template match="field[@name='title']">
        <title type="xs:string">
            <xsl:value-of select="." />
        </title>
    </xsl:template>  
    
    <xsl:template match="field[@name='user_id']">
        <userId type="xs:integer">
            <xsl:value-of select="." />
        </userId>
    </xsl:template>    
    
    <xsl:template match="field[@name='saved_file']">
        <savedFile type="xs:string">
            <xsl:value-of select="." />
        </savedFile>
    </xsl:template>  
    
    <xsl:template match="field[@name='status']">
        <status type="xs:string">
            <xsl:if test="@displayAs">
                <xsl:attribute name="showAs">
                    <xsl:value-of select="@displayAs" />
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </status>
    </xsl:template>

    <xsl:template match="field[@name='status_date']">
        <xsl:variable name="status_date" select="." />
        <statusDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($status_date)" />
        </statusDate>  
    </xsl:template>
    
    <xsl:template match="field[@name='parliament_type']">
        <legislatureType isA="TLCTerm" showAs="{data(@displayAs)}">
            <value type="xs:string">
                <xsl:value-of select="." />
            </value>
        </legislatureType>
    </xsl:template>
    
    <xsl:template match="field[@name='type']">
        <type isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="." />
            </value>
        </type>
    </xsl:template> 
    
    <xsl:template match="field[@name='tag']">
        <tag isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="." />
            </value>    
        </tag>
    </xsl:template>    
    
    <xsl:template match="field[@name='first_name']">
        <firstName type="xs:string">
            <xsl:value-of select="." />
        </firstName>
    </xsl:template>  
    
    <xsl:template match="field[@name='last_name']">
        <lastName type="xs:string">
            <xsl:value-of select="." />
        </lastName>
    </xsl:template>      
    
    <xsl:template match="field[@name='short_name']">
        <shortName type="xs:string">
            <xsl:value-of select="." />
        </shortName>
    </xsl:template>
    
    <xsl:template match="field[@name='full_name']">
        <fullName type="xs:string">
            <xsl:value-of select="." />
        </fullName>
    </xsl:template>
    
    
    <xsl:template match="field[@name='description']">
        <description>
            <xsl:value-of select="." />
        </description>
    </xsl:template>   
    
    
    <xsl:template match="permissions">
        <permissions >
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    <xsl:template match="permission">
        <permission 
            setting="{field[@name='setting']}" 
            name="{field[@name='permission']}"  
            role="{field[@name='role']}" />
    </xsl:template>    
    
    <xsl:template match="versions">
        <versions>
            <xsl:apply-templates />
        </versions>
    </xsl:template>
    
    <xsl:template match="field[@name='notes']">
        <notes type="xs:string">
            <xsl:value-of select="." />
        </notes>
    </xsl:template>
    
    <xsl:template match="field[@name='status_date']">
        <xsl:variable name="status_date" select="." />
        <statusDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($status_date)" />
        </statusDate>  
    </xsl:template>    
    
</xsl:stylesheet>