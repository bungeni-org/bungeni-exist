<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_dates.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_users.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_identity.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_common.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_user_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_addr_tmpls.xsl"/>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 24, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="permissions">
        <permissions id="addressPermissions">
            <xsl:apply-templates />
        </permissions>
    </xsl:template>
    
</xsl:stylesheet>