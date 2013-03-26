$(document).ready(function(){

    if(window.location.hash) {
        //get the index from URL hash
        tabSelect = document.location.hash.substr(1,document.location.hash.length);
        // timeout because of http://stackoverflow.com/questions/2060019/how-to-trigger-click-on-page-load
        setTimeout(function() {
            $("#tabs li#"+tabSelect).trigger('click');
        },10);        
        
    }
    
    // Adding confirmation dialog for Saving configuration back to File-System
    $("a.confirm-delete").click(function() {
        return confirm('This action overwrites your custom configuration for bungeni, proceed?');
    });    
    
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
    
    // moving nodes up and down (reordering)
    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
    $(".up, .down").click(function(){
        var row = $(this).parents("li:first");
        var href = $(this).attr('href');
        if ($(this).is(".up")) {
            $("ul.ulfields li:first .up").show();
            $.get(href,function(data,status) {
                if (status == "success")
                    row.insertBefore(row.prev());
                    row.find(".down").show();
                    $("ul.ulfields li:first .up, ul.ulfields li:last .down").hide();
            });        
            
        } else {        
            $.get(href,function(data,status){             
                if (status == "success") {                
                    row.insertAfter(row.next());   
                    row.find(".up").show();
                    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
                }
            });
        }
        return false;
    });  
    
    // deleting a node
    $(".delete").live('click', function() {
        var href = $(this).attr('href');
        var li = $(this).closest('li');          

        if ($(this).is(".delete")) {   
            if (confirm('Are you sure to perform this delete?\r\n It is non-reversible')) {
                $.ajax({
                    type: "DELETE",
                    url: href,
                    data: "nothing",
                    success: function(data) {                      
                        li.fadeOut('slow', function() { li.remove(); });
                    }
                });        
            }        
        }  
        
        return false;
        
    });  
    
    // commit
    $(".commit").live('click', function() {
        var href = $(this).attr('href');
        
        $.ajax({
            type: "GET",
            url: href,
            dataType: "html",
            success: function(data) {
                // message|warning|error|fatal - increasing order of severity
                if(data = 'true') {
                    require(["dojox/widget/Toaster", "dijit/registry", "dojo/parser", "dojo/on", "dojo/dom", "dojo/domReady!"],
                        function(Toaster, registry, parser, on, dom) {
                        parser.parse();
                        registry.byId('betterformMessageToaster').positionDirection = 'br-down';
                        registry.byId('betterformMessageToaster').setContent('The document + types.xml saved successfully!', 'error');
                        registry.byId('betterformMessageToaster').show();
                    });
                }
                else {
                    require(["dojox/widget/Toaster", "dijit/registry", "dojo/parser", "dojo/on", "dojo/dom", "dojo/domReady!"],
                        function(Toaster, registry, parser, on, dom) {
                        parser.parse();
                        registry.byId('betterformMessageToaster').positionDirection = 'br-down';
                        registry.byId('betterformMessageToaster').setContent('The document + types.xml saved successfully!', 'warning');
                        registry.byId('betterformMessageToaster').show();
                    });                    
                }
            },
            error: function() {
                alert("There was an error. Try again please!");
            }
        });        
        
        return false;
        
    });   
});
