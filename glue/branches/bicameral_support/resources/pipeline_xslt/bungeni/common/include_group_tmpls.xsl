<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="func_dates.xsl" />
    
    <xsl:template match="field[@name='acronym']">
        <acronym isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </acronym>
    </xsl:template>      
    
    <xsl:template match="field[@name='quorum']">
        <quorum type="xs:integer">
            <xsl:value-of select="." />
        </quorum>
    </xsl:template>

    <xsl:template match="field[@name='group_id']">
        <groupId type="xs:integer">
            <xsl:value-of select="." />
        </groupId>
    </xsl:template>
    
    <xsl:template match="field[@name='parent_group_id']">
        <parentGroupId type="xs:integer">
            <xsl:value-of select="." />
        </parentGroupId>
    </xsl:template>
    
    <xsl:template match="field[@name='group_continuity']">
        <groupContinuity isA="TLCTerm">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </groupContinuity>
    </xsl:template> 
    
    <xsl:template match="field[@name='num_members']">
        <numMembers type="xs:integer">
            <xsl:value-of select="." />
        </numMembers>
    </xsl:template>    
    
    <xsl:template match="field[@name='sub_type']">
        <subType isA="TLCTerm">
            <xsl:attribute name="showAs" select="@displayAs"/>
            <xsl:value-of select="."/>
        </subType>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='committee_id']">
        <committeeId type="xs:integer">
            <xsl:value-of select="." />
        </committeeId>
    </xsl:template>   
    
    <xsl:template match="field[@name='start_date']">
        <xsl:variable name="start_date" select="." />
        <startDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($start_date)" />
        </startDate>
    </xsl:template>
    

    <xsl:template match="field[@name='end_date']">
        <xsl:variable name="end_date" select="." />
        <endDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($end_date)" />
        </endDate>
    </xsl:template>    
    
    <xsl:template match="field[@name='min_num_members']">
        <minNumMembers type="xs:integer">
            <xsl:value-of select="." />
        </minNumMembers>
    </xsl:template>
    
    <xsl:template match="field[@name='num_researchers']">
        <numResearchers type="xs:integer">
            <xsl:value-of select="." />
        </numResearchers>
    </xsl:template>    
    
    
    <xsl:template match="field[@name='group_principal_id']">
        <groupPrincipalId isA="TLCReference">
            <value type="xs:string">
                <xsl:value-of select="." />                
            </value>
        </groupPrincipalId>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='identifier']">
        <identifier isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="." />                
            </value>
        </identifier>
    </xsl:template>     
    

    <xsl:template match="group_addresses">
        <groupAddresses>
            <xsl:apply-templates />    
        </groupAddresses>
    </xsl:template>      
    
    <xsl:template match="group_address[parent::group_addresses]">
        <groupAddress isA="TLCObject">
            <xsl:apply-templates />
        </groupAddress>
    </xsl:template>      
    
    <xsl:template match="members">
        <members id="groupMembers">
            <xsl:apply-templates />
        </members>
    </xsl:template>
    
    <xsl:template match="member[parent::members]">
        <member isA="TLCObject">
            <xsl:apply-templates />
        </member>
    </xsl:template>

  <!-- !+FIX_THIS parent group templates to be done -->

    <xsl:template match="parent_group">
        <xsl:if test="not(normalize-space(.))">
            <parentGroup>
                <xsl:apply-templates />
            </parentGroup>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>