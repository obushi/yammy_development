votedPeriods = [];

$(function () {
	user = fetchCookie('user_token');
	$('p.vote-button').on('click', vote);
	fetchVotes();

	// if ($('main#pageDaily').length) {
	// 	fetchVotes();
	// 	if (votedPeriods != null) {
	// 		applyVotesData();
	// 	}
	// }
	function fetchCookie (name) {
		var result = null;
		var cookieName = name + '=';
		var allCookies = document.cookie;

		var position = allCookies.indexOf(cookieName);
		if (position != -1) {
			var startIndex = position + cookieName.length;
			var endIndex = allCookies.indexOf(';', startIndex);
			if (endIndex == -1) {
				endIndex = allCookies.length;
			}

			result = decodeURIComponent(allCookies.substring(startIndex, endIndex));
		}
		return result;
	}
	function fetchVotes () {
		$.ajax ({
			async: false,
			type: 'GET',
			url: 'api/v1/vote',
			data: 'user=' + user,
			dataType: 'jsonp',
			jsonpCallback: 'callback',
			success: function(json) {
				votedPeriods = json;
				applyVotesData();
			}
		});
	}
	function getVotedPeriodArray (hash) {
		for (key in hash) {
			if (key == 'periods') {
				return hash[key];
			}
		}
	}
	function applyVotesData () {
		for (var i = 0; i < votedPeriods.length; i++) {
			switch (votedPeriods[i]) {
				case 'breakfast':
					$('p#vote-button-breakfast').removeClass('vote-button').addClass('voted-button').html('投票しました');
					break;
				case 'lunch':
					$('p#vote-button-lunch').removeClass('vote-button').addClass('voted-button').html('投票しました');
					break;
				case 'dinner':
					$('p#vote-button-dinner').removeClass('vote-button').addClass('voted-button').html('投票しました');
					break;
				default:
					break;
			}
		}
	}
	function vote () {
		var period;
		var id = this.id;
		console.log(id);
		switch (id) {
			case 'vote-button-breakfast':
				period = 'breakfast';
				break;
			case 'vote-button-lunch':
				period = 'lunch';
				break;
			case 'vote-button-dinner':
				period = 'dinner';
				break;
			default:
				period = null;
				break;
		}
		$.ajax ({
			async: false,
			type: 'POST',
			url: 'api/v1/vote',
			data: {'user': user, 'period': period},
			success: function() {
				console.log('投票しました(user => ' + user + 'period => ' + period);
				fetchVotes();
				applyVotesData();
			}
		});
	}
});