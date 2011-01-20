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

})(jQuery);


$(document).ready(function () {
  $("#oy-fontsel").setupFontsel();
});


