(function () {
  function addDays(date, days) {
    var next = new Date(date.getTime());
    next.setDate(next.getDate() + days);
    return next;
  }

  function toMonday(date) {
    var monday = new Date(date.getTime());
    var day = (monday.getDay() + 6) % 7;
    monday.setDate(monday.getDate() - day);
    return monday;
  }

  function toIsoDate(date) {
    return date.toISOString().slice(0, 10);
  }

  function levelForCount(count) {
    if (count <= 0) {
      return 0;
    }
    if (count === 1) {
      return 1;
    }
    if (count <= 3) {
      return 2;
    }
    if (count <= 5) {
      return 3;
    }
    return 4;
  }

  function formatDate(date) {
    return date.toLocaleDateString(undefined, {
      month: "short",
      day: "numeric",
      year: "numeric"
    });
  }

  var dataNode = document.getElementById("heatmap-data");
  var gridNode = document.getElementById("heatmap-grid");
  var monthNode = document.getElementById("heatmap-months");

  if (!dataNode || !gridNode) {
    return;
  }

  var dailyCounts = {};
  try {
    dailyCounts = JSON.parse(dataNode.textContent || "{}");
  } catch (_error) {
    dailyCounts = {};
  }

  var weeks = parseInt(gridNode.getAttribute("data-weeks"), 10);
  if (!Number.isFinite(weeks) || weeks <= 0) {
    weeks = 26;
  }

  gridNode.style.setProperty("--weeks", String(weeks));
  if (monthNode) {
    monthNode.style.setProperty("--weeks", String(weeks));
    monthNode.innerHTML = "";
  }
  gridNode.innerHTML = "";

  var today = new Date();
  today.setHours(0, 0, 0, 0);

  var currentMonday = toMonday(today);
  var startDate = addDays(currentMonday, -((weeks - 1) * 7));

  var previousMonthKey = null;

  for (var week = 0; week < weeks; week += 1) {
    var monday = addDays(startDate, week * 7);
    var monthKey = String(monday.getFullYear()) + "-" + String(monday.getMonth() + 1);

    if (monthNode && monthKey !== previousMonthKey) {
      var monthLabel = document.createElement("span");
      monthLabel.className = "heatmap-month";
      monthLabel.textContent = monday.toLocaleDateString(undefined, { month: "short" });
      monthLabel.style.gridColumnStart = String(week + 1);
      monthNode.appendChild(monthLabel);
      previousMonthKey = monthKey;
    }

    for (var day = 0; day < 7; day += 1) {
      var date = addDays(monday, day);
      var iso = toIsoDate(date);
      var count = Number(dailyCounts[iso] || 0);

      var cell = document.createElement("div");
      cell.className = "heatmap-cell level-" + String(levelForCount(count));
      cell.style.gridColumnStart = String(week + 1);
      cell.style.gridRowStart = String(day + 1);
      cell.setAttribute("data-date", iso);
      cell.setAttribute("data-count", String(count));

      if (date.getTime() > today.getTime()) {
        cell.classList.add("future");
      }

      var noun = count === 1 ? "entry" : "entries";
      cell.title = formatDate(date) + " - " + String(count) + " " + noun;
      gridNode.appendChild(cell);
    }
  }
})();
