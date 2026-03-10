(function () {
  var overlay = document.getElementById("search-overlay");
  var input = document.getElementById("search-input");
  var resultsNode = document.getElementById("search-results");
  var emptyNode = document.getElementById("search-empty");

  if (!overlay || !input || !resultsNode || !emptyNode) {
    return;
  }

  var openButtons = Array.prototype.slice.call(document.querySelectorAll("[data-search-open]"));
  var closeButtons = Array.prototype.slice.call(document.querySelectorAll("[data-search-close]"));

  var entries = null;
  var indexUrl = overlay.getAttribute("data-index-url") || "/search.json";
  var currentResults = [];
  var activeIndex = 0;

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function normalizeTags(tags) {
    return Array.isArray(tags) ? tags : [];
  }

  function tokenize(query) {
    return query
      .toLowerCase()
      .trim()
      .split(/\s+/)
      .filter(Boolean);
  }

  function scoreField(field, token, weight) {
    if (!field) {
      return 0;
    }

    var index = field.indexOf(token);
    if (index === -1) {
      return 0;
    }

    if (index === 0) {
      return weight + 14;
    }

    return Math.max(1, weight - index);
  }

  function scoreEntry(entry, tokens) {
    var title = String(entry.title || "").toLowerCase();
    var category = String(entry.category || "").toLowerCase();
    var excerpt = String(entry.excerpt || "").toLowerCase();
    var tags = normalizeTags(entry.tags).join(" ").toLowerCase();

    var combined = title + " " + category + " " + tags + " " + excerpt;
    var matchesAllTokens = tokens.every(function (token) {
      return combined.indexOf(token) !== -1;
    });

    if (!matchesAllTokens) {
      return 0;
    }

    var score = 0;
    tokens.forEach(function (token) {
      score += scoreField(title, token, 50);
      score += scoreField(tags, token, 35);
      score += scoreField(category, token, 25);
      score += scoreField(excerpt, token, 10);
    });

    return score;
  }

  function buildResultMarkup(entry, isActive) {
    var tags = normalizeTags(entry.tags).slice(0, 4).map(function (tag) {
      return '<span class="tag-pill">#' + escapeHtml(tag) + "</span>";
    }).join("");

    return '' +
      '<li class="search-result-item' + (isActive ? ' is-active' : '') + '">' +
      '  <a class="search-result-link" href="' + escapeHtml(entry.url || "#") + '">' +
      '    <div class="search-result-title">' + escapeHtml(entry.title || "Untitled") + '</div>' +
      '    <div class="search-result-meta">' +
      '      <span>' + escapeHtml(entry.category || "uncategorized") + '</span>' +
      '      <span class="meta-separator">&middot;</span>' +
      '      <span>' + escapeHtml(entry.date || "") + '</span>' +
      '    </div>' +
      (tags ? ('<div class="tag-pills">' + tags + '</div>') : '') +
      '    <div class="search-result-excerpt">' + escapeHtml(entry.excerpt || "") + '</div>' +
      '  </a>' +
      '</li>';
  }

  function renderResults() {
    resultsNode.innerHTML = "";

    if (!currentResults.length) {
      emptyNode.hidden = false;
      return;
    }

    emptyNode.hidden = true;
    var html = currentResults.map(function (entry, index) {
      return buildResultMarkup(entry, index === activeIndex);
    }).join("");
    resultsNode.innerHTML = html;
  }

  function runSearch(query) {
    if (!entries || !query.trim()) {
      currentResults = [];
      activeIndex = 0;
      renderResults();
      return;
    }

    var tokens = tokenize(query);
    var ranked = entries.map(function (entry) {
      return {
        entry: entry,
        score: scoreEntry(entry, tokens)
      };
    }).filter(function (item) {
      return item.score > 0;
    }).sort(function (a, b) {
      if (a.score !== b.score) {
        return b.score - a.score;
      }
      return String(b.entry.date || "").localeCompare(String(a.entry.date || ""));
    }).slice(0, 10).map(function (item) {
      return item.entry;
    });

    currentResults = ranked;
    activeIndex = 0;
    renderResults();
  }

  function ensureEntries() {
    if (entries) {
      return Promise.resolve(entries);
    }

    return fetch(indexUrl)
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Failed to fetch search index");
        }
        return response.json();
      })
      .then(function (json) {
        entries = Array.isArray(json) ? json : [];
        return entries;
      })
      .catch(function () {
        entries = [];
        return entries;
      });
  }

  function openSearch() {
    overlay.hidden = false;
    document.body.style.overflow = "hidden";
    ensureEntries().then(function () {
      input.focus();
      runSearch(input.value);
    });
  }

  function closeSearch() {
    overlay.hidden = true;
    document.body.style.overflow = "";
  }

  function navigateActiveResult() {
    if (!currentResults.length) {
      return;
    }

    var target = currentResults[activeIndex] || currentResults[0];
    if (target && target.url) {
      window.location.href = target.url;
    }
  }

  openButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      openSearch();
    });
  });

  closeButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      closeSearch();
    });
  });

  overlay.addEventListener("click", function (event) {
    if (event.target === overlay) {
      closeSearch();
    }
  });

  input.addEventListener("input", function () {
    runSearch(input.value);
  });

  input.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      event.preventDefault();
      closeSearch();
      return;
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (currentResults.length) {
        activeIndex = (activeIndex + 1) % currentResults.length;
        renderResults();
      }
      return;
    }

    if (event.key === "ArrowUp") {
      event.preventDefault();
      if (currentResults.length) {
        activeIndex = (activeIndex - 1 + currentResults.length) % currentResults.length;
        renderResults();
      }
      return;
    }

    if (event.key === "Enter") {
      event.preventDefault();
      navigateActiveResult();
    }
  });

  document.addEventListener("keydown", function (event) {
    var isMacCommand = event.metaKey && event.key.toLowerCase() === "k";
    var isCtrlCommand = event.ctrlKey && event.key.toLowerCase() === "k";

    if (isMacCommand || isCtrlCommand) {
      event.preventDefault();
      openSearch();
      return;
    }

    if (event.key === "Escape" && !overlay.hidden) {
      event.preventDefault();
      closeSearch();
    }
  });
})();
