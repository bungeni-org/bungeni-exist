<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:bctype="http://www.bungeni.org/xml/contenttypes/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    version="2.0">
    
    <xsl:import href="func_content_types.xsl" />
    <xsl:import href="func_users.xsl" />
    <xsl:import href="func_dates.xsl" />
    
    <xsl:template name="ownerRender">
        <xsl:param name="type-mappings" />
        <xsl:param name="country-code" />
        <xsl:param name="uri-base" />
        <xsl:variable name="user-type-uri-name" select="bctype:get_content_type_uri_name('user', $type-mappings)" />
        <xsl:variable name="first-name" select="data(field[@name='first_name'])" />
        <xsl:variable name="last-name" select="data(field[@name='last_name'])" />
        <xsl:variable name="user-id" select="data(field[@name='user_id'])" />
        <xsl:variable name="yyyy-mm-dd-dob" select="bdates:parse-datepart-only(data(field[@name='date_of_birth']))" />
        <xsl:variable name="user-identifier" select="busers:get_user_identifer(
            $country-code, 
            $last-name, 
            $first-name, 
            $user-id, 
            $yyyy-mm-dd-dob
            )" 
        />
        <xsl:variable name="user-uri" select="busers:get_user_uri(
            concat(
            $uri-base, '/',
            $user-type-uri-name
            ),
            $user-identifier
            )" />
        <owner isA="TLCPerson">
            <person href="{$user-uri}" showAs="{concat($last-name, ', ', $first-name)}" />
            <role type="TLCConcept">
                <value type="xs:string">
                    <xsl:value-of select="bctype:get_content_type_uri_name(
                        'member',
                        $type-mappings
                        )" />
                </value>
            </role>
        </owner>
    </xsl:template>
    
    
</xsl:stylesheet>
