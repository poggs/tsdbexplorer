(function($){  
    $.fn.extend({   
        //plugin name
		twisty: function(options) {
		var defaults = {
			speed: 'fast',
			classOpen: 'twistyOpen',
			classClosed: 'twistyClosed'
		};
		var options = $.extend(defaults, options); 
			return this.each(function() {
				var o =options;
				var obj = $(this);
				var header = $("div:eq(0)", obj);
				var tbody = $("div:eq(1)",obj);
				if (obj.is('.open')) {
					header.addClass( o.classOpen );
				} else {
					header.addClass( o.classClosed );
					tbody.hide();
				}
				header.click(function() {  
				  	tbody.slideToggle(o.speed);
				  	if($(this).is('.' + o.classOpen)) {
						$(this).removeClass(o.classOpen);
						$(this).addClass(o.classClosed);
					} else {
						$(this).removeClass(o.classClosed);
						$(this).addClass(o.classOpen);
					}
				});
			});  
        }  
    });  
})(jQuery);  
      
