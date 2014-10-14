votedMeals = null;

$(function () {
  user = fetchCookie('user_token');
  fetchVotes();
  $('p.vote-button').on('click', vote);

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
      async: true,
      type: 'GET',
      url: 'api/v1/votes/' + user,
      dataType: 'jsonp',
      success: function(json) {
        votedMeals = json;
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
    pageDate = $('main').data('date');
    for (var i = 0; i < votedMeals.length; i++) {
      Object.keys(votedMeals[i]).forEach(function(key) {
        if (key == 'period' && votedMeals[i].date == pageDate) {
          switch (votedMeals[i].period) {
          case 'breakfast':
            $('p#vote-button-breakfast').removeClass('vote-button').addClass('voted-button').html('投票しました').unbind().on('click', unvote);
            break;
          case 'lunch':
            $('p#vote-button-lunch').removeClass('vote-button').addClass('voted-button').html('投票しました').unbind().on('click', unvote);
            break;
          case 'dinner':
            $('p#vote-button-dinner').removeClass('vote-button').addClass('voted-button').html('投票しました').unbind().on('click', unvote);
            break;
          default:
            break;
          }
        }
      });
    }
  }
  function vote () {
    $(this).removeClass('vote-button').addClass('voted-button').html('投票しました').unbind().on('click', unvote);
    var date = $('main').data('date').replace(/-/g, '');
    var period;
    var id = this.id;
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
      async: true,
      type: 'POST',
      url: 'api/v1/votes',
      data: {'user': user, 'date': date, 'period': period},
      success: function() {
        fetchVotes();
      }
    });
  }
  function unvote () {
    $(this).removeClass('voted-button').addClass('vote-button').html('投票').unbind().on('click', vote);  
    var date = $('main').data('date').replace(/-/g, '');
    var period;
    var id = this.id;
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
      async: true,
      type: 'DELETE',
      url: 'api/v1/votes/' + user,
      data: {'date': date, 'period': period},
      success: function() {
        $(this).on('click', vote);
        fetchVotes();
      }
    });
  }
});