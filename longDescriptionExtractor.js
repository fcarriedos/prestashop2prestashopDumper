const cheerio = require('cheerio');

const fs = require('fs');
const file = fs.readFileSync(process.argv[2], "utf8");
const $ = cheerio.load(file);


var longDescriptionElement = $('#product_description').toArray()[1];
var longDescriptionParagraphs = $(longDescriptionElement).children().toArray();

var descriptionAsText = '';
for (paragraph of longDescriptionParagraphs) {
	descriptionAsText += $(paragraph).text() + ' ';
	//console.log('Description paragraph: ' + $(paragraph).text());
}

console.log(descriptionAsText);

