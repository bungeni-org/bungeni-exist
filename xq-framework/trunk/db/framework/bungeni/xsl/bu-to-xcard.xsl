<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:ietf:params:xml:ns:vcard-4.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xsl:import href="config.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:param name="server-path"/>
    <xsl:template match="doc">
        <vcards>
            <vcard>
                <n>
                    <surname>
                        <xsl:value-of select="bu:ontology/bu:user/bu:lastName"/>
                    </surname>
                    <given>
                        <xsl:value-of select="bu:ontology/bu:user/bu:firstName"/>
                    </given>
                    <additional/>
                    <prefix>
                        <xsl:value-of select="bu:ontology/bu:user/bu:salutation"/>
                    </prefix>
                    <suffix>
                        <xsl:value-of select="bu:ontology/bu:user/bu:title"/>
                    </suffix>
                </n>
                <fn>
                    <text>
                        <xsl:value-of select="concat(bu:ontology/bu:user/bu:firstName,' ', bu:ontology/bu:user/bu:lastName)"/>
                    </text>
                </fn>
                <org>
                    <text>
                        <xsl:value-of select="membership/bu:ontology/bu:membership/bu:group/bu:shortName"/>
                    </text>
                </org>
                <title>
                    <text>
                        <xsl:value-of select="bu:ontology/bu:user/bu:title"/>
                    </text>
                </title>
                <photo>
                    <xsl:variable name="img_hash" select="bu:ontology/bu:image/bu:imageHash"/>
                    <uri>
                        <xsl:value-of select="concat($server-path,'bungeni-atts/',$img_hash)"/>
                    </uri>
                </photo>
                <xsl:for-each select="ref/bu:ontology/bu:address">
                    <tel>
                        <parameters>
                            <type>
                                <xsl:value-of select="data(bu:logicalAddressType/@showAs)"/>
                            </type>
                            <type>voice</type>
                        </parameters>
                        <uri>tel:<xsl:value-of select="bu:phone"/>
                        </uri>
                    </tel>
                </xsl:for-each>
                <xsl:for-each select="ref/bu:ontology/bu:address">
                    <adr>
                        <parameters>
                            <type>
                                <xsl:value-of select="data(bu:logicalAddressType/@showAs)"/>
                            </type>
                            <label>
                                <xsl:value-of select="concat(bu:street,', ', bu:city, ' ',bu:zipCode,' ',bu:countryId/bu:value)"/>
                            </label>
                        </parameters>
                        <pobox/>
                        <ext/>
                        <street>
                            <xsl:value-of select="bu:street"/>
                        </street>
                        <locality>
                            <xsl:value-of select="bu:street"/>
                        </locality>
                        <region>
                            <xsl:value-of select="bu:city"/>
                        </region>
                        <code>
                            <xsl:value-of select="bu:zipCode"/>
                        </code>
                        <country>
                            <xsl:value-of select="bu:countryId/bu:value"/>
                        </country>
                    </adr>
                </xsl:for-each>
                <email>
                    <text>
                        <xsl:value-of select="ref/bu:ontology/bu:address[1]/bu:email"/>
                    </text>
                </email>
                <rev>
                    <timestamp>
                        <xsl:value-of select="ref/bu:ontology/bu:address[1]/bu:statusDate"/>
                    </timestamp>
                </rev>
            </vcard>
        </vcards>
    </xsl:template>
</xsl:stylesheet>