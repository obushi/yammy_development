$(function () {
  if ($('main#list').length) {
    $(window).bind('scroll', function () {
      $('footer').fadeOut(200);
      var scrollHeight = $(document).height();
      var scrollPosition = $(window).height() + $(window).scrollTop();
      if ( (scrollHeight - scrollPosition) / scrollHeight <= 0.01) {
        load();
      }
    });
  }
  var page = 8;
  var load_days = 1;
  var page_404 = false;
  var loading = false;
  var day_array = ['日', '月', '火', '水', '木', '金', '土'];
  function load() {
    if (!page_404 && !loading) {
      loading = true;
      $.ajax ({
        type: 'GET',
        url: 'api/v1/load',
        data: 'p=' + page.toString() + '&d=' + load_days.toString(),
        dataType: 'jsonp',
        success: function (json) {
          Object.keys(json).forEach(function (key) {

            full_date = new Date(key);
            year = full_date.getFullYear().toString();
            month = zeroFormat(full_date.getMonth() + 1);
            date = zeroFormat(full_date.getDate());
            day = day_array[full_date.getDay()];
            periods = {'breakfast' : '朝', 'lunch' : '昼', 'dinner' : '夜'};

            $('main').append('<article class="list"><h2><a href="' + year + month + date + '">' + year + '年' + month + '月' + date + '日' + '(' + day + ')</a></h2>');
            Object.keys(periods).forEach(function (period_key) {
              if (json[key][period_key]['menu'].length != 0) {
                $('article.list:last').append('<section class="meal"><h3>' + periods[period_key] + '</h3><ul>');
                for (var j = 0; j < json[key][period_key]['menu'].length; j++) {
                  $('section.meal:last ul').append('<li class="dish">' + json[key][period_key]['menu'][j]['name'] + '</li>');
                }
                $('article.list:last').append('</ul>');
                $('article.list:last').append('</section>');
              }
            });
            $('main').append('</article>');
          });
        },
        error: function () {
          page_404 = true;
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
    loading = false;
  }
});