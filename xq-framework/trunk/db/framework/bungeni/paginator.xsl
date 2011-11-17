<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 2, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Ashok Hariharan</xd:p>
            <xd:p>This is the template for the common paginator generator</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- this is the paginator template matcher -->
    <xsl:template match="paginator">
        <!-- The paginator expects a document with the following -->
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
            <!-- How to know the current page -->
            <xsl:variable name="pwhere" select="($limit+$offset) div $limit"/>
            <!-- Calculate the number of pages that need links -->
            <xsl:variable name="raw-page-count" select="floor($count div $limit)"/>
            <!--    
                $raw-page-count should now contain total number(integer) of links unless 
                there is a remainder from division. 
            -->
            <xsl:variable name="pages">
                <xsl:choose>
                    <xsl:when test="$count mod $limit">
                        <!-- $raw-page-count has a remainder so we need to add an extra page -->
                        <xsl:value-of select="$raw-page-count + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$raw-page-count"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- This serves the purpose of showing 'First' page link -->
            <xsl:choose>
                <xsl:when test="$pwhere &lt;= 1"/>
                <xsl:otherwise>
                    <a title="Fist Page">
                        <xsl:attribute name="href">
                            <xsl:text>?offset=</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        «</a>
                </xsl:otherwise>
            </xsl:choose>            
            <!-- if is first page then set previous link a disabled, otherwise linked... -->
            <xsl:choose>
                <xsl:when test="$pwhere &lt;= 1">
                    <a class="curr-no">‹</a>
                </xsl:when>
                <xsl:otherwise>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>?offset=</xsl:text>
                            <xsl:value-of select="$offset - $limit"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        ‹</a>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 
                manually set to show 5 page-links per page 
                group, group-left and group-right an integer, 5, which eventually
                can be factored into a user-configuration to be adjusted at user's discretion.
            -->
            <xsl:variable name="group" select="floor($offset div (5 * $limit))"/>
            <!-- Calculate boundary-point while there are more pages to show on right -->
            <xsl:variable name="group-left" select="($group+1)*5"/>
            <!-- Calculate boundary to now show the available pages on the right -->
            <xsl:variable name="group-right" select="($group*5)+1"/>
            <xsl:choose>
                <xsl:when test="$pages &lt;= $group-left">
                    <xsl:call-template name="generate-paginator">
                        <xsl:with-param name="i" select="$group-right"/>
                        <xsl:with-param name="pages" select="$pages"/>
                        <xsl:with-param name="count" select="$count"/>
                        <xsl:with-param name="offset" select="$offset"/>
                        <xsl:with-param name="limit" select="$limit"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="generate-paginator">
                        <xsl:with-param name="i" select="$group-right"/>
                        <xsl:with-param name="pages" select="$group-left"/>
                        <xsl:with-param name="count" select="$count"/>
                        <xsl:with-param name="offset" select="$offset"/>
                        <xsl:with-param name="limit" select="$limit"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 
                Determines whether it's sound to show or not to show 'Next' 
                based on whether we have insufficient pages-count or we are
                on the last page.
            -->
            <xsl:choose>
                <xsl:when test="$pages &lt;= 2 or ($offset+$limit) &gt;= $count"/>
                <xsl:otherwise>
                    <a title="Next Page">
                        <xsl:attribute name="href">
                            <xsl:text>?offset=</xsl:text>
                            <xsl:value-of select="abs($limit)*abs($pwhere)"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        ›
                    </a>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 
                Show the 'Last' page link based on similar conditions as 'Next' above.
            -->
            <xsl:choose>
                <xsl:when test="$pages &lt;= 2 or ($offset+$limit) &gt;= $count"/>
                <xsl:otherwise>
                    <a title="Last Page">
                        <xsl:attribute name="href">
                            <xsl:text>?offset=</xsl:text>
                            <xsl:value-of select="abs($pages*$limit) - $limit"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        »
                    </a>
                </xsl:otherwise>
            </xsl:choose>            
            <!-- 
                +KNOWN ISSUES
                1. Initially, the next button links to itself, ideally simply link to page 2
                2. Somehow page 5 has disappears into thin air...
                3. Otherwise it works fine, only remaining to add is 'First' and 'Last' page links.
            -->
        </div>
    </xsl:template>
    
    <!-- this is the paginator generator -->
    <xsl:template name="generate-paginator">
        <xsl:param name="i"/>
        <xsl:param name="pages"/>
        <xsl:param name="count"/>
        <xsl:param name="offset"/>
        <xsl:param name="limit"/>
        
        <!--begin_: Line_by_Line_Output -->
        <xsl:if test="$i &lt;= ($pages - 1)">
            <xsl:choose>
                <xsl:when test="(abs($i)*$limit = $offset) or (($offset+1) = $i)">
                    <a class="curr-no">
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$i"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a title="Page {$i}">
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
        <xsl:if test="$i &lt;= $pages">
            <xsl:call-template name="generate-paginator">
                <xsl:with-param name="i">
                    <xsl:value-of select="$i + 1"/>
                </xsl:with-param>
                <xsl:with-param name="pages" select="$pages"/>
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="offset" select="$offset"/>
                <xsl:with-param name="limit" select="$limit"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>