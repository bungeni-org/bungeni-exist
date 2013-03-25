<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
        Update: currently updated to bungeni_custom r10268
    -->
    <xsl:include href="merge_tags.xsl"/>
    <xsl:include href="copy_attrs.xsl" />
    <xsl:output indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <workflow>
            <xsl:call-template name="copy-attrs" />
            <!-- 
                !+NOTE (ao, 7th Jan 2013) Without the below <xsl:if/> the wf_merge_attrs 
                failed on documents like group_assignment that didn't have  <tags/> in the
                root node.
            -->
            <xsl:if test="./tags">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./tags"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./permActions"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </workflow>
    </xsl:template>
    <xsl:template match="state">
        <state>
            <xsl:call-template name="copy-attrs" />
            <xsl:if test="./tags">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./tags"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </state>
    </xsl:template>
    <xsl:template match="allow | deny">
        <xsl:element name="{name()}">
            <xsl:call-template name="copy-attrs" />
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="transition">
        <xsl:element name="transition">
            <xsl:call-template name="copy-attrs" />
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./sources"/>
            </xsl:call-template>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./destinations"/>
            </xsl:call-template>
            <xsl:if test="./roles">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./roles"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="permActions[@originAttr] | roles[@originAttr]  | sources[@originAttr] | destinations[@originAttr] | tags[@originAttr]"/>
</xsl:stylesheet>