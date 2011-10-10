<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 6, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill item from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:template match="akomaNtoso">
        <div id="main-wrapper" role="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select=".//docTitle[@id='ActTitle']"/>
                </h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <li>
                        <a href="#tab1">text</a>
                    </li>
                    <li>
                        <a href="#tab2">timelime</a>
                    </li>
                    <li>
                        <a href="#tab3">related</a>
                    </li>
                    <li>
                        <a href="#tab4">attached file</a>
                    </li>
                </ul>
            </div>
            <div id="main-doc" class="rounded-eigh tab_container" role="main">
                <div id="doc-downloads">
                    <img src="assets/bungeni/images/download.png" height="18"/>
                    <ul class="ls-downloads">
                        <li class="selected">RSS</li>
                        <li>Akoma Ntoso XML</li>
                        <li>ODT</li>
                        <li>PDF</li>
                        <li>RTF</li>
                        <li>PRINT</li>
                    </ul>
                </div>
                <div id="tab1" class="tab_content">
                    <div id="doc-main-section">
                        <h3 id="doc-heading" class="doc-headers">Bungeni Parliament</h3>
                        <img id="doc-img" src="assets/bungeni/images/bungeni-logo.png"/>
                        <h4 id="doc-item-desc" class="doc-headers">
                            <xsl:value-of select=".//docTitle[@id='ActTitle']"/>
                        </h4>
                        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Introduced by: <i>
                                <a href="1">Member P1_01</a>
                            </i>
                        </h4>
                        <h4 id="doc-item-desc2" class="doc-headers-darkgrey">Moved by: (<i>
                                <a href="1">Member P1_01</a>
                            </i>,<i>
                                <a href="1">Member P1_02</a>
                            </i>,<i>
                                <a href="1">Member P1_06</a>
                            </i>,<i>
                                <a href="1">Member P1_03</a>
                            </i>,<i>
                                <a href="1">Member P1_04</a>
                            </i>)</h4>
                        <div class="doc-status">
                            <span>
                                <b>Status:</b>
                            </span>
                            <span>response completed</span>
                            <span>
                                <b>Status Date:</b>
                            </span>
                            <span>
                                <xsl:value-of select="//docDate[@refersTo='#CommencementDate']"/>
                            </span>
                        </div>
                        <div id="doc-content-area">
                            <xsl:value-of select="//docTitle[@refersTo='#TheActLongTitle']"/>
                            <ul>
                                <xsl:for-each select="//section">
                                    <li>
                                        <xsl:value-of select="heading"/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                            <xsl:value-of select="//docTitle[@refersTo='#TheActLongTitle']"/>
                        </div>
                    </div>
                </div>
                <div id="tab2" class="tab_content">
                    <table class="listing timeline">
                        <tr>
                            <th>type</th>
                            <th>description</th>
                            <th>date</th>
                        </tr>
                        <tr>
                            <td>
                                <span>modified</span>
                            </td>
                            <td>
                                <span>Mrs clerk P1_02</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:55:34 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>workflow</span>
                            </td>
                            <td>
                                <span>first reading pending</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:55:34 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>new-version</span>
                            </td>
                            <td>
                                <span>
                                    <a href="http://test.bungeni.org/business/bills/obj-37/versions/obj-8">Version at the first reading</a>
                                </span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:55:26 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>modified</span>
                            </td>
                            <td>
                                <span>Mrs clerk P1_02</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:55:11 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>modified</span>
                            </td>
                            <td>
                                <span>Mrs clerk P1_02</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:54:08 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>workflow</span>
                            </td>
                            <td>
                                <span>bill published in gazette</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:54:08 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>new-version</span>
                            </td>
                            <td>
                                <span>
                                    <a href="http://test.bungeni.org/business/bills/obj-37/versions/obj-7">New version on workflow transition to: gazetted</a>
                                </span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:54:08 AM</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>modified</span>
                            </td>
                            <td>
                                <span>Mrs clerk P1_02</span>
                            </td>
                            <td>
                                <span>Aug 17, 2011 12:53:58 AM</span>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="tab3" class="tab_content">
                    <ul class="ls-row" id="list-toggle-wide" style="font-size:0.9em;">
                        <li>
                            <div style="padding-left:2px;">
                                <b>Bill Id</b> : <xsl:value-of select="//docNumber[@id='ActIdentifier']"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding:-2px;">
                                <b>Parliament</b> : XI</div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Commencement Date</b> : <xsl:value-of select="//docDate[@refersTo='#CommencementDate']"/>
                            </div>
                        </li>
                        <li>
                            <div style="margin-top:-15px;padding-left:2px;">
                                <b>Session Num</b> : <xsl:value-of select="//docNumber[@id='ActNumber']"/>
                            </div>
                        </li>
                        <xsl:for-each select="//section">
                            <li>
                                <div style="width:100%;">
                                    <span class="tgl" style="margin-right:10px">+</span>
                                    <a href="#1">
                                        <xsl:value-of select="heading"/>
                                    </a>
                                </div>
                                <div class="doc-toggle">
                                    <span>
                                        <xsl:value-of select="num"/>
                                    </span>
                                    <div>
                                        <xsl:value-of select="content"/>
                                    </div>
                                </div>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
                <div id="tab4" class="tab_content">
                    <table class="tbl-tgl" style="width:90%;float:none;margin:20px auto 0 auto;text-align:left;">
                        <tr>
                            <td class="fbtd" style="text-align:left;padding-left:10px;">
                                <a style="padding-right: 18px;">office</a>
                                <div style="width:10px;float:right;">&#160;</div>
                            </td>
                            <td class="fbtd" style="text-align:left;padding-left:10px;">
                                <a style="padding-right: 18px;">type</a>
                                <div style="width:10px;float:right;">&#160;</div>
                            </td>
                            <td class="fbtd" style="text-align:left;padding-left:10px;">
                                <a style="padding-right: 18px;">title</a>
                                <div style="width:10px;float:right;">&#160;</div>
                            </td>
                            <td class="fbtd" style="text-align:left;padding-left:10px;">
                                <a style="padding-right: 18px;">from</a>
                                <div style="width:10px;float:right;">&#160;</div>
                            </td>
                            <td class="fbtd" style="text-align:left;padding-left:10px;">
                                <a style="padding-right: 18px;">to</a>
                                <div style="width:10px;float:right;">&#160;</div>
                            </td>
                        </tr>
                        <xsl:for-each select="//outOfLine">
                            <tr class="items">
                                <td class="fbt bclr" width="50%" style="text-align-left;">
                                    <xsl:value-of select="foreign//child::node()"/>
                                </td>
                                <td class="fbt bclr">parliament</td>
                                <td class="fbt bclr">member</td>
                                <td class="fbt bclr">Jan 18, 2001</td>
                                <td class="fbt bclr">Jan 18, 2001</td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>