// Semicolon (;) to ensure closing of earlier scripting
// Encapsulation
// $ is assigned to jQuery
;(function($) {
     // DOM Ready
    $(function() {
    
        /*$("#submit-btn").click(function() {
            $('#store_config').submit();
            alert("Handler for .click() called.");
        });
        
        $('#store_config').submit(function() {
          alert('Handler for .submit() called.');
          //return false;
        });  */
    
        // Binding a click event
        // From jQuery v.1.7.0 use .on() instead of .bind()
        /*$('#show-popup').on('click', function(e) {
            // Prevents the default action to be triggered. 
            e.preventDefault();

            // Triggering bPopup when click event is fired
            $('#popup').bPopup({
                modalClose: true,
                opacity: 0.2,
                positionStyle: 'fixed' //'fixed' or 'absolute'
            });  
        });*/
    });
})(jQuery);

$(document).ready(function(){
    if(window.location.hash) {
        //get the index from URL hash
        tabSelect = document.location.hash.substr(1,document.location.hash.length);
        $('#tabs li#tabfields').trigger('click');
    }

    //  When user clicks on tab, this code will be executed
    $("#tabs li").click(function() {
        //  First remove class "active" from currently active tab
        $("#tabs li").removeClass('active');
 
        //  Now add class "active" to the selected/clicked tab
        $(this).addClass("active");
 
        //  Hide all tab content
        $(".tab_content").hide();
 
        //  Here we get the href value of the selected tab
        var selected_tab = $(this).find("a").attr("href");
 
        //  Show the selected tab content
        $(selected_tab).fadeIn();
 
        //  At the end, we add return false so that the click on the link is not executed
        return false;
    });
    
    $("table.listingTable tbody tr:first .up,table.listingTable tbody tr:last .down").hide();
    $(".up, .down").click(function(){
        var row = $(this).parents("tr:first");
        var href = $(this).attr('href');
        if ($(this).is(".up")) {
            $("table.listingTable tbody tr:first .up").show();
            $.get(href,function(data,status) {
                if (status == "success")
                    row.insertBefore(row.prev());
                    row.find(".down").show();
                    $("table.listingTable tbody tr:first .up,table.listingTable tbody tr:last .down").hide();
            });        
            
        } else {        
            $.get(href,function(data,status){             
                if (status == "success") {                
                    row.insertAfter(row.next());   
                    row.find(".up").show();
                    $("table.listingTable tbody tr:first .up,table.listingTable tbody tr:last .down").hide();
                }
            });
        }
        return false;
    });  
    
    $(".delete").click(function() {
        var row = $(this).parents("tr:first");
        var href = $(this).attr('href');

        if ($(this).is(".delete")) {   
            if (confirm('Are you sure to delete this field?')) {
                $.ajax({
                    type: "DELETE",
                    url: href,
                    data: "nothing",
                    success: function(data){
                        $(row).remove();
                    }
                });        
            }        
        }
        return false;
        
    });     
    
    /*$(".nodeMove a").click (function () {
      $.ajax({
        type: "POST", // or GET
        url: $(this).getAttr('href'),
        data: "nothing",
        success: function(data){
         $("#someElement").doSomething().
        }
      });
      return false; // stop the browser following the link
    }; */   
});