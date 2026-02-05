<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="html" indent="yes"/>

  <xsl:param name="defaultTitle" select="'Titolo non specificato'"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:choose>
            <xsl:when test="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
              <xsl:value-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$defaultTitle"/>
            </xsl:otherwise>
          </xsl:choose>
        </title>
      </head>
      <body>
        <div>
          <span>1.</span>
          <xsl:call-template name="content"/>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="content">
    <xsl:apply-templates select="tei:TEI"/>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:apply-templates/>

    <xsl:choose>
      <xsl:when test="tei:teiHeader">
        <p>Header presente.</p>
      </xsl:when>
      <xsl:when test="tei:text">
        <p>Testo presente.</p>
      </xsl:when>
      <xsl:otherwise>
        <p>Nessun contenuto presente.</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:fileDesc">
    <ol>
      <xsl:for-each select="tei:titleStmt/tei:title">
        <li><xsl:value-of select="."/></li>
      </xsl:for-each>
    </ol>
  </xsl:template>

</xsl:stylesheet>
