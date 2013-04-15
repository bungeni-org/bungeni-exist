<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"
    exclude-result-prefixes="xs bctype"
    version="2.0">
    
    <!-- INCLUDE FUNCTIONS -->
    <xsl:include href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />
    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_tmpls.xsl" />
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 24, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Anthony</xd:p>
            <xd:p>This is a template for generating a membership document </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- these are input parameters to the transformation a-->


    <xsl:include href="resources/pipeline_xslt/bungeni/common/include_params.xsl" />
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- Content Type matcher -->
    <xsl:template match="contenttype">
        <xsl:variable name="group_id" select="field[@name='group_id']" />
        <xsl:variable name="group-type" select="field[@name='type']" />
        <ontology for="membership">
            <!-- this return the embedded membership-title etc .-->
            <xsl:variable name="bungeni-membership-name" select="@name" />
            <!-- we map internal group type names to configured mapped name types -->
            <xsl:variable name="user-type-element-name" select="bctype:get_content_type_element_name('user', $type-mappings)" />
            <xsl:variable name="user-type-uri-name" select="bctype:get_content_type_uri_name('user', $type-mappings)" />
            
            <xsl:variable name="content-type-element-name" select="bctype:get_content_type_element_name($bungeni-membership-name, $type-mappings)" />
            <xsl:variable name="content-type-uri-name" select="bctype:get_content_type_uri_name($bungeni-membership-name, $type-mappings)" />

            <xsl:variable name="group-uri">
                <xsl:variable name="group-type" select="group/field[@name='type']" />
                <xsl:variable name="group-type-uri-name" select="bctype:get_content_type_uri_name($group-type, $type-mappings)" />
                <xsl:variable name="group-identifier" select="group/field[@name='identifier']" />
                <xsl:value-of select="concat('/', $group-type-uri-name, '/', $group-identifier)" />                
            </xsl:variable>
            
            <xsl:variable name="group_principal_id" select="field[@name='group_principal_id']" />
            <xsl:variable name="group_id" select="field[@name='group_id']" />    
            <xsl:variable name="user_id" select="field[@name='user_id']" />
            <xsl:variable name="membership_id" select="field[@name='membership_id']" />
            
            
            <membership id="bungeniMembership" isA="TLCPerson" >

                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="field[@name='language']" />
                </xsl:attribute>                  
                <!-- !+URI_REWORK(ah, 11-04-2012) -->
                
                <xsl:variable name="full-user-identifier"
                    select="translate(concat($country-code, '.',
                    user/field[@name='last_name'], '.', 
                    user/field[@name='first_name'], '.', 
                    user/field[@name='date_of_birth'], '.', 
                    field[@name='user_id']),' ','')" />
                
                <!-- 
                    generates group-membership prefices based on membership_type
                    e.g. committee_member       => CommitteeMember
                         member_of_parliament   => MemberOfParliament
                         minister               => Minister
                -->
                <xsl:variable name="group-member">
                    <xsl:for-each select="tokenize(field[@name='membership_type'],'_')">
                        <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(., 2))"/>
                    </xsl:for-each>                    
                </xsl:variable>
                
                <!-- !+NOTES (ao, 26 Mar 2012)
                    This is temporary - Group membership URI should be built with the group and not 
                    by parliament as enforced now. Proposed URI scheme should have secondary URIs to a resource 
                    embedded to a document. e.g. 
                    MP's URI... 
                    /ke/parliament/2011-02-01/parliament/2/member/20 
                    MP's other URIs to group memberships... 
                    /ke/parliament/2011-02-01/political-group/45/member/20
                    /ke/parliament/2011-02-01/office/16/member/20 
                -->
                <!-- !+URI_REWORK(ah, 11-04-2012 -->
                <!--
                <xsl:attribute name="uri" 
                    select="concat('/ontology/Person/',
                    $country-code, '/', 
                    $group-member,'/', 
                    $for-parliament, '/', 
                    $parliament-election-date, '/',
                    $full-user-identifier)" 
                /> -->

                <!-- /ontology/ke/User/Legislature/x/Chamber/y/Office/a/MemberType/y/user-identifier -->
                <xsl:attribute name="uri">
                    <xsl:value-of select="concat(
                        $uri-base, '/',
                        $user-type-uri-name, 
                        $group-uri, '/',
                        $content-type-uri-name, '/',
                        $membership_id, '/',
                        $full-user-identifier
                        )" />
                </xsl:attribute>
                <!--
                <xsl:attribute name="uri" 
                    select="concat(
                    $parliament-full-uri, 
                    '/',
                    $full-user-identifier)" 
                /> -->
                
                <xsl:attribute name="unique-id">
                    <!-- this attribute uniquely identifies the document in the system -->
                    
                    <xsl:value-of select="concat(
                        $legislature-type-name, '.', $legislature-identifier, 
                        '-', 
                        $parliament-type-name, '.', $parliament-id, 
                        '-',
                        $user-type-uri-name, '.', $user_id,
                        '-',
                        $content-type-uri-name,'.',  $membership_id
                        )" />
                </xsl:attribute>
                
                
                
                <xsl:call-template name="incl_origin">
                    <xsl:with-param name="parl-id" select="$parliament-id" />
                    <xsl:with-param name="parl-identifier" select="$parliament-identifier" />
                </xsl:call-template>
                
                
                <docType isA="TLCTerm">
                    <value type="xs:string"><xsl:value-of select="$content-type-uri-name" /></value>
                </docType>      
                <membershipID isA="key" type="xs:integer"><xsl:value-of select="$membership_id" /></membershipID>
                <!--
                    <xsl:attribute name="uri" 
                    select="concat('/', $country-code, '/',
                    $for-parliament, '/', 
                    $parliament-id, '/',                     
                    'member','/',
                    $item_number)" /> -->
                
                <xsl:copy-of select="field[  
                    @name='status' or 
                    @name='membership_type' or  
                    @name='member_election_type' or 
                    @name='status' or 
                    @name='election_nomination_date' or 
                    @name='start_date' or 
                    @name='end_date' or                     
                    @name='notes' or 
                    @name='party'
                    ]" 
                />     
                <referenceToUser isA="TLCPerson">
                    <refersTo isA="TLCReference"  href="{
                        concat(
                        $uri-base, '/',
                        $user-type-uri-name, '/', 
                        $full-user-identifier
                        )
                        }" />
                    <xsl:copy-of select="user/child::*" /> 
                </referenceToUser>
                
                <xsl:copy-of select="contained_groups" />
                <xsl:copy-of select="representation" />  
                <xsl:copy-of select="changes | member_titles | titletypes"/>
                <xsl:copy-of select="group" />
                <xsl:copy-of select="tags" />
                <!-- PERMISSIONS -->
                <xsl:copy-of select="permissions" />                  
            </membership>

            <xsl:call-template name="incl_legislature">
                <xsl:with-param name="leg-uri" select="$legislature-full-uri" />
                <xsl:with-param name="leg-election-date" select="$legislature-election-date" />
                <xsl:with-param name="leg-identifier" select="$legislature-identifier" />
            </xsl:call-template>
            <xsl:call-template name="incl_chamber">
                <xsl:with-param name="parl-uri" select="$parliament-full-uri" />
                <xsl:with-param name="parl-id" select="$parliament-id" />
                <xsl:with-param name="elect-date" select="$parliament-election-date" />
                <xsl:with-param name="country-code" select="$country-code" />
                <xsl:with-param name="type" select="$parliament-type" />
                <xsl:with-param name="type-display" select="$parliament-type-display" />
            </xsl:call-template>
            <!--
            <chamber isA="TLCConcept" href="{$parliament-full-uri}">
                <electionDate type="xs:date" select="{$parliament-election-date}"></electionDate>                 
                <xsl:copy-of select="group/field[  
                    @name='short_name' or
                    @name='full_name' or 
                    @name='type' or 
                    @name='group_id' or  
                    @name='election_date' or 
                    @name='start_date' or 
                    @name='end_date' or 
                    @name='dissolution_date' or 
                    @name='results_date' or 
                    @name='proportional_presentation' or 
                    @name='status_date' ] " 
                />             
            </chamber> -->             
            <bungeni id="bungeniMeta" showAs="Bungeni Specific info" isA="TLCObject">
                <xsl:attribute name="id" select="$parliament-id"/>
                <xsl:copy-of select="field[@name='timestamp']" />                    
                <xsl:copy-of select="field[@name='group_principal_id' ]" 
                />    
            </bungeni> 
            
            <custom>
                <xsl:copy-of select="$type-mappings" />
                <bungeni_doc_type>
                    <xsl:value-of select="$group-type"/>
                </bungeni_doc_type>
                <uri-base><xsl:value-of select="$uri-base" /></uri-base>
                <legislature-uri><xsl:value-of select="$legislature-uri" /></legislature-uri>
                <parliament-uri><xsl:value-of select="$parliament-uri" /></parliament-uri>
                <legislature-full-uri><xsl:value-of select="$legislature-full-uri" /></legislature-full-uri>
                <parliament-full-uri><xsl:value-of select="$parliament-full-uri" /></parliament-full-uri>
            </custom>
            
            
            <!--    !+FIX_THIS (ao, jan 2012. Some address documents for individuals like clerk dont have 'type' field and 
                this broke the pipeline processor
                
                <xsl:element name="{$group-type}">
                <xsl:attribute name="isA">TLCOrganization</xsl:attribute>
                <xsl:attribute name="refersTo" select="concat('#', $group_id)" />
                </xsl:element>
            -->
        </ontology>
    </xsl:template>
    
</xsl:stylesheet>
