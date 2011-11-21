<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Anthony</xd:p>
            <xd:p> Members of parliament from Bungeni</xd:p>
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
                    <xsl:apply-templates select="paginator"/>
                    <div id="search-n-sort" class="search-bar">
                        <form method="get" action="" name="search_sort">
                            <label for="search_for">Search text:</label>
                            <input id="search_for" name="q" class="search_for" type="text" value=""/>
                            <label for="search_in">in:</label>
                            <select name="w" id="search_w">
                                <option value="doc" selected="">entire document</option>
                                <option value="name">short name</option>
                                <option value="text">body text</option>
                                <option value="desc">description</option>
                                <option value="changes">changes</option>
                                <option value="versions">versions</option>
                                <option value="owner">owner</option>
                            </select>
                            <label for="search_in">sort by:</label>
                            <select name="s" id="sort_by">
                                <option value="ln" selected="">last name</option>
                                <option value="fn">first_name</option>
                            </select>
                            <input value="search" type="submit"/>
                        </form>
                    </div>
                </div>
                <div id="toggle-wrapper" class="clear toggle-wrapper">
                    <div class="toggler-list" id="expand-all">- compress all</div>
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
            <xsl:apply-templates mode="renderui">
                <xsl:sort select="bu:ontology/bu:user/bu:field[@name='first_name']" order="ascending"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="output" mode="renderui">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:user/@uri"/>
        <li>
            <a href="member?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="concat(bu:ontology/bu:user/bu:field[@name='titles'],'. ',bu:ontology/bu:user/bu:field[@name='first_name'],' ', bu:ontology/bu:user/bu:field[@name='last_name'])"/>
            </a>
            <div style="display:inline-block;">/ Constitutency / Party</div>
            <span>-</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <tr>
                        <td class="labels">id:</td>
                        <td>
                            <xsl:value-of select="$docIdentifier"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">gender:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:user/bu:gender"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">date of birth:</td>
                        <td>
                            <xsl:value-of select="format-date(xs:date(bu:ontology/bu:user/bu:field[@name='date_of_birth']),$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">status:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:user/bu:status"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>