<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:custom="http://bungeni-exist.googlecode.com/custom_functions"
    exclude-result-prefixes="xsl custom"
    version="2.0">
    <!--
        Ashok Hariharan
        14 Nov 2012
        Serializes Bungeni Form XML (ui , custom) to a more usable XML format
    -->
    <xsl:include href="split_attr_roles.xsl" />
    <xsl:output indent="yes"/>
    
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="preserve"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

   
    <!--
        Specifies all the valid modes
        -->
    <xsl:variable name="modes">
        <mode name="view" />
        <mode name="edit" />
        <mode name="add" />
        <mode name="listing" />
    </xsl:variable>
    
    <!--
        All the valid roles 
        -->
    <xsl:variable name="global-roles" select="data(//ui/@roles)"></xsl:variable>
   
   
    <!-- 
        Specialized functions to merge mode attributes since 
        multiple show elements are allowed in a field
        -->
   
    <xsl:function name="custom:__get_modes">
        <xsl:param name="nodes" />
        <xsl:for-each select="$nodes">
            <xsl:value-of select="@modes"></xsl:value-of>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="custom:get_modes">
        <xsl:param name="nodes"></xsl:param>
        <xsl:value-of select="string-join(custom:__get_modes($nodes), ' ')" />
    </xsl:function>
    
    
   
    <!-- 
        We need to process the attributes while preserving them at the same time
    -->
    <xsl:template mode="preserve" match="@modes | @roles"/>
    <xsl:template mode="preserve" match="@*">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="show | hide" mode="comment">
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:text disable-output-escaping="yes">![CDATA["</xsl:text>  
        <xsl:copy-of select="." ></xsl:copy-of>
        <xsl:text disable-output-escaping="yes">"]]</xsl:text><xsl:text disable-output-escaping="yes">&gt;</xsl:text>  
        <xsl:text>
        </xsl:text>
        
        <!-- <xsl:apply-templates select="@*" /> -->
    </xsl:template>
    


    <xsl:template match="modes">
        <xsl:variable name="declared-modes" select="concat(custom:get_modes(./show), custom:get_modes(./hide))" />
        <xsl:variable name="modes-element" select="." />
        
        <!-- output the current show/hide in a comment -->
        <!-- uncomment the below to test in oxygen the old and new show/hide side by side -->
        <!-- xsl:apply-templates mode="comment" /-->
        
        
        <!-- iterate through all the possible modes -->
        <xsl:for-each select="$modes/mode">
            <!-- 
                generate the <view .../> <edit ... /> mode nodes 
            -->
            <xsl:variable name="current-mode" select="data(@name)" />
            <xsl:choose>
                <!-- check if current mode is in the declared modes -->
                <!-- To generate <view show="true" roles="Clerk MP " /> -->
                <xsl:when test="contains($declared-modes, @name)">
                    <xsl:variable name="matching-show-or-hide" 
                        select="$modes-element/(show|hide)[contains(data(./@modes), $current-mode)]" />
                     <xsl:element name="{@name}" >
                          <xsl:attribute name="show">
                            <xsl:choose>
                                <xsl:when test="local-name($matching-show-or-hide) eq 'show'">
                                    <xsl:text>true</xsl:text>
                                </xsl:when>
                                <xsl:when test="local-name($matching-show-or-hide) eq 'hide'">
                                    <xsl:text>false</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- it should never reach here, unless there was a mistake in the 
                                        configuration -->
                                    <xsl:text>ERROR</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            </xsl:attribute>
                        <xsl:element name="roles">
                            <xsl:choose>
                                <xsl:when test="$matching-show-or-hide/@roles">
                                    <xsl:for-each select="tokenize($matching-show-or-hide/@roles, '\s+')">
                                        <role>
                                            <xsl:value-of select="."/>
                                        </role>
                                    </xsl:for-each> 
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- the below template imports all the global roles locally -->
                                    <!--
                                        <xsl:for-each select="tokenize($global-roles, '\s+')">
                                        <role>
                                        <xsl:value-of select="."/>
                                        </role>
                                        </xsl:for-each>
                                    -->
                                    <role>ALL</role>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <!-- when a mode is not in any of the declared roles , we hide it -->
                    <xsl:element name="{@name}">
                        <xsl:attribute name="show" select="string('false')" />
                        <roles>
                            <role>ALL</role>
                        </roles>
                    </xsl:element>                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="@*"/>
</xsl:stylesheet>