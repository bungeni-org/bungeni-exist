$(document).ready(function(){

    if(window.location.hash) {
        //get the index from URL hash
        tabSelect = document.location.hash.substr(1,document.location.hash.length);
        // timeout because of http://stackoverflow.com/questions/2060019/how-to-trigger-click-on-page-load
        setTimeout(function() {
            $("#tabs li#"+tabSelect).trigger('click');
        },10);
    }
    
    // POPUP to load subform --BEGIN
    window.deselect = function() {
        $(".pop").slideFadeToggle(function() { 
            //$("#itemto").removeClass("selected");
        });    
    }
    $(function() {
        $(".event a, .signatory a, .schedule a, .download a").live('click', function(event) {
            $('.pop div').empty();
            $('.pop div').html('loading...');
                
            if($(this).hasClass("selected")) {
                deselect();                         
            } else {
                $(this).addClass("selected");               
                
                $(".pop").slideFadeToggle(function() { 
                    //$("#itemto").focus();
                });
                
                $('.pop').css('left',event.pageX);
                $('.pop').css('top',event.pageY);
                $('.pop').css('display','inline');     
                $(".pop").css("position", "absolute");
                
                $(this).removeClass("selected");
            }
            return false;
        });
    
        $(".close").live('click', function() {
            deselect();
            return false;
        });
    });
    // POPUP to load subform --END
    
    $.fn.slideFadeToggle = function(easing, callback) {
        return this.animate({ opacity: 'toggle', height: 'toggle' }, "fast", easing, callback);
    };    
    
    // Adding confirmation dialog for Saving configuration back to File-System
    $("a.confirm-delete").click(function() {
        return confirm('This action overwrites your custom configuration for bungeni, proceed?');
    });    
    
    //  When user clicks on tab, this code will be executed
    $("#tabs li").click(function() {    
        // generate graphviz SVG
        if($(this).attr("id") == 'tabgraphviz') {
            var href = $(this).attr('data-type');      
            $.ajax({
                type: "GET",
                url: href,
                data: "nothing",
                dataType: "xml",
                success: function(svgDoc) {
                    $("#graphviz").empty();
                    //import contents of the svg document into this document
                    var importedSVGRootElement = document.importNode(svgDoc.documentElement,true);
                    //append the imported SVG root element to the appropriate HTML element
                    $("#graphviz").append(importedSVGRootElement);
                    $("#graphviz").append('<a target="_blank" class="ext-links" href="'+href+'">open on new tab</a>');
                }
            });        
        }   
    
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
    
    // moving nodes up and down (reordering) in <table>
    $("table#transitionSources tbody tr:first .up,table#transitionSources tbody tr:last .down").hide();
    $("tr .up, tr .down").click(function(){
        var row = $(this).parents("tr:first");
        var href = $(this).attr('href');
        if ($(this).is(".up")) {
            $("table#transitionSources tbody tr:first .up").show();
            $.ajax({
                type: "GET",
                url: href+(row.index()+1),
                data: "nothing",
                success: function(data) {                      
                    row.insertBefore(row.prev());
                    row.find(".down").show();
                    $("table#transitionSources tbody tr:first .up,table#transitionSources tbody tr:last .down").hide();
                }
            });
        } else {      
            $.ajax({
                type: "GET",
                url: href+(row.index()+1),
                data: "nothing",
                success: function(data) {                      
                    row.insertAfter(row.next());
                    row.find(".up").show();
                    $("table#transitionSources tbody tr:first .up,table#transitionSources tbody tr:last .down").hide();
                }
            });
        }
        return false;
    });
    
    // moving nodes up and down (reordering) in <ul>
    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
    $("li .up, li .down").click(function(){
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
    
    // deleting an import_
    $(".delete-import").live('click', function() {
        var href = $(this).attr('href');
        var tr = $(this).closest('tr');          

        if ($(this).is(".delete-import")) {   
            if (confirm('Are you sure to proceed with DELETE?\r\n It is non-reversible')) {
                $.ajax({
                    type: "DELETE",
                    url: href,
                    data: "nothing",
                    success: function(data) {  
                        tr.fadeOut('slow', function() { tr.remove(); });
                        //tr.animate({ backgroundColor: "#fbc7c7" }, "slow").animate({ opacity: "hide" }, "slow");
                    },
                    error: function (request, status, throwerror) {
                        tr.find("div.btn-group").removeClass("open");
                    }
                });        
            }        
        }        
        return false;
    }); 
    
    // change-of-configuration 
    $(".activate-import").live('click', function() {
        var href = $(this).attr('href');
        var tr = $(this).closest('tr');          

        if ($(this).is(".activate-import")) {   
            tr.find(".import-progress > div").show();
            tr.find("div.btn-group").removeClass("open");
            $.ajax({
                type: "GET",
                url: href,
                success: function(data) {   
                    tr.siblings().find(".btn").removeClass("disabled");
                    tr.siblings().find(".btn").removeClass("btn-success");
                    tr.find(".btn").addClass("btn-success");
                    tr.find(".btn").next().addClass("disabled");
                    tr.find(".import-progress > div").hide();
                },
                error: function (request, status, throwerror) {
                    tr.find(".import-progress > div").hide();
                }
            });        
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
                        registry.byId('betterformMessageToaster').setContent('The document saved successfully!', 'error');
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
