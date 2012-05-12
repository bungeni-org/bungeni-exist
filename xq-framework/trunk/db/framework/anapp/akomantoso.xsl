<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/2.0" exclude-result-prefixes="an" version="2.0">
    <xsl:output indent="yes" method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="docIdentifier" select="an:akomaNtoso/child::*/an:meta/an:identification/an:FRBRWork/an:FRBRuri/@value"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="an:akomaNtoso/child::*/an:preface//an:docTitle"/>
                </h1>
            </div>   
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="an-bill"/>
                <xsl:with-param name="uri" select="docIdentifier"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section" class="akn-doc">
                    <xsl:apply-templates/>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="an:*">
        <xsl:apply-templates/>
        <xsl:apply-templates select="div"/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="*[@class='sup']">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="an:akomaNtoso">
        <div>
            <xsl:attribute name="class">main_container akomantoso</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:act">
        <div>
            <xsl:attribute name="class">act_container act</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:bill">
        <div>
            <xsl:attribute name="class">bill_container bill</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:doc">
        <div>
            <xsl:attribute name="class">doc_container doc</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:report">
        <div>
            <xsl:attribute name="class">report_container report</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:debateRecord">
        <div>
            <xsl:attribute name="class">debaterecord_container debaterecord</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:judgement">
        <div>
            <xsl:attribute name="class">judgment_container judgment</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:preface">
        <div>
            <xsl:attribute name="class">preface_container preface</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:preamble">
        <div>
            <xsl:attribute name="class">preamble_container preamble</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:conclusions">
        <div>
            <xsl:attribute name="class">conclusion_container conclusions</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:header">
        <div>
            <xsl:attribute name="class">header_container header</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:attachments">
        <xsl:variable name="xpval">
            <xsl:for-each select="ancestor-or-self::node()">
                <xsl:value-of select="concat(name(),count(preceding::*))"/>/</xsl:for-each>
        </xsl:variable>
        <div class="attachments">
            ATTACHMENTS: <ul>
                <xsl:attribute name="class">attachments_container attachments</xsl:attribute>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="an:attachment">
        <xsl:variable name="xpvalo">
            <xsl:for-each select="ancestor-or-self::node()">
                <xsl:value-of select="concat(name(),count(preceding::*))"/>/</xsl:for-each>
        </xsl:variable>
        <li>
            <a>
                <xsl:attribute name="class">attachment attachment</xsl:attribute>
                <xsl:attribute name="target">_blank</xsl:attribute>
                <xsl:if test="@href">
                    <xsl:attribute name="href">
                        <xsl:value-of select="@href"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="@showAs"/>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="an:body">
        <xsl:if test="count(//an:sidenote) = 0">
            <div class="bodyWithoutSidenotes">
                <xsl:apply-templates/>
            </div>
        </xsl:if>
        <xsl:if test="count(//an:sidenote) &gt; 0">
            <div class="bodyWithSidenotes">
                <xsl:apply-templates/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="an:debate">
        <div>
            <xsl:attribute name="class">debate_container debate</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:mainContent">
        <div>
            <xsl:attribute name="class">maincontent_container maincontent</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:judgementBody">
        <div>
            <xsl:attribute name="class">judgmentBody_container judgmentBody</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:section">
        <div>
            <xsl:attribute name="class">hierarchy section</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:part">
        <div>
            <xsl:attribute name="class">hierarchy part</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:paragraph">
        <!-- !+NOTES (ao, 12-Apr-2012) check to see in the paragraph nodes come ins a set
             so as to wrap them in a list structure o'wise simply wrap with div element -->
        <xsl:variable name="prev-similar" select="name(preceding-sibling::*[1]) eq name(.)"/>
        <xsl:variable name="next-similar" select="name(following-sibling::*[1]) eq name(.)"/>
        <xsl:choose>
            <xsl:when test="$prev-similar or $next-similar">
                <ol class="numera-para">
                    <!--find the members of the list, assuming one item per member-->
                    <xsl:for-each select="node()">
                        <xsl:if test="node()">
                            <li>
                                <xsl:attribute name="class">hierarchy paragraph</xsl:attribute>
                                <xsl:if test="@id">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@id"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:apply-templates select="."/>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:attribute name="class">heirarchy_content</xsl:attribute>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="an:chapter">
        <div>
            <xsl:attribute name="class">hierarchy chapter</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:title">
        <div>
            <xsl:attribute name="class">hierarchy title</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:book">
        <div>
            <xsl:attribute name="class">hierarchy book</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:tome">
        <div>
            <xsl:attribute name="class">hierarchy tome</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:article">
        <div>
            <xsl:attribute name="class">hierarchy article</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:clause">
        <div>
            <xsl:attribute name="class">hierarchy clause</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subsection">
        <div>
            <xsl:attribute name="class">hierarchy subsection</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subpart">
        <div>
            <xsl:attribute name="class">hierarchy subpart</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subparagraph">
        <div>
            <ul class="unordereds">
                <!--find the members of the list, assuming one item per member-->
                <xsl:for-each select="node()">
                    <xsl:if test="node()">
                        <li>
                            <xsl:attribute name="class">hierarchy subparagraph</xsl:attribute>
                            <xsl:if test="@id">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@id"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:apply-templates select="."/>
                        </li>
                    </xsl:if>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="an:subchapter">
        <div>
            <xsl:attribute name="class">hierarchy subchapter</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subtitle">
        <div>
            <xsl:attribute name="class">hierarchy subtitle</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subclause">
        <div>
            <xsl:attribute name="class">hierarchy subclause</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:content">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:entity">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:listIntroduction">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:blockList">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:affectedDocument">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:amendmentBody">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:amendmentHeading">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:amendmentContent">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:amendmentJustification">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:amendmentReference">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:point">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:interstitial">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:collectionContent">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:documentCollection">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!--xsl:template match="an:paragraph">
        <div>

            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template-->
    <xsl:template match="an:caption">
        <div>
            <xsl:attribute name="class">heirarchy_content</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:num">
        <span>
            <xsl:attribute name="class">hierarchy_num num</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:heading">
        <span>
            <xsl:attribute name="class">hierarchy_heading heading <xsl:value-of select="@class"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:subheading">
        <span>
            <xsl:attribute name="class">hierarchy_subheading subheading</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:sidenote">
        <span>
            <xsl:attribute name="class">hierarchy_sidenote sidenote</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:from">
        <span>
            <xsl:attribute name="class">speec_from from</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:administrationOfOath">
        <div>
            <xsl:attribute name="class">speech_hierarchy AdministrationOfOath</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:declarationOfVote">
        <div>
            <xsl:attribute name="class">speech_hierarchy DeclarationOfVote</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:communication">
        <div>
            <xsl:attribute name="class">speech_hierarchy Communication</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:petitions">
        <div>
            <xsl:attribute name="class">speech_hierarchy Petitions</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:papers">
        <div>
            <xsl:attribute name="class">speech_hierarchy Papers</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:noticesOfMotion">
        <div>
            <xsl:attribute name="class">speech_hierarchy NoticesOfMotion</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:questions">
        <div>
            <xsl:attribute name="class">speech_hierarchy Questions</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:address">
        <div>
            <xsl:attribute name="class">speech_hierarchy Address</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:proceduralMotions">
        <div>
            <xsl:attribute name="class">speech_hierarchy ProceduralMotions</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:pointOfOrder">
        <div>
            <xsl:attribute name="class">speech_hierarchy PointOfOrder</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:subdivision">
        <div>
            <xsl:attribute name="class">speech_hierarchy subdivision</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:speech">
        <div>
            <xsl:attribute name="class">speech speech</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:question">
        <div>
            <xsl:attribute name="class">speech question</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:answer">
        <div>
            <xsl:attribute name="class">speech answer</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:other">
        <div>
            <xsl:attribute name="class">speech other</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:scene">
        <div>
            <xsl:attribute name="class">speech comment</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:list">
        <ol>
            <xsl:attribute name="class">hierarchy list</xsl:attribute>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="an:introduction">
        <div>
            <xsl:attribute name="class">judgment_part introduction</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:background">
        <div>
            <xsl:attribute name="class">judgment_part background</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:motivation">
        <div>
            <xsl:attribute name="class">judgment_part motivation</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:decision">
        <div>
            <xsl:attribute name="class">judgment_part decision</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:tblock">
        <div>
            <xsl:attribute name="class">generic_block tblock</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:item">
        <xsl:choose>
            <xsl:when test="contains(an:num/text(), '1.')">
                <ol class="numeration">

                    <!--find the members of the list, assuming one item per member-->
                    <xsl:for-each select="node()">
                        <xsl:if test="node()">
                            <li>
                                <xsl:attribute name="class">hierarchy item</xsl:attribute>
                                <xsl:if test="@id">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@id"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:apply-templates select="."/>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <ul class="unordereds">

                    <!--find the members of the list, assuming one item per member-->
                    <xsl:for-each select="node()">
                        <xsl:if test="node()">
                            <li>
                                <xsl:attribute name="class">hierarchy item</xsl:attribute>
                                <xsl:if test="@id">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@id"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:apply-templates select="."/>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        <!--start the list-->
        <!--ul class="unordereds">
			<xsl:for-each select="node()">
				<xsl:if test="node()">
					<li>
						<xsl:apply-templates select="."/>
					</li>					
				</xsl:if>
			</xsl:for-each>
		</ul-->
    </xsl:template>
    <xsl:template match="an:toc">
        <div>
            <xsl:attribute name="class">toc</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:tocItem">
        <p>
            <xsl:attribute name="class">tocitem</xsl:attribute>
            <xsl:if test="@href">
                <xsl:attribute name="href">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="an:docType">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActType</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:docTitle">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActTitle</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:docNumber">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActNumber</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:docProponent">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActProponent</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:docDate">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActDate</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:docPurpose">
        <xsl:text> </xsl:text>
        <span>
            <xsl:attribute name="class">inline_meta ActPurpose</xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:judgementType">
        <span>
            <xsl:attribute name="class">inline_meta judgmentType</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:judgementTitle">
        <span>
            <xsl:attribute name="class">inline_meta judgmentTitle</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:judgementNumber">
        <span>
            <xsl:attribute name="class">inline_meta judgmentNumber</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:courtType">
        <span>
            <xsl:attribute name="class">inline_meta courtType</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:neutralCitation">
        <span>
            <xsl:attribute name="class">inline_meta neutralCitation</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:party">
        <span>
            <xsl:attribute name="class">inline_meta party</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:judge">
        <span>
            <xsl:attribute name="class">inline_meta judge</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:judgementDate">
        <span>
            <xsl:attribute name="class">inline_meta judgmentDate</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:mref">
        <div>
            <xsl:attribute name="class">reference_container mref</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:ref">
        <xsl:text> </xsl:text>
        <a>
            <xsl:attribute name="class">ref</xsl:attribute>
            <xsl:apply-templates/>
        </a>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="an:rref">
        <div>
            <xsl:attribute name="class">reference_container rref</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:mod">
        <span>
            <xsl:attribute name="class">modification</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:mmod">
        <div>
            <xsl:attribute name="class">modification_container mmod</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:rmod">
        <div>
            <xsl:attribute name="class">modification_container rmod</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:quotedText">
        <span>
            <xsl:attribute name="class">quoted quotedText</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:quotedStructure">
        <div>
            <xsl:attribute name="class">quoted quotedStructure</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:def">
        <span>
            <xsl:attribute name="class">def</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:ins">
        <span>
            <xsl:attribute name="class">ins</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:del">
        <span>
            <xsl:attribute name="class">del</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:omissis">
        <span>
            <xsl:attribute name="class">omissis</xsl:attribute> (...) </span>
    </xsl:template>
    <xsl:template match="an:noteRef">
        <!--<a>
			<xsl:attribute name="xp">
				<xsl:for-each select="ancestor-or-self::node()"><xsl:value-of select="concat(name(),count(preceding::*))" />/</xsl:for-each>
			</xsl:attribute>			
            <xsl:attribute name="class">ref noteref</xsl:attribute>
			<xsl:if test="@href">
				<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
			</xsl:if>

            <xsl:apply-templates/>
        </a>-->
    </xsl:template>
    <xsl:template match="an:recordedTime">
        <span>
            <xsl:attribute name="class">recorderedTime</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:eol">
        <br>
            <xsl:attribute name="class">eol</xsl:attribute>
            <xsl:apply-templates/>
        </br>
    </xsl:template>
    <xsl:template match="an:eop">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:hcontainer">
        <div>
            <xsl:attribute name="class">generic_hierarchy hcontainer</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:container">
        <div>
            <xsl:attribute name="class">generic_container container</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:block">
        <div>
            <xsl:attribute name="class">generic_block block</xsl:attribute>
            <xsl:if test="@name">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:inline">
        <span>
            <xsl:attribute name="class">generic_inline inline </xsl:attribute>
            <xsl:if test="@name">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:marker">
        <span>
            <xsl:attribute name="class">generic_marker marker</xsl:attribute>
            <xsl:if test="@name">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:foreign">
        <div>
            <xsl:attribute name="class">foreign_elements foreign</xsl:attribute>
            <xsl:if test="@name">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:div">
        <div>
            <xsl:attribute name="class">html_container div</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="an:p">
        <xsl:variable name="prefaced1" select="name(./parent::*) eq 'coverPage'"/>
        <xsl:variable name="prefaced2" select="name(./parent::*) eq 'preface'"/>
        <xsl:variable name="prefaced3" select="name(./parent::*) eq 'subdivision'"/>
        <xsl:variable name="prefaced4" select="name(./parent::*) eq 'header'"/>
        <xsl:choose>
            <xsl:when test="$prefaced1 or $prefaced2 or $prefaced3 or $prefaced4">
                <!-- centering the headers -->
                <p>
                    <xsl:attribute name="style">
                        <xsl:value-of>text-align:center</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="class">html_paragraph p <xsl:value-of select="@class"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:attribute name="class">html_paragraph p <xsl:value-of select="@class"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="an:li">
        <li>
            <xsl:attribute name="class">html_list_item li</xsl:attribute>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="an:span">
        <span>
            <xsl:attribute name="class">html_inline span <xsl:value-of select="@class"/>
            </xsl:attribute>
            <xsl:if test="@name">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="an:b">
        <b>
            <xsl:attribute name="class">html_bold b</xsl:attribute>
            <xsl:apply-templates/>
        </b>&#160; </xsl:template>
    <xsl:template match="an:i">
        <i>
            <xsl:attribute name="class">html_italic i</xsl:attribute>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="an:a">
        <a>
            <xsl:attribute name="class">html_anchor a</xsl:attribute>
            <xsl:if test="@href">
                <xsl:attribute name="href">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="an:img">
        <img>
            <xsl:attribute name="class">html_img img</xsl:attribute>
            <xsl:if test="@src">
                <xsl:attribute name="src">
                    <xsl:value-of select="concat('../images/',translate(@src,'/','_'))"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </img>
    </xsl:template>
    <xsl:template match="an:ul">
        <ul>
            <xsl:attribute name="class">html_unordered_list ul</xsl:attribute>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="an:ol">
        <ol>
            <xsl:attribute name="class">html_ordered_list ol</xsl:attribute>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="an:table">
        <table>
            <xsl:attribute name="class">html_table table</xsl:attribute>
            <xsl:if test="@border">
                <xsl:attribute name="border">
                    <xsl:value-of select="@border"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cellspacing">
                <xsl:attribute name="cellspacing">
                    <xsl:value-of select="@cellspacing"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cellpadding">
                <xsl:attribute name="cellpadding">
                    <xsl:value-of select="@cellpadding"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="an:tr">
        <tr>
            <xsl:attribute name="class">html_table_row tr</xsl:attribute>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <xsl:template match="an:th">
        <th>
            <xsl:attribute name="class">html_table_heading_column th</xsl:attribute>
            <xsl:if test="@colspan">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@colspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@rowspan">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rowspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </th>
    </xsl:template>
    <xsl:template match="an:td">
        <td>
            <xsl:attribute name="class">html_table_column td</xsl:attribute>
            <xsl:if test="@colspan">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@colspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@rowspan">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rowspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="an:meta">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:identification">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:FRBRWork">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:FRBRExpression">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:FRBRManifestation">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:FRBRItem">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:this">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:uri">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:alias">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:date">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:author">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:components">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:component">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:preservation">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:publication">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:classification">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:keyword">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:lifecycle">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:event">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:workflow">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:action">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:analysis">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:activeModifications">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:passiveModifications">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:textualMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:meaningMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:scopeMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:forceMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:efficacyMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:legalSystemMod">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:source">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:destination">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:force">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:efficacy">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:application">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:duration">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:condition">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:old">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:new">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:domain">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:references">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:original">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:passiveRef">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:activeRef">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:jurisprudence">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:hasAttachment">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:attachmentOf">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCPerson">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCOrganization">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCConcept">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCObject">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCEvent">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCPlace">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCProcess">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCRole">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCTerm">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:TLCReference">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:notes"/>
    <xsl:template match="an:note">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="an:proprietary">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>