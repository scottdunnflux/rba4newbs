<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:kml="http://www.opengis.net/kml/2.2" exclude-result-prefixes="xs math" version="3.0">
    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:variable name="hotspotxml">
            <xsl:element name="map" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:element name="array">
                    <xsl:attribute name="key">hotspots</xsl:attribute>
                    <xsl:for-each select="//kml:Placemark">
                        <xsl:element name="map">
                            <xsl:element name="string"><xsl:attribute name="key">name</xsl:attribute>
                                <xsl:value-of select="kml:name"/>
                            </xsl:element>
                            <xsl:element name="string"><xsl:attribute name="key">lat</xsl:attribute>
                                <xsl:value-of select="tokenize(normalize-space(.//kml:coordinates[1]), ',')[2]"/>
                            </xsl:element>
                            <xsl:element name="string"><xsl:attribute name="key">lon</xsl:attribute>
                                <xsl:value-of select="tokenize(normalize-space(.//kml:coordinates[1]), ',')[1]"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:variable>

        <xsl:value-of select="xml-to-json($hotspotxml)"/>
<!--        <xsl:copy-of select="$hotspotxml"/>-->
    </xsl:template>
            
</xsl:stylesheet>
