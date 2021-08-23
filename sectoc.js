// Courtesy to main author Martin Schmelzer schmelzer.martin@gmx.de
// Modified by Javad Razavian javadr@gmail.com

$chks = $('div.qa-part-q-view, div.qa-part-a-list');

// The following lines are there to debug what elements got selected
//$chks.on('mouseover', 'pre, span > code, p > code', function() {
// 	$(this).css('background-color', '#FF0000');
//});

$chks.on('dblclick', 'pre, span > code, p > code', function() {
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
