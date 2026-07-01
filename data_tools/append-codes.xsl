<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:kml="http://www.opengis.net/kml/2.2" exclude-result-prefixes="xs math" 
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    version="3.0">
    <xsl:output method="text"/>

    <!-- Reads the raw eBird download and adds a code4 (4-letter banding code) to each record.
         Input:  ../data_raw/nyc-species-raw.json  (from get-species.py)
         Output: stdout — redirect to ../docs/data/nyc-species.json (the file the app loads).
         Input and output are deliberately different files: re-running on an already-augmented
         file would emit duplicate code4 keys.

         Prefer running the whole pipeline via data_tools/regenerate-species.sh. To run this
         step by hand: the real data is pulled through unparsed-text(), but match="/" still
         needs a context node, so pass any dummy source document with -s:. From data_tools/
         ($SAXON_LIB/* pulls in Saxon-HE plus its xmlresolver companion jars):
           java -cp "$SAXON_LIB/*" net.sf.saxon.Transform \
                -xsl:append-codes.xsl -s:../docs/data/dummy.xml > /tmp/out.json -->
    <xsl:variable name="birdcodes" select="json-to-xml(unparsed-text('../docs/data/alpha_codes_from_excel.json'))"/>
    <xsl:template match="/">
    <xsl:variable name="nyc-species-with-code">        
                <xsl:apply-templates select="json-to-xml(unparsed-text('../data_raw/nyc-species-raw.json'))/*"/>
    </xsl:variable>
    <xsl:value-of select="xml-to-json($nyc-species-with-code)"/>
        
    </xsl:template>
    
    <xsl:template match='j:map[j:string[@key="common_name"]]'>
        <xsl:variable name="nyc_common" select="j:string[@key='common_name']/text()"/>
        <xsl:copy>
        <xsl:element name="string" namespace="http://www.w3.org/2005/xpath-functions"><xsl:attribute name="key">code4</xsl:attribute>
            <xsl:value-of select='translate(
                $birdcodes//j:map[
                j:string[
                @key="english_name" and text()=$nyc_common
                ]
                ]/*[@key="four_letter_code"]/text()
                ,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")'/>
        </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
