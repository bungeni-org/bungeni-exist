

$(document).ready(function () {
    /*** TOGGLE FEATURES **/
    
    /** toggling doc items per item isolated not in <li>**/  
    $('.blocks div span.tgl').click(function () {
 
        var text = $(this).parent('div').siblings('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span.tgl').html('-');     
        } else {
            text.slideUp('200');
            $(this).closest('span.tgl').html('+');     
        }
         
    });     
    
    /** toggling doc items per item isolated **/  
    $('.ls-row span').click(function () {
 
        var text = $(this).next('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span').html('-');     
        } else {
            text.slideUp('200');
            $(this).closest('span').html('+');     
        }
         
    });
    
    /** toggling all doc item **/  
    $('#list-toggle-ctrl li a').click(function () {
    
        if($(this).attr('id') == "txt-expand")
        {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideDown('200');
            $(this).siblings('span').html('-');     
        }
        else {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideUp('200');
            $(this).siblings('span').html('+');     
        }                
         
    });    
    
    /** toggling doc items per item within div **/  
    $('.ls-row div span.tgl').click(function () {
 
        var text = $(this).parent('div').siblings('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span.tgl').html('-');     
        } else {
            text.slideUp('200');
            $(this).closest('span.tgl').html('+');     
        }
         
    });    
    
    /** toggling all doc item within div **/  
    $('#list-toggle-ctrl2 li a').click(function () {
    
        if($(this).attr('id') == "txt-expand")
        {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideDown('200');
            $(this).closest('span.tgl').html('-');     
        }
        else {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideUp('200');
            $(this).closest('span.tgl').html('+');     
        }                
         
    }); 
    
    /*new toggler*/
    $(function() {
            $("#expand-all").toggle(function (){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideDown('200');
                $(this).parent().parent().find('span').html('-');     
   
                $("#expand-all").text("- compress all")
                .stop();
            }, function(){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideUp('200');
                $(this).parent().parent().find('span').html('+');
                            
                $("#expand-all").text("+ expand all")
                .stop();
            });
        });    
    
    
    /**
        !+SORT_ORDER (ah, nov-2011)
        Set the sort selector list to the correct option 
        based on the sort parameter int the request
    **/
    
    if ($('#sort_by').length != 0 ) {
        sort_by = getParameterByName("s");
        if (sort_by == "") {
            sort_by = "st_date_newest";
        }
        select_sort_by  = $("#sort_by").val();
        if (select_sort_by != sort_by) {
            $("#sort_by").val(sort_by);
        }
    }


    
    /*
	$(".tab_content").hide(); //Hide all content
	$("ul.ls-doc-tabs li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content

	//On Click Event
	$("ul.ls-doc-tabs li").click(function() {

		$("ul.ls-doc-tabs li").removeClass("active"); //Remove any "active" class
		$(this).addClass("active"); //Add "active" class to selected tab
		$(".tab_content").hide(); //Hide all tab content

		var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active ID content
		return false;
	});               
    */
});   

