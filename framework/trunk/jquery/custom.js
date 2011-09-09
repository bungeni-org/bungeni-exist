/*** custom jquery overrides ***/
function movePreamble(){
	var preamble = $('.preamble');
	var scrollTop = $(window).scrollTop();
	var bottomOfPreface = $('.preface').height() + $('.preface').offset().top;
	var moveTo = scrollTop - bottomOfPreface;
	if(moveTo < 0) moveTo = 0;
	preamble.stop().animate({'marginTop': moveTo + 'px'});
}

jQuery(document).ready(function($){
	movePreamble();
	// store the initial height 
	$(window).scroll(function(){
		movePreamble();
	});
});
