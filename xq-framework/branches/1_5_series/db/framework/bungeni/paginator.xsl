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
        
        <!-- 
            the sort by of page (for search) 
        -->
        <xsl:variable name="sortBy">
            <xsl:value-of select="./sortBy"/>
        </xsl:variable>           
        
        <!-- 
            the type of page (for search) 
        -->
        <xsl:variable name="documentType">
            <xsl:value-of select="./documentType"/>
        </xsl:variable>        
        
        <!-- 
            the search string of page (for search) 
        -->
        <xsl:variable name="searchString">
            <xsl:value-of select="./searchString"/>
        </xsl:variable>         
        
        <!-- 
           the starting point of the pager 
        -->
        <xsl:variable name="offset">
            <xsl:value-of select="./offset"/>
        </xsl:variable>
        <!--
            the total number of records 
            -->
        <xsl:variable name="count">
            <xsl:value-of select="./count"/>
        </xsl:variable>
        <!--
            The number of records per page 
            -->
        <xsl:variable name="limit">
            <xsl:value-of select="./limit"/>
        </xsl:variable>
        
        <!--
            Render the pager 
            -->
        <div id="paginator" class="paginate" align="right">
            
            <!-- DEBUG
            <span><xsl:value-of select="$count"></xsl:value-of>,</span>
            <span><xsl:value-of select="$limit"></xsl:value-of>,</span>
            <span><xsl:value-of select="$offset"></xsl:value-of>,</span>
            <span><xsl:value-of select="($limit+$offset) div $limit"></xsl:value-of>,</span>
            -->
            
            <!-- The current page number -->
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
            <div id="page-state" class="page-state">Page <xsl:value-of select="$pwhere"/> of <xsl:value-of select="$pages"/>
            </div>
            <div id="paginate-pages" class="inline">
                <!-- This serves the purpose of showing 'First' page link -->
                <xsl:choose>
                    <!-- If the current page is page 1 , we dont render anything -->
                    <xsl:when test="$pwhere eq 1">
                        <a title="Beginning" class="disabled">
                            <xsl:text>«</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a title="Beginning">
                            <xsl:attribute name="href">
                                <xsl:text>?type=</xsl:text>
                                <xsl:value-of select="$documentType"/>
                                <xsl:text>&amp;q=</xsl:text>
                                <xsl:value-of select="$searchString"/>
                                <xsl:text>&amp;s=</xsl:text>
                                <xsl:value-of select="$sortBy"/>
                                <xsl:text>&amp;offset=</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&amp;limit=</xsl:text>
                                <xsl:value-of select="$limit"/>
                            </xsl:attribute>
                            <xsl:text>«</xsl:text>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- if is first page then set previous link a disabled, otherwise linked... -->
                <xsl:choose>
                    <!-- If in the first page dont link back -->
                    <xsl:when test="$pwhere eq 1">
                        <a class="disabled">
                            <xsl:text>‹</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a title="Previous Page">
                            <xsl:attribute name="href">
                                <xsl:text>?type=</xsl:text>
                                <xsl:value-of select="$documentType"/>
                                <xsl:text>&amp;q=</xsl:text>
                                <xsl:value-of select="$searchString"/>
                                <xsl:text>&amp;s=</xsl:text>
                                <xsl:value-of select="$sortBy"/>
                                <xsl:text>&amp;offset=</xsl:text>
                                <xsl:value-of select="$offset - $limit"/>
                                <xsl:text>&amp;limit=</xsl:text>
                                <xsl:value-of select="$limit"/>
                            </xsl:attribute>
                            <xsl:text>‹</xsl:text>
                        </a>
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
                <!-- DEBUG
                <span>;;<xsl:value-of select="$group"></xsl:value-of> ,</span>
                <span><xsl:value-of select="$group-left"></xsl:value-of> (group-left),</span>
                <span><xsl:value-of select="$group-right"></xsl:value-of>(group-right) ,</span>
                <span><xsl:value-of select="$pages"></xsl:value-of>(pages) ,</span>
                -->
                <xsl:choose>
                    <xsl:when test="$pages &lt;= $group-left">
                        <xsl:call-template name="generate-paginator">
                            <xsl:with-param name="i" select="$group-right"/>
                            <xsl:with-param name="pages" select="$pages"/>
                            <xsl:with-param name="count" select="$count"/>
                            <xsl:with-param name="offset" select="$offset"/>
                            <xsl:with-param name="limit" select="$limit"/>
                            <xsl:with-param name="documentType" select="$documentType"/>
                            <xsl:with-param name="searchString" select="$searchString"/>
                            <xsl:with-param name="sortBy" select="$sortBy"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="generate-paginator">
                            <xsl:with-param name="i" select="$group-right"/>
                            <xsl:with-param name="pages" select="$group-left"/>
                            <xsl:with-param name="count" select="$count"/>
                            <xsl:with-param name="offset" select="$offset"/>
                            <xsl:with-param name="limit" select="$limit"/>
                            <xsl:with-param name="documentType" select="$documentType"/>
                            <xsl:with-param name="searchString" select="$searchString"/>
                            <xsl:with-param name="sortBy" select="$sortBy"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <!-- 
                Determines whether it's sound to show or not to show 'Next' 
                based on whether we have insufficient pages-count or we are
                on the last page.
            -->
            <xsl:choose>
                <xsl:when test="$pages &lt;= 2 or ($offset+$limit) &gt;= $count">
                    <a title="Next Page" href="#" class="disabled">
                        <xsl:text>›</xsl:text>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a title="Next Page">
                        <xsl:attribute name="href">
                            <xsl:text>?type=</xsl:text>
                            <xsl:value-of select="$documentType"/>
                            <xsl:text>&amp;q=</xsl:text>
                            <xsl:value-of select="$searchString"/>
                            <xsl:text>&amp;s=</xsl:text>
                            <xsl:value-of select="$sortBy"/>
                            <xsl:text>&amp;offset=</xsl:text>
                            <xsl:value-of select="abs($limit)*abs($pwhere)"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        ›</a>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 
                Show the 'Last' page link based on similar conditions as 'Next' above.
            -->
            <xsl:choose>
                <xsl:when test="$pages &lt;= 2 or ($offset+$limit) &gt;= $count">
                    <a title="Last Page" href="#" class="disabled">
                        <xsl:text>»</xsl:text>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a title="Last Page">
                        <xsl:attribute name="href">
                            <xsl:text>?type=</xsl:text>
                            <xsl:value-of select="$documentType"/>
                            <xsl:text>&amp;q=</xsl:text>
                            <xsl:value-of select="$searchString"/>
                            <xsl:text>&amp;s=</xsl:text>
                            <xsl:value-of select="$sortBy"/>
                            <xsl:text>&amp;offset=</xsl:text>
                            <xsl:value-of select="abs($pages*$limit) - $limit"/>
                            <xsl:text>&amp;limit=</xsl:text>
                            <xsl:value-of select="$limit"/>
                        </xsl:attribute>
                        »</a>
                </xsl:otherwise>
            </xsl:choose>            
            <!-- 
                +KNOWN ISSUES
                1. Initially, the next button links to itself, ideally simply link to page 2
                    (FIXED - 17-nov)
                2. Somehow page 5 has disappears into thin air...
                    (FIXED - 17-nov)
                3. Otherwise it works fine, only remaining to add is 'First' and 'Last' page links.
                    (LOOKS FINE ?)
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
        <xsl:param name="documentType"/>
        <xsl:param name="searchString"/>
        <xsl:param name="sortBy"/>
        <!-- DEBUG
        <span>i=<xsl:value-of select="$i" />,</span>
        <span>limi=<xsl:value-of select="$limit" />,</span>
        <span>off=<xsl:value-of select="$offset" />,</span>
        -->
        <!--begin_: Line_by_Line_Output -->
        <xsl:if test="$i &lt;= ($pages)">
            <xsl:choose>
                <xsl:when test="((abs($i)-1)*$limit = $offset) or (($offset+1) = $i)">
                    <a class="curr-no">
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$i"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a title="Page {$i}" accesskey="{$i}">
                        <xsl:attribute name="href">
                            <xsl:text>?type=</xsl:text>
                            <xsl:value-of select="$documentType"/>
                            <xsl:text>&amp;q=</xsl:text>
                            <xsl:value-of select="$searchString"/>
                            <xsl:text>&amp;s=</xsl:text>
                            <xsl:value-of select="$sortBy"/>
                            <xsl:text>&amp;offset=</xsl:text>
                            <xsl:value-of select="abs($limit)*(abs($i)-1)"/>
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
                <xsl:with-param name="documentType" select="$documentType"/>
                <xsl:with-param name="searchString" select="$searchString"/>
                <xsl:with-param name="sortBy" select="$sortBy"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>