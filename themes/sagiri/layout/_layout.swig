<!DOCTYPE html>

{% set html_class = 'theme-next ' + theme.scheme %}
{% if theme.motion.enable %}
  {% set html_class = html_class + ' use-motion' %}
{% endif %}

<html class="{{ html_class | lower }}" lang="{{ config.language }}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
  {% include '_third-party/analytics/index.swig' %}
  <!-- valine -->
  <script src="https://cdn.jsdelivr.net/npm/jquery/dist/jquery.min.js"></script>
  <script src="//cdn1.lncld.net/static/js/3.3.1/av-min.js"></script>
  <script src='//unpkg.com/valine/dist/Valine.min.js'></script>
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ page.lang || page.language || config.language }}" class="theme-darling">

  {% set container_class = "container " %}
  {% if theme.sidebar.position %}
    {% set container_class = container_class + 'sidebar-position-' + theme.sidebar.position %}
  {% endif %}

  <div class="{{ container_class }} {% block page_class %}{% endblock %}">
    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
    </header>


 <div class="loading-bar">
  <div class="progress"></div>
 </div>
    <main id="main" class="main">
      <div class="main-inner">
        <div class="content-wrap">
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_third-party/duoshuo-hot-articles.swig' %}
          {% include '_partials/comment.swig' %}
    </div>
        {% if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {% endif %}
      </div>
    </main>
<script>
  //刷新时初始化评论
  new Valine({
          el: '#comments',
          notify: false, 
          verify: false, 
          appId: 'V1Q5z5Gjq9fnYEHGB05RjoMF-gzGzoHsz',
          appKey: 'cksjsrfoq0N1MAvbrT2KYnYB',
          placeholder: '这是萌萌哒占位符！ o(*≧▽≦)ツ',
          path: window.location.pathname
      });
</script>
    <footer id="footer" class="footer">
      <div class="footer-image"></div>
      <div class="footer-inner">
        {% include '_partials/footer.swig' %}
        {% include '_third-party/analytics/analytics-with-widget.swig' %}
        {% block footer %}{% endblock %}
      </div>
    </footer>

      <div class="back-to-top">
        <i class="fa fa-arrow-up"></i>
      </div>
      <script src="/js/top.js"></script>
    <canvas id="evanyou"></canvas>

    {% if theme.needmoreshare2.enable and theme.needmoreshare2.float.enable %}
      <div id="needsharebutton-float">
        <span class="btn">
          <i class="fa fa-share-alt" aria-hidden="true"></i>
        </span>
      </div>
    {% endif %}

  </div>
  <!--
  <script type="text/javascript" src="{{ url_for(theme.js) }}/sagiri.min.js?v={{ theme.version }}"></script>
-->
  {% include '_third-party/search/index.swig' %}
  {% include '_third-party/seo/baidu-push.swig' %}
  {% include '_third-party/needsharebutton.swig' %}
  {% include '_third-party/rating.swig' %}
  {% include '_third-party/mathjax.swig' %}
  {% include '_third-party/analytics/lean-analytics.swig' %}
  {% include '_third-party/scroll-cookie.swig' %}
  {% include '_third-party/exturl.swig' %}
  <script async src="/js/fireworks.js"></script>
  <script src="/js/cheat.js"></script>
  <script async src="/js/evan-you.js"></script>
  <script src="/js/affix.js"></script>
  <script src="/js/pisces.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/pjax/pjax.js"></script>
  <script src="/js/pjax.js"></script>

  <!--<script>
    // remove service worker cache
    // from https://stackoverflow.com/questions/33704791/how-do-i-uninstall-a-service-worker
    "use strict";
    if(navigator.serviceWorker)
    {
        navigator.serviceWorker.getRegistrations().then(function(registrations) {
            for(let registration of registrations) {
                registration.unregister()
            }
        })
    }
  </script>-->
<!--
  <script>
    var serviceWorkerUri = '/sw.js';
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register(serviceWorkerUri).then(function() {
          if (navigator.serviceWorker.controller) {
            console.log('Assets cached by the controlling service worker.');
          } else {
            console.log('Please reload this page to allow the service worker to handle network operations.');
          }
        }).catch(function(error) {
          console.log('ERROR: ' + error);
        });
    } else {
        console.log('Service workers are not supported in the current browser.');
    }
  </script>
  -->
</body>
</html>
