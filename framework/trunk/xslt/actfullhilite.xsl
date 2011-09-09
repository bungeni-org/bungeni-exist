<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  xmlns:an="http://www.akomantoso.org/1.0" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:exist="http://exist.sourceforge.net/NS/exist" exclude-result-prefixes="xs an exist" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 5, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> ashok</xd:p>
            <xd:p>Present the complete Act </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xhtml" />
    <!-- global variable input parameter -->
    <xsl:param name="pref"  select="'ts'" />
    <xsl:param name="searchfor" select="'Civil Procedure'" />
    
    <xsl:template match="akomaNtoso">

        <div class="act">
            <div class="key-results">
                <xsl:variable name="key-count" select="count(//exist:match)" />
                <span class="key-results-label">Found <xsl:value-of select="$key-count" /> instances of </span> <span class="hilite-keyword"> <xsl:value-of select="$searchfor" /> <xsl:text>:</xsl:text> </span>
                <xsl:for-each select="//exist:match">
                    <xsl:variable name="ctr" select="position()" />
                    <a href="#{generate-id(.)}"><xsl:value-of select="$ctr" /></a>
                    <xsl:choose>
                        <xsl:when test="$ctr eq $key-count"></xsl:when>
                        <xsl:otherwise><xsl:text>,</xsl:text></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </div>
            <xsl:call-template name="preface" />
            <xsl:apply-templates select="//preamble" />
            <xsl:apply-templates select="//body" />
        </div>
    </xsl:template>
    
    
    <xsl:template match="docTitle[@id='ActTitle']">
            <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="docTitle[@id='ActLongTitle']">
        <xsl:apply-templates />
    </xsl:template>


    <xsl:template name="preface">
        <div id="{$pref}-preface" class="preface">
            <div class="act-number">
                <span class="label">Act No: </span>
                <xsl:value-of select="//docNumber[@id='ActNumber']" />  
            </div>
            <div class="act-title">
                <span class="label">Act Title: </span>
                <xsl:apply-templates select="//docTitle[@id='ActTitle']" />  
            </div>
            <div class="act-long-title">
                
                <xsl:apply-templates select="//docTitle[@id='ActLongTitle']" />  
            </div>
            <div class="act-commencement">
                <span class="label">Enacted Date:</span>
                <xsl:value-of select="//docDate[@refersTo='#CommencementDate']" />  
            </div>
            <xsl:variable name="this-act"><xsl:value-of select="//docNumber[@id='ActIdentifier']" /></xsl:variable>
        </div>
        
    </xsl:template>
    
    <!-- Use wendel/piesz algorithm to convert TOC into a hierarchial list -->
    
    <xsl:key name="k_section" match="tocItem[@level='2']" use="generate-id((preceding-sibling::tocItem[@level='0']|
                                                                            preceding-sibling::tocItem[@level='1'])[last()])" />
    <xsl:key name="k_sectionheading" match="tocItem[@level='1']"
        use="generate-id(preceding-sibling::tocItem[@level='0'][1])"/>
    
    
    <xsl:template match="preamble">
        <div id="{$pref}-preamble" class="preamble">
            <xsl:apply-templates select="toc" />
        </div>
    </xsl:template>
    
    <xsl:template match="toc">
        <!-- check if the document has only a section structure i.e. only level = 2 -->
        <span class="toc">Arrangement of Sections</span>
        <xsl:choose>
            <xsl:when test="(count(//tocItem[@level='0']) eq 0 ) and (count(//tocItem[@level='1']) eq  0)">
                <ul>
                <xsl:apply-templates select="tocItem[@level='2']" mode="k_section"></xsl:apply-templates>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/>
                    <xsl:apply-templates select="tocItem[@level='0']" mode="k_part"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tocItem" mode="k_part">
        <li><a href="#{$pref}-{substring(@href,2)}"><xsl:value-of select="."></xsl:value-of></a>
            <ul>
            <xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/>
            <xsl:apply-templates select="key('k_sectionheading',generate-id())" mode="k_sectionheading"/>
            </ul>    
        </li>
    </xsl:template>
    
    <xsl:template match="tocItem" mode="k_sectionheading">
        <li><a href="#{$pref}-{substring(@href,2)}"><xsl:value-of select="."></xsl:value-of></a>
            <ul>
                <xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/>
            </ul>    
        </li>
    </xsl:template>
    
    <xsl:template match="tocItem" mode="k_section">
        <li><a href="#{$pref}-{substring(@href,2)}" ><xsl:value-of select="."></xsl:value-of></a></li>
    </xsl:template>
    
    <xsl:template match="body">
        <div id="body">
            <xsl:apply-templates />
            
        </div>
        
    </xsl:template>
    
    <xsl:template match="sectionheading">
        <div class="sectionheading" id="{$pref}-{@id}" >
            <xsl:variable name="snref" >
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@id"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="strsnref"><xsl:value-of select="string($snref)"></xsl:value-of></xsl:variable>
            <xsl:apply-templates select="./heading">
                <xsl:with-param name="class-suffix" select="'sectionheading'"></xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="./content" />
            <xsl:apply-templates select="section | chapter" />
        </div>
    </xsl:template>


    <xsl:template match="subpart">
        <div class="subpart" id="{$pref}-{@id}" >
            <xsl:variable name="snref" >
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@id"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="strsnref"><xsl:value-of select="string($snref)"></xsl:value-of></xsl:variable>
            <xsl:apply-templates select="./heading">
                <xsl:with-param name="class-suffix" select="'subpart'"></xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="./content" />
            <xsl:apply-templates select="section | chapter" />
        </div>
    </xsl:template>
    

    <xsl:template match="part">
        <div class="part" id="{$pref}-{@id}" >
            <xsl:variable name="snref" >
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@id"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="strsnref"><xsl:value-of select="string($snref)"></xsl:value-of></xsl:variable>
            <xsl:apply-templates select="./heading">
                <xsl:with-param name="class-suffix" select="'part'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="./content" />
            <xsl:apply-templates select="section | sectionheading | chapter | subpart" />
        </div>
    </xsl:template>
    
    <xsl:template match="chapter">
        <div class="chapter" id="{$pref}-{@id}" >
            <xsl:variable name="snref" >
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@id"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="strsnref"><xsl:value-of select="string($snref)"></xsl:value-of></xsl:variable>
            <xsl:apply-templates select="./heading">
                <xsl:with-param name="class-suffix" select="'chapter'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="./content" />
            <xsl:apply-templates select="section | sectionheading" />
        </div>
    </xsl:template>
    
    
   
    <xsl:template match="section">
        <div class="section" id="{$pref}-{@id}">
            <xsl:variable name="snref" >
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@id"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="strsnref"><xsl:value-of select="string($snref)"></xsl:value-of></xsl:variable>
            <xsl:if test="count(//outOfLine[@href=$strsnref]) gt 0">
                <xsl:if test="count(//outOfLine[@href=$strsnref]/foreign/child::node()) gt 0">
                <div class="sidenote" id="sn-{$pref}-{@id}">
                    <xsl:apply-templates select="//outOfLine[@href=$strsnref]"  mode="generator"/>
                </div>
                </xsl:if>   
            </xsl:if>
            <xsl:apply-templates select="./heading">
                <xsl:with-param name="class-suffix" select="'section'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="./content" />
        </div>
        
    </xsl:template>
    
    
    <xsl:template match="content">
        <div class="content">
            <!-- <xsl:copy-of select="./child::node()" copy-namespaces="no" />  -->
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="foreign">
      <xsl:apply-templates select="child::node()"></xsl:apply-templates>
    </xsl:template>
  
    <xsl:template match="xhtml:*">
        <xsl:copy>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="exist:match">
        <span class="hilite-keyword" id="{generate-id(.)}">
            <xsl:apply-templates />
        </span>
    </xsl:template>

    <xsl:template match="p">
        <p><xsl:apply-templates /></p>
    </xsl:template>
    
    <xsl:template match="i">
        <em><xsl:apply-templates /></em>
    </xsl:template>
    
    <xsl:template match="br">
            <br />
    </xsl:template>
    <xsl:template match="b">
        <strong><xsl:apply-templates /></strong>
    </xsl:template>
    
    <xsl:template match="outOfLine" mode="generator">
            <xsl:apply-templates select="foreign" mode="generator" />
    </xsl:template>
    
    <xsl:template match="foreign" mode="generator">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="heading">
        <xsl:param name="class-suffix" select="'sectionheading'"></xsl:param>
        <div class="heading-{$class-suffix}"><xsl:apply-templates /></div>
    </xsl:template>
    

</xsl:stylesheet>
