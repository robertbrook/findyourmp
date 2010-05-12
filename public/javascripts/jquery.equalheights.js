/***
@exampleJS:
$('#jquery-equal-height-example p').equalHeight();
$('#content, #secondary-content').equalHeight();
***/
jQuery.fn.equalHeight = function(options){
	var height = 0;
	var maxHeight = 0;

	// Store the tallest element's height
	this.each(function (){
		height = jQuery(this).outerHeight();
		maxHeight = (height > maxHeight) ? height : maxHeight;
	});

	//set element's min-height to tallest element's height
	return this.each(function (){
		var t = jQuery(this);
		var innerHeight = t.innerHeight();
		var outerHeight = t.outerHeight();
		var notHeight = outerHeight - innerHeight;
		var minHeight = maxHeight - notHeight;
		var property = jQuery.browser.msie && jQuery.browser.version < 7 ? 'height' : 'min-height';

		t.css(property, minHeight + 'px');
		
		if(options.objectToAppend != undefined){
			options.objectToAppend.css(property,(minHeight+options.height) + 'px');
		}
	});
};