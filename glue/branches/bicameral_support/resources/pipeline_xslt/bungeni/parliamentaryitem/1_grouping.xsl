<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"
                exclude-result-prefixes="xs bctype"
                version="2.0">
    
    <!-- INCLUDE FUNCTIONS -->
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_tmpls.xsl" />
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 17, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- INPUT PARAMETERS TO TRANSFORM-->
    
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_params.xsl" />
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <!-- Content Type matcher -->
    <xsl:template match="contenttype">
  
        <!-- this field identifies the type of the input xml bill, question , motion etc. -->
        <xsl:variable name="bungeni-content-type" select="field[@name='type']" />
        <!-- We map the bungeni internal content type name to a alternative name to prevent tie-in to internal representations -->
        <!-- the type mapping specifies both the name in the URI and the Element name -->
        <xsl:variable name="content-type-element-name" select="bctype:get_content_type_element_name($bungeni-content-type, $type-mappings)" />
        <xsl:variable name="content-type-uri-name" select="bctype:get_content_type_uri_name($bungeni-content-type, $type-mappings)" />
        <xsl:variable name="language" select="field[@name='language']" />
 
 
        <!-- ROOT ELEMENT OF DOCUMENT -->
        <ontology for="document">
            
            <!-- 
            Test for and calculate the item_number for the item
            this is available only after a certain stage of the workflow 
            -->
            <!--
            <xsl:variable name="item_number">
                <xsl:choose>
                 
                    <xsl:when test="field[@name='doc_id']" >
                        <xsl:value-of select="field[@name='doc_id']" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="field[@name='registry_number']" />
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:variable> -->
            <document id="bungeniDocument" isA="TLCConcept">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="field[@name='language']" />
                </xsl:attribute>
                <!--
                <xsl:call-template name="incl_origin">
                    <xsl:with-param name="parl-id" select="$parliament-id" />
                    <xsl:with-param name="parl-identifier" select="$parliament-identifier" />
                </xsl:call-template>
                -->
                <!--
                <xsl:attribute name="uri" 
                    select="concat(
                    '/', $country-code,'/', 
                    $content-type-uri-name,'/', 
                    $item_number,'/', 
                    $language
                    )" /> -->
                <docType isA="TLCTerm">
                    <value type="xs:string"><xsl:value-of select="$content-type-uri-name" /></value>
                </docType>
               
                
                
      
                
                <!-- !+URI_GENERATOR,!+FIX_THIS(ah,nov-2011) this logic needs to be eventually
                    factored out -->
         
                
                <xsl:copy-of select="field[
                    @name='status_date' or 
                    @name='registry_number' or 
                    @name='doc_id'
                    ] | 
                    changes |
                    audits |
                    sa_events | 
                    sittingreport | 
                    versions |
                    owner" />
                
                
                <!-- for <event> and <attachment> -->
                <xsl:copy-of select="head" />    
                
                <xsl:copy-of select="field[
                    @name='status' or 
                    @name='mimetype' or 
                    @name='title' or 
                    @name='long_title' or 
                    @name='body' or 
                    @name='language'  or 
                    @name='owner_id' or 
                    @name='attachment_id' or 
                    @name='type'
                    ]" />
                
                <!-- NUMBER AND IDENTIFIERS -->
                
                <xsl:copy-of select="field[
                    @name='type_number' 
                    ]" />                  
                
                <!-- for <tableddocument> 
                    <xsl:copy-of select="field[
                    @name='tabled_document_id' or 
                    @name='tabled_document_number' 
                    ]" />    
                    
                    
                    <xsl:copy-of select="field[
                    @name='bill_id' or 
                    @name='bill_type_id' or 
                    @name='bill_number'
                    ]" />
                    
                    <xsl:copy-of select="field[
                    @name='motion_id' or 
                    @name='motion_number'
                    ]" />
                -->
                
                <!-- for <motion> & <bill> !+FIX_THIS(ah,17-04-2012)
                    <xsl:copy-of select="field[
                    @name='publication_date' or
                    @name='doc_type' 
                    ]" />  -->
                
                <!-- for <event> -->
                <xsl:copy-of select="field[
                    @name='doc_type' or 
                    @name='acronym' or 
                    @name='long_title'
                    ]" />                
                
                <!-- PERMISSIONS -->
                <xsl:copy-of select="permissions" />
                
                <!-- for <question> !+FIX_THIS(ah,17-04-2012)
                    <xsl:if test="ministry/*">
                    <assignedTo group="ministry">
                    <xsl:copy-of select="ministry" />
                    </assignedTo>
                    </xsl:if>                 
                -->               
                
            </document>
            <xsl:call-template name="incl_parliament">
                <xsl:with-param name="leg-uri" select="$legislature-uri" />
                <xsl:with-param name="leg-election-date" select="$legislature-election-date" />
                <xsl:with-param name="leg-identifier" select="$legislature-identifier" />
            </xsl:call-template>
            <legislature isA="TLCConcept" href="{$for-parliament}">
               <parliamentId key="true" type="xs:integer" select="{$parliament-id}" />
               <electionDate type="xs:date" select="{$parliament-election-date}"></electionDate> 
                <country isA="TLCLocation">
                    <value type="xs:string"><xsl:value-of select="$country-code" /></value>
                </country>
            </legislature>
            <bungeni id="bungeniMeta" showAs="Bungeni Specific info" isA="TLCObject">
                <xsl:copy-of select="tags" />
                <xsl:copy-of select="field[@name='timestamp']" />
                <withPermissions href="#documentPermissions" />
            </bungeni>
                        
            <!-- 
            e.g. <question> or <motion> or <tableddocument> or <bill> are Bungeni "object" concepts and not 
            really documents so we model them as TLCObject items
            -->
            
            <xsl:element name="{$content-type-element-name}" >
                
                <xsl:attribute name="isA"><xsl:text>TLCObject</xsl:text></xsl:attribute>
                
                <document href="#bungeniDocument" />
                
                <xsl:copy-of select="field[
                        @name='doc_type'
                        ] |
                        _vp_response_type " /> <!-- was question_type and response_tyep -->
                
                <!-- This is a reference to a group from the parliamentary item -->         
                <xsl:if test="group">
                   <xsl:for-each select="group">
                       
                       <group isA="TLCReference">
                           
                           <xsl:variable name="group-id" select="field[@name='group_id']" />
                           
                           <xsl:variable name="group-type" select="field[@name='type']" />
                           
                           <xsl:variable name="group-type-element-name" select="translate(bctype:get_content_type_element_name(
                               $group-type, 
                               $type-mappings
                               ),' ','')" />
                           
                           <xsl:variable name="group-type-uri-name" select="translate(bctype:get_content_type_uri_name(
                               $group-type, 
                               $type-mappings
                               ),' ','')" />
                           
                           <xsl:variable name="full-group-identifier" select="translate(bctype:generate-group-identifier(
                               $group-type-uri-name, 
                               $for-parliament, 
                               $parliament-election-date, 
                               $parliament-id, 
                               $group-id
                               ),' ','')" />
                           
                           <xsl:attribute name="href" select="translate(bctype:generate-group-uri(
                               $group-type-uri-name, 
                               $full-group-identifier
                               ),' ','')" />
                           
                           <xsl:copy-of select="field[@name='group_id' or 
                               @name='short_name' or
                               @name='full_name' or 
                               @name='acronym' or 
                               @name='status_date' or 
                               @name='identifier' or 
                               @name='type' or  
                               @name='start_date' ]"/>                           
                       </group>
                       
                   </xsl:for-each>
                </xsl:if>
                
                <!-- for <bill> and <tableddocument> and <user> -->
                <!-- DEPRECATE
                <xsl:if test="item_assignments/* or item_assignments/text()">
                    <xsl:copy-of select="item_assignments" />
                </xsl:if>
                -->
                
                
                <!-- for <user> -->
                <!--
                <xsl:copy-of select="field[
                                            @name='first_name' or 
                                            @name='last_name' or 
                                            @name='user_id' or 
                                            @name='description' or 
                                            @name='gender' or 
                                            @name='active_p' or 
                                            @name='date_of_birth' or 
                                            @name='titles' or 
                                            @name='birth_country' or 
                                            @name='national_id' or 
                                            @name='login' or 
                                            @name='password' or 
                                            @name='salt' or 
                                            @name='email' or 
                                            @name='birth_nationality' or 
                                            @name='current_nationality' 
                                            ] |
                                       subscriptions | 
                                       user_addresses " />     -->
                
            </xsl:element>

            
            <!-- End of Legislative Item -->
            
            <xsl:copy-of select="attachments" />
           
            <xsl:copy-of select="item_signatories" />        
            
            <custom>
                <xsl:copy-of select="$type-mappings" />
                <bungeni_doc_type>
                    <xsl:value-of select="$bungeni-content-type"/>
                </bungeni_doc_type>
            </custom>
            
           </ontology>
    </xsl:template>

</xsl:stylesheet>