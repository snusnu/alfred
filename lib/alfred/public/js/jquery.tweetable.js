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
					$('.tweet_content_'+i+'').append('<span class="tweet_link_'+i+'">'+item.text.replace(/#(.*?)(\s|$)/g, '<span class="hash">#$1 </span>').replace(/(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig, '<a href="$&">$&</a> ' ).replace(/@(.*?)(\s|\(|\)|$)/g, '<a href="http://twitter.com/$1">@$1 </a>$2'));
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

