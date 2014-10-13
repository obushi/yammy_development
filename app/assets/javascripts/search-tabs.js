$(function () {
	function init(){
		objSearchSelector = {
			word: '#word-search',
			date: '#date-search'
		};
	}

	$('#search-tab li').on('click', function() {
		var searchtype = $(this).data('searchtype'),
		targetSelector = objSearchSelector[searchtype];

		$('#searchContainer div:not(' + targetSelector + ')').css('display', 'none');
		$(targetSelector).css('display', 'block');
		$('#search-tab li.current-tab').removeClass('current-tab');
		$(this).addClass('current-tab');
	});

	if($('#pageSearch').length){init();}
});