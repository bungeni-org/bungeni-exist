<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill attachments from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="bu:ontology">
        <xsl:variable name="doc_uri" select=".//bu:bill/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select=".//bu:bill/bu:shortName"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="uri" select="$doc_uri"/>
                <xsl:with-param name="tab">attachments</xsl:with-param>
            </xsl:call-template>
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div style="width:700px;margin: 0 auto;">
                        <table class="listing timeline">
                            <tr>
                                <th>file title</th>
                                <th>type</th>
                                <th>date</th>
                            </tr>
                            <xsl:for-each select=".//bu:attached_files/bu:attached_file">
                                <tr>
                                    <td>
                                        <span>
                                            <xsl:value-of select="./bu:field[@name='file_title']"/>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:value-of select="./bu:field[@name='file_mimetype']"/>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:value-of select="./bu:statusDate"/>
                                        </span>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>