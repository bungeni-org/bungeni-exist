<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.akomantoso.org/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xsl:import href="config.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:template match="bu:ontology">
        <akomaNtoso contains="originalVersion">
            <xsl:apply-templates/>
        </akomaNtoso>
    </xsl:template>
    <xsl:template name="main" match="bu:document[parent::bu:ontology]">
        <xsl:variable name="doc-uri">
            <xsl:choose>
                <xsl:when test="./@uri">
                    <xsl:value-of select="./@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="contenturidate" select="substring-before(bu:statusDate,'T')"/>
        <!-- extract the lasy two characters e.g. 'en' -->
        <xsl:variable name="contentlang" select="substring($doc-uri,string-length($doc-uri) - 1)"/>
        <xsl:variable name="contentcountry" select="substring($doc-uri,2,2)"/>
        <xsl:variable name="personeditor" select="normalize-space(substring-before(data(bu:owner/bu:person/@showAs),','))"/>
        <xsl:element name="{lower-case(bu:docType/bu:value/text())}">
            <meta>
                <identification source="#bungeni">
                    <xsl:call-template name="frbrwork">
                        <xsl:with-param name="doc-uri" select="$doc-uri"/>
                        <xsl:with-param name="contenturidate" select="$contenturidate"/>
                        <xsl:with-param name="contentlang" select="$contentlang"/>
                        <xsl:with-param name="personeditor" select="$personeditor"/>
                        <xsl:with-param name="contentcountry" select="$contentcountry"/>
                    </xsl:call-template>
                    <xsl:call-template name="frbrexpression">
                        <xsl:with-param name="doc-uri" select="$doc-uri"/>
                        <xsl:with-param name="contenturidate" select="$contenturidate"/>
                        <xsl:with-param name="contentlang" select="$contentlang"/>
                        <xsl:with-param name="personeditor" select="$personeditor"/>
                    </xsl:call-template>
                    <xsl:call-template name="frbrmanisfestation">
                        <xsl:with-param name="doc-uri" select="$doc-uri"/>
                        <xsl:with-param name="contenturidate" select="$contenturidate"/>
                        <xsl:with-param name="contentlang" select="$contentlang"/>
                        <xsl:with-param name="personeditor" select="$personeditor"/>
                    </xsl:call-template>
                </identification>
                <publication id="publication" date="{$contenturidate}" showAs="Bungeni Gazette" name="BG" number="{./bu:registryNumber}"/>
                <classification source="#main">
                    <keyword value="{bu:status/bu:value}" showAs="{upper-case(bu:status/bu:value)}" dictionary="/path/path/path/path"/>
                </classification>
                <lifecycle source="#bungeni">
                    <eventRef date="{xs:date($contenturidate)}" id="e1" source="#ro1" type="generation"/>
                </lifecycle>
                <references source="#bungeni">
                    <xsl:call-template name="add-attachments">
                        <xsl:with-param name="for-reference">true</xsl:with-param>
                    </xsl:call-template>
                    <TLCOrganization id="parliament" href="/ontology/organiaktions/akf/parliament" showAs="Parliament"/>
                    <TLCOrganization id="bungeni" href="/ontology/organiaktion/ak/bungeni" showAs="Bungeni"/>
                    <TLCRole id="author" href="{$doc-uri}" showAs="Author of Document"/>
                    <TLCRole id="editor" href="{$doc-uri}" showAs="Editor of Document"/>
                    <TLCPerson id="{substring-before(bu:owner/bu:person/@showAs,',')}" href="{data(bu:owner/bu:person/@href)}" showAs="Editor"/>
                </references>
            </meta>
            <preface>
                <p>
                    <docTitle>
                        <xsl:value-of select="./bu:title"/>
                    </docTitle>
                    <date date="{$contenturidate}" refersTo="#publication">
                        <xsl:value-of select="format-date(xs:date($contenturidate),$date-format,'en',(),())"/>
                    </date>
                    <docProponent>
                        <xsl:value-of select="concat(data(bu:owner/bu:person/@showAs),' - ', bu:owner/bu:role/bu:value)"/>
                    </docProponent>
                </p>
                <p>
                    <docType>
                        <xsl:value-of select="upper-case(bu:type/bu:value)"/>
                    </docType>
                </p>
                <longTitle/>
            </preface>
            <preamble>
                <p/>
                <p/>
            </preamble>
            <body>
                <division id="div1">
                    <content>
                        <p>
                            <xsl:copy-of select="./bu:body/child::node()/child::node()"/>
                        </p>
                    </content>
                </division>
            </body>
        </xsl:element>
    </xsl:template>
    <xsl:template match="bu:legislature"/>
    <xsl:template match="bu:bill"/>
    <xsl:template match="bu:agendaItem"/>
    <xsl:template match="bu:question"/>
    <xsl:template match="bu:motion"/>
    <xsl:template match="bu:tabledDocument"/>
    <xsl:template name="component-info" match="bu:bungeni">
        <!--xsl:value-of select="data(./@showAs)"/-->
    </xsl:template>
    <xsl:template match="bu:signatories"/>
    <xsl:template name="add-attachments" match="bu:attachments">
        <xsl:param name="for-reference"/>
        <xsl:if test=".">
            <xsl:choose>
                <xsl:when test="$for-reference eq 'true'">
                    <xsl:for-each select="bu:attachment">
                        <hasAttachment id="{concat(bu:type/bu:value,bu:headId)}" href="{concat('http://localhost:8088/exist/rest/bungeni-atts/',bu:fileHash)}" showAs="{bu:mimetype/bu:value}"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <attachments>
                        <xsl:for-each select="bu:attachment">
                            <componentRef id="{concat(bu:type/bu:value,bu:headId)}" src="{concat('http://localhost:8088/exist/rest/bungeni-atts/',bu:fileHash)}" showAs="{bu:mimetype/bu:value}"/>
                        </xsl:for-each>
                    </attachments>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="frbrwork">
        <xsl:param name="doc-uri"/>
        <xsl:param name="contenturidate"/>
        <xsl:param name="contentlang"/>
        <xsl:param name="personeditor"/>
        <xsl:param name="contentcountry"/>
        <FRBRWork>
            <FRBRthis value="{$doc-uri}"/>
            <FRBRuri value="{$doc-uri}"/>
            <FRBRdate date="{$contenturidate}" name="Enactment"/>
            <FRBRauthor href="#parliament" as="#author"/>
            <componentInfo>
                <componentData id="emain" href="#mmain" name="main" showAs="Main document"/>
                <componentData id="ememorandum" href="#mmemorandum" name="memorandum" showAs="Bungeni Specific Info"/>
            </componentInfo>
            <FRBRcountry value="{$contentcountry}"/>
        </FRBRWork>
    </xsl:template>
    <xsl:template name="frbrexpression">
        <xsl:param name="doc-uri"/>
        <xsl:param name="contenturidate"/>
        <xsl:param name="contentlang"/>
        <xsl:param name="personeditor"/>
        <FRBRExpression>
            <FRBRthis value="{$doc-uri}"/>
            <FRBRuri value="{$doc-uri}"/>
            <FRBRdate date="{$contenturidate}" name="Expression"/>
            <FRBRauthor href="#{$personeditor}" as="#editor"/>
            <componentInfo>
                <componentData id="emain" href="#mmain" name="main" showAs="Main document"/>
                <componentData id="ememorandum" href="#mmemorandum" name="memorandum" showAs="Bungeni Specific Info"/>
            </componentInfo>
            <FRBRlanguage language="{$contentlang}"/>
        </FRBRExpression>
    </xsl:template>
    <xsl:template name="frbrmanisfestation">
        <xsl:param name="doc-uri"/>
        <xsl:param name="contenturidate"/>
        <xsl:param name="contentlang"/>
        <xsl:param name="personeditor"/>
        <FRBRManifestation>
            <FRBRthis value="{$doc-uri}"/>
            <FRBRuri value="{$doc-uri}"/>
            <FRBRdate date="{$contenturidate}" name="XMLConversion"/>
            <FRBRauthor href="#{$personeditor}" as="#editor"/>
            <componentInfo>
                <componentData id="emain" href="#mmain" name="main" showAs="Main document"/>
                <componentData id="ememorandum" href="#mmemorandum" name="memorandum" showAs="Bungeni Specific Info"/>
            </componentInfo>
        </FRBRManifestation>
    </xsl:template>
</xsl:stylesheet>