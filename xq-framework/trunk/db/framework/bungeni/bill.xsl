<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 6, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    
    <xsl:template match="bu:ontology">
        <div id="main-doc" class="rounded-eigh tab_container" role="main">
            <div id="doc-main-section">
                <h3 id="doc-heading" class="doc-headers">
                    <xsl:value-of select=".//bu:bill/bu:shortName" />
                </h3>
                <h4 id="doc-item-desc" class="doc-headers">
                    <xsl:value-of select=".//docTitle[@id='ActTitle']"/>
                </h4>
                <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Introduced by: <i>
                    <xsl:variable name="user_uri" select=".//bu:owner/bu:field[@name='user_id']" />
                    <a href="{$user_uri}">
                        <xsl:value-of select="concat(.//bu:bill/bu:owner/bu:field[@name='first_name'],' ', .//bu:bill/bu:owner/bu:field[@name='last_name'])"/>
                    </a>
                </i>
                </h4>
                <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Moved by: (<i>
                    <a href="1">Member P1_01</a>
                </i>,<i>
                    <a href="1">Member P1_02</a>
                </i>,<i>
                    <a href="1">Member P1_06</a>
                </i>,<i>
                    <a href="1">Member P1_03</a>
                </i>,<i>
                    <a href="1">Member P1_04</a>
                </i>)</h4>
                <div class="doc-status">
                    <span>
                        <b>Status:</b>
                    </span>
                    <span>
                        <xsl:value-of select=".//bu:bill/bu:status" />
                    </span>
                    <span>
                        <b>Status Date:</b>
                    </span>
                    <span>
                        <xsl:value-of select=".//bu:bungeni/bu:parliament/@date"/>
                    </span>
                </div>
                <div id="doc-content-area">
                    <xsl:value-of select="//docTitle[@refersTo='#TheActLongTitle']"/>
                    <ul>
                        <xsl:for-each select="//section">
                            <li>
                                <xsl:value-of select="heading"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                    <div>
                        <xsl:copy-of select=".//bu:bill/bu:body" />
                    </div>
                    <!-- TO_BE_REVIEWED -->    
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>