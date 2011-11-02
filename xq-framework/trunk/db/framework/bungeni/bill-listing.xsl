<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 5, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>Lists bills from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- load configuration info -->
    <xsl:include href="config.xsl"/>
    <xsl:template match="docs">
        <div id="main-doc" class="rounded-eigh tab_container" role="main">
            <!-- container for holding listings -->
            <div id="doc-listing" class="acts">
                <!-- render the paginator -->
                <div class="list-header">
                    <div class="toggler-list" id="expand-all">+ expand all</div>
                    <xsl:apply-templates select="paginator"/>
                </div>
                <!-- render the actual listing-->
                <xsl:apply-templates select="alisting"/>
            </div>
        </div>
    </xsl:template>
    
    <!-- Include the paginator generator -->
    <xsl:include href="paginator.xsl"/>
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row" style="clear:both">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="document" mode="renderui">
        <xsl:variable name="billIdentifier" select="output/bu:ontology/bu:bill/@uri"/>
        <li>
            <a href="bill?doc={$billIdentifier}" id="{$billIdentifier}">
                <xsl:value-of select="output/bu:ontology/bu:bill/bu:shortName"/>
            </a>
            <span>+</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <tr>
                        <td class="labels">id:</td>
                        <td>
                            <xsl:value-of select="$billIdentifier"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">moved by:</td>
                        <td>
                            <xsl:value-of select="concat(output/bu:ontology/bu:bill/bu:owner/bu:field[@name='first_name'],' ', output/bu:ontology/bu:bill/bu:owner/bu:field[@name='last_name'])"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status:</td>
                        <td>
                            <xsl:value-of select="output/bu:ontology/bu:bill/bu:status"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status date:</td>
                        <td>
                            <xsl:value-of select="format-dateTime(output/bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">submission date:</td>
                        <td>
                            <xsl:value-of select="format-date(output/bu:ontology/bu:bungeni/bu:parliament/@date,$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">ministry:</td>
                        <td>
                            <xsl:value-of select="output/bu:ontology/bu:ministry/bu:shortName"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>