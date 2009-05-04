<!--
    Copyright  Adam Retter 2007 <adam.retter@googlemail.com>
    
    Modifies an Akoma Ntoso Document to
    reflect a new version by updating the URIs
    and references
    
    @author Adam Retter
    @version 1.0
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xml:lang="en"><xsl:param name="versionDate" as="xs:string" required="yes"/><xsl:param name="originalURI" as="xs:string" required="yes"/><xsl:output encoding="UTF-8" indent="yes" media-type="text/xml" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- match the document root --><xsl:template match="/"><xsl:apply-templates mode="copy"/></xsl:template>
    
    <!-- by default copy everything --><xsl:template match="*" mode="copy"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="copy"/></xsl:copy></xsl:template>
    
    <!-- modify Expression and Manifestation URIs with version --><xsl:template match="an:Expression/an:uri | an:Manifestation/an:uri" mode="copy"><xsl:element name="uri" namespace="http://www.akomantoso.org/1.0"><xsl:attribute name="href"><xsl:call-template name="versionURI"><xsl:with-param name="currentURI" select="@href"/></xsl:call-template></xsl:attribute></xsl:element></xsl:template>
    
    <!-- modify Expression and Manifestation Component URIs with version --><xsl:template match="an:Expression/an:components/an:component | an:Manifestation/an:components/an:component" mode="copy"><xsl:variable name="baseComponentURI" as="xs:string"><xsl:call-template name="versionURI"><xsl:with-param name="currentURI" select="substring-before(@href, concat('/', replace(@href, '.*/', '')))"/></xsl:call-template></xsl:variable><xsl:variable name="componentVersionURI" as="xs:string" select="concat($baseComponentURI, '/', replace(@href, '.*/', ''))"/><xsl:element name="component" namespace="http://www.akomantoso.org/1.0"><xsl:copy-of select="@id"/><xsl:attribute name="href" select="$componentVersionURI"/><xsl:copy-of select="@showAs"/></xsl:element></xsl:template>
    
    <!-- modify the reference to the Original --><xsl:template match="an:references/an:Original" mode="copy"><xsl:element name="Original" namespace="http://www.akomantoso.org/1.0"><xsl:copy-of select="@id"/><xsl:attribute name="href" select="$originalURI"/><xsl:copy-of select="@showAs"/></xsl:element></xsl:template>
    
    <!-- 
        Returns a URI with the version date added to it
        Expects either an expression or manifetsation URI
    --><xsl:template name="versionURI" as="xs:string"><xsl:param name="currentURI" as="xs:string"/><xsl:choose><xsl:when test="contains($currentURI, '@')">
                <!-- uri already has a version in it --><xsl:choose><xsl:when test="contains($currentURI, '.')">
                        <!-- manifestation --><xsl:value-of select="concat(substring-before($currentURI, '@'), '@', $versionDate, '.', substring-after($currentURI, '.'))"/></xsl:when><xsl:otherwise>
                        <!-- expression --><xsl:value-of select="concat(substring-before($currentURI, '@'), '@', $versionDate)"/></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise>
                <!-- no version in the uri --><xsl:choose><xsl:when test="contains($currentURI, '.')">
                        <!-- manifestation --><xsl:value-of select="concat(substring-before($currentURI, '.'), '@', $versionDate, '.', substring-after($currentURI, '.'))"/></xsl:when><xsl:otherwise>
                        <!-- expression --><xsl:value-of select="concat($currentURI, '@', $versionDate)"/></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:template></xsl:stylesheet>