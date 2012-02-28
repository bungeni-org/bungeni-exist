$(document).ready(function () {
    /* query-params-set */
    $.urlParam = function(name){
        var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results[1].split("+").join(" ") || 0;
    } 
    if(window.location.search) { 
        if(window.location.search.search("scope") !== -1) {
            if($.urlParam('scope'))
                $("#global-search").val($.urlParam('q'));
        }
    }
    /* stores locally the literals for toggling compress/expand... */
    $('body').data('compress',$("#i-compress").html());
    $('body').data('expand',$("#i-expand").html());
    
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
    $('.toggler-list').click(function () {
    
        if($(this).attr('id') == "expand-all")
        {      
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideUp('200');
            $(this).siblings('span').html('+');    
        }
        else {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideDown('200');
            $(this).siblings('span').html('-');              
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
                text.slideUp('200');
                $(this).parent().parent().find('span').html('+');
                            
                $("#expand-all").text("+ "+$("body").data("expand"))
                .stop();            
            }, function(){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideDown('200');
                $(this).parent().parent().find('span').html('-');     
   
                $("#expand-all").text("- "+$("body").data("compress"))
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


    /**
    * The hidden search box
    */
    
	/**
	* the element
	*/
	var $ui = $('#ui_search');

	/**
	* selecting all checkboxes and also ensure atleast a checkbox is checked (pun intented)
	*/
	$ui.find('.sb_dropdown').find('label[for="all"]').prev().bind('click',function(){
	   if(this.checked == false)
	       $(this).parent().siblings().find(':checkbox').attr('checked',true).attr('disabled',this.checked);
	   else
	       $(this).parent().siblings().find(':checkbox').attr('checked',this.checked).attr('disabled',this.checked);
	});		
	
	/*
	* If any other checkbox is checked (pun), then make sure its siblings aren't... !+UNCOMMENT_TO_ENABLE
	*/
	/*
	$ui.find('.sb_dropdown').find('label[for!="all"]').prev().bind('click',function(){
		$(this).parent().siblings().find(':checkbox').attr('checked',false);
	});
	*/	

    $(".dropdown dt a").click(function() {
        $(".dropdown dd ul").toggle();
    });
                
    $(".dropdown dd ul li a").click(function() {
        var text = $(this).html();
        $(".dropdown dt a span").html(text);
        $(".dropdown dd ul").hide();
    });
                
    function getSelectedValue(id) {
        return $("#" + id).find("dt a span.value").html();
    }

    $(document).bind('click', function(e) {
        var $clicked = $(e.target);
        if (! $clicked.parents().hasClass("dropdown"))
            $(".dropdown dd ul").hide();
    });
    
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
    
    /* CALENDAR */
	var date = new Date();
	var d = date.getDate();
	var m = date.getMonth();
	var y = date.getFullYear();
	
	$('#calendar').fullCalendar({
		header: {
			left: 'prev,next today',
			center: 'title',
			right: 'agendaDay,basicWeek,month'
		},
        defaultView: 'month',
		editable: true,
		disableDragging: true,
        events: function(start, end, callback) {
            $.ajax({
                url: 'get-sittings-json',
                dataType: 'json',
                data: {
                    uri: "all",
                    // our hypothetical feed requires UNIX timestamps
                    start: Math.round(start.getTime() / 1000),
                    end: Math.round(end.getTime() / 1000)
                },
                success: function(data) {
                    var events = [];
                    for (var i = 0; i < data.ontology.length; i++) {
                        events.push({
                            title: data.ontology[i].legislature.shortName+" at the "+data.ontology[i].groupsitting.venue.shortName,
                            start: data.ontology[i].groupsitting.startDate["#text"],
                            end: data.ontology[i].groupsitting.endDate["#text"],
                            url: "sitting?uri="+data.ontology[i].groupsitting.uri,
                            allDay: false
                        });                       
                    }                   
                    callback(events);
                }
            });
        }		
		/*events: $('#events_json').data('locations')
		events: [
			{
				title: 'Meeting',
				start: 'Thu Feb 23 2012 10:08:01 GMT+0300 (EAT)',
				allDay: false
			},
			{
				title: 'Lunch',
				start: 'Thu Feb 23 2012 12:00 GMT+0300 (EAT)',
				end: 'Thu Feb 23 2012 16:00 GMT+0300 (EAT)',
				allDay: false
			}
			]*/
	}); 
	console.log("Looks Good! "+Date());
	
});   

