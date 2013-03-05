<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="field[@name='combined_name']" />
    <xsl:template match="field[@name='receive_notification']" />
    <xsl:template match="field[@name='_password']" />
    <xsl:template match="field[@name='password']" />
    <xsl:template match="_vp_response_text" />
    <xsl:template match="_vp_event_date" />
    
    <xsl:template match="_vp_note" />
    <xsl:template match="field[@name='object_type'][parent::_vp_response_text]" />
    <xsl:template match="field[@name='object_id'][parent::_vp_response_text]" />
</xsl:stylesheet>