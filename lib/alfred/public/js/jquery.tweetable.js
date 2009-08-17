//extend the plugin
(function($){

	//define the new for the plugin ans how to call it	
	$.fn.tweetable = function(options) {
		//set default options  
		var defaults = {
			limit: 5,
			username: 'philipbeel',
			time: false
		};

		//call in the default otions
		var options = $.extend(defaults, options);
		//act upon the element that is passed into the design    
		return this.each(function(options) {
			var act = $(this);
			var api = "http://twitter.com/statuses/user_timeline/";
			var count= "?count=";
			$.getJSON(api+defaults.username+".json"+count+defaults.limit+"&callback=?", act,
			function(data){
				$(act).prepend('<ul class="tweetList">');
				$.each(data, function(i,item){
					$(act).append('<li class="tweet_content_'+i+'">');
					var info = item.text.split(' at ');
					var text = info[0];
					var link = info[1];
					var tweet = text.replace(/(note|question|reply|snippet)/, '<a href="' + link + '">$1</a>');
					$('.tweet_content_'+i+'').append('<span class="tweet_link_'+i+'">' + tweet);
					if(defaults.time == true) {
						$('.tweet_content_'+i).append('<small> '+item.created_at.substr(0,20)+'</small>');	
					}
					$(act).append('</li>')
			    });
   				$(act).append('</ul>');
        	});	
		});
	};
	//end the plugin call 
})(jQuery);

