$(function () {
  $(window).bind('scroll', function () {
    $('footer').fadeOut(200);
  });
  if($('body.pc main#pageSearch').length){location.href = "/";}
  $('input.datepicker').datepicker({
    numberOfMonths: 1,
　　    showButtonPanel: true,
    dateFormat: 'yymmdd'
  });
  $('input.keyword-textbox').focus(function () {
    if ($('input.keyword-textbox').val() != '') {
      wordSearch();
    }
  });
  $('button.word-search-button').on('click', function (e) {
    if ($('input.keyword-textbox').val().length != 0) {
      wordSearch();
    }
    return false;
  });
  $('body').keyup(function (e) {
    if ($('input.keyword-textbox').val() == '') {
      $('div.keyword-search-results').hide();
    }
    if ((e.which >= 65 && e.which <= 90) || e.which == 32 || e.which == 8 || e.which
       == 46) { 
      if ($('input.keyword-textbox').val().length != 0) {
        wordSearch();
      }
    } else if (e.which == 27) {
      $('div.keyword-search-results').hide();
    }
  });
  $('body').on('click', function () {
    $('div.keyword-search-results').hide();
  });
  $('button.date-search-button').on('click', dateSearch);
  function wordSearch() {
    console.log("wordSearch");
    var keyword = $('.keyword-textbox').val();
    $.ajax ({
      type: 'GET',
      url: 'api/v1/search',
      data: 'q=' + keyword,
      dataType: 'jsonp',
      success: function(json) {
        $('div.keyword-search-results >').remove();
        $('div.keyword-search-results').show();

        for (var i = 0; i < json.length; i++) {
          console.log(json[i]);
          var appendDate = new Date(json[i][0].date);
          var appendPeriod = '';

          switch (json[i][0].period) {
            case 'breakfast':
              appendPeriod = '朝';
              break;
            case 'lunch':
              appendPeriod = '昼';
              break;
            case 'dinner':
              appendPeriod = '夜';
              break;
            default:
              appendPeriod = '';
              break;
          }

          console.log(appendDate);
          appendYear = appendDate.getFullYear();
          appendMonth = appendDate.getMonth() + 1;
          appendDay = appendDate.getDate();

          appendElem = '<section class="result"><h3><a href="' 
                       + zeroFormat(appendYear)
                       + zeroFormat(appendMonth)
                       + zeroFormat(appendDay)
                       + '">' 
                       + appendYear + '年' 
                       + appendMonth + '月' 
                       + appendDay + '日' 
                       + appendPeriod + '</a></h3><p class="result-name">' 
                       + json[i][0].name + '</p></section>';

          $('div.keyword-search-results').hide().append(appendElem).fadeIn(100);
        }
      },
      error: function(json) {
        $('div.keyword-search-results >').remove();
        $('div.keyword-search-results').show();
        $('div.keyword-search-results').append('<p class="error">結果なし</p>');
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
  }
  function dateSearch() {
    var date = $('.datepicker').val();
    $.ajax ({
      type: 'GET',
      url: 'api/v1/date',
      data: 'd=' + date,
      dataType: 'jsonp',
      success: function(json) {
        $('div.date-search-results *').remove();
        $('div.date-search-results').show();
        console.log(json);
        key = '';
        for (key in json) {
          console.log(key);
        }
        date = new Date(key);
        year = date.getFullYear().toString();
        month = zeroFormat(date.getMonth() + 1);  
        day = zeroFormat(date.getDate());
        console.log(date);
        periods = {'breakfast' : '朝', 'lunch' : '昼', 'dinner' : '夜'};

        $('div.date-search-results').append('<article class="list">');
        $('div.date-search-results').prepend('<h2><a href="' + year + month + day + '">' + year + '年' + month + '月' + day + '日の献立</a></h2>');
        Object.keys(periods).forEach(function (period_key) {
          console.log(json);
          console.log(period_key);
          if (json[key][period_key]['menu'].length != 0) {
            $('article.list:last').append('<section class="meal">');
            $('section.meal:last').append('<h3>' + periods[period_key] + '</h3>');
            $('section.meal:last').append('<ul>');
            console.log(json);
            for (var j = 0; j < json[key][period_key]['menu'].length; j++) {
              $('section.meal:last ul').append('<li class="dish">' + json[key][period_key]['menu'][j]['name'] + '</li>');
            }
            $('section.list:last').append('</ul>');
            $('article.list:last').append('</section>');
          }
        });
        $('article.list:last').append('</article>');
      },
      error: function(json) {
        $('div.date-search-results *').remove();
        $('div.date-search-results').show();
        $('div.date-search-results').append('<p class="error">見つかりませんでした。</p>');
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
 
  }

});