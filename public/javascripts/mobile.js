$(function() {

	$('div').live('pageshow', function() {
		$.each($(".timinigs li a"), function(i, element) { 
      (function($inner) {
				navigator.geolocation.getCurrentPosition(function(position) {
					var lat = position.coords.latitude;
					var lng = position.coords.longitude;
					$inner.attr('href', $inner.attr('href') + "?lat=" + lat + "&lng=" + lng);
				},function(error){ alert(error); });
			})($(element));
		});
	});
});

