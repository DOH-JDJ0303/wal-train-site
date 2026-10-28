/* =============================================================
   Course interactions
   - Collapsible sidebar on small screens
   - Code block chrome: terminal styling + copy button
   - Activity steps built from "## " headings, with saved progress
   - Lecture "mark complete", completion ticks in the sidebar
   - Knowledge-check questions (text, multiple choice, open)
   Progress is stored in this browser only (localStorage).
   ============================================================= */
(function () {
  "use strict";

  var NS = "course:" + ((window.COURSE && window.COURSE.baseurl) || "") + ":";

  // ---- storage helpers (never throw) ---------------------------
  function load(key, fallback) {
    try {
      var v = window.localStorage.getItem(NS + key);
      return v === null ? fallback : JSON.parse(v);
    } catch (e) { return fallback; }
  }
  function save(key, value) {
    try { window.localStorage.setItem(NS + key, JSON.stringify(value)); } catch (e) { /* ignore */ }
  }
  function completed() { return load("complete", {}); }
  function setCompleted(id, done) {
    var c = completed();
    if (done) { c[id] = true; } else { delete c[id]; }
    save("complete", c);
    paintCompletion();
  }

  function $(sel, root) { return (root || document).querySelector(sel); }
  function $$(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

  // ---- sidebar toggle -------------------------------------------
  function initSidebar() {
    var sb = $("#course-sidebar");
    if (!sb) return;
    var btn = $(".sidebar-toggle", sb);
    btn.addEventListener("click", function () {
      var open = sb.classList.toggle("is-open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  // ---- completion ticks + progress --------------------------------
  function paintCompletion() {
    var c = completed();
    $$("[data-lesson]").forEach(function (el) {
      el.classList.toggle("is-complete", !!c[el.getAttribute("data-lesson")]);
    });
    var mini = $("[data-course-progress]");
    if (mini) {
      var items = $$(".nav-item[data-lesson]");
      var done = items.filter(function (el) { return c[el.getAttribute("data-lesson")]; }).length;
      mini.hidden = done === 0;
      $(".progress-fill", mini).style.width = (items.length ? (100 * done / items.length) : 0) + "%";
      $(".progress-label", mini).textContent = done + " / " + items.length + " done";
    }
    var lecBtn = $("[data-mark-complete]");
    var lesson = $("[data-lesson-id]");
    if (lecBtn && lesson) {
      var isDone = !!c[lesson.getAttribute("data-lesson-id")];
      lecBtn.classList.toggle("is-done", isDone);
      $("span", lecBtn).textContent = isDone ? "Lecture completed" : "Mark lecture complete";
    }
  }

  function initLecture() {
    var btn = $("[data-mark-complete]");
    var lesson = $("[data-lesson-id]");
    if (!btn || !lesson) return;
    var id = lesson.getAttribute("data-lesson-id");
    btn.addEventListener("click", function () { setCompleted(id, !completed()[id]); });
  }

  function initResume() {
    var lesson = $("[data-lesson-id]");
    if (lesson) {
      save("last", { url: lesson.getAttribute("data-lesson-id"), title: ($(".lesson-title") || {}).textContent || "" });
    }
    var resume = $("[data-resume]");
    var last = load("last", null);
    if (resume && last && last.url) {
      var a = $("a", resume);
      a.href = last.url;
      a.textContent = "Resume: " + last.title.trim();
      resume.hidden = false;
    }
  }

  // ---- code blocks -------------------------------------------------
  var TERMINAL = ["bash", "shell", "sh", "zsh", "console", "shell-session", "terminal"];
  var LABELS = { python: "Python", r: "R", yaml: "YAML", json: "JSON", javascript: "JavaScript", js: "JavaScript",
    html: "HTML", css: "CSS", sql: "SQL", text: "Text", plaintext: "Text", nextflow: "Nextflow", groovy: "Groovy",
    dockerfile: "Dockerfile", toml: "TOML", markdown: "Markdown", csv: "CSV" };

  function langOf(el) {
    var m = (el.className || "").match(/language-([\w-]+)/);
    return m ? m[1].toLowerCase() : "";
  }

  function textForCopy(lang, raw) {
    if (lang === "console" || lang === "shell-session") {
      // copy only the commands (lines that start with a $ prompt)
      var cmds = raw.split("\n").filter(function (l) { return /^\s*\$\s/.test(l); })
        .map(function (l) { return l.replace(/^\s*\$\s/, ""); });
      if (cmds.length) return cmds.join("\n");
    }
    return raw.replace(/\n$/, "");
  }

  function copyText(text, btn) {
    function ok() {
      btn.textContent = "Copied";
      btn.classList.add("copied");
      setTimeout(function () { btn.textContent = "Copy"; btn.classList.remove("copied"); }, 1600);
    }
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(ok, function () { fallbackCopy(text); ok(); });
    } else { fallbackCopy(text); ok(); }
  }
  function fallbackCopy(text) {
    var ta = document.createElement("textarea");
    ta.value = text; ta.setAttribute("readonly", ""); ta.style.position = "absolute"; ta.style.left = "-9999px";
    document.body.appendChild(ta); ta.select();
    try { document.execCommand("copy"); } catch (e) { /* ignore */ }
    document.body.removeChild(ta);
  }

  function initCode() {
    $$("div.highlighter-rouge, figure.highlight").forEach(function (block) {
      if (block.closest(".code-block")) return;
      var code = $("pre code", block) || $("pre", block);
      if (!code) return;
      var lang = langOf(block) || langOf(code);
      var isOutput = block.classList.contains("output");
      var isTerm = !isOutput && TERMINAL.indexOf(lang) !== -1;

      var wrap = document.createElement("div");
      wrap.className = "code-block" + (isTerm ? " code-block--terminal" : "") + (isOutput ? " code-block--output" : "");
      var bar = document.createElement("div");
      bar.className = "code-bar";
      var label = document.createElement("span");
      if (isTerm) {
        label.innerHTML = '<span class="term-dots" aria-hidden="true"><i></i><i></i><i></i></span>Terminal';
      } else {
        label.textContent = block.getAttribute("data-label") || (isOutput ? "Expected output" : (LABELS[lang] || lang || "Code"));
      }
      bar.appendChild(label);

      if (!isOutput) {
        var btn = document.createElement("button");
        btn.type = "button"; btn.className = "copy-btn"; btn.textContent = "Copy";
        btn.setAttribute("aria-label", "Copy code to clipboard");
        btn.addEventListener("click", function () { copyText(textForCopy(lang, code.innerText), btn); });
        bar.appendChild(btn);
      }

      block.parentNode.insertBefore(wrap, block);
      wrap.appendChild(bar);
      wrap.appendChild(block);
    });
  }

  // ---- activity steps -------------------------------------------------
  function initSteps() {
    var body = $("[data-steps]");
    var lesson = $("[data-lesson-id]");
    if (!body || !lesson) return;
    var id = lesson.getAttribute("data-lesson-id");
    var key = "steps:" + id;

    var steps = [];
    var current = null;
    Array.prototype.slice.call(body.children).forEach(function (node) {
      if (node.tagName === "H2" && !node.classList.contains("no-step")) {
        current = document.createElement("section");
        current.className = "step";
        current.id = node.id ? "step-" + node.id : "";
        body.insertBefore(current, node);
        current.appendChild(node);
        steps.push(current);
      } else if (node.tagName === "H2") {
        current = null; // a .no-step heading ends the current step
      } else if (current) {
        current.appendChild(node);
      }
    });
    if (!steps.length) return;

    var state = load(key, []);
    var bar = $("[data-activity-progress]");
    var done = $("[data-activity-done]");

    function update() {
      var n = steps.filter(function (s) { return s.classList.contains("is-done"); }).length;
      var pct = Math.round(100 * n / steps.length);
      if (bar) {
        bar.hidden = false;
        $(".progress-fill", bar).style.width = pct + "%";
        $(".progress-track", bar).setAttribute("aria-valuenow", String(pct));
        $(".progress-label", bar).textContent = n + " of " + steps.length + " steps";
      }
      if (done) done.hidden = n !== steps.length;
      var c = completed();
      if ((n === steps.length) !== !!c[id]) setCompleted(id, n === steps.length);
    }

    steps.forEach(function (step, i) {
      var num = document.createElement("span");
      num.className = "step-num"; num.setAttribute("aria-hidden", "true");
      num.textContent = String(i + 1);
      step.insertBefore(num, step.firstChild);
      var h = $("h2", step);
      if (h) h.insertAdjacentHTML("afterbegin", '<span class="visually-hidden">Step ' + (i + 1) + ': </span>');

      var foot = document.createElement("div");
      foot.className = "step-check";
      foot.innerHTML = '<label><input type="checkbox"> Step ' + (i + 1) + " done</label>";
      step.appendChild(foot);
      var cb = $("input", foot);
      cb.checked = state.indexOf(i) !== -1;
      step.classList.toggle("is-done", cb.checked);
      cb.addEventListener("change", function () {
        step.classList.toggle("is-done", cb.checked);
        var s = load(key, []).filter(function (x) { return x !== i; });
        if (cb.checked) s.push(i);
        save(key, s);
        update();
      });
    });

    var reset = $("[data-reset-steps]");
    if (reset) reset.addEventListener("click", function () {
      save(key, []);
      steps.forEach(function (s) { s.classList.remove("is-done"); $(".step-check input", s).checked = false; });
      update();
    });
    update();
  }

  // ---- questions --------------------------------------------------------
  function norm(s) {
    return String(s).trim().replace(/^\$\s+/, "").replace(/\s+/g, " ").replace(/[.;]$/, "").toLowerCase();
  }

  function initQuestions() {
    $$("[data-question]").forEach(function (q) {
      var type = q.getAttribute("data-question");
      var feedback = $(".question-feedback", q);
      var expl = $(".question-explanation", q);
      var check = $("[data-q-check]", q);
      var reveal = $("[data-q-reveal]", q);
      var reset = $("[data-q-reset]", q);
      var hint = q.getAttribute("data-hint");
      var attempts = 0;

      function say(msg, cls) {
        feedback.textContent = msg;
        feedback.className = "question-feedback" + (cls ? " " + cls : "");
      }
      function solved() { q.classList.add("is-solved"); if (expl) expl.hidden = false; }

      if (type === "open") {
        var notes = $("textarea", q);
        var nkey = "notes:" + location.pathname + "#" + q.id;
        if (notes) {
          notes.value = load(nkey, "");
          notes.addEventListener("input", function () { save(nkey, notes.value); });
        }
        if (reveal) reveal.addEventListener("click", function () {
          if (expl && expl.children.length) { expl.hidden = !expl.hidden; }
          else { say("Saved. Discuss your answer with the group.", "is-correct"); }
          q.classList.add("is-solved");
        });
        return;
      }

      var answers = [];
      try { answers = JSON.parse(q.getAttribute("data-answers") || "[]").map(norm); } catch (e) { answers = []; }
      var correct = q.getAttribute("data-correct");
      var input = $(".question-input", q);

      function wrong() {
        attempts++;
        if (hint && attempts >= 2) say("Hint: " + hint, "is-hint");
        else say("Not quite. Try again.", "is-wrong");
      }

      function doCheck() {
        if (type === "text") {
          if (!input.value.trim()) { say("Type an answer first.", ""); return; }
          if (answers.indexOf(norm(input.value)) !== -1) { say("Correct!", "is-correct"); solved(); }
          else wrong();
        } else if (type === "choice") {
          var picked = $("input:checked", q);
          $$(".question-option", q).forEach(function (o) { o.classList.remove("is-correct", "is-wrong"); });
          if (!picked) { say("Choose an option first.", ""); return; }
          var opt = picked.closest(".question-option");
          if (picked.value === String(correct)) { opt.classList.add("is-correct"); say("Correct!", "is-correct"); solved(); }
          else { opt.classList.add("is-wrong"); wrong(); }
        }
      }

      if (check) check.addEventListener("click", doCheck);
      if (input) input.addEventListener("keydown", function (e) { if (e.key === "Enter") { e.preventDefault(); doCheck(); } });
      if (reveal) reveal.addEventListener("click", function () {
        if (type === "choice") {
          var right = $('input[value="' + correct + '"]', q);
          if (right) right.closest(".question-option").classList.add("is-correct");
        }
        say("", "");
        if (expl) expl.hidden = false;
      });
      if (reset) reset.addEventListener("click", function () {
        attempts = 0; say("", ""); q.classList.remove("is-solved");
        if (expl) expl.hidden = true;
        if (input) { input.value = ""; input.focus(); }
        $$("input[type=radio]", q).forEach(function (r) { r.checked = false; });
        $$(".question-option", q).forEach(function (o) { o.classList.remove("is-correct", "is-wrong"); });
      });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initSidebar();
    initCode();
    initSteps();
    initQuestions();
    initLecture();
    initResume();
    paintCompletion();
  });
})();
