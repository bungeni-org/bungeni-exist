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
    <xsl:output method="xml" use-character-maps="html-unescape"/>
    <xsl:character-map name="html-unescape">
        
        <xsl:output-character character="&lt;" string="&lt;"/>
        <xsl:output-character character="&gt;" string="&gt;"/>
    </xsl:character-map>
    
    <xsl:template match="docs">
        <div id="main-doc" class="rounded-eigh tab_container" role="main">
            <div id="doc-listing" class="acts">
                <div class="list-header">
                    <div class="toggler-list" id="expand-all">+ expand all</div>
                    <xsl:apply-templates select="paginator"/>
                </div>
                <ul id="list-toggle" class="ls-row" style="clear:both">
                    <xsl:apply-templates select="alisting" mode="akomaNtoso"/>
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="paginator">
        <xsl:variable name="offset">
            <xsl:value-of select="./offset"/>
        </xsl:variable>
        <xsl:variable name="count">
            <xsl:value-of select="./count"/>
        </xsl:variable>
        <xsl:variable name="limit">
            <xsl:value-of select="./limit"/>
        </xsl:variable>
        <div id="paginator" class="paginate" align="right">
            <!--div id="xxx"><xsl:value-of select="$count"></xsl:value-of></div-->
            <xsl:call-template name="generate-paginator">
                <xsl:with-param name="i">1</xsl:with-param>
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="offset" select="$offset"/>
                <xsl:with-param name="limit" select="$limit"/>
            </xsl:call-template>
        </div>
    </xsl:template>
    <xsl:template name="generate-paginator">
        <xsl:param name="i"/>
        <xsl:param name="count"/>
        <xsl:param name="offset"/>
        <xsl:param name="limit"/>
        
        <!--begin_: Line_by_Line_Output -->
        <xsl:if test="$i &lt;= round($count div $limit)">
            <xsl:choose>
                <xsl:when test="((abs($i)-0)*$limit = $offset) or ($offset = $i)">
                    <a class="curr-no">
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$i"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>?offset=</xsl:text>
                            <xsl:value-of select="abs($limit)*abs($i)"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
        <!--begin_: RepeatTheLoopUntilFinished-->
        <xsl:if test="$i &lt; floor($count div $limit)">
            <xsl:call-template name="generate-paginator">
                <xsl:with-param name="i">
                    <xsl:value-of select="$i + 1"/>
                </xsl:with-param>
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="offset" select="$offset"/>
                <xsl:with-param name="limit" select="$limit"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="document" mode="akomaNtoso">
        <xsl:variable name="billIdentifier" select=".//bu:bill/@uri"/>
        <li>
            <a href="bill?doc={$billIdentifier}" id="{$billIdentifier}">
                <xsl:value-of select=".//bu:bill/bu:shortName"/>
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
                            <xsl:value-of select="concat(.//bu:bill/bu:owner/bu:field[@name='first_name'],' ', .//bu:bill/bu:owner/bu:field[@name='last_name'])"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status:</td>
                        <td>
                            <xsl:value-of select=".//bu:bill/bu:status"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status date:</td>
                        <td>
                            <xsl:value-of select=".//bu:legislativeItem/bu:statusDate"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">question type:</td>
                        <td>
                            <xsl:value-of select=".//docTitle[@id='ActLongTitle']"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">submission date:</td>
                        <td>
                            <xsl:value-of select=".//bu:bungeni/bu:parliament/@date"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">ministry:</td>
                        <td>
                            <xsl:value-of select=".//bu:ministry/bu:shortName"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>