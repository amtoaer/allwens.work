$.scrollto = function (scrolldom, scrolltime) {
	$(scrolldom).click(function () {
		$(this).addClass("active").siblings().removeClass("active");
		$('html, body').animate({
			scrollTop: $('body').offset().top
		}, scrolltime);
		return false;
	});
};
// 判断位置控制 返回顶部的显隐
// 控制header的升降
var backTo = $(".back-to-top");
var head = $("nav");
var backHeight = $(window).height() - 980 + 'px';

$(window).scroll(function () {
	if ($(window).scrollTop() > 700 && backTo.css('top') === '-900px') {
		backTo.css('top', backHeight);
		head.removeClass("slideDown");
		head.addClass("slideUp");
	} else if ($(window).scrollTop() <= 700 && backTo.css('top') !== '-900px') {
		backTo.css('top', '-900px');
		head.removeClass("slideUp");
		head.addClass("slideDown");
	}
});

// 启用
$.scrollto(".back-to-top", 800);