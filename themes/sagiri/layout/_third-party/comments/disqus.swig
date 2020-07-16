{% if not (theme.duoshuo and theme.duoshuo.shortname) and not theme.duoshuo_shortname %}
  {% if theme.disqus.enable %}

    {% if page.comments %}
      <script type="text/javascript">
        window.DISQUS = null;
        new DisqusJS({
          shortname: 'allwens',
          siteName: 'allwens.work',
          identifier: '{{ page.path }}',
          url: '{{ page.permalink }}',
          api: 'https://disqus.diygod.me/api/',
          apikey: 'Rchj1riQoiyEsZ6hJnkFUbSbHLqdh9uIG65WJy1WhQDRiFJa4wRl1w1QpoRat63g',
          admin: '文文',
          adminLabel: 'admin',
        });
      </script>
    {% endif %}

  {% endif %}
{% endif %}
