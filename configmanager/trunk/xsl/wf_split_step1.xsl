<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Workflow XML to a more usable XML format
        Update: currently updated to bungeni_custom r10268
        10 Apr 2013
        This is now split into 2 chained templates
    -->
    <xsl:include href="split_attr_tags.xsl"/>
    <xsl:include href="split_attr_roles.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:param name="docname"/>
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="allow[parent::facet] | deny[parent::facet]">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- template to match global permission declarations -->
    <xsl:template match="allow[parent::workflow] | deny[parent::workflow]">
        <xsl:variable name="matched-node" select="."/>
        <xsl:variable name="roles-list" select="tokenize(normalize-space(@roles), '\s+')"/>
        <xsl:for-each select="$roles-list">
            <xsl:element name="facet">
                <xsl:variable name="role-name" select="."/>
                <xsl:attribute name="name" select="concat('global_',$role-name)"/>
                <xsl:for-each select="$matched-node">
                    <xsl:element name="{local-name()}">
                        <xsl:apply-templates select="@*" mode="preserve"/>
                        <roles originAttr="roles">
                            <role>
                                <xsl:value-of select="$role-name"/>
                            </role>
                        </roles>
                    </xsl:element>
                    <!--
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="preserve" />
                        <xsl:apply-templates select="@*|node()" />
                    </xsl:copy>
                    -->
                </xsl:for-each>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@tags | @roles | @source | @destination | @permission_actions | @actions"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    <!-- 
        !+NOTE (ao, 13th Dec 2012)
        Adding an empty @permissions_from_state and @order attributes for XForms
        XForms cannot provide a control for a node/attribute that do not provide 
        the node/attribute in the first place. This has to be replicated on entire document.
    -->
    <xsl:template match="state">
        <xsl:copy>
            <xsl:if test="not(@permissions_from_state)">
                <xsl:attribute name="permissions_from_state"/>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:if test="not(@actions)">
                <xsl:element name="actions">
                    <xsl:attribute name="originAttr">actions</xsl:attribute>
                    <xsl:element name="action"/>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="transition">
        <xsl:copy>
            <xsl:if test="not(@order)">
                <xsl:attribute name="order">0</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@require_confirmation)">
                <xsl:attribute name="require_confirmation">false</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@source">
        <xsl:element name="sources">
            <xsl:attribute name="originAttr">source</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <source>
                    <xsl:value-of select="."/>
                </source>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@destination">
        <xsl:element name="destinations">
            <xsl:attribute name="originAttr">destination</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <destination>
                    <xsl:value-of select="."/>
                </destination>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@actions">
        <xsl:element name="actions">
            <xsl:attribute name="originAttr">actions</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <action>
                    <xsl:value-of select="."/>
                </action>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@permission_actions">
        <xsl:element name="permActions">
            <xsl:attribute name="originAttr">permission_actions</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <permAction>
                    <xsl:value-of select="."/>
                </permAction>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>