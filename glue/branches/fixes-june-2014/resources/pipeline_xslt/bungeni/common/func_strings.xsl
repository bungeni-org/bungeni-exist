<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:bstrings="http://www.bungeni.org/xml/strings/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 13, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Ashok</xd:p>
            <xd:p>This is the XSLT function to process content type mappings</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    
    <xsl:function name="bstrings:uscorename-to-camel-case" as="xs:string" 
         >
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            string-join((tokenize($arg,'_')[1],
            for $word in tokenize($arg,'_')[position() > 1]
            return bstrings:capitalize-first($word))
            ,'')
            "/>
        
    </xsl:function>
    
    <xsl:function name="bstrings:capitalize-first" as="xs:string?" 
        >
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            concat(upper-case(substring($arg,1,1)),
            substring($arg,2))
            "/>
        
    </xsl:function>
    
</xsl:stylesheet>
