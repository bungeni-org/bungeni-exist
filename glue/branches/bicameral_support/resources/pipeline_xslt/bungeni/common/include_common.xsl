<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    exclude-result-prefixes="xs bdates"
    version="2.0">
    <xsl:import href="func_dates.xsl" />
    <xsl:import href="include_tmpls.xsl" />
    
    <xsl:template match="field[@name='language']">
        <language type="xs:string" >
            <xsl:if test="@displayAs">
                <xsl:attribute name="showAs"><xsl:value-of select="@displayAs" /></xsl:attribute>
            </xsl:if>
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

<!--
    <xsl:template match="field[@name='status_date']">
        <xsl:variable name="status_date" select="." />
        <statusDate type="xs:dateTime">
            <xsl:value-of select="bdates:parse-date($status_date)" />
        </statusDate>  
    </xsl:template>
-->
    
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
    
    <!--
    <xsl:template match="permission">
        <permission 
            setting="{field[@name='setting']}" 
            name="{field[@name='permission']}"  
            role="{field[@name='role']}" />
    </xsl:template>    
    -->
    <xsl:template match="permissions">
        <permissions>
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    <xsl:template match="permissions[parent::document]">
        <permissions id="documentPermissions">
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
    <xsl:template match="permission">
        <xsl:variable name="bungeni-content-type" select="data(//custom/bungeni_doc_type)" />
        <xsl:variable name="content-type-uri-name" select="data(/ontology/document/docType[@isA='TLCTerm']/value)" />
        
        <xsl:variable name="perm-content-type-view" select="concat('bungeni.',$bungeni-content-type,'.View')" />
        <xsl:variable name="perm-content-type-edit" select="concat('bungeni.',$bungeni-content-type,'.View')" />
        <!--
        <xsl:variable name="perm-event-type-view">
            <xsl:if test="head/node()">
                <xsl:value-of select="concat('bungeni.',head/field[@name='type'],'.View')"/>
            </xsl:if>
        </xsl:variable>          
        -->
        <xsl:variable name="perm-name" select="data(field[@name='permission'])" />
        <xsl:variable name="perm-role" select="data(field[@name='role'])" />
        <xsl:variable name="perm-setting" select="data(field[@name='setting'])" />
        <permission 
            setting="{$perm-setting}" 
            name="{$perm-name}"  
            role="{$perm-role}" />
        <xsl:choose>
            <xsl:when test="$perm-name eq $perm-content-type-view">
                <control name="View" setting="{$perm-setting}" role="{$perm-role}" />  
            </xsl:when>
            <xsl:when test="$perm-name eq $perm-content-type-edit">
                <control name="Edit" setting="{$perm-setting}" role="{$perm-role}" />  
            </xsl:when>
           <!--
            <xsl:when test="not(empty($perm-event-type-view)) and ends-with($perm-name,'.View')">
                <control name="View" setting="{$perm-setting}" role="{$perm-role}" />  
            </xsl:when>
            -->
            <xsl:otherwise />
        </xsl:choose>
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
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>statusDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    </xsl:template>    
    
    <xsl:template match="field[@name='timestamp']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>timestampDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>    
    </xsl:template>
    
    
    <xsl:template match="field[@name='body_text' or @name='body']">
        <body type="xs:string">
            <xsl:value-of select="." />
        </body>
    </xsl:template>    
    
    
    
    <xsl:template match="field[@name='doc_id']">
        <docId type="xs:integer">
            <xsl:value-of select="." />
        </docId>
    </xsl:template>    
    
    <xsl:template match="field[@name='attachment_id']">
        <attachmentId type="xs:integer">
            <xsl:value-of select="." />
        </attachmentId>
    </xsl:template>    
    
    <xsl:template match="field[@name='geolocation']">
        <xsl:if test=". ne 'None'">
            <geoLocation type="xs:string">
                <xsl:value-of select="." />
            </geoLocation>
        </xsl:if>
    </xsl:template>
    
    
    
    <xsl:template match="field[@name='owner_id']">
        <ownerId type="xs:integer">
            <xsl:value-of select="." />
        </ownerId>
    </xsl:template>
    
    
    <xsl:template match="field[@name='date_active']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>activeDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 
    
    
    <xsl:template match="field[@name='date_audit']">
        <xsl:call-template name="renderDateElement">
            <xsl:with-param name="elementName">
                <xsl:text>auditDate</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 
    
    
    
    
</xsl:stylesheet>