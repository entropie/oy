(function( $ ){

    $.fn.setupFontselLinks = function(){
        $("li", this).each(function(){
            $(this).click(function(){
                $("#dynfont").attr("href", "/css/font?font=" + escape($(this).text()));
            });
        });
    };

    $.fn.setupFontsel = function(){
        $(this).click(function(){
            var box = $(this);
            if($("#oy-font-list").length && $("#oy-font-list").is(":visible"))
                $("#oy-font-list").slideUp(function(){ $(this).remove(); });
            else {
                $.ajax({
                    type: "GET",
                    url: "/oy/special/list_fonts",
                    success: function(data){
                        $(box).parent().append(data);
                    },
                    complete: function(){
                        $("#oy-font-list").setupFontselLinks();
                        $("#oy-font-list").slideDown();
                    }
                });
            }
        });
    };

    $.fn.setupToc = function() {
        var toc = $(this);
        $("h2", toc).click(function(){
            $("h2", toc).toggleClass("active");
            $("ul", toc).fadeToggle();
        });
    };

    $.fn.setupPreviewLink = function() {
        $(this).click(function(){
            var data = $("#oy-editform form").serialize();
            $("#oy-editform-more").slideUp();
            $("#oy-editform .spinner").show();

            $.ajax({
                type: "POST",
                url:  "/preview",
                data: data,
                success: function(data){
                    $("#oy-preview-box").html(data);
                },
                complete: function(){
                    $("#oy-editform .spinner").fadeOut();
                    $("#oy-preview-box").slideDown();

                    $("#oy-page .oy-preview-buttons .edit").click(function(){
                        $("#oy-preview-box").slideUp(function(){
                            $("#oy-editform-more").slideDown();
                        });
                    });
                }
            });
            return false;
        });
    };

    $.fn.setupGistScrollbar = function() {
      var target = $(".gist-highlight", this);
      target.addClass("simple");
      target.scrollbar();
    };

    $.fn.setupGraphs = function() {
        $("table.chart").each(function(){
            var chartType   = $(this).attr("data-charttype");
            var chartHeight = $(this).attr("data-height");
            var chartWidth  = $(this).attr("data-width");
            var chartVTitle = $(this).attr("data-v-title");
            var chartHTitle = $(this).attr("data-h-title");
            try{
                // dont load graphs w/o gvChart lib
                // needed because i dont want a request if the wiki runs local
                $(this).gvChart({
                    chartType: chartType,
                    gvSettings: {
                        vAxis: {title: chartVTitle},
                        hAxis: {title: chartHTitle},
                        width: chartWidth,
                        height: chartHeight
                    }
                });
            } catch(err) {}

        });
    };


})(jQuery);


$(document).ready(function () {
    $("#oy-fontsel").setupFontsel();

    if($("table.chart").length) $("#oy-body").setupGraphs();


    if($("#oy-toc").length) $("#oy-toc").setupToc();

    if($(".oy-preview #preview").length){
        $("#preview").setupPreviewLink();
    }

    if($(".oy-gist").length){
        $(".oy-gist").setupGistScrollbar();
    }

    if($("#oy-pageslide-link").length)
    $("#oy-pageslide-link").pageSlide({
      width: '350px',
      direction: 'left',
      onOpen: function(){
        //$("#oy-wrap").toggleClass("small");
        $("#oy-pageslide-link").fadeOut();
        $("#oy-wrap").animate({"margin-left": "360px"});
        $("#oy-page").animate({"margin-right": "60px"});
      }, onClose: function(){
        $("#oy-pageslide-link").fadeIn();
        $("#oy-wrap").animate({"margin-left": "10%"});
        $("#oy-page").animate({"margin-right": "0px"});
    }});

});


