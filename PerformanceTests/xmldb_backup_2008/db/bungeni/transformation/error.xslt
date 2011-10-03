<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:error="http://exist.bungeni.org/query/error" version="2.0">
        <!--
            Copyright  Adam Retter 2008 <adam.retter@googlemail.com>
            
            Akoma Ntoso Error Message Transformation for XML 1.0 to XHTML 1.1
            
            Author: Adam Retter
            Version: 1.0
        --><xsl:output encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" indent="yes" omit-xml-declaration="no" method="xhtml" media-type="text/html"/><xsl:template match="error:error"><div class="error"><h1>An Error Has Occured</h1><xsl:apply-templates/></div></xsl:template><xsl:template match="error:message"><p class="errorMessage"><xsl:value-of select="."/></p><xsl:apply-templates/></xsl:template><xsl:template match="error:params"><div class="errorParams"><h2/><ul><xsl:for-each select="child::element()"><li><xsl:value-of select="local-name(.)"/>: <xsl:value-of select="."/></li></xsl:for-each></ul></div></xsl:template></xsl:stylesheet>