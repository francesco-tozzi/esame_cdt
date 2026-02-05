<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <html lang="it">
            <head>
                <title><xsl:value-of select="//tei:titleStmt/tei:title"/></title>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <link rel="stylesheet" href="style.css"/>
                <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;700&amp;family=Merriweather:ital,wght@0,300;0,400;1,400&amp;display=swap" rel="stylesheet"/>
                <script defer="defer" src="style.js"></script>
            </head>
            <body class="diplomatic-mode">
                <nav id="main-nav">
                    <!--nome-->
                    <div class="nav-brand">La Rassegna Settimanale (ed. digitale)</div>

                    <!--link per la navigazione-->
                    <ul class="nav-links">
                        
                        <!--indice dei contenuti-->
                        <xsl:for-each select="//tei:div[@type='article' or @type='bibliography' or @type='section']">
                            <li>
                                <!--link per il contenuto all'interno della pagina-->
                                <a href="#{@xml:id}">
                                    <!--estraggo il titolo della sezione di interesse,(che non ha un type a meno che non ci sia un titolo o un sottotitolo. Se ha un type prendo il valore testuale dove type=main, escludendo così eventuali sottotitoli)-->
                                    <xsl:value-of select="tei:head[@type='main' or not(@type)]"/>
                                </a>
                            </li>
                        </xsl:for-each>
                        
                    </ul>
                </nav>
                
                <div id="app-container">
                    <!--creo una barra laterale utile per il tipo di visualizzazione e i filtri di entità-->
                    <aside id="sidebar">
                        <h3>Visualizzazione</h3>
                        <div class="toggle-group">
                            <button class="mode-btn" onclick="setMode('interpretative')">Interpretativa</button>
                            <button class="mode-btn active" onclick="setMode('diplomatic')">Diplomatica</button>
                        </div>

                        <h3>Filtri Entità</h3>
                        <div class="filter-group">
                            <button class="filter-btn" onclick="toggleFilter(this, 'persName')">Persone</button>
                            <button class="filter-btn" onclick="toggleFilter(this, 'placeName')">Luoghi</button>
                            <button class="filter-btn" onclick="toggleFilter(this, 'term')">Termini</button>
                            <button class="filter-btn" onclick="toggleFilter(this, 'date')">Date</button>
                        </div>
                    </aside>

                    <!--per creare lo spazio di visualizzazione del facsimile, cerco tutti i surface. Ottengo la lista e su di ognuno "applico le template rules" descritte per "tei:surface" -->
                    <div id="facsimile-panel">
                        <xsl:apply-templates select="//tei:facsimile/tei:surface"/>
                    </div>
                    
                    <!--per creare lo spazio di visualizzazione del testo, cerco tutti i body. Ottengo la lista e su di ognuno "applico le template rules" descritte per "tei:body"-->
                    <div id="text-panel">
                        <xsl:apply-templates select="//tei:body"/>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

    <!--TEMPLATE RULES PER SURFACE-->
    <xsl:template match="tei:surface">
        <!--creo un container per le immagini delle pagine del facsimile e un svg di rettangoli che delimitano le varie "zone"-->
        <div class="surface-container" id="{@xml:id}">

            <!--cerco l'immagine di quella "surface" (indicata nel foglio .xml con l'attributo url dell'elemento <graphic>) tramite il percorso XPath-->
            <img class="facsimile-img" src="{tei:graphic/@url}" alt="Facsimile pagina {@n}"/>

            <!--creo due variabili (larghezza e altezza) il cui valore è contenuto dai due attributi omonimi in .xml elemento <graphic>. Poiché i valori sono in formato "px", tolgo l'unità con replace() (necessario per i seguenti passaggi)-->
            <xsl:variable name="width" select="replace(tei:graphic/@width, 'px', '')"/>
            <xsl:variable name="height" select="replace(tei:graphic/@height, 'px', '')"/>

            <!--creo l'elemento svg che si sovrapporà all'immagine. 
            L'attributo viewBox è impostato in base alle dimensioni dell'immagine (concretamente serve per garantire che, se ridimensiono la pagina, anche le dimensioni dei rettangoli delle zone vengano aggiornate per tenersi in proporzione)-->
            <svg class="facsimile-overlay" viewBox="0 0 {$width} {$height}">
                <xsl:for-each select="tei:zone">
                    <!--creo un rettangolo per ogni zona. Le due coordinate di origine sono uguali a quelle di TEI (upper left), mentre larghezza e altezza, che non ci sono in TEI, si possono ottenere tramite una semplice differenza rispettivamente tra le due x e tra le due y -->
                    <rect 
                        id="{@xml:id}" 
                        x="{@ulx}" y="{@uly}" 
                        width="{@lrx - @ulx}" height="{@lry - @uly}" 
                        class="zone-rect"
                        onclick="handleZoneClick('{@xml:id}')">
                    </rect>
                </xsl:for-each>
            </svg>
        </div>
    </xsl:template>

    <!--TEMPLATE RULES PER BODY e figli-->
    <xsl:template match="tei:body">
        <xsl:apply-templates select="tei:div[@type='article' or @type='bibliography' or @type='section']"/>
    </xsl:template>

    <!--per ogni div con il testo codificato in .xml, creo un <article> che ha un id (utile per la navigazione)-->
    <xsl:template match="tei:div[@type='article' or @type='bibliography' or @type='section']">
        <article class="text-article" id="{@xml:id}">
            <xsl:apply-templates/>
        </article>
    </xsl:template>

    <!--poiché i paragrafi e i titoli sono elementi che devono comportarsi in modo simile, uso una unica istruzione per entrambi. In particolare, per quanto riguarda il collegamento tra immagine e testo-->
    <xsl:template match="tei:p | tei:head">
        <!--salvo in una variabile xsl il valore dell'attributo facs, togliendo il carattere '#' che lo precede-->
        <xsl:variable name="facsClean" select="translate(@facs, '#', '')"/>
        <!--creo un div in cui assegno dinamicamente il valore dell'attributo class e data-facs (attributo personalizzato html, si crea con "data-" e il nome target)-->
        <div class="{local-name()}-block text-block" data-facs="{$facsClean}">
            <!--se l'elemento ha un attributo xml:id, lo assegno all'attributo id del div creato-->
             <xsl:if test="@xml:id">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!--gestione dell'elemento choice (scelta fra due opzioni)-->
    <xsl:template match="tei:choice">
        <!--creo un container con le due opzioni-->
        <span class="choice-wrap">
            <!--le tre opzioni "diplomatiche" (totalmente fedeli al testo originale)-->
            <xsl:if test="tei:abbr">
                <span class="diplomatic form-abbr"><xsl:apply-templates select="tei:abbr"/></span>
            </xsl:if>
            <xsl:if test="tei:sic">
                <span class="diplomatic form-sic"><xsl:apply-templates select="tei:sic"/></span>
            </xsl:if>
            <xsl:if test="tei:orig">
                <span class="diplomatic form-orig"><xsl:apply-templates select="tei:orig"/></span>
            </xsl:if>

            <!--le tre opzioni "interpretative" (che migliorano la lettura del testo venendo meno alla totale fedeltà al testo originale)-->
            <xsl:if test="tei:expan">
                <span class="interpretative form-expan"><xsl:apply-templates select="tei:expan"/></span>
            </xsl:if>
            <xsl:if test="tei:corr">
                <span class="interpretative form-corr"><xsl:apply-templates select="tei:corr"/></span>
            </xsl:if>
            <xsl:if test="tei:reg">
                <span class="interpretative form-reg"><xsl:apply-templates select="tei:reg"/></span>
            </xsl:if>
        </span>
    </xsl:template>

    <!--gestione delle entità (persone, luoghi, termini, date): creo un tag di linea generico che racchiude il testo della parola. Assegno una classe (per css e js) e un titolo (per tooltip)-->
    <xsl:template match="tei:persName">
        <span class="entity persName" title="Persona"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:placeName">
        <span class="entity placeName" title="Luogo"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="tei:term">
        <span class="entity term" title="Termine"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <span class="entity date" title="Data"><xsl:apply-templates/></span>
    </xsl:template>

    <!--gestione delle parole con ulteriori informazioni-->
    <xsl:template match="tei:distinct | tei:rs">
        <!--creo un elemento inline con classe e attributo (personalizzato) data-ref che contiene l'xml:id dell'elemento-->
        <span class="gloss-trigger" data-ref="{@xml:id}">
            <!--prendo il testo dell'elemento-->
             <xsl:apply-templates/>
             <!--creo il contenuto del tooltip-->
             <span class="tooltip-content">
                 <xsl:value-of select="@type"/>
             </span>
        </span>
    </xsl:template>

    <!--indicazione di pagina-->
    <xsl:template match="tei:pb">
        <div class="page-break">Pagina <xsl:value-of select="@n"/></div>
    </xsl:template>

    <!--indicazione di colonna-->
    <xsl:template match="tei:cb">
        <span class="column-marker" title="Inizio Colonna {@n}">¶</span>
    </xsl:template>

    <!--gestione parole evidenziate nel testo per importanza o per enfasi-->
    <xsl:template match="tei:hi[@rend='bold']"><strong><xsl:apply-templates/></strong></xsl:template>
    <xsl:template match="tei:hi[@rend='italic']"><em><xsl:apply-templates/></em></xsl:template>

    <!--gestione a capo-->
    <xsl:template match="tei:lb"><br/></xsl:template>

</xsl:stylesheet>