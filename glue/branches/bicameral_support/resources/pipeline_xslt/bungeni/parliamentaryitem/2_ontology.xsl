<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_users.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_identity.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_common.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_user_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_group_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_memb_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_pi_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_suppress.xsl"/>
    
    
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 17, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <!--
    <xsl:variable name="country-code" select="data(/ontology/legislature/country)" />
    <xsl:variable name="parliament-election-date" select="data(/ontology/bungeni/parliament/@date)" />
    <xsl:variable name="for-parliament" select="data(/ontology/bungeni/parliament/@href)" />
    <xsl:variable name="parliament-id" select="data(/ontology/bungeni/@id)" />
    <xsl:variable name="type-mappings" select="//custom/value" />
    <xsl:variable name="bungeni-content-type" select="data(//custom/bungeni_doc_type)" />
    <xsl:variable name="content-type-uri-name" select="data(/ontology/document/docType[@isA='TLCTerm']/value)" />
    
    <xsl:variable name="perm-content-type-view" select="concat('bungeni.',$bungeni-content-type,'.View')" />
    <xsl:variable name="perm-content-type-edit" select="concat('bungeni.',$bungeni-content-type,'.View')" />
    <xsl:variable name="perm-event-type-view">
        <xsl:if test="head/node()">
            <xsl:value-of select="concat('bungeni.',head/field[@name='type'],'.View')"/>
        </xsl:if>
    </xsl:variable>          
    -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    
    <!--
    <xsl:template match="field[@name='title']">
        <title type="xs:string">
            <xsl:value-of select="." />
        </title>
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
    -->
    <xsl:template match="field[@name='name']">
        <name type="xs:string">
            <xsl:value-of select="." />
        </name>
    </xsl:template>  
    
    <!--
    
    
    <xsl:template match="field[@name='identifier']">
        <identifier type="xs:string">
            <xsl:value-of select="." />
        </identifier>
    </xsl:template>     
    
    <xsl:template match="field[@name='type']">
        <type isA="TLCTerm">
            <value type="xs:string">
                <xsl:value-of select="bctypes:get_content_type_element_name(., $type-mappings)" />
            </value>
        </type>
    </xsl:template>    
    
    
    
    
    <xsl:template match="field[@name='saved_file']">
        <savedFile type="xs:string">
            <xsl:value-of select="." />
        </savedFile>
    </xsl:template>  
    
    <xsl:template match="field[@name='att_hash']">
        <fileHash type="xs:string">
            <xsl:value-of select="." />
        </fileHash>
    </xsl:template>
    -->    
    <!--
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
                <xsl:when test="not(empty($perm-event-type-view)) and ends-with($perm-name,'.View')">
                    <control name="View" setting="{$perm-setting}" role="{$perm-role}" />  
                </xsl:when>                
                <xsl:otherwise />
            </xsl:choose>
    </xsl:template>
    
    <xsl:template match="item_signatories">
        <xsl:if test="child::*">
        <signatories>
            <xsl:apply-templates />
        </signatories>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="item_signatorie">
        <signatory isA="TLCReference">
            <xsl:apply-templates />
        </signatory>
    </xsl:template>     
    
    
    
    <xsl:template match="field[@name='doc_id']">
        <docId type="xs:integer" key="true">
            <xsl:value-of select="." />
        </docId>
    </xsl:template> 
    
    <xsl:template match="field[@name='signatory_id']">
        <signatoryId type="xs:integer" key="true">
            <xsl:value-of select="." />
        </signatoryId>
    </xsl:template>     
    
    <xsl:template match="field[@name='acronym']">
        <acronym isA="TLCTerm">
            <value type="xs:string"><xsl:value-of select="." /></value>
        </acronym>
    </xsl:template>    
    
    
    
    <xsl:template match="sittingreport">
        <sittingReports id="sittingReports">
            <xsl:apply-templates />
        </sittingReports>
    </xsl:template>
    
    <xsl:template match="sittingreport[parent::sittingreport]">
        <sittingReport>
            <xsl:apply-templates />
        </sittingReport>
    </xsl:template>   
    
    <xsl:template match="field[@name='sitting_id']">
        <sittingId type="xs:integer">
            <xsl:value-of select="." />
        </sittingId>
    </xsl:template>   
    
    <xsl:template match="field[@name='report_id']">
        <reportId type="xs:integer">
            <xsl:value-of select="." />
        </reportId>
    </xsl:template>    
    
    
    
    <xsl:template match="versions">
        <versions>
            <xsl:apply-templates />
        </versions>
    </xsl:template>
  
    <xsl:template match="versions[parent::document]">
        <versions id="documentVersions">
            <xsl:apply-templates />
        </versions>
    </xsl:template>
    
    
    <xsl:template match="version">
        <version isA="TLCObject">
            <xsl:apply-templates />
        </version>
        
    </xsl:template>
    -->

    
    <!--
    <xsl:template match="field[@name='head_id']">
        <headId type="xs:integer">
            <xsl:value-of select="." />
        </headId>
    </xsl:template>    
    -->
    
    <!--
    <xsl:template match="field[@name='audit_user_id']">
        <auditUserId>
            <xsl:value-of select="." />
        </auditUserId>
    </xsl:template>  
    -->
    <!--
    <xsl:template match="field[@name='description']">
        <description>
            <xsl:value-of select="." />
        </description>
    </xsl:template>     
    -->
    

    <!--
    <xsl:template match="head">
        <xsl:choose>
            <xsl:when test=".[parent::document[docType/value eq 'Attachment']]">
                <attachmentOf isA="TLCObject">
                    <refersTo href="!+FIX_THIS_PUT_SOURCE_URI_HERE" />
                    <xsl:apply-templates />
                </attachmentOf>                    
            </xsl:when>
            <xsl:otherwise>
                <eventOf isA="TLCObject">
                    <refersTo href="!+FIX_THIS_PUT_SOURCE_URI_HERE" />
                    <xsl:apply-templates />
                </eventOf>                   
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> 
    
    -->
    
    <!--
    <xsl:template match="field[@name='publication_date']">
        <publicationDate type="xs:date"><xsl:value-of select="." /></publicationDate>
    </xsl:template>
    
    -->
   
   <!--
    <xsl:template match="field[
        @name='content_id' or
        @name='ministry_id' or
        @name='version_id' 
        ]">
       
        
    </xsl:template> -->
    
    
</xsl:stylesheet>