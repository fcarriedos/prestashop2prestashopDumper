#!/bin/bash

IVA="1.21"

imageSet=""
title=""
heading=""
publicPrice=""
longDescription=""
category=""
reference=""
tags=""
shortURL=""


function resetVariables {
	imageSet=""
	title=""
	heading=""
	publicPrice=""
	longDescription=""
	category=""
	reference=""
	tags=""
	shortURL=""
}


# Save the images
#function downloadImage {
#	echo "Downloading image: $1"
#}


function extractImages {
	images=`cat $1 | grep "class=\"thumbnail fancybox" | cut -f2 -d"=" | cut -f1 -d" "`
	while read -r i
	do
		URL=`echo $i | sed "s/\"//g"`
		# echo "Adding $URL"
		imageSet="$imageSet,$URL"
		# echo "Added $images"
	done <<< "$images"
	imageSet=`echo $imageSet | sed 's/^.//'`
}


function saveTitle {
	title=`cat $1 | grep "productname" | cut -f2 -d">" | cut -f1 -d"<"`
	#echo "Title is $title"
	title="$title"
}


function saveHeading {
	heading=`cat $1 | grep "product_description" | sed "s/<p>//g" | sed "s/<\/p>//g" | cut -f2 -d">" | cut -f1 -d"<"`
	echo "Heading recien extraido: $heading"
}


function savePublicPrice {
	# echo "Public price initially: $publicPrice"
	publicPrice=`cat $1 | grep "itemprop=\"price\"" | cut -f4 -d">" | cut -f1 -d"<" | sed "s/,/\./g" | sed "s/€//g" | sed "s/ //g"`
	if [ -z "$publicPrice" ]; then
		publicPrice=`cat $1 | grep "itemprop=\"price\"" | cut -f3 -d">" | cut -f1 -d"<" | sed "s/,/\./g" | sed "s/€//g" | sed "s/ //g"`
	fi
	echo "Public price is $publicPrice/$IVA"
	publicPrice=`echo "scale=2; $publicPrice/$IVA" | bc -l`
}


function saveLongDescription {
	longDescription=`node longDescriptionExtractor.js $1`
	#echo "Long description is $longDescription"
	longDescription="$longDescription"
}


function saveTags {
	# $1 is the title var as param
	echo "Working with tags $1"
	tags=`echo -n $1 | tr '[:upper:]' '[:lower:]' | sed "s/ /,/g"`
}


function ensureEscapedQuotes {
	title=`echo -n $title | sed "s/&quot;/\"/g" | sed "s/&Prime;/\"/g" | sed "s/&nbsp;/\"/g" | sed "s/&ordm;/\"/g" | sed "s/&rdquo;/\"/g" | sed "s/&ldquo;/\"/g" | sed "s/\"/\"\"/g" | sed "s/”/\"\"/g"`
	heading=`echo -n $heading | sed "s/&quot;/\"/g" | sed "s/&Prime;/\"/g" | sed "s/&nbsp;/\"/g" | sed "s/&ordm;/\"/g" | sed "s/&rdquo;/\"/g" | sed "s/&ldquo;/\"/g" | sed "s/\"/\"\"/g"`
	longDescription=`echo -n $longDescription | sed "s/&quot;/\"/g" | sed "s/&Prime;/\"/g" | sed "s/&nbsp;/\"/g" | sed "s/&ordm;/\"/g" | sed "s/&rdquo;/\"/g" | sed "s/&ldquo;/\"/g" | sed "s/\"/\"\"/g" | sed "s/”/\"\"/g"`
	reference=`echo -n $reference | sed "s/&quot;/\"/g" | sed "s/&Prime;/\"/g" | sed "s/&nbsp;/\"/g" | sed "s/&ordm;/\"/g" | sed "s/&rdquo;/\"/g" | sed "s/&ldquo;/\"/g" | sed "s/\"/\"\"/g" | sed "s/”/\"\"/g"`
	tags=`echo -n $tags | sed "s/&quot;/\"/g" | sed "s/&Prime;/\"/g" | sed "s/&nbsp;/\"/g" | sed "s/&ordm;/\"/g" | sed "s/&rdquo;/\"/g" | sed "s/&ldquo;/\"/g" | sed "s/\"/\"\"/g" | sed "s/”/\"\"/g"`
}


function ensureOneLine {
	title=`echo -n $title | sed "s/\n//g"`
	heading=`echo -n $heading | sed "s/\n//g"`
	longDescription=`echo -n $longDescription | sed "s/\n//g"`
	reference=`echo -n $reference | sed "s/\n//g"`
	tags=`echo -n $tags | sed "s/\n//g"`
}


function removeHTMLEntities {
	# &iacute
	title=`echo -n $title | sed "s/&aacute;/á/g" | sed "s/&eacute;/é/g" | sed "s/&iacute;/í/g" | sed "s/&oacute;/ó/g" | sed "s/&uacute;/ú/g" | sed "s/&ntilde;/ñ/g"`
	heading=`echo -n $heading | sed "s/&aacute;/á/g" | sed "s/&eacute;/é/g" | sed "s/&iacute;/í/g" | sed "s/&oacute;/ó/g" | sed "s/&uacute;/ú/g" | sed "s/&ntilde;/ñ/g"`
	longDescription=`echo -n $longDescription | sed "s/&aacute;/á/g" | sed "s/&eacute;/é/g" | sed "s/&iacute;/í/g" | sed "s/&oacute;/ó/g" | sed "s/&uacute;/ú/g" | sed "s/&ntilde;/ñ/g"`
	reference=`echo -n $reference | sed "s/&aacute;/á/g" | sed "s/&eacute;/é/g" | sed "s/&iacute;/í/g" | sed "s/&oacute;/ó/g" | sed "s/&uacute;/ú/g" | sed "s/&ntilde;/ñ/g"`
	tags=`echo -n $tags | sed "s/&aacute;/á/g" | sed "s/&eacute;/é/g" | sed "s/&iacute;/í/g" | sed "s/&oacute;/ó/g" | sed "s/&uacute;/ú/g" | sed "s/&ntilde;/ñ/g"`
}


