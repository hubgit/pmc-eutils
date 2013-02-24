<?php

$params = array(
	'db' => 'pmc',
	'retmode' => 'xml',
	'term' => 'all[SB]',
	'retstart' => 0,
	'retmax' => 0,
	'usehistory' => 'y',
);

$url = 'http://eutils.be-md.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?' . http_build_query($params);
print "$url\n";

$dom = new DOMDocument;
$dom->load($url);

$result = array(
	'count' => $dom->getElementsByTagName('Count')->item(0)->textContent,
	'webenv' => $dom->getElementsByTagName('WebEnv')->item(0)->textContent,
	'querykey' => $dom->getElementsByTagName('QueryKey')->item(0)->textContent,
);

$file = sprintf('../data/result-%d.json', time());
file_put_contents($file, json_encode($result));

print_r($result);
print "Saved to $file\n";
