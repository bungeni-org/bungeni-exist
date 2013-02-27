<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="func_dates.xsl" />
    
    <xsl:template match="field[@name='membership_id']">
        <membershipId type="xs:integer">
            <xsl:value-of select="." />
        </membershipId>
    </xsl:template>    
    
    <xsl:template match="field[@name='title_type_id']">
        <titleTypeId type="xs:integer">
            <xsl:value-of select="." />
        </titleTypeId>
    </xsl:template>  
    
    <xsl:template match="field[@name='member_title_id']">
        <memberTitleId type="xs:integer">
            <xsl:value-of select="." />
        </memberTitleId>
    </xsl:template>  
    
    
    <xsl:template match="field[@name='membership_type']">
        <membershipType isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="." />                
            </value>
        </membershipType>
    </xsl:template>      
    
    <xsl:template match="field[@name='election_nomination_date']">
        <xsl:variable name="nomination_date" select="." />
        <electionNominationDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($nomination_date)" />
        </electionNominationDate>
    </xsl:template>      
    
    <xsl:template match="field[@name='election_date']">
        <xsl:variable name="elec_date" select="." />
        <electionDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($elec_date)" />
        </electionDate>
    </xsl:template>      
    
    <xsl:template match="field[@name='member_election_type']">
        <memberElectionType isA="TLCTerm" showAs="{data(@displayAs)}">
            <value type="xs:string">
                <xsl:value-of select="." />
            </value>            
        </memberElectionType>
    </xsl:template>
    
    <xsl:template match="field[@name='user_unique']">
        <userUnique type="xs:boolean" showAs="{data(@displayAs)}">
            <xsl:variable name="user_unique">
                <xsl:value-of select="." />
            </xsl:variable>
            <xsl:value-of select="lower-case($user_unique)" />
        </userUnique>
    </xsl:template>  
    
    <xsl:template match="field[@name='sort_order']">
        <sortOrder type="xs:integer">
            <xsl:value-of select="." />
        </sortOrder>
    </xsl:template>    
    
    <xsl:template match="field[@name='title_name']">
        <titleName type="xs:string">
            <xsl:value-of select="." />
        </titleName>
    </xsl:template>    
    
    
    
    
</xsl:stylesheet>