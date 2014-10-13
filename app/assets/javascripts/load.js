$(function () {
	if ($('main#list').length) {
		$(window).bind('scroll', function () {
			$('footer').fadeOut(200);
			var scrollHeight = $(document).height();
			var scrollPosition = $(window).height() + $(window).scrollTop();
			if ( (scrollHeight - scrollPosition) / scrollHeight <= 0.05) {
				load();
			}
		});
	}
	var page = 2;
	var load_days = 7;
	function load() {
		$.ajax ({
			type: 'GET',
			url: 'api/v1/load',
			data: 'p=' + page.toString() + '&d=' + load_days.toString(),
			dataType: 'jsonp',
			success: function(json) {
				console.log('p=' + page.toString() + '&d=' + load_days.toString());
				Object.keys(json).forEach(function (key) {
					console.log(key);
					console.log('length=' + Object.keys(json).length);

					date = new Date(key);
					year = date.getFullYear().toString();
					month = zeroFormat(date.getMonth() + 1);
					day = zeroFormat(date.getDate());
					periods = {'breakfast' : '朝', 'lunch' : '昼', 'dinner' : '夜'};

					$('main').append('<article class="list"><h2><a href="' + year + month + day + '">' + year + '年' + month + '月' + day + '日</a></h2>');
					Object.keys(periods).forEach(function (period_key) {
						$('article.list:last').append('<section class="meal"><h3>' + periods[period_key] + '</h3><ul>');
						for (var j = 0; j < json[key][period_key]['menu'].length; j++) {
							$('section.meal:last ul').append('<li class="dish">' + json[key][period_key]['menu'][j]['name'] + '</li>');
						}
						$('article.list:last').append('</ul>');
						$('article.list:last').append('</section>');
					});
					$('main').append('</article>');
				});
			}
		});
		function zeroFormat (val) {
			if (val.toString().length == 1) {
				s = '0' + val.toString();
			} else {
				s = val.toString();
			}
			return s
		}
		page ++;
	}
});