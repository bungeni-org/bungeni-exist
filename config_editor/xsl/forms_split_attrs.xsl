<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Form XML (ui , custom) to a more usable XML format
    -->
    <!--xsl:include href="split_attr_roles.xsl"-->
    <xsl:output indent="yes"/>
    <!-- What does this parameter do ? -->
    <xsl:param name="fname"/>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="modes">
        <mode name="view" />
        <mode name="edit" />
        <mode name="add" />
        <mode name="listing" />
    </xsl:variable>
    <xsl:variable name="global-roles" select="data(//ui/@roles)"></xsl:variable>
    
    <xsl:template match="ui">
        <xsl:copy>
            <!-- Option to pass-in the form-id as a parameter from XQuery -->
            <xsl:variable name="wfname">
                <xsl:choose>
                    <xsl:when test="not($fname)">
                        <xsl:variable name="filename" select="tokenize(base-uri(),'/')"/>
                        <xsl:variable name="wfname" select="tokenize($filename[last()],'\.')"/>
                        <xsl:value-of select="$wfname[1]"/>
                    </xsl:when>
                    <!-- XQuery transform passed in a param -->
                    <xsl:when test="$fname">
                        <xsl:value-of select="$fname"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="name" select="$wfname"/>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template> 
    

    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@modes | @roles"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="show | hide">
        <xsl:comment>
           <xsl:element name="{local-name(.)}">
               <xsl:copy-of select="@*" />
          </xsl:element>
        </xsl:comment>
        <xsl:apply-templates select="@*" />
    </xsl:template>
    
    <xsl:template match="@modes">
        <xsl:variable name="modes-attr" select="." />
        <xsl:for-each select="$modes/mode">
            <!-- 
                generate the <view .../> <edit ... /> mode nodes 
                -->
            <xsl:element name="{@name}">
                <!-- 
                    generate the @show attribute true or false 
                    -->
                <xsl:attribute name="show">
                    <xsl:choose>
                        <xsl:when test="local-name($modes-attr/parent::node()) eq 'show'">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:when test="local-name($modes-attr/parent::node()) eq 'hide'">
                            <xsl:text>false</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>ERROR</xsl:text>
                        </xsl:otherwise>
                   </xsl:choose>
                </xsl:attribute>
                <!-- embed the role within the element -->
                <xsl:variable name="mode-parent" select="$modes-attr/parent::node()" />
                    <xsl:element name="roles">
                        <xsl:choose>
                            <xsl:when test="$mode-parent/@roles">
                                <xsl:for-each select="tokenize($mode-parent/@roles, '\s+')">
                                    <role>
                                        <xsl:value-of select="."/>
                                    </role>
                                </xsl:for-each> 
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="tokenize($global-roles, '\s+')">
                                    <role>
                                        <xsl:value-of select="."/>
                                    </role>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                      
                    </xsl:element>
                </xsl:element>
        </xsl:for-each>
        <!--
        <xsl:element name="modes">
            <xsl:attribute name="originAttr">modes</xsl:attribute>
            <xsl:for-each select="tokenize(., '\s+')">
                <mode>
                    <xsl:value-of select="."/>
                </mode>
            </xsl:for-each>
        </xsl:element>
        </xsl:template> -->
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>