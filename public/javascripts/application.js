$(document).ready(function() {

	// infinitescroll() is called on the element that surrounds
	// the items you will be loading more of
	$('.pager .tweets .parent').infinitescroll({
		navSelector: "#next",
		nextSelector: "#next a:first",
		itemSelector: "div.bubble",
		loadingText: "Loading more reviews...",
		loadingImg: "/images/ajax-loading.gif",
		donetext: "We've hit the end of the reviews."
	},
	function(elements) {
		$("input[name='filter']:checked").triggerHandler('click');
	});

	$("input[name='filter']").click(function() {
		$(".tweets ul li").hide();
		if ($(this).val() == "all") {
			$(".tweets ul li").show();
		}
		else {
			$(".tweets ul li.js_" + $(this).val()).show();
		}
		return true;
	});

	$('#carousel ul').roundabout({
		startingChild: 0,
		minOpacity: 0.0,
		// invisible!
		minScale: 0.2,
		// tiny!
		shape: 'square'
	});

	$('#carousel li').focus(function() {
		$("#" + $(this).find("a").attr('rel')).removeClass("inactive");

	}).blur(function() {
		$("#" + $(this).find("a").attr('rel')).addClass("inactive");
	});

	$(".tweet").live("click", function() {
		window.location = $(this).find(".avatar").attr("rel");
		return true;
	});

	$("#jq-primarySearch").autocomplete({
		source: "/movies/autocomplete",
		minLength: 1,
		select: function(event, ui) {
			window.location = ui.item.url;
		}
	});

	$("#destroy_all").live("click", function() {
		if ($(this).is(":checked")) {
			$("input[id$='_destroy']").attr('checked', 'checked')
		} else {

			$("input[id$='_destroy']").removeAttr('checked')
		}
	});

	$("#feature_all").live("click", function() {
		if ($(this).is(":checked")) {
			$("input[id$='featured']").attr('checked', 'checked')
		} else {

			$("input[id$='featured']").removeAttr('checked')
		}
	});

	$(".category_all").live('click', function() {
		$("input[name$='[category]'][value='" + $(this).val() + "']").each(function() {
			$(this).attr('checked', 'checked');
		});
	});
});

