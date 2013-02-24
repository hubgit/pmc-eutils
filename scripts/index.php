<?php

// curl -XPUT 'http://localhost:9200/pmc-eutils'
// curl -XDELETE http://localhost:9200/pmc-eutils/articles

$curl = curl_init();

curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'PUT');
curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json; charset=UTF-8'));
//curl_setopt($curl, CURLOPT_VERBOSE, true);

$xsl = new DOMDocument;
$xsl->load('transform.xsl');

$processor = new XSLTProcessor;
$processor->importStylesheet($xsl);

foreach (glob(__DIR__ . '/../data/*.xml') as $file) {
	print "Indexing $file\n";

	$input = new DOMDocument;
	$input->load($file);

	$doc = $processor->transformToDoc($input); // TODO: transform to JSON?
	$articles = json_decode(json_encode(simplexml_import_dom($doc)));

	foreach ($articles->article as $article) {
		fix_arrays($article);

		curl_setopt($curl, CURLOPT_URL, 'http://localhost:9200/pmc-eutils/articles/' . $article->id);
		curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($article));

		$result = curl_exec($curl);
		$code = curl_getinfo($curl, CURLINFO_HTTP_CODE);

		if (201 !== $code && 200 !== $code) {
			print "\nUnexpected code in {$article->id}: $code\n";
			print "\t$result\n";
			print json_encode($article) . "\n";
			//exit();
		}
	}
}

// make sure possibly multiple items are arrays
function fix_arrays($article) {
	if (isset($article->link)) {
		$article->link = (array) $article->link;
	}

	if (isset($article->author)) {
		$article->author = (array) $article->author;

		foreach ($article->author as $author) {
			if (isset($author->affiliation)) {
				$author->affiliation = (array) $author->affiliation;
			}
		}
	}
}
