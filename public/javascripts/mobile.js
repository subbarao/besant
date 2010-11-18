$(function() {
	$('div').live('pageshow', function(page, nextPage) {
		var showtime = $('.showtimes:visible');
		if (showtime.length && !(showtime.find('li').length > 1)) {
			var href = $(page.currentTarget).attr('id') + "/closest";
			var success = function(position) {
				var lat = position.coords.latitude;
				var lng = position.coords.longitude;
				$.getJSON(href, {
					lat: lat,
					lng: lng
				},
				function(data) {
					if (data.length) {
						$.each(data, function(i, el) {
							var li = $('<li/>');
							$('<h3 />', {
								html: el.name
							}).appendTo(li);
							$('<p />', {
								html: el.address
							}).appendTo(li);
							$('<p />', {
								html: el.times
							}).appendTo(li);
							li.appendTo(showtime);
						});

					}
					else {
						var li = $('<li/>');
						$('<h3 />', {
							html: 'No shows for today.'
						}).appendTo(li);
						li.appendTo(showtime);
					}
					showtime.listview('refresh');
				});
			};
			navigator.geolocation.getCurrentPosition(success);
		}
	});
});

