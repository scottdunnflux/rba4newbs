<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:kml="http://www.opengis.net/kml/2.2"
    exclude-result-prefixes="xs math"
    version="3.0">
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:text>Name,Latitude,Longitude&#10;</xsl:text>
        <xsl:for-each select="//kml:Placemark">
            <xsl:variable name="hotspotname" select="kml:name"/>
            <xsl:variable name="lat" select="tokenize(normalize-space(.//kml:coordinates[1]),',')[2]"/>
            <xsl:variable name="lon" select="tokenize(normalize-space(.//kml:coordinates[1]),',')[1]"/>
            <xsl:call-template name="csvdata">
                <xsl:with-param name="val" select="$hotspotname"/>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
            <xsl:call-template name="csvdata">
                <xsl:with-param name="val" select="$lat"/>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
            <xsl:call-template name="csvdata">
                <xsl:with-param name="val" select="$lon"/>
            </xsl:call-template>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="csvdata">
        <xsl:param name="val"/>
        <xsl:if test="contains($val,'&quot;')">"</xsl:if>
        <xsl:value-of select="replace($val,'&quot;','&quot;&quot;')"/>
        <xsl:if test="contains($val,'&quot;')">"</xsl:if>
            
    </xsl:template>
</xsl:stylesheet>