function extractBike {
	resetVariables
	category=`echo $1 | cut -f3 -d"/"`
	reference=`echo $1 | cut -f4 -d"/" | sed "s/\.html//g" | cut -c 1-32`
	extractImages $1
	saveTitle $1
	saveHeading $1
	savePublicPrice $1
	saveLongDescription $1
	ensureEscapedQuotes
	ensureOneLine
	removeHTMLEntities
	shortURL="$reference"
	saveTags "$title"
	echo ""
	echo "****************************************************************************************************************************************"
	echo "Heading: $heading"
	echo "Images: $imageSet"
	echo "Title: $title"
	echo "Price: $publicPrice"
	echo "Description: $longDescription"
	echo "Category: $category"
	echo "Reference: $reference"
	echo "ShortURL: $shortURL"
	prepareInputLine $1 $2 $3
}


function prepareInputLine {
	if [ $2 -eq 1 ]
	then
#Product ID;	Active (0/1);	Name *;				Categories (x,y,z...);	Price tax excluded or Price tax included;	Tax rules ID;	Wholesale price;	On sale (0/1);	Discount amount;	Discount percent;	Discount from (yyyy-mm-dd);	Discount to (yyyy-mm-dd);	Reference #;	Supplier reference #;	Supplier;	Manufacturer;	EAN13;		UPC;	Ecotax;		Width;	Height;		Depth;		Weight;		Quantity;	Minimal quantity;	Visibility;	Additional shipping cost;	Unity;	Unit price;	Short description;	Description;		Tags (x,y,z...);	Meta title;		Meta keywords;		Meta description;	URL rewritten;	Text when in stock;	Text when backorder allowed;		Disponible for order (0 = No, 1 = Yes);		Product available date;		Product creation date;	Show price (0 = No, 1 = Yes);	Image URLs (x,y,z...);				Delete existing imageSet (0 = No, 1 = Yes);	Feature(Name:Value:Position);	Available online only (0 = No, 1 = Yes);Condition;	Customizable (0 = No, 1 = Yes);	Uploadable files (0 = No, 1 = Yes);	Text fields (0 = No, 1 = Yes);	Out of stock;	ID / Name of shop;	Advanced stock management;	Depends On Stock;	Warehouse
		echo "Product ID;	Active (0/1);	Name *;				Categories (x,y,z...);	Price tax excluded or Price tax included;	Tax rules ID;	Wholesale price;	On sale (0/1);	Discount amount;	Discount percent;	Discount from (yyyy-mm-dd);		Discount to (yyyy-mm-dd);	Reference #;	Supplier reference #;	Supplier;	Manufacturer;	EAN13;			UPC;	Ecotax;		Width;	Height;		Depth;		Weight;		Quantity;	Minimal quantity;	Visibility;	Additional shipping cost;	Unity;	Unit price;	Short description;	Description;		Tags (x,y,z...);	Meta title;		Meta keywords;		Meta description;	URL rewritten;	Text when in stock;		Text when backorder allowed;			Available for order (0 = No, 1 = Yes);		Product available date;		Product creation date;	Show price (0 = No, 1 = Yes);	Image URLs (x,y,z...);				Delete existing imageSet (0 = No, 1 = Yes);	Feature(Name:Value:Position);	Available online only (0 = No, 1 = Yes);	Condition;	Customizable (0 = No, 1 = Yes);	Uploadable files (0 = No, 1 = Yes);	Text fields (0 = No, 1 = Yes);	Out of stock;	ID / Name of shop;	Advanced stock management;	Depends On Stock;	Warehouse" | sed "s/\t//g" > $3
	fi

	echo "Heading right before: $heading"

	heading=`echo $heading | tr -d '\r'`

		 #2;1;BICICLETA CLEAN K1 (HOPE/HOPE);		Bicicletas;				2171.71;												1;				2749;				1;				;					0.0;				2013-06-01;						2018-12-31;					RP-demo_1;		RF-demo_1;				Abel;		Clean;			1234567890123;	;		1;			0.6;	0.2;		0.4;		6.668357;	20;			1;					;			;							;		;			Bicicleta Clean...;	Cada...;			clean,k1;		Meta title-K1;		Meta keywords-K1;	Meta description-K1;	clean-k1;	In Stock;				Current supply. Ordering availlable;	1;											2013-03-01;					2013-01-01;				1;								https://;							0;											;								0;											new;		0;								0;									0;								0;				0;					0;							0;					0
	echo "$2;1;$title;								bikes; 			$publicPrice;											1;				$publicPrice;		1;				;					0.0;				2019-01-01;						2019-01-01;					$reference;		RF-demo-1;				Abel;		Clean;			1234567890123;	;		1;			0.6;	0.2;		0.4;		6.668357;	10;			1;					;			;							;		;			$heading;			$longDescription;	$tags;			$tags;				$tags;				$title;					;			Available;				Available now;							1;											2019-01-01;					2019-01-01;				1;								$imageSet;							0;											;								0;											new;		0;								0;									0;								0;				0;					0;							0;					0;" | sed "s/\t//g" >> $3
}


echo "Invoked with: $*"
extractBike $1 $2 $3



