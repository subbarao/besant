$(function() {
	$('div').live('pageshow', function(page, nextPage) {
		var showtime = $(page.currentTarget).find('.showtimes');
		if (showtime.length && !(showtime.find('li').length > 1)) {
			var success = function(position) {
				var lat = position.coords.latitude;
				var lng = position.coords.longitude;
				$.getJSON(showtime.data().url, {
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

