// Courtesy to main author Martin Schmelzer schmelzer.martin@gmx.de
// Modified by Javad Razavian javadr@gmail.com

$chks = $('div.qa-part-q-view, div.qa-part-a-list, div#question, div#answers, div.qist-data');

// The following lines highlight what elements got selected
$chks.on('mouseover', 'pre, span > code, p > code, li > code', function() {
	$border = $(this).css("border");
		$(this).css('border', 'solid');
});
$chks.on('mouseout', 'pre, span > code, p > code, li > code', function() {
	$(this).css('border', $border);
});

// Main part which copies the text to the clipboard
$chks.on('dblclick', 'pre, span > code, p > code, li > code', function() {
	var $flash = $(this);
	var $code = ($(this).is('pre')) ? ($(this).children('code')) : ($(this));

	var $temp = $("<textarea>").appendTo("body");
	$temp.val($code.text()).select();
	if(document.execCommand("copy")) {
		$flash.addClass("soctoc");
		setTimeout(function () {
			$flash.removeClass("soctoc");
		}, 410);
	};
	$temp.remove();
});
