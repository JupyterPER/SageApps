function getBrowserLanguage() {
  return (navigator.language || navigator.userLanguage).substring(0, 2);
}

function makeMenu() {
  var lang = getBrowserLanguage();
  $("head").first().append('<link rel="stylesheet" href="custom.css">');
  $("body").first().append('<script src="custom.js"><\/script>');

  var toggleCodeText = lang === "de" ? "Code ausblenden/einblenden" : "Show / Hide Code";
  var executeCellsText = lang === "de" ? "Code-Zellen in der gegebenen Reihenfolge ausführen!" : "Execute Cells in the Sequence Given!";
  var saveText = lang === "de" ? "Speichern" : "Save";

  var readButton = '<a href="#" role="button" id="read-button" class="btn btn-primary" onclick="setView()">' +
    (lang === "de" ? "Lesen" : "Read") + "</a>";
  var executeButton = '<a href="#" role="button" id="execute-button" class="btn btn-primary" onclick="setExecute()">' +
    (lang === "de" ? "Ausführen" : "Execute") + "</a>";

  var navbar =
    '<div id="navbar">' +
    (playerConfig.panes === "Exec" ? "" : readButton + executeButton) +
    '<a href="#" role="button" class="btn btn-primary" onclick="toggleInput()">' + toggleCodeText + '</a>\n' +
    '<a href="#" role="button" class="btn btn-primary" onclick="saveHtml()">' + saveText + "</a>" +
    (playerConfig.linked ? '<a id="evalWarning" href="#" role="button" class="btn btn-warning" style="display: none;">' + executeCellsText + "</a>" : "") +
    '\n<img src="' + playerConfig.playerPath + '/resources/logo.png" width="45px" style="float:right;"></img>\n</div>';

  $("body").prepend(navbar);
  $("#main").addClass("belowMenu");
}

function scrollFunction() {
  var navbar = document.getElementById("navbar");
  var sticky = navbar.offsetTop;
  if (window.pageYOffset >= sticky) {
    navbar.classList.add("sticky");
  } else {
    navbar.classList.remove("sticky");
  }
}

function saveHtml() {
  saveAddSageCells(".nb-code-cell", ".sagecell_input,.sagecell_output");
  $("script").html().replace(/\u200B/g, "");
  var blob = new Blob([
    "<!DOCTYPE html>\n<html>\n<head>" + $("head").html() + '</head>\n<body>\n<div id="main">' + $("#main").html() + '</div>\n' +
    '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js" integrity="sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW" crossorigin="anonymous"><\/script>\n' +
    '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"><\/script>\n' +
    '<script src="https://sagecell.sagemath.org/embedded_sagecell.js"><\/script>\n' +
    '<script src="' + playerConfig.playerPath + '/vendor/js/FileSaver.min.js"><\/script>\n' +
    '<script src="' + playerConfig.playerPath + '/nbplayerConfig.js"><\/script>\n' +
    '<script src="' + playerConfig.playerPath + '/js/nbrunner.min.js"><\/script>\n' +
    '<script>\n' +
    '  playerConfig=' + JSON.stringify(playerConfig) + ";\n" +
    '  playerMode=' + JSON.stringify(playerMode) + ";\n" +
    '  makeMenu();\n' +
    '  localize();\n' +
    '  loadStatus();\n' +
    '  makeSageCells(playerConfig);\n' +
    '  launchPlayer();\n' +
    '<\/script>\n' +
    '</body></html>'
  ], { type: "text/plain;charset=utf-8" });

  saveAs(blob, playerConfig.name + ".html");

  let message = "Do NOT use this page anymore - open your saved copy or reload this page.";
  if ("de" === getBrowserLanguage()) {
    message = "Bitte die Seite neu laden oder die gespeicherte Kopie öffnen.";
  }
  $("#navbar").html('<div class="save-warning">' + message + "</div>");
}

function makeSageCells(config) {
  sagecell.makeSagecell({
    inputLocation: "div.compute",
    languages: [config.lang],
    evalButtonText: getBrowserLanguage() === "de" ? "Ausführen" : "Execute",
    linked: config.linked,
    autoeval: config.eval,
    hide: config.hide
  });
}

function saveAddSageCells(selector, removeSelector) {
  $(selector).each(function () {
    $(this).append("\n  <div class='compute'>\n    <script type='text/x-sage'>1+1<\/script>\n  </div>");
    let input = getSageInput($(this));
    input = input.replace(/\u200B/g, "");
    $(this).find(".compute script").text(input);
    if (removeSelector) $(this).find(removeSelector).remove();
    $(this).find(".compute").hide();
  });
}

window.onscroll = function () { scrollFunction() };

let playerConfig = {
  panes: "ExecRead",
  lang: "sage",
  linked: true,
  eval: false,
  hide: ["fullScreen"],
  execute: true,
  showRead: true,
  collapsable: false,
  playerPath: playerPath
};

let cellInput = ".nb-input",
  cellOutput = ".nb-output",
  codeCell = ".nb-code-cell";

function getSageInput(element) {
  let input = "";
  element.find(".CodeMirror-line").each(function () {
    input += $(this).text() + "\n";
  });
  return input;
}

let playerMode = {
  showSage: false,
  showNotebookInput: true,
  showSageInput: true
};

function launchPlayer() {
  playerMode.showSage ? setExecute() : setView();
}

function setView() {
  $(".compute").hide();
  if (playerMode.showNotebookInput) $(cellInput).show();
  $(cellOutput).show();
  playerMode.showSage = false;
  $("#evalWarning").hide();
}

