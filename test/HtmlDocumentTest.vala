/* HtmlDocumentTest.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011-2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;

public class XHtmlDocumentTest : GLib.Object {
    public static int main (string[] args)
    {
        Test.init (ref args);
		Test.add_func ("/gxml/HtmlDocument/api/element_id", () => {
			try {
				var doc = new XHtmlDocument.from_path (GXmlTestConfig.TEST_DIR+"/index.html");
				Test.message ("Checking root element...");
				assert (doc.document_element != null);
				assert (doc.document_element.node_name.down () == "html".down ());
				Test.message ("Searching for elemento with id 'user'...");
				var n = doc.get_element_by_id ("user");
				assert (n != null);
				assert (n.node_name == "p");
				assert (n is GXml.DomElement);
				message (((GXml.DomElement) n).text_content);
				assert (((GXml.DomElement) n).node_value == "");
			} catch (GLib.Error e){
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/HtmlDocument/api/element_class", () => {
			try {
				var doc = new XHtmlDocument.from_path (GXmlTestConfig.TEST_DIR+"/index.html");
				Test.message ("Checking root element...");
				assert (doc.document_element != null);
				assert (doc.document_element.node_name.down () == "html".down ());
				Test.message ("Searching for element with property class and value app...");
				var np = doc.document_element.get_elements_by_property_value ("class","app");
				assert (np != null);
				assert (np.size == 2);
				Test.message ("Searching for elemento with class 'app'...");
				var l = doc.get_elements_by_class_name ("app");
				assert (l != null);
				assert (l.size == 2);
				bool fdiv, fp;
				fdiv = fp = false;
				foreach (GXml.DomElement e in l) {
					if (e.node_name == "div") fdiv = true;
					if (e.node_name == "p") fp = true;
				}
				assert (fdiv);
				assert (fp);
			} catch (GLib.Error e){
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/HtmlDocument/fom_string_doc", () => {
			try {
				var sdoc = "<!doctype html>
<html>
<head>
  <style>
  * { color: red; }
  </style>
</head>
<body>
  <script type=\"text/javascript\">
  </script>
</body>
</html>
";
				var doc = new XHtmlDocument.from_string_doc (sdoc);
				assert (doc.document_element != null);
				assert (doc.document_element.node_name.down () == "html".down ());
				var ln = doc.document_element.get_elements_by_property_value ("type","text/javascript");
				assert (ln != null);
				assert (ln.size == 1);
				var np = ln.item (0);
				assert (np != null);
				assert (np.node_name == "script");
				var l = doc.get_elements_by_tag_name ("style");
				assert (l != null);
				assert (l.size == 1);
				var sn = l.item (0);
				assert (sn != null);
				assert (sn.node_name == "style");
				message (sn.child_nodes.length.to_string ());
				assert (sn.child_nodes.length == 1);
				message (doc.to_html ());
				var s = doc.to_html ();
				message (s);
				assert ("style>\n  * { color: red; }\n  </style>" in s);
			} catch (GLib.Error e){
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		// Test.add_func ("/gxml/HtmlDocument/uri", () => {
		// 	try {
		// 		var f = GLib.File.new_for_uri ("http://www.omgubuntu.co.uk/2017/05/kde-neon-5-10-available-download-comes-plasma-5-10");
		// 		DomDocument doc;
		// 		doc = new XHtmlDocument.from_uri ("http://www.omgubuntu.co.uk/2017/05/kde-neon-5-10-available-download-comes-plasma-5-10");
		// 		message ((doc as GDocument).to_string ());
		// 	} catch (GLib.Error e){
		// 		message ("ERROR: "+e.message);
		// 		assert_not_reached ();
		// 	}
		// });
		Test.add_func ("/gxml/HtmlDocument/element-by-property", () => {
		 	var src = """
<!--[if lt IE 7]>      <html dir="ltr" lang="fr" data-locale="fr" data-locale-long="fr_FR" data-locale-name="French (France)" data-locale-facebook="fr_FR" data-locale-twitter="fr" data-locale-google="fr" data-locale-linkedin="fr_FR" class="no-js lt-ie9 lt-ie8 lt-ie7 "> <![endif]-->
<!--[if IE 7]>         <html dir="ltr" lang="fr" data-locale="fr" data-locale-long="fr_FR" data-locale-name="French (France)" data-locale-facebook="fr_FR" data-locale-twitter="fr" data-locale-google="fr" data-locale-linkedin="fr_FR" class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html dir="ltr" lang="fr" data-locale="fr" data-locale-long="fr_FR" data-locale-name="French (France)" data-locale-facebook="fr_FR" data-locale-twitter="fr" data-locale-google="fr" data-locale-linkedin="fr_FR" class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!-->
<html dir="ltr" lang="fr" data-locale="fr" data-locale-long="fr_FR" data-locale-name="French (France)" data-locale-facebook="fr_FR" data-locale-twitter="fr" data-locale-google="fr" data-locale-linkedin="fr_FR" class="no-js "><!--<![endif]--><head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# article: http://ogp.me/ns/article#"><meta charset="UTF-8"/><title>Climat&#xA0;: la Chine est-elle le nouveau leader ? - France 24</title><meta http-equiv="X-UA-Compatible" content="IE=edge"/><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/><meta name="title" content="Climat&#xA0;: la Chine est-elle le nouveau leader ? - France 24"/><meta name="description" content="&#xC9;L&#xC9;MENT TERRE : Autrefois mauvaise &#xE9;l&#xE8;ve des n&#xE9;gociations climatiques, la Chine a chang&#xE9; de cap. D&#xE9;sormais, P&#xE9;kin investit massivement dans les &#xE9;nergies..."/><link rel="search" type="application/opensearchdescription+xml" href="/opensearch_fr.xml?version=20171213121500" title="France 24"/><meta name="apple-mobile-web-app-capable" content="yes"/><meta name="apple-mobile-web-app-status-bar-style" content="black-translucent"/><meta name="apple-mobile-web-app-title" content="France 24"/><meta name="application-name" content="France 24"/><link rel="shortcut icon" href="/favicon.ico?version=20171213121500" type="image/x-icon"/><link rel="apple-touch-icon" href="/apple-touch-icon-57x57.png?version=20171213121500" sizes="57x57"/><link rel="apple-touch-icon" href="/apple-touch-icon-60x60.png?version=20171213121500" sizes="60x60"/><link rel="apple-touch-icon" href="/apple-touch-icon-72x72.png?version=20171213121500" sizes="72x72"/><link rel="apple-touch-icon" href="/apple-touch-icon-76x76.png?version=20171213121500" sizes="76x76"/><link rel="apple-touch-icon" href="/apple-touch-icon-114x114.png?version=20171213121500" sizes="114x114"/><link rel="apple-touch-icon" href="/apple-touch-icon-120x120.png?version=20171213121500" sizes="120x120"/><link rel="apple-touch-icon" href="/apple-touch-icon-144x144.png?version=20171213121500" sizes="144x144"/><link rel="apple-touch-icon" href="/apple-touch-icon-152x152.png?version=20171213121500" sizes="152x152"/><link rel="apple-touch-icon" href="/apple-touch-icon-180x180.png?version=20171213121500" sizes="180x180"/><link rel="icon" type="image/png" href="/favicon-16x16.png?version=20171213121500" sizes="16x16"/><link rel="icon" type="image/png" href="/favicon-32x32.png?version=20171213121500" sizes="32x32"/><link rel="icon" type="image/png" href="/favicon-48x48.png?version=20171213121500" sizes="48x48"/><link rel="icon" type="image/png" href="/favicon-64x64.png?version=20171213121500" sizes="64x64"/><link rel="icon" type="image/png" href="/favicon-96x96.png?version=20171213121500" sizes="96x96"/><link rel="icon" type="image/png" href="/favicon-160x160.png?version=20171213121500" sizes="160x160"/><link rel="icon" type="image/png" href="/favicon-192x192.png?version=20171213121500" sizes="192x192"/><meta name="msapplication-TileColor" content="#454349"/><meta name="msapplication-TileImage" content="/mstile-144x144.png?version=20171213121500"/><link rel="icon" type="image/x-icon" href="/favicon.ico?version=20171213121500"/><meta property="og:site_name" content="France 24"/><meta property="og:url" content="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat"/><meta property="og:type" content="article"/><meta property="og:image" content="http://scd.france24.com/fr/files_fr/imagecache/home_1024/edition/fr_element_terre_chine_charbon_pad.sub_.01.jpg"/><meta property="og:image:width" content="1024"/><meta property="og:image:height" content="576"/><meta property="og:image:type" content="image/jpg"/><meta property="og:title" content="Climat&#xA0;: la Chine est-elle le nouveau leader ? - France 24"/><meta property="og:description" content="&#xC9;L&#xC9;MENT TERRE : Autrefois mauvaise &#xE9;l&#xE8;ve des n&#xE9;gociations climatiques, la Chine a chang&#xE9; de cap. D&#xE9;sormais, P&#xE9;kin investit massivement dans les &#xE9;nergies..."/><meta property="fb:app_id" content="121241974571942"/><meta property="fb:pages" content="153632746935"/><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:url" content="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat"/><meta name="twitter:creator" content="@France24_fr"/><meta name="twitter:site" content="@FRANCE24"/><meta name="twitter:image" content="http://scd.france24.com/fr/files_fr/imagecache/home_1024/edition/fr_element_terre_chine_charbon_pad.sub_.01.jpg"/><meta name="twitter:title" content="Climat&#xA0;: la Chine est-elle le nouveau leader ? - France 24"/><meta name="twitter:description" content="&#xC9;L&#xC9;MENT TERRE : Autrefois mauvaise &#xE9;l&#xE8;ve des n&#xE9;gociations climatiques, la Chine a chang&#xE9; de cap. D&#xE9;sormais, P&#xE9;kin investit massivement dans les &#xE9;nergies..."/><meta name="twitter:domain" content="FRANCE24.com"/><meta name="twitter:account_id" content="1994321"/><meta name="twitter:app:id:iphone" content="364379394"/><meta name="twitter:app:id:ipad" content="364379394"/><meta name="twitter:app:id:googleplay" content="com.france24.androidapp"/><meta name="apple-itunes-app" content="app-id=364379394"/><meta name="msApplication-ID" content="57d03d56-dd7c-449e-8fa1-a87c090f54df"/><meta name="msApplication-PackageFamilyName" content="FRANCE24.FRANCE24-MCD-RFI_3zfmvk45gp28r"/><meta name="twitter:app:name:iphone" content="FRANCE 24"/><meta name="twitter:app:name:ipad" content="FRANCE 24"/><meta name="twitter:app:name:googleplay" content="FRANCE 24 pour Android"/><meta property="og:locale" content="fr_FR"/><link href="https://plus.google.com/116536894056162235467/" rel="publisher"/><meta property="article:publisher" content="http://www.facebook.com/FRANCE24"/><meta property="article:author" content="http://www.facebook.com/FRANCE24"/><meta property="article:published_time" content="2017-10-18T18:01:28+02:00"/><meta property="article:modified_time" content="2017-10-20T15:14:13+02:00"/><meta property="article:section" content="&#xC9;L&#xC9;MENT TERRE"/><meta property="article:tag" content="Chine"/><meta property="article:tag" content="Climat"/><meta property="article:tag" content="&#xC9;nergies renouvelables"/><link rel="alternate" href="android-app://com.france24.androidapp/f24/fr/show/WB5190871-F24-FR-20171018"/><meta name="twitter:app:url:googleplay" content="f24://fr/show/WB5190871-F24-FR-20171018"/><link rel="canonical" href="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat"/><link rel="alternate" media="only screen and (max-width: 640px)" href="http://m.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat"/><link rel="stylesheet" type="text/css" href="/css/compiled/main.css?version=20171213121500"/><link rel="stylesheet" type="text/css" href="/css/compiled/print.css?version=20171213121500" media="print"/><script type="text/javascript" src="/bundles/aefhermesf24/js/hacks.js?version=20171213121500"/><!-- [if lt IE 9] --><script type="text/javascript" src="/bundles/aefhermesf24/js/vendor/modernizr.js?version=20171213121500"/><script type="text/javascript" src="/bundles/aefhermesf24/js/vendor/respond.min.js?version=20171213121500"/><!-- [endif] --><script type="text/javascript"><![CDATA[
                var domainConfig = {
    baseDomain: "france24.com",
    defaultSubdomain: "www",
    mobileSubdomain: "m",
    tabletSubdomain: "t",
    currentSubdomain: "www",
    currentLocale: {
        short: "fr",
        long: "fr_FR"
    }
};
var isAefHermes = true;

    window.janrainEnabled = true;

            ]]></script><script type="text/javascript"><![CDATA[
                var specialEventId = '';
            ]]></script><script type="text/javascript" src="/js/compiled/mobile-redirect.js?version=20171213121500"/><script type="text/javascript" data-main="/js/main.built.js?version=20171213121500" src="/js/require.js?version=20171213121500" async=""/><script class="tc-config-vars" type="text/javascript"><![CDATA[<!--
var tms_vars = {};
tms_vars["page"] = "Detail\x20page";
tms_vars["env_context"] = "main";
tms_vars["reqtag"] = "";
tms_vars["locale"] = "fr";
tms_vars["sous-repertoire"] = "\u00C9L\u00C9MENT\x20TERRE";
tms_vars["aef_libelle_contenu_page"] = "\u00C9L\u00C9MENT\x20TERRE\x2DClimat\u00A0\x3A\x20la\x20Chine\x20est\x2Delle\x20le\x20nouveau\x20leader\x20\x3F";
tms_vars["aef_id_contenu"] = "WB5190871\x2DF24\x2DFR\x2D20171018";
tms_vars["aef_marque"] = "france24";
tms_vars["aef_rep1"] = "emission";
tms_vars["aef_rep2"] = "element\x2Dterre";
tms_vars["aef_rep3"] = "defaut";
tms_vars["aef_rep_global"] = "emission";
tms_vars["aef_thema"] = "chine,climat,energies\x20renouvelables";
tms_vars["aef_type_page1"] = "edition";
tms_vars["aef_auteur"] = "marina\x20bertsch,\x20mairead\x20dundas,\x20juliette\x20lacharnay,\x20valerie\x20dekimpe";
tms_vars["aef_acces"] = "gratuit";
tms_vars["markup_ftp"] = "emissions";
tms_vars["nom_page"] = "climat\x3A\x2Dla\x2Dchine\x2Dest\x2Delle\x2Dle\x2Dnouveau\x2Dleader\x2D\x3F";
tms_vars["aef_dpubli"] = "2017\x2D10\x2D20";
tms_vars["aef_hpubli"] = "15\x3A14";
tms_vars["aef_type_contenu1"] = "video";
tms_vars["env_work"] = 'prod';
tms_vars["aef_version_environnement"] = 'v3.0.22';
        var tc_vars = {};
window.tc_vars = tms_vars;
//-->]]></script><script type="application/ld+json"><![CDATA[{"@context":"http:\/\/schema.org","@type":"NewsArticle","mainEntityOfPage":"True","url":"http:\/\/www.france24.com\/fr\/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat","thumbnailUrl":"http:\/\/scd.france24.com\/fr\/files_fr\/imagecache\/home_1024\/edition\/fr_element_terre_chine_charbon_pad.sub_.01.jpg","headline":"Climat\u00a0: la Chine est-elle le nouveau leader ?","alternativeHeadline":"\u003Cp\u003EAutrefois mauvaise \u00e9l\u00e8ve des n\u00e9gociations climatiques, la Chine a chang\u00e9 de cap. D\u00e9sormais, P\u00e9kin investit massivement dans les \u00e9nergies renouvelables et participe \u00e0 l\u2019effort collectif, occupant la chaise vide laiss\u00e9e par les \u00c9tats-Unis de Donald Trump. Mais par ailleurs, des entreprises publiques chinoises sont li\u00e9es \u00e0 une centaine de projets de centrales \u00e0 charbon \u00e0 l'\u00e9tranger. La Chine peut-elle tout de m\u00eame \u00eatre consid\u00e9r\u00e9e comme un h\u00e9ros du climat ? Ou joue-t-elle un double jeu\u00a0?\u003C\/p\u003E","description":"\u003Cp\u003EAutrefois mauvaise \u00e9l\u00e8ve des n\u00e9gociations climatiques, la Chine a chang\u00e9 de cap. D\u00e9sormais, P\u00e9kin investit massivement dans les \u00e9nergies renouvelables et participe \u00e0 l\u2019effort collectif, occupant la chaise vide laiss\u00e9e par les \u00c9tats-Unis de Donald Trump. Mais par ailleurs, des entreprises publiques chinoises sont li\u00e9es \u00e0 une centaine de projets de centrales \u00e0 charbon \u00e0 l'\u00e9tranger. La Chine peut-elle tout de m\u00eame \u00eatre consid\u00e9r\u00e9e comme un h\u00e9ros du climat ? Ou joue-t-elle un double jeu\u00a0?\u003C\/p\u003E","image":{"@type":"ImageObject","url":"http:\/\/scd.france24.com\/fr\/files_fr\/imagecache\/home_1024\/edition\/fr_element_terre_chine_charbon_pad.sub_.01.jpg","width":"1024","height":"576"},"keywords":["Chine","Climat","\u00c9nergies renouvelables"],"datePublished":"2017-10-18T18:01:28Z","dateCreated":"2017-10-18T18:01:28Z","dateModified":"2017-10-20T15:14:13Z","articleSection":"emission-\u00c9L\u00c9MENT TERRE","creator":"Marina BERTSCH","author":[{"@type":"Person","name":"Marina BERTSCH","url":"http:\/\/www.france24.com"},{"@type":"Person","name":"Mairead DUNDAS","url":"http:\/\/www.france24.com"},{"@type":"Person","name":"Juliette LACHARNAY","url":"http:\/\/www.france24.com"},{"@type":"Person","name":"Val\u00e9rie DEKIMPE","url":"http:\/\/www.france24.com"}],"publisher":{"@type":"Organization","name":"France 24","url":"https:\/\/plus.google.com\/116536894056162235467\/","logo":{"@type":"ImageObject","url":"http:\/\/static.france24.com\/meta_og_twcards\/jsonld_publisher.png","width":"1200","height":"1200"}}}]]></script></head><body class="desktop fluid-transition">
            <div class="side-bar">
                            <header class="identity"><div class="logo">
                            <a href="/fr/">
                                France 24 : L&#x2019;actualit&#xE9; internationale 24h / 24                            </a>
                        </div>
                                        <p>L&#x2019;actualit&#xE9; internationale 24H / 24</p>
                </header><nav class="main-nav"><ul><li class="nav-filters">
                                                                                                                                                                                                                            <a href="/fr/" class="modeless" title="Infos, news &amp; actualit&#xE9;s - L'information internationale en direct">
                            A la une
                        </a>
                                                                            <dl class="mn-filters"><dt>Filtrer la page :</dt>
                                <dd><a class="modeless filter" title="Infos, news &amp; actualit&#xE9;s - L'information internationale en direct" href="http://www.france24.com/fr/depeches/">AFP</a></dd>
                                <dd><a class="modeless filter" title="Les derni&#xE8;res 24h" href="http://www.france24.com/fr/home/24h/1/">24h</a></dd>
                                <dd><a class="modeless filter" title="Vid&#xE9;os" href="http://www.france24.com/fr/video/">Vid&#xE9;os</a></dd>
                            </dl></li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/video/" class="modeless" title="Vid&#xE9;os News - Actualit&#xE9; vid&#xE9;o - France24">
                            Vid&#xE9;os
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/france/" class="modeless" title="FRANCE : News et actualit&#xE9; en continu - France 24">
                            France
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/afrique/" class="modeless" title="Politique &amp; &#xE9;conomie en AFRIQUE, infos &amp; news au Maghreb - France 24">
                            Afrique
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/moyen-orient/" class="modeless" title="Informations et news au MOYEN-ORIENT - Toute l'actualit&#xE9; sur France 24">
                            Moyen-orient
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/europe/" class="modeless" title="News, actualit&#xE9; politique &amp; &#xE9;conomique en Europe - France 24">
                            Europe
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/ameriques/" class="modeless" title="Am&#xE9;riques : information en direct, news et actu en continu - France 24">
                            Am&#xE9;riques
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/asie-pacifique/" class="modeless" title="Asie et Pacifique : actualit&#xE9; internationale en continu - France 24">
                            Asie-pacifique
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/sports/" class="modeless" title="SPORT : toutes les news sportives et les r&#xE9;sultats - France 24">
                            Sports
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/eco-tech/" class="modeless" title="&#xC9;CONOMIE &amp; TECHNOLOGIE : toute l'actu &#xE9;co &amp; tech  - France 24">
                            &#xC9;co/tech
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/culture/" class="modeless" title="CULTURE &amp; artistes : l'actualit&#xE9; culturelle &amp; artistique - France 24">
                            Culture
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/planete/" class="modeless" title="PLAN&#xC8;TE : toute l'actu environnement - France 24">
                            Plan&#xE8;te
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/reportages/" class="modeless light" title="Tous les reportages des grands reporters de France 24 aux 4 coins du monde">
                            Reportages
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/emissions/" class="modeless light" title="Programmes TV, Emissions et news en VOD">
                            &#xC9;missions
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                                                                                                            <a href="/fr/webdocumentaires/" class="modeless light" title="Webdocumentaires et Infographies - France 24">
                            Infographies
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                            <a href="http://www.infomigrants.net/fr/" class="item-im" title="InfoMigrants" target="_blank">
                            Infomigrants
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                            <a href="http://observers.france24.com/fr" class="item-lo" title="Les Observateurs" target="_blank">
                            Les observateurs
                        </a>
                                                                                    </li>




                <li class="">
                                                                                                                                            <a href="http://mashable.france24.com" class="item-mash" title="Mashable avec France 24" target="_blank">
                            Mashable avec france 24
                        </a>
                                                                                    </li>
                        </ul></nav></div>
        <div class="page mini-player-context">
            <div id="loading">

                <div id="squaresWaveG">
                    <div id="squaresWaveG_1" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_2" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_3" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_4" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_5" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_6" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_7" class="squaresWaveG">
                    </div>
                    <div id="squaresWaveG_8" class="squaresWaveG">
                    </div>
                </div>

            </div>
                            <div class="on-air-board-outer">
    <div class="on-air-board">
        <div class="first-row">
                                                                                                        <script type="application/json" data-player-playlist="main-player" data-player-bind="main-player"><![CDATA[
    {"medias":{"media":{"type":"video","media_sources":{"media_source":[{"streaming_type":{"platforms":{"platform":["flash","html5"]},"mime_type":"application\/vnd.apple.mpegurl","type":"video","html5_codec":"avc1.42E01E, mp3","bitrate":0},"is_default":0,"source":"http:\/\/static.france24.com\/live\/F24_FR_LO_HLS\/live_web.m3u8"}]},"title":"","is_live":true,"photo_url":"","thumbnail_url":"","rolls":{"urlpre":"http:\/\/ad2play.ftv-publicite.fr\/preroll.vast?v=2&sitepage=www.france24.fr\/direct","urlpost":""},"is_active":1,"labels":{"now":""},"comscore":{"baseMeasurementURL":"fr.sitestat.com\/aef\/f24-mcd-rfi\/s?","labels":{"ns_st_ci":"direct_france24","ns_st_ep":"direct_france24","ns_st_pr":"live","ns_st_ty":"video","ns_st_st":"france24_francais","ns_st_pl":"france24_francais","ns_st_el":0,"ns_st_ub":0,"ns_st_cn":1,"ns_st_cl":0,"ns_st_dt":"2016-01-13","aef_streamtype_2":"live","aef_rep_global":"live","aef_type_page1":"player","aef_type_contenu1":"video","aef_section1":"live","aef_auteur":"france24","aef_dpubli":"2016-01-13","aef_hpubli":"14:37","ns_st_li":1,"aef_marque":"france24","name":"itemtype.defaut.defaut","aef_type_environnement":"site","aef_plateforme":"ordinateur","aef_nom_environnement":"france24_site","aef_version_environnement":"v1.36.9","aef_perimetre_diffusion":"interne","aef_url_provenance":"http:\/\/www.france24.com\/fr\/","aef_page_provenance":"\/fr\/","aef_langue":"francais","aef_acces":"gratuit","aef_user_connection":"visiteur","aef_user_id":""}}}}}
]]></script><div id="dynamic-player-element" class="async-load" data-content="http://www.france24.com/fr/_fragment/player/tofollow/">



<a href="#" class="player-live" data-stream="main-player" data-players-toggle="">
</a>

<a href="#" class="player-toggler" data-youtube-id="">
    <span>&#xA0;</span>
</a>

<div/>

    <div class="block">
        <h3>Rendez-vous</h3>
        <div class="oab-rendez"/>
    </div>

<div class="block">
    <h3>Rejouer</h3>
    <ul class="oab-replay"/></div>

                </div>
                <br style="clear: both; line-height: 0;"/></div>

        <div class="second-row">
            <div class="oab-first-col">
                                                <div class="video-player">
                                        <div data-player-id="main-player" class="main-player" data-player-duplication-id="main-player-yt"/>
                    <div data-ytplayer-id="main-player-yt" class="main-player" data-player-duplication-id="main-player"/>
                    <p class="copy">
                    </p><div data-fragment-src="http://www.france24.com/fr/_fragment/player/nowplaying/"/>

                </div>
                <div class="video-board">
                    <div class="v-header"><h2>LES DERNI&#xC8;RES &#xC9;MISSIONS</h2></div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5214082-F24-FR-20180105">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/1801.png" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">MODE </p>
                                        <h2 class="title">La mode en 2017&#xA0;: f&#xE9;minisme, business et tabous &#xE0; briser</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:xVmbTxp2zK8" data-players-video-title="MODE">
                                        <a rel="nofollow" href="/fr/20180105-mode-dior-lvmh-harcelement-maigreur-hyeres-barcelone-beyrouth-madrid-fashion-week">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5214076-F24-FR-20180105">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/dls_rvpi_wsj.png.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">REVUE DE PRESSE </p>
                                        <h2 class="title">Trump pour "une expansion massive des forages p&#xE9;troliers offshore"</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:d1xP867dis4" data-players-video-title="REVUE DE PRESSE">
                                        <a rel="nofollow" href="/fr/20180105-offshore-etats-unis-trump-exploitation-hydrocarbures-avocate-ukrainienne-assassinat">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5214068-F24-FR-20180105">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/dls_rvp_une_huma.png_1.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">REVUE DE PRESSE </p>
                                        <h2 class="title">Erdogan en visite &#xE0; Paris&#xA0;: "Le d&#xE9;jeuner qui fait grincer"</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:bQHgoynC580" data-players-video-title="REVUE DE PRESSE">
                                        <a rel="nofollow" href="/fr/20180105-erdogan-visite-paris-macron-droits-homme-purges-zad-carte-loeb-dakar-perou">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5214050-F24-FR-20180105">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/photo_eco_encadre_turquie.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">LE JOURNAL DE L'&#xC9;CO </p>
                                        <h2 class="title">Erdogan &#xE0; Paris, une visite aux accents &#xE9;conomiques</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:M3jovViFXdY" data-players-video-title="LE JOURNAL DE L'&#xC9;CO">
                                        <a rel="nofollow" href="/fr/20180105-turquie-erdogan-france-cuba-mogherini-moneygram-or-air-france-spotify-galette">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5213972-F24-FR-20180104">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/salah-mohamed-ballon-dor-africain_ok.jpeg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">LE JOURNAL DE L&#x2019;AFRIQUE </p>
                                        <h2 class="title">L'&#xC9;gyptien Mohamed Salah sacr&#xE9; Joueur africain de l'ann&#xE9;e</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:uW9fR1zqMCQ" data-players-video-title="LE JOURNAL DE L&#x2019;AFRIQUE">
                                        <a rel="nofollow" href="/fr/20180104-mohamed-salah-joueur-africain-annee-rdc-eglise-catholique-togo-gnassingbe">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5213964-F24-FR-20180104">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/2018-01-04_2221_un_oeil_sur_les_medias.jpeg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">UN &#x152;IL SUR LES M&#xC9;DIAS </p>
                                        <h2 class="title">Emmanuel Macron d&#xE9;clare la guerre aux "Fake News"</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:I9Ev83CpSTI" data-players-video-title="UN &#x152;IL SUR LES M&#xC9;DIAS">
                                        <a rel="nofollow" href="/fr/oeil-medias/20180104-emmanuel-macron-declare-a-guerre-fake-news">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5213929-F24-FR-20180104">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/debat_43.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">LE D&#xC9;BAT </p>
                                        <h2 class="title">Diplomatie fran&#xE7;aise : Emmanuel Macron, changement de style ou changement de fond ? (partie 2)</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:-3pkJVuQgbQ" data-players-video-title="LE D&#xC9;BAT">
                                        <a rel="nofollow" href="/fr/20180104-le-debat-emmanuel-macron-diplomatie-francaise-partie-2">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5213928-F24-FR-20180104">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/debat_42.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">LE D&#xC9;BAT </p>
                                        <h2 class="title">Diplomatie fran&#xE7;aise : Emmanuel Macron, changement de style ou changement de fond ? (partie 1)</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:9tGoUCa_HBA" data-players-video-title="LE D&#xC9;BAT">
                                        <a rel="nofollow" href="/fr/20180104-le-debat-emmanuel-macron-diplomatie-francaise">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             <div class="v-item-2" data-bo-type="edition" data-bo-nid="WB5213822-F24-FR-20180104">
                                    <div class="media video">
                                        <img src="http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_medium_169/edition/rwanda_evangelicals_focus.jpg" alt=""/></div>
                                    <div class="copy">
                                        <p class="place">FOCUS </p>
                                        <h2 class="title">Le Rwanda en plein "r&#xE9;veil" &#xE9;vang&#xE9;lique</h2>
                                    </div>
                                    <p class="default-read-more" style="" data-players-toggle="main-player-yt.loadVideoById:bg9camAClZU" data-players-video-title="FOCUS">
                                        <a rel="nofollow" href="/fr/2018-01-04-focus-rwanda-evangeliques-religion-eglises-catholiques">En savoir plus</a>
                                    </p>
                                </div>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               <script type="application/json" data-player-playlist="edition-WB5213751-F24-FR-20180104" data-player-bind="main-player" data-player-playlist-default=""><![CDATA[
    {"medias":{"media":{"type":"video","media_sources":{"media_source":[{"streaming_type":{"platforms":{"platform":["flash","html5"]},"mime_type":"video\/mp4","type":"video","html5_codec":"avc1.42E01E, mp3","bitrate":0},"is_default":0,"source":"http:\/\/medias.france24.com\/fr\/vod\/2018\/01\/04\/FRAN180104-0916-Live_CS0916.mp4"}]},"title":"","is_live":0,"photo_url":"","thumbnail_url":"","rolls":{"urlpre":"","urlpost":""},"is_active":1,"labels":{"now":""},"comscore":{"baseMeasurementURL":"fr.sitestat.com\/aef\/f24-mcd-rfi\/s?","labels":{"ns_st_ci":"WB5213751-F24-FR-20180104","ns_st_ep":"L'Union europ\u00e9enne renforce ses liens avec Cuba","ns_st_pr":"fr","ns_st_ty":"video","ns_st_st":"france24_francais","ns_st_pl":"france24_francais","ns_st_el":0,"ns_st_ub":0,"ns_st_cn":1,"ns_st_cl":0,"ns_st_dt":"2016-01-13","aef_streamtype_2":"od","aef_rep_global":"live","aef_type_page1":"player","aef_type_contenu1":"video","aef_section1":"live","aef_auteur":"france24","aef_dpubli":"2016-01-13","aef_hpubli":"14:37","ns_st_li":1,"aef_marque":"france24","name":"itemtype.defaut.defaut","aef_type_environnement":"site","aef_plateforme":"ordinateur","aef_nom_environnement":"france24_site","aef_version_environnement":"v1.36.9","aef_perimetre_diffusion":"interne","aef_url_provenance":"http:\/\/www.france24.com\/fr\/","aef_page_provenance":"\/fr\/","aef_langue":"francais","aef_acces":"gratuit","aef_user_connection":"visiteur","aef_user_id":""}}}}}
]]></script><div class="v-expand-items">
                        <a href="/fr/emissions/" class="default-button-1 modeless" title="Derni&#xE8;res &#xE9;missions">
                            Toutes les &#xE9;missions
                        </a>
                    </div>
                </div>
            </div>

            <div class="oab-second-col">
                <div class="program-schedule">
                    <div class="hd">
                        <div class="type-1">
                            <a href="#" class="tabs" data-target="player-comments">
                                <span class="comment-count">

            <span class="fb-comments-count" data-href="http://www.france24.com/fr/?query=player-live"/>

                                </span>
                                COMMENTAIRE(S)
                            </a>
                            <a href="#" class="tabs active" data-target="player-programs">Grille des programmes</a>
                        </div>
                        <div class="type-2">
                            <a href="#" class="comm tabs" data-target="player-comments">
                                <span class="comment-count">

            <span class="fb-comments-count" data-href="http://www.france24.com/fr/?query=player-live"/>

                                </span>
                                &#xA0;commentaires
                            </a>
                            <a href="#" class="pro tabs active" data-target="player-programs">
                                <span/>Programmes
                            </a>
                        </div>
                    </div>
                    <div id="player-comments" class="bd tabs" style="display: none">
            <div class="facebook-comment">
                                    <div class="fb-comments" data-href="http://www.france24.com/fr/?query=player-live" width="100%" data-numposts="5" data-colorscheme="light" data-mobile="false"/>
                    </div>

                    </div>
                    <div id="player-programs" class="bd tabs">
                        <div data-fragment-src="http://www.france24.com/fr/_fragment/player/programgrid/"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

                                    <div class="slider-wrap">
                <div class="content-slider">
                    <div class="content-slide">
                        <div class="main-board emission-board">

    <div class="adv-megaban tms-block" data-pos="1" data-type="megaban" data-location="top" data-expand="true" data-loaded="false">
    </div>


                                                        <div id="modeless-target" data-fb-no-comments="Laisser un commentaire">
                                            <a href="/fr/emissions/element-terre/">
        <div class="section-banner" data-bo-type="emission" data-bo-nid="287F6962-3E2B-4232-B35F-B709BF190D84">
            <div class="image-banner">
                                <img src="http://scd.france24.com/fr/files_fr/ELEMENT_TERRE_FR_0.jpg" alt="&#xC9;L&#xC9;MENT TERRE"/></div>
            <div class="intro-banner">
                <p> Ouvrons les yeux sur le monde qui nous entoure! Aid&#xE9;s par une &#xE9;quipe de graphistes, nous d&#xE9;poussi&#xE9;rons et d&#xE9;cortiquons les grands th&#xE8;mes qui font l&#x2019;environnement aujourd&#x2019;hui. Le samedi &#xE0; 20h20. Et d&#xE8;s le vendredi en avant-premi&#xE8;re sur internet! </p>
            </div>
        </div>
    </a>
        <div class="col-1 highfooter">

                <article class="article-long" data-bo-type="edition" data-bo-nid="WB5190871-F24-FR-20171018"><header class="hd"><ul class="tag"><li><a href="/fr/tag/chine/" title="Chine" class="modeless">Chine</a></li>
                            <li><a href="/fr/tag/climat/" title="Climat" class="modeless">Climat</a></li>
                            <li><a href="/fr/tag/energies-renouvelables/" title="&#xC9;nergies renouvelables" class="modeless">&#xC9;nergies renouvelables</a></li>
                        </ul><p class="modification">Derni&#xE8;re modification : 20/10/2017</p>
                <h1 class="title">Climat&#xA0;: la Chine est-elle le nouveau leader ?</h1>

                <div class="article-action emission-action">
                    <div class="emission_title">
                                                                                                <a class="icon-rss" target="_blank" href="/fr/emissions/element-terre/podcast"/>
                        <a class="icon-podcast" target="_blank" href="itpc://www.france24.com/fr/emissions/element-terre/podcast"/>
                    </div>

<script type="text/javascript"><![CDATA[
    function linkedInSuccess(data) {
        trackingSocial.li_tracker();
    }
]]></script><ul class="sharebar-social-part"><li class="social-cell fb">
                        <div class="fb-share-button" data-href="http://f24.my/1yc3.F" data-type="button_count" data-width="90" data-callback="trackingSocial.fb_tracker"/>
        </li>

            <li class="social-cell tt">
            <a href="https://twitter.com/share" class="twitter-share-button" data-url="http://f24.my/1yc3.T" data-counturl="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat" data-text="&#xC9;L&#xC9;MENT TERRE - Climat&#xA0;: la Chine est-elle le nouveau leader ?" data-via="" data-lang="fr" data-related="France24_fr" data-callback="trackingSocial.tt_tracker">Tweeter</a>
        </li>

            <li class="social-cell gg">
            <div class="g-plus" data-action="share" data-annotation="bubble" data-href="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat" data-callback="trackingSocial.gg_tracker"/>
        </li>


            <li class="social-cell in">
            <script type="IN/Share" data-url="http://f24.my/1yc3.L" data-counter="right" data-onsuccess="liTracker"/></li>
    </ul><ul class="sharebar-internal-part"/><div class="clear-both"/>


                </div>


                <figure class="img"><div style="background-image: url('http://scd.france24.com/fr/files_fr/imagecache/france24_ct_api_bigger_169/edition/fr_element_terre_chine_charbon_pad.sub_.01.jpg'); background-size: cover" data-ytplayer-id="15oDkx7jjvU" class="youtube-container bsplayer-type-video bsplayer-processed"/>
                                                                                                                <figcaption>&#xA9; Capture France 24</figcaption></figure></header><div class="bd">
                <h2>Autrefois mauvaise &#xE9;l&#xE8;ve des n&#xE9;gociations climatiques, la Chine a chang&#xE9; de cap. D&#xE9;sormais, P&#xE9;kin investit massivement dans les &#xE9;nergies renouvelables et participe &#xE0; l&#x2019;effort collectif, occupant la chaise vide laiss&#xE9;e par les &#xC9;tats-Unis de Donald Trump. Mais par ailleurs, des entreprises publiques chinoises sont li&#xE9;es &#xE0; une centaine de projets de centrales &#xE0; charbon &#xE0; l'&#xE9;tranger. La Chine peut-elle tout de m&#xEA;me &#xEA;tre consid&#xE9;r&#xE9;e comme un h&#xE9;ros du climat ? Ou joue-t-elle un double jeu&#xA0;?</h2>
                <p>La Chine poursuit sa politique charbon &#xE0; l&#x2019;&#xE9;tranger. Des entreprises publiques chinoises sont li&#xE9;es &#xE0; une centaine de projets de centrales &#xE0; charbon dans 27 pays &#xE9;trangers. Alors, la Chine joue-t-elle double jeu ?</p>
                                    <p class="author">
                        Par <a title="Marina BERTSCH" class="modeless" href="/fr/auteur/marina-bertsch/">Marina BERTSCH</a>
                                                    , <a title="Mairead DUNDAS" class="modeless" href="/fr/auteur/mairead-dundas/">Mairead DUNDAS</a>
                                                    , <a title="Juliette LACHARNAY" class="modeless" href="/fr/auteur/juliette-lacharnay/">Juliette LACHARNAY</a>
                                                    , <a title="Val&#xE9;rie DEKIMPE" class="modeless" href="/fr/auteur/valerie-dekimpe/">Val&#xE9;rie DEKIMPE</a>
                                                                    </p>
                            </div>

                        <div class="clear-both"/>

                                    <div class="clear-both"/>
        </article><div class="article-action">

<script type="text/javascript"><![CDATA[
    function linkedInSuccess(data) {
        trackingSocial.li_tracker();
    }
]]></script><ul class="sharebar-social-part"><li class="social-cell fb">
                        <div class="fb-share-button" data-href="http://f24.my/1yc3.F" data-type="button_count" data-width="90" data-callback="trackingSocial.fb_tracker"/>
        </li>

            <li class="social-cell tt">
            <a href="https://twitter.com/share" class="twitter-share-button" data-url="http://f24.my/1yc3.T" data-counturl="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat" data-text="&#xC9;L&#xC9;MENT TERRE - Climat&#xA0;: la Chine est-elle le nouveau leader ?" data-via="" data-lang="fr" data-related="France24_fr" data-callback="trackingSocial.tt_tracker">Tweeter</a>
        </li>

            <li class="social-cell gg">
            <div class="g-plus" data-action="share" data-annotation="bubble" data-href="http://www.france24.com/fr/20171021-chine-charbon-centrale-etranger-energie-environnement-leader-climat" data-callback="trackingSocial.gg_tracker"/>
        </li>


            <li class="social-cell in">
            <script type="IN/Share" data-url="http://f24.my/1yc3.L" data-counter="right" data-onsuccess="liTracker"/></li>
    </ul><ul class="sharebar-internal-part"/><div class="clear-both"/>


        </div>


                                    <div class="footage-board vertical-position">
        <h5 class="default-header-2">Les archives</h5>
                    <div class="news-item no-0" data-bo-type="edition" data-bo-nid="WB5208883-F24-FR-20171214">
            <div class="media video">

                <img src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_vignette_home/edition/emission_year_in_review_1.jpg" alt=""/><span/>
            </div>


            <div class="copy">
                <p class="meta">14/12/2017 R&#xE9;chauffement climatique</p>
                <h3 class="title">
                    <a title="2017, ann&#xE9;e catastrophique pour l&#x2019;environnement ?" href="/fr/20171216-pire-annee-2017-environnement-climat-catastrophes-naturelles-ouragans-trump-accord-paris" class="modeless">
                        2017, ann&#xE9;e catastrophique pour l&#x2019;environnement ?
                    </a>
                </h3>
                <p class="desc">
                   Inondations, ouragans, s&#xE9;cheresse, feux de for&#xEA;t, temp&#xE9;ratures extr&#xEA;mes, &#xE9;missions de Co2 en augmentation : 2017 a &#xE9;t&#xE9; un cru exceptionnellement mauvais, battant mois apr&#xE8;s mois...
                </p>
            </div>


            <ul class="social-nt"><li class="target">
                    <div>
                        <img alt="Partager" width="32" height="32" src="/bundles/aefhermesf24/img/01.png?version=20171213121500"/></div>
                </li>
                <li class="item"><div class="fb fb-share" data-href="http://f24.my/2F7g.F" data-callback="trackingSocial.fb_tracker" data-title="2017, ann&#xE9;e catastrophique pour l&#x2019;environnement ?"/></li>
                <li class="item"><div class="tw tt-share" data-href="http://f24.my/2F7g.T" data-callback="trackingSocial.tt_tracker" data-text="2017, ann&#xE9;e catastrophique pour l&#x2019;environnement ?"/></li>
                <li class="item"><div class="go gg-share" data-href="http://www.france24.com/fr/20171216-pire-annee-2017-environnement-climat-catastrophes-naturelles-ouragans-trump-accord-paris" data-callback="trackingSocial.gg_tracker"/></li>
                <li class="item"><div class="li in-share" data-href="http://f24.my/2F7g.L" data-callback="trackingSocial.in_tracker" data-title="2017, ann&#xE9;e catastrophique pour l&#x2019;environnement ?"/></li>
            </ul><p class="default-read-more">
                <a rel="nofollow" title="http://www.france24.com/fr/20171216-pire-annee-2017-environnement-climat-catastrophes-naturelles-ouragans-trump-accord-paris" href="/fr/20171216-pire-annee-2017-environnement-climat-catastrophes-naturelles-ouragans-trump-accord-paris" class="modeless">En savoir plus</a>
            </p>
        </div>

                                                    <div class="news-item no-0" data-bo-type="edition" data-bo-nid="WB5204867-F24-FR-20171201">
            <div class="media video">

                <img src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_vignette_home/edition/en_element_terre_virage_vert.jpg" alt=""/><span/>
            </div>


            <div class="copy">
                <p class="meta">01/12/2017 P&#xE9;trole</p>
                <h3 class="title">
                    <a title="Le virage vert des p&#xE9;troliers, info ou intox&#xA0;?" href="/fr/20171202-elementerre-petroliers-investissements-energies-renouvelables-virage-vert-total" class="modeless">
                        Le virage vert des p&#xE9;troliers, info ou intox&#xA0;?
                    </a>
                </h3>
                <p class="desc">
                   Total, Shell, Statoil, l'Arabie Saoudite... Les g&#xE9;ants du p&#xE9;trole annoncent des milliards de dollars d'investissements dans les &#xE9;nergies renouvelables. Nous avons voulu savoir...
                </p>
            </div>


            <ul class="social-nt"><li class="target">
                    <div>
                        <img alt="Partager" width="32" height="32" src="/bundles/aefhermesf24/img/01.png?version=20171213121500"/></div>
                </li>
                <li class="item"><div class="fb fb-share" data-href="http://f24.my/2B88.F" data-callback="trackingSocial.fb_tracker" data-title="Le virage vert des p&#xE9;troliers, info ou intox&#xA0;?"/></li>
                <li class="item"><div class="tw tt-share" data-href="http://f24.my/2B88.T" data-callback="trackingSocial.tt_tracker" data-text="Le virage vert des p&#xE9;troliers, info ou intox&#xA0;?"/></li>
                <li class="item"><div class="go gg-share" data-href="http://www.france24.com/fr/20171202-elementerre-petroliers-investissements-energies-renouvelables-virage-vert-total" data-callback="trackingSocial.gg_tracker"/></li>
                <li class="item"><div class="li in-share" data-href="http://f24.my/2B88.L" data-callback="trackingSocial.in_tracker" data-title="Le virage vert des p&#xE9;troliers, info ou intox&#xA0;?"/></li>
            </ul><p class="default-read-more">
                <a rel="nofollow" title="http://www.france24.com/fr/20171202-elementerre-petroliers-investissements-energies-renouvelables-virage-vert-total" href="/fr/20171202-elementerre-petroliers-investissements-energies-renouvelables-virage-vert-total" class="modeless">En savoir plus</a>
            </p>
        </div>

                                                    <div class="news-item no-0" data-bo-type="edition" data-bo-nid="WB5200175-F24-FR-20171116">
            <div class="media video">

                <img src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_vignette_home/edition/saumon_norvege.jpg" alt=""/><span/>
            </div>


            <div class="copy">
                <p class="meta">16/11/2017 Norv&#xE8;ge</p>
                <h3 class="title">
                    <a title="Saumon de Norv&#xE8;ge : la guerre du pou est d&#xE9;clar&#xE9;e " href="/fr/20171118-norvege-saumon-industrie-parasite-poux-mer-innovation" class="modeless">
                        Saumon de Norv&#xE8;ge : la guerre du pou est d&#xE9;clar&#xE9;e
                    </a>
                </h3>
                <p class="desc">
                   &#xC0; une &#xE9;poque, le saumon &#xE9;tait un poisson luxueux, r&#xE9;serv&#xE9; aux tables de No&#xEB;l. Aujourd&#x2019;hui, il est devenu un plat du quotidien. La croissance de ce march&#xE9; est vertigineuse. On...
                </p>
            </div>


            <ul class="social-nt"><li class="target">
                    <div>
                        <img alt="Partager" width="32" height="32" src="/bundles/aefhermesf24/img/01.png?version=20171213121500"/></div>
                </li>
                <li class="item"><div class="fb fb-share" data-href="http://f24.my/2703.F" data-callback="trackingSocial.fb_tracker" data-title="Saumon de Norv&#xE8;ge : la guerre du pou est d&#xE9;clar&#xE9;e "/></li>
                <li class="item"><div class="tw tt-share" data-href="http://f24.my/2703.T" data-callback="trackingSocial.tt_tracker" data-text="Saumon de Norv&#xE8;ge : la guerre du pou est d&#xE9;clar&#xE9;e "/></li>
                <li class="item"><div class="go gg-share" data-href="http://www.france24.com/fr/20171118-norvege-saumon-industrie-parasite-poux-mer-innovation" data-callback="trackingSocial.gg_tracker"/></li>
                <li class="item"><div class="li in-share" data-href="http://f24.my/2703.L" data-callback="trackingSocial.in_tracker" data-title="Saumon de Norv&#xE8;ge : la guerre du pou est d&#xE9;clar&#xE9;e "/></li>
            </ul><p class="default-read-more">
                <a rel="nofollow" title="http://www.france24.com/fr/20171118-norvege-saumon-industrie-parasite-poux-mer-innovation" href="/fr/20171118-norvege-saumon-industrie-parasite-poux-mer-innovation" class="modeless">En savoir plus</a>
            </p>
        </div>

                                                    <div class="news-item no-0" data-bo-type="edition" data-bo-nid="WB5195708-F24-FR-20171102">
            <div class="media video">

                <img src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_vignette_home/edition/nucleaire_sans_texte_pad.jpg" alt=""/><span/>
            </div>


            <div class="copy">
                <p class="meta">02/11/2017 &#xC9;nergie nucl&#xE9;aire</p>
                <h3 class="title">
                    <a title="Nucl&#xE9;aire : on fait quoi des d&#xE9;chets ?" href="/fr/20171104-nucleaire-dechets-radioactifs-france-hague-bure-enfouissement" class="modeless">
                        Nucl&#xE9;aire : on fait quoi des d&#xE9;chets ?
                    </a>
                </h3>
                <p class="desc">
                   La France est le royaume du nucl&#xE9;aire. L&#x2019;industrie &#xE9;met peu de Co2, mais les d&#xE9;chets qu&#x2019;elle produit sont un casse-t&#xEA;te sans solution &#xE0; long terme.
                </p>
            </div>


            <ul class="social-nt"><li class="target">
                    <div>
                        <img alt="Partager" width="32" height="32" src="/bundles/aefhermesf24/img/01.png?version=20171213121500"/></div>
                </li>
                <li class="item"><div class="fb fb-share" data-href="http://f24.my/22pU.F" data-callback="trackingSocial.fb_tracker" data-title="Nucl&#xE9;aire : on fait quoi des d&#xE9;chets ?"/></li>
                <li class="item"><div class="tw tt-share" data-href="http://f24.my/22pU.T" data-callback="trackingSocial.tt_tracker" data-text="Nucl&#xE9;aire : on fait quoi des d&#xE9;chets ?"/></li>
                <li class="item"><div class="go gg-share" data-href="http://www.france24.com/fr/20171104-nucleaire-dechets-radioactifs-france-hague-bure-enfouissement" data-callback="trackingSocial.gg_tracker"/></li>
                <li class="item"><div class="li in-share" data-href="http://f24.my/22pU.L" data-callback="trackingSocial.in_tracker" data-title="Nucl&#xE9;aire : on fait quoi des d&#xE9;chets ?"/></li>
            </ul><p class="default-read-more">
                <a rel="nofollow" title="http://www.france24.com/fr/20171104-nucleaire-dechets-radioactifs-france-hague-bure-enfouissement" href="/fr/20171104-nucleaire-dechets-radioactifs-france-hague-bure-enfouissement" class="modeless">En savoir plus</a>
            </p>
        </div>

                                                            <div class="f-expand-items">
            <a href="/fr/emissions/element-terre/" title="element-terre" class="default-button-1 modeless">Voir toutes les archives</a>
        </div>
    </div>


    </div>

        <aside class="col-2"><div class="equipe">
        <div class="persons">
                                <div class="person">
                <div>
                                        <figure><img src="http://scd.france24.com/fr/files_fr/author_pictures/marina_bertsch.jpg" alt="" width="213"/><figcaption><strong>MARINA BERTSCH</strong>
                            <cite>Journaliste &#xE0; France 24, sp&#xE9;cialiste des questions d&#x2019;environnement</cite>
                        </figcaption></figure><a href="https://twitter.com/greenF24" class="twitter-follow-button" data-show-count="false" data-show-screen-name="false" data-lang="fr">
                                </a>
                                                                                            <p>
                       </p><p>Dipl&#xF4;m&#xE9;e de Sciences Po Paris et du CFJ, elle a travaill&#xE9; pour France 3 et France 5, avant de rejoindre FRANCE 24 &#xE0; sa cr&#xE9;ation, en 2006. Elle est sp&#xE9;cialiste des questions d&#x2019;environnement.</p>

                </div>
            </div>
                            </div>
    </div>


    <div class="ib-adv tms-block" data-pos="1" data-type="pave" data-location="sidebar" data-expand="true" data-loaded="false">
    </div>




    <div class="emissions-list shadow-section">
        <h5>Nos &#xE9;missions</h5>

                                <div class="emission-item" data-bo-type="edition" data-bo-nid="WB5214082-F24-FR-20180105">
                <div class="media video">
                    <img style="width:324px; height:182px;" src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_caroussel_home/edition/1801.png" alt=""/><span/>
                </div>
                <div class="copy">
                    <p>MODE</p>
                    <h4>La mode en 2017&#xA0;: f&#xE9;minisme, business et tabous &#xE0; briser</h4>
                </div>
                <p class="default-read-more"><a rel="nofollow" class="modeless" href="/fr/20180105-mode-dior-lvmh-harcelement-maigreur-hyeres-barcelone-beyrouth-madrid-fashion-week">En savoir plus</a></p>
            </div>
                                <div class="emission-item" data-bo-type="edition" data-bo-nid="WB5214076-F24-FR-20180105">
                <div class="media video">
                    <img style="width:324px; height:182px;" src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_caroussel_home/edition/dls_rvpi_wsj.png.jpg" alt=""/><span/>
                </div>
                <div class="copy">
                    <p>REVUE DE PRESSE</p>
                    <h4>Trump pour "une expansion massive des forages p&#xE9;troliers offshore"</h4>
                </div>
                <p class="default-read-more"><a rel="nofollow" class="modeless" href="/fr/20180105-offshore-etats-unis-trump-exploitation-hydrocarbures-avocate-ukrainienne-assassinat">En savoir plus</a></p>
            </div>
                                <div class="emission-item" data-bo-type="edition" data-bo-nid="WB5214068-F24-FR-20180105">
                <div class="media video">
                    <img style="width:324px; height:182px;" src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_caroussel_home/edition/dls_rvp_une_huma.png_1.jpg" alt=""/><span/>
                </div>
                <div class="copy">
                    <p>REVUE DE PRESSE</p>
                    <h4>Erdogan en visite &#xE0; Paris&#xA0;: "Le d&#xE9;jeuner qui fait grincer"</h4>
                </div>
                <p class="default-read-more"><a rel="nofollow" class="modeless" href="/fr/20180105-erdogan-visite-paris-macron-droits-homme-purges-zad-carte-loeb-dakar-perou">En savoir plus</a></p>
            </div>
                                <div class="emission-item" data-bo-type="edition" data-bo-nid="WB5214050-F24-FR-20180105">
                <div class="media video">
                    <img style="width:324px; height:182px;" src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_caroussel_home/edition/photo_eco_encadre_turquie.jpg" alt=""/><span/>
                </div>
                <div class="copy">
                    <p>LE JOURNAL DE L'&#xC9;CO</p>
                    <h4>Erdogan &#xE0; Paris, une visite aux accents &#xE9;conomiques</h4>
                </div>
                <p class="default-read-more"><a rel="nofollow" class="modeless" href="/fr/20180105-turquie-erdogan-france-cuba-mogherini-moneygram-or-air-france-spotify-galette">En savoir plus</a></p>
            </div>
                                <div class="emission-item" data-bo-type="edition" data-bo-nid="WB5213972-F24-FR-20180104">
                <div class="media video">
                    <img style="width:324px; height:182px;" src="http://scd.france24.com/fr/files_fr/imagecache/hermes_infographie_caroussel_home/edition/salah-mohamed-ballon-dor-africain_ok.jpeg" alt=""/><span/>
                </div>
                <div class="copy">
                    <p>LE JOURNAL DE L&#x2019;AFRIQUE</p>
                    <h4>L'&#xC9;gyptien Mohamed Salah sacr&#xE9; Joueur africain de l'ann&#xE9;e</h4>
                </div>
                <p class="default-read-more"><a rel="nofollow" class="modeless" href="/fr/20180104-mohamed-salah-joueur-africain-annee-rdc-eglise-catholique-togo-gnassingbe">En savoir plus</a></p>
            </div>
            </div>











    <div class="ib-adv tms-block" data-pos="2" data-type="pave" data-location="sidebar" data-expand="true" data-loaded="false">
    </div>



        <div class="intro-program">
        <div class="ip-item">
                        <div class="bd">

    <div class="tms-block" data-pos="1" data-type="partner_block" data-location="sidebar" data-expand="true" data-loaded="false">
    </div>


            </div>
        </div>

    </div>








             </aside></div>
                                                                                                            </div>
                    </div>
                </div>
            </div>
            <footer><div class="inner">
    <img class="f-logo" src="/bundles/aefhermesf24/img/france-24-logo.png?version=20171213121500" alt=""/><div class="f-link-list fl-l-l-1 fl-l-l-l-1">
                <p>Actualit&#xE9;</p>
                <ul><li><a class="modeless" href="/fr/" title="Infos, news &amp; actualit&#xE9;s - L'information internationale en direct">&#xC0; la une</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/france/" title="FRANCE : News et actualit&#xE9; en continu">France</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/afrique/" title="Politique &amp; &#xE9;conomie en AFRIQUE, infos &amp; news au Maghreb">Afrique</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/moyen-orient/" title="Informations et news au MOYEN-ORIENT - Toute l'actualit&#xE9; sur France 24">Moyen-Orient</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/ameriques/" title="Am&#xE9;riques : information en direct, news et actu en continu - France 24">Am&#xE9;riques</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/europe/" title="News, actualit&#xE9; politique &amp; &#xE9;conomique en Europe - France 24">Europe</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/asie-pacifique/" title="Asie et Pacifique : actualit&#xE9; internationale en continu - France 24">Asie-Pacifique</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/eco-tech/" title="&#xC9;CONOMIE &amp; TECHNOLOGIE : toute l'actu &#xE9;co &amp; tech">&#xC9;co/Tech</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/sports/" title="SPORT : toutes les news sportives et les r&#xE9;sultats">Sport</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/culture/" title="CULTURE &amp; artistes : l'actualit&#xE9; culturelle &amp; artistique">Culture</a></li>
                                                            </ul></div>

                        <div class="f-link-list fl-l-l-2">
                <p>la cha&#xEE;ne</p>
                <ul><li><a href="/fr/tv-en-direct-chaine-live" class="modeless video" title="Regarder France 24 en direct">La cha&#xEE;ne en direct</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/actualites-sous-titrees" class="modeless video" title="Suivez les derni&#xE8;res informations sous-titr&#xE9;es et la m&#xE9;t&#xE9;o">Accessibilit&#xE9;</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/emissions/" class="modeless" title="Programmes TV, Emissions et news en VOD">&#xC9;missions</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/reportages/" class="modeless" title="Tous les reportages des grands reporters de France 24 aux 4 coins du monde">Reportages</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/emissions/revue-presse/" class="modeless" title="Revue de presse">Revue de presse</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/emissions/" class="modeless" title="Podcasts">Podcasts</a></li>
                                                            </ul></div>
                    <div class="f-link-list fl-l-l-3">
                <p>Aller plus loin</p>
                <ul><li><a href="http://observers.france24.com/fr/" title="Les Observateurs" target="_blank">Les Observateurs</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://mashable.france24.com/" title="Mashable avec France 24" target="_blank">Mashable FR</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/webdocumentaires/" title="Infographies et Webdocumentaires">Webdocumentaires</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a class="modeless" href="/fr/dossiers/" title="Tous les Dossiers sp&#xE9;ciaux de la r&#xE9;daction France 24">Dossiers</a></li>
                                                            </ul></div>
                    <div class="f-link-list fl-l-l-4">
                <p>Services 24/7</p>
                <ul><li><a href="https://emailing.france24.com/fr/subscribe" title="Newsletters" target="_blank">Newsletters</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="https://emailing.france24.com/fr/subscribe" title="Espace personnel" target="_blank">Espace personnel</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/mobile" class="modeless" title="Applications Mobiles et Tablettes">Mobiles / Tablettes</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/tv-connectee" class="modeless" title="France 24 sur la TV connect&#xE9;e">TV connect&#xE9;es</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/rss" class="modeless" title="Flux RSS">Flux RSS</a></li>
                                                            </ul></div>

    <span class="f-line-1"/>
    <span class="f-line-2"/>
            <div class="f-social-link">

                                                                                                                                                                                                                                                                                                                                                                                                                                                    <a href="https://emailing.france24.com/fr/subscribe" title="Rejoignez la communaut&#xE9; France 24" target="_blank">Rejoignez la communaut&#xE9;</a>

                                                                                                                                                                                                                                                                                                                                                                                                                                                    <a href="/fr/medias-sociaux" class="modeless" title="Retrouvez France 24 sur les m&#xE9;dias sociaux">France 24 sur les m&#xE9;dias sociaux</a>
                                                                            <ul><li><a href="http://f24.my/rhako6" class="fb" title="Facebook" target="_blank">Facebook</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/XLkdot" class="tw" title="Twitter" target="_blank">Twitter</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/tASiE4" class="go" title="Google +" target="_blank">Google +</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/cHF8Wc" class="dm" title="Dailymotion" target="_blank">Dailymotion</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/bGRWve" class="yt" title="Youtube" target="_blank">Youtube</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/oTjdan" class="fs" title="Foursquare" target="_blank">Foursquare</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="http://f24.my/nsM8q8" class="sc" title="Soundcloud" target="_blank">Soundcloud</a></li>
                                                            </ul></div>

    <div class="f-adv tms-block" data-pos="1" data-type="pave" data-location="footer" data-expand="false" data-loaded="false">
    </div>


                                                                                                                                                                                                        <div class="f-map">
            <a href="/fr/comment-recevoir-la-chaine" class="modeless" title="Recevoir France 24">Recevoir France 24</a>
        </div>
                <nav class="f-nav"><ul><li><a href="/fr/entreprise" class="modeless" title="L'Entreprise France 24">&#xC0; propos de France 24</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/tag/communique-presse/" class="modeless" title="Communiqu&#xE9;s de Presse">Presse</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            <li><a href="http://static.france24.com/infographies/presse/FRANCE24_PressKit_1214_FR.pdf" class="" title="" target="_blank">Dossier de presse</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/contactez-nous?section=publicite" class="modeless" title="Opportunit&#xE9;s publicitaires et partenariats">R&#xE9;gie publicitaire</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/contactez-nous" class="modeless" title="Contact">Contact</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="https://careerpage.multiposting.fr/career/france-medias-monde/" class="modeless" title="Nous rejoindre">Nous rejoindre</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/plan-du-site" class="modeless" title="Plan du site">Plan du site</a></li>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <li><a href="/fr/mentions-legales" class="modeless" title="Mentions l&#xE9;gales">Mentions l&#xE9;gales</a></li>
                                                    </ul></nav><div class="f-partner">
        <a href="http://www.rfi.fr/" target="_blank"><img src="/bundles/aefhermesf24/img/rfi-logo.png?version=20171213121500" alt=""/></a>
        <a href="/fr/" target="_blank"><img src="/bundles/aefhermesf24/img/france24-logo.png?version=20171213121500" alt=""/></a>
        <a href="http://www.mc-doualiya.com/" target="_blank"><img src="/bundles/aefhermesf24/img/mcd-logo.png?version=20171213121500" alt=""/></a>
        <a href="http://www.francemediasmonde.com" target="_blank"><img src="/bundles/aefhermesf24/img/fmm-logo.png?version=20171213121500" alt=""/></a>
    </div>
    <p class="f-copy">
        &#xA9; 2018 Copyright France 24 &#x2013; Tous droits r&#xE9;serv&#xE9;s<br/>
        France 24 n'est pas responsable des contenus provenant de sites Internet externes<br/><a href="http://www.acpm.fr/Marque/marque-france-24" target="_blank" rel="nofollow" class="ojd">Fr&#xE9;quentation certifi&#xE9;e par l'ACPM/OJD</a>
            </p>
</div>

                            </footer><!-- mobile placeholder F24x4 --><style type="text/css"><![CDATA[
/* Masquage JR */
.user-janrain, #janrain {
display: none;
}
.g-list .copy {line-height: 20px; padding: 2px 6px !important;}
.orientation-center{width: 100% !important;}
.citation-material.orientation-center{width: auto !important;}
.default-header-2{width: auto !important;}
#SCRBBL-TOP {display:none !important;}
#nav-main-special-event {
margin-bottom: 10px !important;
height: 30px !important;
}
.main-nav .item-im {
height: 21px;
text-indent: -9999px !important;
background: transparent url(//static.france24.com/infomigrants/menu/logo_fren_v2@1x.png) center center no-repeat;
}
.main-nav .item-mash {
height: 21px;
text-indent: -9999px !important;
background: transparent url(//static.france24.com/mashable/menu/logo@1x.png) center center no-repeat;
}
.site-pusher nav li .logo-im {
display: block;
padding: 10px;
height: 21px;
overflow: hidden;
text-indent: -9999em;
background-image: url(//static.france24.com/infomigrants/menu/logo_fren_v2@1x.png);
background-position: left 10px center;
background-repeat: no-repeat;
}
.site-pusher nav li .logo-mashfr {
display: block;
margin: 10px;
height: 21px;
overflow: hidden;
text-indent: -9999em;
background-image: url(//static.france24.com/mashable/menu/logo@1x.png);
background-position: left center;
background-repeat: no-repeat;
}
.site-pusher nav li a.m-cgu {
font-size: 80%;
}
.site-pusher nav ul li:nth-last-child(2) a, .site-pusher nav ul li:nth-last-child(1) a {
border-bottom: none;
}
.site-pusher nav ul li:nth-last-child(2) {
border-bottom: 1px solid #ccc;
border-top: 1px solid #ccc;
}
/* menu d?roulant */
.sc-info .bd:hover {
max-height: 285px !important;
}
/* fixed for bs player fallback */
.alt-player.bsplayer-container {
padding-bottom:10px;
}
]]></style><script type="text/javascript"><![CDATA[
function handleAjaxSuccess() {
if (typeof($) !== 'function') {
return;
}
$(document).ajaxSuccess(function(event, xhr, settings) {
if (settings.url.indexOf('player/tofollow') > 1) {
setTimeout(function () {
$('[data-player-playlist^="replay"]')
.each(function() {
var $data = $(this).text();
var $dataJson = JSON.parse($data);
$dataJson = $.extend(true, $dataJson, {
'medias': {
'media': {
'rolls': {
'urlpre': 'http://ad2play.ftv-publicite.fr/preroll.vast?v=2&sitepage=www.france24.fr/journaletchroniques',
'urlpost': ''
}
}
}
});
$(this).text(JSON.stringify($dataJson));
});
}, 200);
}
});
}
window.CEM = function() {
//handleAjaxSuccess();
};
// AJOUT SUPPRESSION SURTITRE VIDEO
function defer(method) {
if (window.jQuery)
method();
else
setTimeout(function() { defer(method) }, 200);
}
function cleanVideoTitle() {
$("div.tab div.copy p.place:contains('Grab')").css('display','none');
$("div.tab div.copy p.place:contains('PKG')").css('display','none');
$("div.tab div.copy p.place:contains('INTRO')").css('display','none');
$("div.tab div.copy p.place:contains('GREB')").css('display','none');
$("div.tab div.copy p.place:contains('GRAB')").css('display','none');
}
defer(cleanVideoTitle);
defer(function(){
$(document).ajaxSuccess(function() {
cleanVideoTitle();
});
});
// FIN SUPPRESSION SURTITRE VIDEO
]]></script><div class="short-cuts-outer">
                                        <div class="short-cuts">


            <div class="sc-search">



            <p class="hd">



            <a href="#">
            search
                    </a>

                                    </p>



            <div class="bd">



            <form name="Search" method="get" action="/fr/recherche/" id="sinequa-search-form"><div><label for="Search_term" class="required">Terme</label><input type="text" id="Search_term" name="Search[term]" required="required" placeholder="Recherche&#x2026;"/></div><input type="hidden" id="Search_page" name="Search[page]" value="1"/><div><button type="submit">Lancer la recherche</button></div><div><label class="required">Filters</label><div id="Search_filters"/></div></form>

                                    </div>

                                    </div>



            <div class="sc-mail">



            <p class="hd">



            <a href="https://emailing.france24.com/fr/subscribe" target="_blank">
            e-mail
                    </a>

                                    </p>

                                    </div>



            <div class="sc-info">



            <p class="hd">
            France M&#xE9;dias Monde
                    </p>



            <div class="bd">



            <ul><li>



            <a href="http://observers.france24.com/fr" target="_blank">
            Les Observateurs
                    </a>

                                    </li>



            <li>



            <a href="http://mashable.france24.com" target="_blank">
            Mashable FR
                    </a>

                                    </li>



            <li>



            <a href="http://www.rfi.fr/" target="_blank">
            RFI
                    </a>

                                    </li>



            <li>



            <a href="http://musique.rfi.fr/" target="_blank">
            RFI Musique
                    </a>

                                    </li>



            <li>



            <a href="https://savoirs.rfi.fr/" target="_blank">
            RFI Savoirs
                    </a>

                                    </li>



            <li>



            <a href="http://atelier.rfi.fr/" target="_blank">
            Atelier des m&#xE9;dias
                    </a>

                                    </li>



            <li>



            <a href="http://mondoblog.org/" target="_blank">
            Mondoblog
                    </a>

                                    </li>



            <li>



            <a href="http://www.mc-doualiya.com/" target="_blank">
            Monte Carlo Doualiya
                    </a>

                                    </li>



            <li>



            <a href="http://academie.france24-mcd-rfi.com/fr/" target="_blank">
            Acad&#xE9;mie
                    </a>

                                    </li>



            <li>



            <a href="http://www.cfi.fr/" target="_blank">
            CFI
                    </a>

                                    </li>



            <li>



            <a href="http://www.francemediasmonde.com/" target="_blank">
            France M&#xE9;dias Monde
                    </a>

                                    </li>



            <li>



            <a href="http://www.rfi-instrumental.com/fr" target="_blank">
            RFI Instrumental
                    </a>

                                    </li>

                                    </ul></div>

                                    </div>



            <div class="sc-rec">



            <p class="hd">



            <a href="/fr/comment-recevoir-la-chaine">
            Recevoir France 24
                    </a>

                                    </p>

                                    </div>



            <div class="sc-voy">



            <p class="hd">



            <a href="/fr/voyage">
            Voyage
                    </a>

                                    </p>

                                    </div>



            <div class="sc-lang">



            <p class="hd">



            <a href="/fr/" class="active">
            Fran&#xE7;ais
                    </a>



            <a href="/en/" class="">
            English
                    </a>



            <a href="/es/" class="">
            Espa&#xF1;ol
                    </a>



            <a href="/ar/" class="">
            &#x639;&#x631;&#x628;&#x64A;
                    </a>

                                    </p>



            <p class="hd">



            <a href="/fr/actualites-sous-titrees" class="accessibility">
            Accessibilit&#xE9;
                    </a>

                                    </p>

                                    </div>

        <div class="user-janrain sc-info">
    <div id="user-disconnected">
        <a href="#" data-user="signin" class="hd active">Mon compte</a>
        <div class="bd" data-user="disconnected">
            <ul><li>
                    <a data-user="signin" href="#" target="_self" class="">Connexion</a>
                </li>
                <li>
                    <a href="/fr/rejoindre-la-communaute" target="_self" class="">Pr&#xE9;sentation</a>
                </li>
                <li>
                    <a href="/fr/rejoindre-communaute/faq" target="_self" class="">Aide</a>
                </li>
            </ul></div>
    </div>
    <div id="user-connected">
        <p class="hd">
            <span class="user-avatar"/>
            <span class="user-name" id="displayName"/>
        </p>
        <div class="bd" data-user="connected">
            <ul><li>
                    <a href="#" data-user="editProfile" class="">Mon Profil</a>
                </li>
                <li>
                    <a href="/fr/rejoindre-la-communaute" target="_self" class="">Pr&#xE9;sentation</a>
                </li>
                <li>
                    <a href="/fr/rejoindre-communaute/faq" target="_self" class="">Aide</a>
                </li>
                <li>
                    <a href="#" data-user="signout" class="">Me d&#xE9;connecter</a>
                </li>
            </ul></div>
    </div>
</div>

<div class="parameters-link">
    <a class="tos" href="/fr/mentions-legales" target="_self"/>
</div>
</div>

                            </div>
                            <div id="janrain">

<div style="display:none" id="signIn"><div class="capture_header"><h2>Cr&#xE9;er un compte / Se connecter</h2></div><div class="capture_signin"><h2>Avec le compte existant de...</h2>{* loginWidget *}<br/></div><div class="capture_backgroundColor"><div class="capture_signin"><h2>Avec un compte habituel</h2>{* #signInForm *} {* signInEmailAddress *} {* currentPassword *}<div class="capture_form_item"><a href="#" data-capturescreen="forgotPassword">Mot de passe oubli&#xE9; ?</a></div><div class="capture_rightText"><button class="capture_secondary capture_btn capture_primary" type="submit"><span class="janrain-icon-16 janrain-icon-key"/> Se connecter</button> <a href="#" id="capture_signIn_createAccountButton" data-capturescreen="traditionalRegistration" class="capture_secondary capture_createAccountButton capture_btn capture_primary">Cr&#xE9;er un compte</a></div>{* /signInForm *}</div></div></div><div style="display:none" id="returnSocial"><div class="capture_header"><h2>Sign In</h2></div><div class="capture_signin"><h2>Bienvenue ! {* welcomeName *}</h2>{* loginWidget *}<div class="capture_centerText switchLink"><a href="#" data-cancelcapturereturnexperience="true">Use another account</a></div></div></div><div style="display:none" id="returnTraditional"><div class="capture_header"><h2>Se connecter</h2></div><h2 class="capture_centerText"><span>Bienvenue !</span></h2><div class="capture_backgroundColor">{* #signInForm *} {* signInEmailAddress *} {* currentPassword *}<div class="capture_form_item capture_rightText"><button class="capture_secondary capture_btn capture_primary" type="submit"><span class="janrain-icon-16 janrain-icon-key"/> Se connecter</button></div>{* /signInForm *}<div class="capture_centerText switchLink"><a href="#" data-cancelcapturereturnexperience="true">Utiliser un autre compte</a></div></div></div><div style="display:none" id="accountDeactivated"><div class="capture_header"><h2>Compte d&#xE9;sactiv&#xE9;</h2></div><div class="content_wrapper"><p>Votre compte a &#xE9;t&#xE9; d&#xE9;sactiv&#xE9;</p></div></div><div style="display:none" id="emailNotVerified"><div class="capture_header"><h1>Adresse email non v&#xE9;rifi&#xE9;e</h1></div><p>Vous devez v&#xE9;rifier votre adresse email pour finaliser votre inscription. Consultez votre boite mail pour valider votre adresse en cliquant sur le lien figurant dans le mail de confirmation ou entrez &#xE0; nouveau votre adresse email pour recevoir une nouvelle fois le mail de confirmation.</p>{* #resendVerificationForm *} {* signInEmailAddress *}<div class="capture_footer"><input value="Envoyer" type="submit" class="capture_btn capture_primary"/></div>{* /resendVerificationForm *}</div>
<div style="display:none" id="socialRegistration"><div class="capture_header"><h2>C'est presque fini !</h2></div><h2>Merci de confirmer les informations ci-dessous avant de vous connecter</h2>{* #socialRegistrationForm *} {* firstName *} {* lastName *} {* emailAddress *} {* displayName *} {* phone *} {* addressCity *} {* addressCountry *} En cliquant sur "Cr&#xE9;er un compte", vous confirmez que vous acceptez nos &#xA0; <a class="termsOfService" href="#">conditions g&#xE9;n&#xE9;rales</a>&#xA0; et que vous avez lu et approuv&#xE9; la&#xA0; <a class="privacyPolicy" href="#">politique de protection de donn&#xE9;es personnelles</a>.<div class="capture_footer"><div class="capture_left">{* backButton *}</div><div class="capture_right"><input value="Cr&#xE9;er un compte" type="submit" class="capture_btn capture_primary"/></div></div>{* /socialRegistrationForm *}</div><div style="display:none" id="traditionalRegistration"><div class="capture_header"><h2>C'est presque fini !</h2></div><p>Merci de confirmer les informations ci-dessous avant de vous connecter <a id="capture_traditionalRegistration_navSignIn" href="#" data-capturescreen="signIn">Se connecter</a></p>{* #registrationForm *} {* firstName *} {* lastName *} {* emailAddress *} {* displayName *} {* phone *} {* addressCity *} {* addressCountry *} {* newPassword *} {* newPasswordConfirm *} En cliquant sur "Cr&#xE9;er un compte", vous confirmez que vous acceptez nos &#xA0; <a class="termsOfService" href="#">conditions g&#xE9;n&#xE9;rales</a>&#xA0; et que vous avez lu et approuv&#xE9; la&#xA0; <a class="privacyPolicy" href="#">politique de protection de donn&#xE9;es personnelles</a>.<div class="capture_footer"><div class="capture_left">{* backButton *}</div><div class="capture_right"><input value="Cr&#xE9;er un compte" type="submit" class="capture_btn capture_primary"/></div></div>{* /registrationForm *}</div><div style="display:none" id="emailVerificationNotification"><div class="capture_header"><h2>Merci de votre inscription</h2></div><p>Nous vous avons envoy&#xE9; un email de confirmation &#xE0; l'adresse suivante&#xA0; {* emailAddressData *}.&#xA0; Merci de consulter votre bo&#xEE;te de r&#xE9;ception et de cliquer sur le lien pour activer votre compte..</p><div class="capture_footer"><a href="#" onclick="janrain.capture.ui.modal.close()" class="capture_btn capture_primary">Fermer</a></div></div>
<div style="display:none" id="forgotPassword"><div class="capture_header"><h2>Cr&#xE9;er un nouveau mot de passe</h2></div><h2>Nous vous enverrons un lien pour cr&#xE9;er un nouveau mot de passe</h2>{* #forgotPasswordForm *} {* signInEmailAddress *}<div class="capture_footer"><div class="capture_left">{* backButton *}</div><div class="capture_right"><input value="Envoyer" type="submit" class="capture_btn capture_primary"/></div></div>{* /forgotPasswordForm *}</div><div style="display:none" id="forgotPasswordSuccess"><div class="capture_header"><h2>Cr&#xE9;er un nouveau mot de passe</h2></div><p>Nous vous avons envoy&#xE9; un email avec les instructions pour cr&#xE9;er un nouveau mot de passe. Votre mot de passe actuel n'a pas &#xE9;t&#xE9; chang&#xE9;</p><div class="capture_footer"><a href="#" onclick="janrain.capture.ui.modal.close()" class="capture_btn capture_primary">Fermer</a></div></div>
<div style="display:none" id="mergeAccounts">{* mergeAccounts {"custom": true} *}<div id="capture_mergeAccounts_mergeAccounts_mergeOptionsContainer" class="capture_mergeAccounts_mergeOptionsContainer"><div class="capture_header"><div class="capture_icon_col">{| rendered_current_photo |}</div><div class="capture_displayName_col">{| current_displayName |}<br/>{| current_emailAddress |}</div><span class="capture_mergeProvider janrain-provider-icon-24 janrain-provider-icon-{| current_provider_lowerCase |}"/></div><div class="capture_dashed"><div class="capture_mergeCol capture_centerText capture_left"><p class="capture_bigText">{| foundExistingAccountText |} <b>{| current_emailAddress |}</b>.</p><div class="capture_hover"><div class="capture_popup_container"><span class="capture_popup-arrow"/>{| moreInfoHoverText |}<br/>{| existing_displayName |} - {| existing_provider |} : {| existing_siteName |} {| existing_createdDate |}</div>{| moreInfoText |}</div></div><div class="capture_mergeCol capture_mergeExisting_col capture_right"><div class="capture_shadow capture_backgroundColor capture_border">{| rendered_existing_provider_photo |}<div class="capture_displayName_col">{| existing_displayName |}<br/>{| existing_provider_emailAddress |}</div><span class="capture_mergeProvider janrain-provider-icon-16 janrain-provider-icon-{| existing_provider_lowerCase |}"/><div class="capture_centerText capture_smallText">Created {| existing_createdDate |} at {| existing_siteName |}</div></div></div></div><div id="capture_mergeAccounts_form_collection_mergeAccounts_mergeRadio" class="capture_form_collection_merge_radioButtonCollection capture_form_collection capture_elementCollection capture_form_collection_mergeAccounts_mergeRadio" data-capturefield="undefined"><div id="capture_mergeAccounts_form_item_mergeAccounts_mergeRadio_1_0" class="capture_form_item capture_form_item_mergeAccounts_mergeRadio capture_form_item_mergeAccounts_mergeRadio_1_0 capture_toggled" data-capturefield="undefined"><label for="capture_mergeAccounts_mergeAccounts_mergeRadio_1_0"><input id="capture_mergeAccounts_mergeAccounts_mergeRadio_1_0" data-capturefield="undefined" data-capturecollection="true" value="1" type="radio" class="capture_mergeAccounts_mergeRadio_1_0 capture_input_radio" checked="checked" name="mergeAccounts_mergeRadio"/> {| connectLegacyRadioText |}</label></div><div id="capture_mergeAccounts_form_item_mergeAccounts_mergeRadio_2_1" class="capture_form_item capture_form_item_mergeAccounts_mergeRadio capture_form_item_mergeAccounts_mergeRadio_2_1" data-capturefield="undefined"><label for="capture_mergeAccounts_mergeAccounts_mergeRadio_2_1"><input id="capture_mergeAccounts_mergeAccounts_mergeRadio_2_1" data-capturefield="undefined" data-capturecollection="true" value="2" type="radio" class="capture_mergeAccounts_mergeRadio_2_1 capture_input_radio" name="mergeAccounts_mergeRadio"/> {| createRadioText |} {| current_provider |}</label></div><div class="capture_tip" style="display:none"/><div class="capture_tip_validating" data-elementname="mergeAccounts_mergeRadio">Validating</div><div class="capture_tip_error" data-elementname="mergeAccounts_mergeRadio"/></div><div class="capture_footer">{| connect_button |} {| create_button |}</div></div></div><div style="display:none" id="traditionalAuthenticateMerge"><div class="capture_header"><h2>Connectez-vous pour terminer la fusion des comptes</h2></div><div class="capture_signin">{* #signInForm *} {* signInEmailAddress *} {* currentPassword *}<div class="capture_footer"><div class="capture_left">{* backButton *}</div><div class="capture_right"><button class="capture_secondary capture_btn capture_primary" type="submit"><span class="janrain-icon-16 janrain-icon-key"/> Se connecter</button></div></div>{* /signInForm *}</div></div>
<div style="display:none" id="verifyEmail"><div class="capture_header"><h2>Renvoyer l'email de v&#xE9;rification</h2></div><p>Merci d'avoir confirm&#xE9; votre adresse email</p>{* #resendVerificationForm *} {* signInEmailAddress *}<div class="capture_footer"><input value="Submit" type="submit" class="capture_btn capture_primary"/></div>{* /resendVerificationForm *}</div><div style="display:none" id="resendVerificationSuccess"><div class="capture_header"><h2>Un email de v&#xE9;rification vous a &#xE9;t&#xE9; envoy&#xE9;</h2></div><div class="hr"/><p>V&#xE9;rifiez vos emails pour r&#xE9;cup&#xE9;rer le lien de changement de mot de passe</p><div class="capture_footer"><a href="#" data-user="signin" class="capture_btn capture_primary">Se connecter</a></div></div><div style="display:none" id="verifyEmailSuccess"><div class="capture_header"><h2>C'est fait !</h2></div><p>Merci d'avoir confirm&#xE9; votre adresse email</p><div class="capture_footer"><a href="#" data-user="signin" class="capture_btn capture_primary">Se connecter</a></div></div>
<div style="display:none" id="resetPassword"><div class="capture_header"><h2>Modifier le mot de passe</h2></div>{* #changePasswordFormNoAuth *} {* newPassword *} {* newPasswordConfirm *}<div class="capture_footer"><input value="Sauvegarder" type="submit" class="capture_btn capture_primary"/></div>{* /changePasswordFormNoAuth *}</div><div style="display:none" id="resetPasswordSuccess"><div class="capture_header"><h2>Votre mot de passe a &#xE9;t&#xE9; chang&#xE9;</h2></div><p>Votre mot de passe a &#xE9;t&#xE9; mis &#xE0; jour avec succ&#xE8;s.</p><div class="capture_footer"><a href="#" onclick="janrain.capture.ui.renderScreen('signIn')" class="capture_btn capture_primary">Se connecter</a></div></div><div style="display:none" id="resetPasswordRequestCode"><div class="capture_header"><h2>Fermer</h2></div><p>Nous n'avons pas reconnu le code de modification de mot de passe. Entrez &#xE0; nouveau votre adresse email pour recevoir un nouveau code</p>{* #resetPasswordForm *} {* signInEmailAddress *}<div class="capture_footer"><input value="Envoyer" type="submit" class="capture_btn capture_primary"/></div>{* /resetPasswordForm *}</div><div style="display:none" id="resetPasswordRequestCodeSuccess"><div class="capture_header"><h2>Cr&#xE9;er un nouveau mot de passe</h2></div><p>Nous vous avons envoy&#xE9; un email avec les instructions pour cr&#xE9;er un nouveau mot de passe. Votre mot de passe actuel n'a pas &#xE9;t&#xE9; chang&#xE9;</p><div class="capture_footer"><a href="#" onclick="janrain.capture.ui.modal.close()" class="capture_btn capture_primary">Fermer</a></div></div>
<div style="display:none" id="editProfileModal"><h2>Modifier votre compte</h2><div class="capture_grid_block"><div class="capture_col_4"><h3>Photo de profil</h3><div class="contentBoxWhiteShadow">{* photoManager *}</div><h3>Comptes li&#xE9;s</h3><div class="contentBoxWhiteShadow">{* linkedAccounts *} {* #linkAccountContainer *}<div class="capture_header"><h2>Liez vos comptes</h2></div><h2>Vous pourrez d&#xE9;sormais vous connecter &#xE0; votre compte via ces identifiants</h2><div class="capture_signin">{* loginWidget *}</div>{* /linkAccountContainer *}</div><h3 class="janrain_traditional_account_only">Mot de passe</h3><div class="janrain_traditional_account_only contentBoxWhiteShadow"><a href="#" data-capturescreen="changePassword">Modifier le mot de passe</a></div><h3 class="janrain_traditional_account_only">D&#xE9;sactiver le compte</h3><div class="capture_deactivate_section contentBoxWhiteShadow clearfix"><a href="#" data-capturescreen="confirmAccountDeactivation">D&#xE9;sactiver le compte</a></div></div><div class="capture_col_8"><h3>Infos sur le compte</h3><div class="contentBoxWhiteShadow"><div class="capture_grid_block"><div class="capture_center_col capture_col_8"><div class="capture_editCol">{* #editProfileModalForm *}<fieldset class="contact-infos"><legend>Vos informations personnelles</legend>{* firstName *} {* lastName *} {* gender *} {* birthdate *} {* displayName *} {* emailAddress *} {* resendLink *} {* phone *} {* addressStreetAddress1 *} {* addressStreetAddress2 *} {* addressCity *} {* addressPostalCode *} {* addressState *} {* addressCountry *}</fieldset><br/><div class="optHidden">{* publicPrivate *} {* journalistContact *} {* aboutMe *} {* usernameTwPublic *} {* preferedContactLanguages *} {* arabicUsername *} {* persianUsername *} {* skypeId *} {* usernameTw *} {* journalistContact *} {* publicPrivate *} {* profession *}</div><fieldset class="newsletters"><legend>Souscrire aux newsletters</legend><div class="optHidden optFr">{* newsMenu *} {* optinalert *} {* optinBestofWeek *} {* optinBestofWEnd *} {* optinBestofObs *}</div><div class="optHidden optEn">{* newsMenuEn *} {* optinalertEn *} {* optinBestofWeekEn *} {* optinBestofWEndEn *} {* optinBestofObsEn *}</div><div class="optHidden optAr">{* newsMenuAr *} {* optinalertAr *} {* optinBestofWeekAr *} {* optinBestofWEndAr *} {* optinBestofObsAr *}</div><div class="optHidden optEs">{* newsMenuEs *} {* optinalertEs *} {* optinbestofweekEs *} {* optinbestofwendEs *}</div><div class="optHidden optCommonMCD">{* optinQuotidienne *} {* optinBreaking *}</div><div class="optHidden optCommonF24">{* optinAutopromo *} {* optinPartenaires *}</div><div class="optHidden optCommonRFI">{* optinActuMonde *} {* optinActuAfrique *} {* optinAlert *} {* optinRfiAfriqueFootFr *} {* optinMfi *} {* optinActuMusique *} {* optinOffreRfi *} {* optinOffrePartenaire *}</div></fieldset><br/><div class="capture_form_item"><input value="Save" type="submit" class="capture_btn capture_primary"/> {* savedProfileMessage *}</div>{* /editProfileModalForm *}</div></div></div></div></div></div></div><div style="display:none" id="changePassword"><div class="capture_header"><h2>Modifier le mot de passe</h2></div>{* #changePasswordForm *} {* currentPassword *} {* newPassword *} {* newPasswordConfirm *}<div class="capture_footer"><input value="Save" type="submit" class="capture_btn capture_primary"/></div>{* /changePasswordForm *}</div><div style="display:none" id="confirmAccountDeactivation"><div class="capture_header"><h2>D&#xE9;sactivez votre compte</h2></div><div class="content_wrapper"><p>Etes-vous s&#xFB;re de vouloir d&#xE9;sactiver votre compte ? Vous n'aurez plus acc&#xE8;s &#xE0; votre profil</p>{* deactivateAccountForm *}<div class="capture_footer"><input value="Yes" type="submit" class="capture_btn capture_primary"/><a href="#" id="capture_confirmAccountDeactivation_noButton" onclick="janrain.capture.ui.modal.close()" class="capture_btn capture_primary">Non</a></div></div>{* /deactivateAccountForm *}</div>
                </div>
                    </div>
        <script type="text/javascript" src="//nexus.ensighten.com/francemm/f24/Bootstrap.js"/><script type="text/javascript"><![CDATA[
//<![CDATA[
(function() {
var _analytics_scr = document.createElement('script');
_analytics_scr.type = 'text/javascript'; _analytics_scr.async = true; _analytics_scr.src = '/_Incapsula_Resource?SWJIYLWA=719d34d31c8e3a6e6fffd425f7e032f3&ns=2&cb=506409422';
var _analytics_elem = document.getElementsByTagName('script')[0]; _analytics_elem.parentNode.insertBefore(_analytics_scr, _analytics_elem);
})();
// ]]></script></body></html>
		""";
	 		DomDocument doc;
	 		doc = new XHtmlDocument.from_string (src);
	 		message (((XDocument) doc).to_string ());
	 		assert (doc.document_element != null);
	 		var c = doc.document_element.get_elements_by_property_value ("property", "article:published_time");
	 		foreach (DomNode n in c) {
	 			message (n.node_name);
	 		}
	 		var collection = doc.get_elements_by_property_value ("property", "article:published_time");
			message (collection.length.to_string ());
			assert (collection.length == 1);
	 		foreach (DomNode n in c) {
	 			message (n.node_name);
	 		}
		 });
        return Test.run ();
	}
}
