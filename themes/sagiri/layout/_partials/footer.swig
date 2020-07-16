<script>
function show_date_time() {
  window.setTimeout(function () {
    show_date_time();
  }, 1000);
  var BirthDay = new Date('12/8/2018 11:30:00');
  var today = new Date();
  var timeold = (today.getTime() - BirthDay.getTime());
  var msPerDay = 24 * 60 * 60 * 1000;
  var e_daysold = timeold / msPerDay;
  var daysold = Math.floor(e_daysold);
  var e_hrsold = (e_daysold - daysold) * 24;
  var hrsold = Math.floor(e_hrsold);
  var e_minsold = (e_hrsold - hrsold) * 60;
  var minsold = Math.floor((e_hrsold - hrsold) * 60);
  var seconds = Math.floor((e_minsold - minsold) * 60);
  $('#since').html(daysold + "天" + hrsold + "小时" + minsold + "分" + seconds + "秒");
}
show_date_time();
</script>
<p>博客已萌萌哒运行<span id="since"></span><span class="my-face">(●'◡'●)ﾉ♥</span></p>
<p>{{ theme.footer.custom_text }}</p>
{% set current = date(Date.now(), "YYYY") %}
<p>© <span itemprop="copyrightYear">{{ current }}</span> {{ config.title }}.</p>
<p>
    Theme By <a href="https://github.com/DIYgod/hexo-theme-sagiri" target="_blank" class="external" rel="nofollow">Sagiri</a>.
</p>
<p>Made with <i class="fa fa-heart throb" style="color: #d43f57;"></i> by <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright || config.author }}</span>. </p>