function setExecute() {
  $(cellInput).hide();
  $(cellOutput).hide();
  $(".compute").show();
  if (!playerMode.showSageInput) $(".compute .sagecell_input").hide();
  playerMode.showSage = true;
  $("#evalWarning").show();
}

function toggleInput() {
  if (playerMode.showSage) {
    $(".compute .sagecell_input").toggle();
    playerMode.showSageInput = !playerMode.showSageInput;
  } else {
    $(cellInput).toggle();
    playerMode.showNotebookInput = !playerMode.showNotebookInput;
  }
}

function makeTransferData() {
  $(".nbdataIn,.nbdataOut").parents(".nb-cell").each(function () {
    let cell = $(this);
    cell.before('<div class="transferData"></div>');
    let transferData = cell.prev(),
      nextCell = cell.next();
    cell.appendTo(transferData);
    nextCell.appendTo(transferData);

    if (transferData.find(".nbdataOut").length) {
      transferData.attr("id", "transferDataOut");
      getBrowserLanguage();
      if (transferData.append('<br/><p><input type="button" role="button" class="btn btn-primary status2Clipboard" onclick="status2ClipBoard()" value="Copy status to clipboard" /></p>'), transferData.append('<p><input type="button" role="button" class="btn btn-primary status2Storage" onclick="status2Storage()" value="Save status" /></p>'), transferData.find(".successor").length) {
        transferData.find("ul").children("a").remove();
        transferData.append('<p id="contMsg">Continue reading:</p>');
        transferData.append("<ul></ul>");
        let ul = transferData.children().last();
        transferData.find(".successor").each(function () {
          let link = $(this).find("a").first().attr("href");
          link = link.replace("ipynb", "html");
          $(this).find("a").attr("href", link);
          $(this).appendTo(ul);
          $(this).append(' <input type="button" role="button" class="btn btn-primary openWithStatus" onclick="openWithStatus(\'' + link + '?status=true\')" value="Open with current status" />');
        });
      }
    } else {
      transferData.attr("id", "transferDataIn");
    }
  });
}

const copyToClipboard = (text) => {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "absolute";
  textarea.style.left = "-9999px";
  document.body.appendChild(textarea);
  const selected = document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;
  textarea.select();
  document.execCommand("copy");
  document.body.removeChild(textarea);
  if (selected) {
    document.getSelection().removeAllRanges();
    document.getSelection().addRange(selected);
  }
};

function getStatus() {
  return $("#transferDataOut .sagecell_stdout").first().text();
}

function openWithStatus(url) {
  let status = getStatus();
  if (status.length) {
    localStorage.setItem("mtStatus", status);
    window.open(url, "_blank");
  } else {
    let message = getBrowserLanguage() === "de" ? "Fehler: Die Statusberechnung wurde noch nicht ausgeführt" : "Error: Status cell not yet executed";
    alert(message);
  }
}

function status2ClipBoard() {
  let status = getStatus(),
    lang = getBrowserLanguage(),
    message = "";
  if (status.length) {
    message = lang === "de" ? "Status in die Zwischenablage kopiert" : "Status copied to clipboard";
    copyToClipboard(status);
    alert(message);
  } else {
    message = lang === "de" ? "Fehler: Die Statusberechnung wurde noch nicht ausgeführt" : "Error: Status cell not yet executed";
    alert(message);
  }
}

function status2Storage() {
  let param = GetURLParameterWithDefault("status", false);
  param && param.toString() !== "true" || (param = "mtStatus");
  param.toString() === "true" && (param = "mtStatus");

  let status = getStatus(),
    lang = getBrowserLanguage(),
    message = "";
  if (status.length) {
    localStorage.setItem(param, status);
    message = lang === "de" ? "Status gespeichert" : "Status saved";
    alert(message);
  } else {
    message = lang === "de" ? "Fehler: Die Statusberechnung wurde noch nicht ausgeführt" : "Error: Status cell not yet executed";
    alert(message);
  }
}

function GetURLParameterWithDefault(param, defaultValue) {
  var params = window.location.search.substring(1).split("&");
  for (var i = 0; i < params.length; i++) {
    var pair = params[i].split("=");
    if (pair[0] === param) return decodeURIComponent(pair[1]);
  }
  return defaultValue;
}

function loadStatus() {
  let param = GetURLParameterWithDefault("status", false);
  if (param) {
    param.toString() === "true" && (param = "mtStatus");
    let status = localStorage.getItem(param);
    if (status) {
      $(".transferData").each(function () {
        let transferData = $(this);
        if (transferData.find(".nbdataIn").length) {
          transferData.find(".nb-code-cell script").html(status + '\nprint("Status restored")');
        }
      });
    }
  }
}

function localize() {
  let translations = {
    ".status2Clipboard": { type: "value", de: "Status  in die Zwischenablage kopieren", en: "Copy status to clipboard" },
    ".loadStatus": { type: "value", de: "Status laden", en: "Load status" },
    ".status2Storage": { type: "value", de: "Status speichern", en: "Save status" },
    "#contMsg": { type: "html", de: "Weiterlesen:", en: "Continue reading:" },
    ".openWithStatus": { type: "value", de: "Mit aktuellem Status öffnen", en: "Open with current status" }
  };

  let lang = getBrowserLanguage();
  let keys = Object.keys(translations);
  for (let i = 0; i < keys.length; i++) {
    let key = keys[i];
    if (translations[key][lang]) {
      if (translations[key].type === "html") {
        $(key).html(translations[key][lang]);
      } else {
        $(key).attr(translations[key].type, translations[key][lang]);
      }
    }
  }
}