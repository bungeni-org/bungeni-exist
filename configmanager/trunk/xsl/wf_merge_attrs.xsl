<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Deserialzes Workflow usable XML format to Bungeni XML format
        Update: currently updated to bungeni_custom r10268
    -->
    <xsl:include href="merge_tags.xsl"/>
    <xsl:include href="copy_attrs.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <!--xsl:strip-space elements="*"-->
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="workflow">
        <workflow>
            <xsl:call-template name="copy-attrs"/>
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
            
            <!-- special handler to render global facet to global permissions using group_by voodoo -->
            <!-- !+NOTE using allow|deny is superfluous because has been entirely removed, if a permission is not 
                declared as allow it is by default deny -->
            <xsl:for-each-group select="facet[starts-with(@name, 'global_')]" group-by="(allow|deny)/@permission">
                <xsl:variable name="current-perm" select="current-grouping-key()" />
                <xsl:element name="allow">
                    <xsl:attribute name="permission" select="$current-perm" />
                    <xsl:variable name="roles">
                        <xsl:for-each select="current-group()">
                            <xsl:for-each select=".//roles/role">
                                <xsl:value-of select="." />
                                <xsl:text> </xsl:text>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:attribute name="roles">
                        <xsl:value-of select="distinct-values(tokenize(normalize-space($roles), '\s+'))" />
                    </xsl:attribute>
                </xsl:element>    
            </xsl:for-each-group>
            
            <xsl:apply-templates/>
        </workflow>
    </xsl:template>
    
    <!-- we dont want the default template matcher to handle the global facet, so add a dummy matcher, 
        this is handled by the for_each in the workflow template -->
    <xsl:template match="facet[starts-with(@name,'global_') and parent::workflow]" />
    
    <xsl:template match="state">
        <state>
            <xsl:call-template name="copy-attrs"/>
            <xsl:if test="./tags">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./tags"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="./actions">
                <xsl:call-template name="merge_tags">
                    <xsl:with-param name="elemOriginAttr" select="./actions"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </state>
    </xsl:template>
    <xsl:template match="allow | deny">
        <xsl:element name="{name()}">
            <xsl:call-template name="copy-attrs"/>
            <xsl:call-template name="merge_tags">
                <xsl:with-param name="elemOriginAttr" select="./roles"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="transition">
        <xsl:element name="transition">
            <xsl:call-template name="copy-attrs"/>
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
    <xsl:template match="permActions[@originAttr] | roles[@originAttr]  | sources[@originAttr] | destinations[@originAttr] | tags[@originAttr] | actions[@originAttr]"/>
    <xsl:template match="@permissions_from_state">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="permissions_from_state" select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>