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
});