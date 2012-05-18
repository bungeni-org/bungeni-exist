$(document).ready(function () {

    $('#startdate').Zebra_DatePicker({
        direction: -1, //past only calendar, the negative integer
        readonly_element: false,
        inside: false
    });
    $('#enddate').Zebra_DatePicker({
        direction: 0, // unrestricted calendar dates
        readonly_element: false,
        inside: false
    });

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
    /* stores locally the literals for toggling compress/expand...
       Useful for i18n labels embedded in jscript files or dynamically
       generated */
    $('body').data('compress',$("#i-compress").html());
    $('body').data('expand',$("#i-expand").html());
    $('body').data('close',$("#popout-close").html());
    
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
    $('.ls-row li > span').click(function () {
 
        var text = $(this).siblings('div.doc-toggle');
 
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
                $(this).parent().siblings("ul").children('li').children('span').html('+');
                            
                $("#expand-all").text("+ "+$("body").data("expand"))
                .stop();            
            }, function(){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideDown('200');
                $(this).parent().siblings("ul").children('li').children('span').html('-');     
   
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
    
    var $adv = $('#adv-search-wrapper');
	$adv.find('.b-left').find('input[name="types"]').bind('click',function(){
	   if(this.checked == false) {
	       $(this).parent().siblings().find(":checkbox").attr('checked',false).attr('disabled',this.checked);
	   }
	   else {
	       $(this).parent().siblings().find(":checkbox").attr('checked',true).attr('disabled',this.checked).attr('disabled',this.checked);
	   }
	});
	
    var select_all = function(id) {
        document.getElementById(id).focus();
        document.getElementById(id).select();
    };
    
	$('#startdate, #enddate').click(function() {
        $(this).focus();
        $(this).select();		
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
        defaultView: 'basicWeek',
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
                            title: data.ontology[i].legislature.shortName["#text"]+" at the "+data.ontology[i].groupsitting.venue.shortName["#text"],
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
	
	
	/* QTIPS */
    // Create the tooltips only on document load
    // Use the each() method to gain access to each elements attributes
    $('.has-popout a[rel]').each(function()
    {
      $(this).qtip(
      {
         content: {
            // Set the text to an image HTML string with the correct src URL to the loading image you want to use
            text: '<img class="throbber" src="../assets/bungeni/images/throbber.gif" alt="Loading..." />',
            url: $(this).attr('href'), // Use the rel attribute of each element for the url to load
            title: {
               text: '<h1 id="doc-title-red-left">' + $(this).text() + '</h1>', // Give the tooltip a title using each elements text
               button: $("body").data("close") // Show a close link in the title
            }
         },
         position: {
            corner: {
               target: 'bottomMiddle', // Position the tooltip above the link
               tooltip: 'topMiddle'
            },
            adjust: {
               screen: true // Keep the tooltip on-screen at all times
            }
         },
         show: { 
            when: 'click', 
            solo: true // Only show one tooltip at a time
         },
         hide: 'unfocus',
         style: {
            tip: true, // Apply a speech bubble tip to the tooltip at the designated tooltip corner
            border: {
               width: 0,
               radius: 4
            },
            name: 'light', // Use the default light style
            width: 720 // Set the tooltip width
         }
      })
    });
});   

