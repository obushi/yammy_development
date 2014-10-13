if ( (navigator.userAgent.indexOf("iPhone") != -1) ||
	(navigator.userAgent.indexOf("Android") != -1) ) {
	$('body').addClass('sp');
	$('head').append('<meta id="sp_optimize"></meta>');
	$('meta#sp_optimize').attr('name', 'viewport').attr('content', 'width=device-width');
} else {
	$('body').addClass('pc');
};