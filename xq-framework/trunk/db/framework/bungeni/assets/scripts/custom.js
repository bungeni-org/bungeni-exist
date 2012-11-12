$(document).ready(function () {

    $('#startdate').Zebra_DatePicker({
        always_show_clear: true,
        direction: -1, //past only calendar, the negative integer
        readonly_element: false,
        inside: false
    });
    $('#enddate').Zebra_DatePicker({
        always_show_clear: true,
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
    $('body').data('close',$("#popout-close").html()); //!+FIX_THIS (ao, 10Jul2012, not in use due to issues with Bungeni, see popout.xsl 
    //Whatson page
    $('body').data('start',$("#range-start").html());
    $('body').data('end',$("#range-end").html());
    
    /*** TOGGLE FEATURES **/
    
    /** toggling doc items per item isolated not in <li>**/  
    $('.blocks div span.tgl').click(function () {
 
        var text = $(this).parent('div').siblings('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span.tgl').html('&#9660;&#160;');     
        } else {
            text.slideUp('200');
            $(this).closest('span.tgl').html('&#9658;&#160;');     
        }
         
    });     
    
    /** toggling doc items per item isolated **/  
    $('.ls-row li > span').click(function () {
 
        var text = $(this).siblings('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span').html('&#9660;&#160;');     
        } else {
            text.slideUp('200');
            $(this).closest('span').html('&#9658;&#160;');     
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
            $(this).siblings('span').html('&#9660;');              
        }                
         
    });    
    
    /** toggling doc items per item within div **/  
    $('.ls-row div span.tgl').click(function () {
 
        var text = $(this).parent('div').siblings('div.doc-toggle');
 
        if (text.is(':hidden')) {
            text.slideDown('200');
            $(this).closest('span.tgl').html('&#9660;&#160;');     
        } else {
            text.slideUp('200');
            $(this).closest('span.tgl').html('&#9658;&#160;');     
        }
         
    });    
    
    /** toggling all doc item within div **/  
    $('#list-toggle-ctrl2 li a').click(function () {
    
        if($(this).attr('id') == "txt-expand")
        {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideDown('200');
            $(this).closest('span.tgl').html('&#9660;&#160;');     
        }
        else {
            var text = $('.ls-row').find('li div.doc-toggle');
            text.slideUp('200');
            $(this).closest('span.tgl').html('&#9658;&#160;');     
        }                
         
    }); 
    
    /*new toggler*/
    $(function() {
            $("#expand-all").toggle(function (){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideUp('200');
                $(this).parent().siblings("ul").children('li').children('span').html('&#9658;&#160;');
                            
                $("#expand-all").html("&#9658; "+$("body").data("expand")).stop();            
            }, function(){
                var text = $('.ls-row').find('li div.doc-toggle');
                text.slideDown('200');
                $(this).parent().siblings("ul").children('li').children('span').html('&#9660;&#160;');     
   
                $("#expand-all").html("&#9660; "+$("body").data("compress")).stop();
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
	$("ul.tabbernav li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content

	//On Click Event
	$("ul.tabbernav li").click(function() {

		$("ul.tabbernav li").removeClass("active"); //Remove any "active" class
		$(this).addClass("active"); //Add "active" class to selected tab
		$(".tab_content").hide(); //Hide all tab content

		var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active ID content
		return false;
	});               
    */
	
	/* QTIPS */
    // Create the tooltips only on document load
    // Use the each() method to gain access to each elements attributes
    $('.has-popout a[rel]').each(function()
    {
      $(this).qtip(
      {
         content: {
            // Set the text to an image HTML string with the correct src URL to the loading image you want to use
            text: '<img class="throbber" src="assets/images/throbber.gif" alt="Loading..." />',
            url: $(this).attr('href'), // Use the href attribute of each element for the url to load
            title: {
               text: '<h1 class="title">' + $(this).text() + '</h1>', // Give the tooltip a title using each elements text
               button: $("body").data("close") // Show a close link in the title !+NOTES see 'close above 
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
    
    var fullDate = new Date();
    var twoDigitMonth = ((fullDate.getMonth().length+1) === 1)? (fullDate.getMonth()+1) : '0' + (fullDate.getMonth()+1);
    var currentDate = fullDate.getFullYear() + "/" + twoDigitMonth + "-" + fullDate.getDate();
    
    /* Whatson calendar */
    $('#range-cal').DatePicker({
    	flat: true,
    	date: [$("body").data("start"), $("body").data("end")],
    	current: $("body").data("start"),
    	calendars: 1,
    	mode: 'range',
    	onRender: function(date) {
    		return {
    			disabled: (date.valueOf() < currentDate),
    			className: date.valueOf() == currentDate ? 'datepickerSpecial' : false
    		}
    	},    	
    	starts: 1   	
    });    
    
    // DHTMLX
    doOnLoad();    
});   

function toggleAndChangeText(toggleId, togglerId, togglerText) {
     if ($('#'+toggleId+'').css('display') == 'none') {
          $('#'+togglerId+'').html('&#9660 '+$('#'+togglerText+'collapse').html());
     } else {
          $('#'+togglerId+'').html('&#9658 '+$('#'+togglerText+'expand').html());
     }
     $('#'+toggleId+'').toggle({"blind":200});     
}

function toggleOnly(toggleId, togglerId, togglerText) {
     if ($('#'+toggleId+'').css('display') == 'none') {
          $('#'+togglerId+'').html('&#9660 '+togglerText);
     } else {    
          $('#'+togglerId+'').html('&#9658 '+togglerText);
     }
     $('#'+toggleId+'').toggle({"blind":200});     
}

function toggleAndChangeFullText(toggleId, togglerId, togglerText) {
     if ($('#'+toggleId+'').css('display') == 'none') {
          $('#'+togglerId+'').html('&#9660 '+$('#'+togglerText).html());
     } else {
          $('#'+togglerId+'').html('&#9658 '+$('#'+togglerText).html());
     }
     $('#'+toggleId+'').toggle({"blind":200});     
}

function getParameterByName(name)
{
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.href);
  if(results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

/*
 * DHTMLX
 */
var prev = null;
var curr = null;
var next = null;

function doOnLoad() {
    // To only load when on the calendar page
    if (document.getElementById("doc-calendar-holder")) {
        scheduler.config.readonly = true;
    	scheduler.config.multi_day = true;
    	scheduler.config.xml_date="%Y-%m-%d %H:%i";
    	
    	scheduler.init('scheduler_here',new Date(),"week");
    	scheduler.load("get-sittings-xml");
    	scheduler.setCurrentView(scheduler._date, scheduler._mode);
    }
}

