// Courtesy to main author Martin Schmelzer schmelzer.martin@gmx.de
// Modified by Javad Razavian javadr@gmail.com

const $chks = $('div.qa-part-q-view, div.qa-part-a-list, div#question, div#answers, div.qist-data');

// The following lines highlight what elements got selected
$chks.on('mouseenter', 'pre, span > code, p > code, li > code', function() {
	$(this).addClass('parsilatex-code-save-hover');
});
$chks.on('mouseleave', 'pre, span > code, p > code, li > code', function() {
	$(this).removeClass('parsilatex-code-save-hover');
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
