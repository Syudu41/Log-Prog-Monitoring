---
layout: default
title: Tags
permalink: /tags/
---
<section class="home-block">
  <h1>Tags</h1>
  <p class="home-subtitle">Browse all tags across your research log.</p>

  {% assign all_tags = site.data.all_tags %}
  {% if all_tags == nil or all_tags.size == 0 %}
    <p>No tags yet. Add inline hashtags to any markdown entry.</p>
  {% else %}
    <div class="tag-cloud">
      {% for pair in all_tags %}
        {% assign tag = pair[0] %}
        {% assign count = pair[1] %}
        <a class="tag-pill tag-pill-cloud" href="#tag-{{ tag | slugify }}" data-tag-link="{{ tag | slugify }}">#{{ tag }} <span class="tag-count">{{ count }}</span></a>
      {% endfor %}
    </div>

    {% for pair in all_tags %}
      {% assign tag = pair[0] %}
      {% assign slug = tag | slugify %}
      {% assign tagged_entries = '' | split: '' %}

      {% for collection in site.collections %}
        {% assign key = collection.label %}
        {% if key != "posts" %}
          {% for doc in collection.docs %}
            {% if doc.tags contains tag %}
              {% assign tagged_entries = tagged_entries | push: doc %}
            {% endif %}
          {% endfor %}
        {% endif %}
      {% endfor %}

      {% assign tagged_entries = tagged_entries | sort: 'date_modified' | reverse %}

      <section id="tag-{{ slug }}" class="tag-group" data-tag-group="{{ slug }}">
        <h2>#{{ tag }} <span class="tag-count">{{ tagged_entries.size }}</span></h2>
        {% for entry in tagged_entries %}
          {% include entry-card.html entry=entry %}
        {% endfor %}
      </section>
    {% endfor %}
  {% endif %}
</section>

<script>
  (function () {
    var groups = Array.prototype.slice.call(document.querySelectorAll("[data-tag-group]"));
    var links = Array.prototype.slice.call(document.querySelectorAll("[data-tag-link]"));

    if (!groups.length) {
      return;
    }

    function applyHashFilter() {
      var hash = window.location.hash || "";
      var match = hash.match(/^#tag-([a-z0-9-]+)$/i);
      var activeSlug = match ? match[1].toLowerCase() : null;

      groups.forEach(function (group) {
        var slug = (group.getAttribute("data-tag-group") || "").toLowerCase();
        group.hidden = !!activeSlug && slug !== activeSlug;
      });

      links.forEach(function (link) {
        var slug = (link.getAttribute("data-tag-link") || "").toLowerCase();
        if (activeSlug && slug === activeSlug) {
          link.classList.add("is-active");
        } else {
          link.classList.remove("is-active");
        }
      });
    }

    window.addEventListener("hashchange", applyHashFilter);
    applyHashFilter();
  })();
</script>
