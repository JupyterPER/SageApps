function getBrowserLanguage() {
    return (navigator.language || navigator.userLanguage).substring(0, 2)
}

function makeMenu() {
    var e = getBrowserLanguage();
    $("head").first().append('<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/JupyterPER/SageMathApplications@main//NBplayerAI/css/nbplayer.css"'), $("body").first().append('<script src="custom.js"><\/script>');
    var t = "de" == e ? "Code ausblenden/einblenden" : "Show / Hide Code",
        n = "de" == e ? "Code-Zellen in der gegebenen Reihenfolge ausfĂĽhren!" : "Execute Cells in the Sequence Given!",
        a = "de" == e ? "Speichern" : "Save",
        s = '<a href="#" role="button" id="read-button" class="btn btn-primary" onclick="setView()">' + ("de" == e ? 'Lesen' : 'Read') + '</a>',
      o = '<a href="#" role="button" id="execute-button" class="btn btn-primary" onclick="setExecute()">' + ('de' == e ? 'AusfĂĽhren' : 'Execute') + '</a>',
      l = '<div id="navbar">' + ('Exec' == playerConfig.panes ? "" : s + o) + '<a href="#" role="button" class="btn btn-primary" onclick="toggleInput()">' + t + '</a>\n  <a href="#" role="button" class="btn btn-primary" onclick="saveHtml()">' + a + "</a>" + '\n  </div>';
    $("body").prepend(l), $("#main").addClass("belowMenu")
}

function scrollFunction() {
    var e = document.getElementById("navbar"),
        t = e.offsetTop;
    window.pageYOffset >= t ? e.classList.add("sticky") : e.classList.remove("sticky")
}

function saveHtml() {

	removeAllControlBars();
	// Update the content of all input and preview elements
    document.querySelectorAll('[id^="mdinput"]').forEach((input, index) => {
        const preview = document.querySelectorAll('[id^="preview"]')[index];
        if (input.style.display !== 'none') {
            // If input is visible, update the data-original attribute
            input.setAttribute('data-original', input.value);
        } else {
            // If preview is visible, ensure it reflects the latest rendered content
            preview.innerHTML = texme.render(input.getAttribute('data-original') || '');
        }
    });

    saveAddSageCells(".nb-code-cell", ".sagecell_input,.sagecell_output");
    $("script").html().replace(/\u200B/g, "");

    const apikey = typeof API_KEY !== 'undefined' ? JSON.stringify(API_KEY) : JSON.stringify('');
    const currentmodel = typeof CURRENT_MODEL !== 'undefined' ? JSON.stringify(CURRENT_MODEL) : JSON.stringify('');
    const delayValue = document.getElementById('delay') ? parseInt(document.getElementById('delay').value) || RUN_DELAY : RUN_DELAY;
    var e = new Blob(["<!DOCTYPE html>\n<html>\n<head>" + $("head").html() + '</head>\n<body>\n<script src="https://cdn.jsdelivr.net/npm/texme@1.2.2"></script>\n<div id="main">' + $("#main").html() + '</div>\n  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js" integrity="sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW" crossorigin="anonymous"><\/script>\n  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"><\/script>\n  <script src="https://sagecell.sagemath.org/embedded_sagecell.js"><\/script>\n  <script src="' + playerConfig.playerPath + '/vendor/js/FileSaver.min.js"><\/script>\n  <script src="' + playerConfig.playerPath + '/nbplayerConfig.js"><\/script>\n  <script>let RUN_DELAY = '+ RUN_DELAY +';</script>\n  <script src="https://cdn.jsdelivr.net/gh/JupyterPER/SageMathApplications@main/NBplayerAI/js/nbrunner4.js"><\/script>\n  <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>\n  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/JupyterPER/SageMathApplications@main//NBplayerAI/css/nbplayer.css">\n  <script>\n    playerConfig=' + JSON.stringify(playerConfig) + ";\n    playerMode=" + JSON.stringify(playerMode) + ";\n    makeMenu();\n    localize();\n    loadStatus();\n    makeSageCells(playerConfig);\n    launchPlayer();\n    addControlPanel();\n    setupRunAllCells();\n    window.onload = initializeMarkdownCells;\n    let API_KEY=" + apikey + ";\n    let CURRENT_MODEL=" + currentmodel + ";\n  <\/script>\n</body>\n</html>"], {
        type: "text/plain;charset=utf-8"
    });
    saveAs(e, playerConfig.name + ".html");
    let t = "Do NOT use this page anymore - open your saved copy or reload this page.";
    if (getBrowserLanguage() == "de") {
        t = "Bitte die Seite neu laden oder die gespeicherte Kopie öffnen.";
    }
    $("#navbar").html('<div class="save-warning">' + t + "</div>");
}

function makeSageCells(e) {
    sagecell.makeSagecell({
        inputLocation: "div.compute",
        languages: [e.lang],
        evalButtonText: "de" == getBrowserLanguage() ? "AusfĂĽhren" : "Execute",
        linked: e.linked,
        autoeval: e.eval,
        hide: e.hide
    })
}

function saveAddSageCells(e, t) {
    $(e).each((function() {
        $(this).append("\n  <div class='compute'>\n    <script type='text/x-sage'>1+1<\/script>\n  </div>");
        let e = getSageInput($(this));
        e = e.replace(/\u200B/g, ""), $(this).find(".compute script").text(e), t && $(this).find(t).remove(), $(this).find(".compute").hide()
    }))
}


window.onscroll = function() {
    scrollFunction()
};
let playerConfig = {
        panes: "ExecRead",
        lang: "sage",
        linked: !0,
        eval: !1,
        hide: ["fullScreen"],
        execute: !0,
        showRead: !0,
        collapsable: !1,
        playerPath: playerPath
    },
    cellInput = ".nb-input",
    cellOutput = ".nb-output",
    codeCell = ".nb-code-cell";

function getSageInput(e) {
    let t = "";
    return e.find(".CodeMirror-line").each((function() {
        t += $(this).text() + "\n"
    })), t
}
let playerMode = {
    showSage: !1,
    showNotebookInput: !0,
    showSageInput: !0
};

function launchPlayer() {
    playerMode.showSage ? setExecute() : setView()
}

function setView() {
    $(".compute").hide(), playerMode.showNotebookInput && $(cellInput).show(), $(cellOutput).show(), playerMode.showSage = !1, $("#evalWarning").hide()
}



function setExecute() {
    $(cellInput).hide(), $(cellOutput).hide(), $(".compute").show(), playerMode.showSageInput || $(".compute .sagecell_input").hide(), playerMode.showSage = !0, $("#evalWarning").show()
}

function toggleInput() {
    playerMode.showSage ? ($(".compute .sagecell_input").toggle(), playerMode.showSageInput = !playerMode.showSageInput) : ($(cellInput).toggle(), playerMode.showNotebookInput = !playerMode.showNotebookInput)
}

function makeTransferData() {
    $(".nbdataIn,.nbdataOut").parents(".nb-cell").each((function() {
        let e = $(this);
        e.before('<div class="transferData"></div>');
        let t = e.prev(),
            n = e.next();
        e.appendTo(t), n.appendTo(t);
        if (t.find(".nbdataOut").length) {
            t.attr("id", "transferDataOut");
            getBrowserLanguage();
            if (t.append('<br/><p><input type="button" role="button" class="btn btn-primary status2Clipboard" onclick="status2ClipBoard()" value="Copy status to clipboard" /></p>'), t.append('<p><input type="button" role="button" class="btn btn-primary status2Storage" onclick="status2Storage()" value="Save status" /></p>'), t.find(".successor").length) {
                t.find("ul").children("a").remove(), t.append('<p id="contMsg">Continue reading:</p>'), t.append("<ul></ul>");
                let e = t.children().last();
                t.find(".successor").each((function() {
                    let t = $(this).find("a").first().attr("href");
                    t = t.replace("ipynb", "html"), $(this).find("a").attr("href", t), $(this).appendTo(e), $(this).append(' <input type="button" role="button" class="btn btn-primary openWithStatus" onclick="openWithStatus(\'' + t + '?status=true\')" value="Open with current status" />')
                }))
            }
        } else t.attr("id", "transferDataIn")
    }))
}
const copyToClipboard = e => {
    const t = document.createElement("textarea");
    t.value = e, t.setAttribute("readonly", ""), t.style.position = "absolute", t.style.left = "-9999px", document.body.appendChild(t);
    const n = document.getSelection().rangeCount > 0 && document.getSelection().getRangeAt(0);
    t.select(), document.execCommand("copy"), document.body.removeChild(t), n && (document.getSelection().removeAllRanges(), document.getSelection().addRange(n))
};

function getStatus() {
    return $("#transferDataOut .sagecell_stdout").first().text()
}

function openWithStatus(e) {
    let t = getStatus();
    if (t.length) localStorage.setItem("mtStatus", t), window.open(e, "_blank");
    else {
        let e = "";
        e = "de" == getBrowserLanguage() ? "Fehler: Die Statusberechnung wurde noch nicht ausgefĂĽhrt" : "Error: Status cell not yet executed", alert(e)
    }
}

function status2ClipBoard() {
    let e = getStatus(),
        t = getBrowserLanguage(),
        n = "";
    e.length ? (n = "de" == t ? "Status in die Zwischenablage kopiert" : "Status copied to clipboard", copyToClipboard(e), alert(n)) : (n = "de" == t ? "Fehler: Die Statusberechnung wurde noch nicht ausgefĂĽhrt" : "Error: Status cell not yet executed", alert(n))
}

function status2Storage() {
    let e = GetURLParameterWithDefault("status", !1);
    e && "true" != e.toString() || (e = "mtStatus"), "true" == e.toString() && (e = "mtStatus");
    let t = getStatus(),
        n = getBrowserLanguage(),
        a = "";
    t.length ? (localStorage.setItem(e, t), a = "de" == n ? "Status gespeichert" : "Status saved", alert(a)) : (a = "de" == n ? "Fehler: Die Statusberechnung wurde noch nicht ausgefĂĽhrt" : "Error: Status cell not yet executed", alert(a))
}

function GetURLParameterWithDefault(e, t) {
    for (var n = window.location.search.substring(1).split("&"), a = 0; a < n.length; a++) {
        var s = n[a].split("=");
        if (s[0] == e) return decodeURIComponent(s[1])
    }
    return t
}

function loadStatus() {
    let e = GetURLParameterWithDefault("status", !1);
    if (e) {
        "true" == e.toString() && (e = "mtStatus");
        let t = localStorage.getItem(e);
        t && $(".transferData").each((function() {
            let e = $(this);
            e.find(".nbdataIn").length && e.find(".nb-code-cell script").html(t + '\nprint("Status restored")')
        }))
    }
}

function localize() {
    let e = {
            ".status2Clipboard": {
                type: "value",
                de: "Status  in die Zwischenablage kopieren",
                en: "Copy status to clipboard"
            },
            ".loadStatus": {
                type: "value",
                de: "Status laden",
                en: "Load status"
            },
            ".status2Storage": {
                type: "value",
                de: "Status speichern",
                en: "Save status"
            },
            "#contMsg": {
                type: "html",
                de: "Weiterlesen:",
                en: "Continue reading:"
            },
            ".openWithStatus": {
                type: "value",
                de: "Mit aktuellem Status Ă¶ffnen",
                en: "Open with current status"
            }
        },
        t = getBrowserLanguage(),
        n = Object.keys(e);
    for (let a = 0; a < n.length; a++) {
        let s = n[a];
        e[s][t] && ("html" == e[s].type ? $(s).html(e[s][t]) : $(s).attr(e[s].type, e[s][t]))
    }
}


function setupRunAllCells() {
    function runAllCells() {
        const delay = parseInt(document.getElementById('delay').value) || 900;
        const executeButtons = document.querySelectorAll('.sagecell_evalButton.ui-button.ui-corner-all.ui-widget');
        
        executeButtons.forEach((button, index) => {
            setTimeout(() => {
                button.click();
            }, delay * (index + 1));
        });
    }

    document.getElementById('runAllCellsButton').addEventListener('click', runAllCells);
}

function removeDuplicateStyles() {
    // Get all style elements
    const styles = document.getElementsByTagName('style');
    
    // Create a Set to store unique style contents
    const uniqueStyles = new Set();
    
    // Iterate through the styles in reverse order
    for (let i = styles.length - 1; i >= 0; i--) {
        const style = styles[i];
        const styleContent = style.textContent.trim();
        
        // Check if this style content has been seen before
        if (uniqueStyles.has(styleContent)) {
            // If it's a duplicate, remove it
            style.parentNode.removeChild(style);
        } else {
            // If it's unique, add it to the Set
            uniqueStyles.add(styleContent);
        }
    }
}

// Run the function when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', removeDuplicateStyles);



let editMode = true;

function toggleEditMode() {
    if (editMode) {
		toggleMarkdownMode();
        editMode = false;
    } else {
		toggleMarkdownMode();
        editMode = true;
    }
}

function updateMarkdownPreview(cell) {
    const input = cell.querySelector('[id^="mdinput"]');
    const preview = cell.querySelector('[id^="preview"]');

    if (!input || !preview) {
        console.error("Input or preview element not found in the cell.");
        return;
    }

    // Store original markdown
    input.setAttribute('data-original', input.value);

    // Render content
    if (typeof texme !== 'undefined' && texme.render) {
        const output = texme.render(input.value);
        preview.innerHTML = output;

        // Ensure all hyperlinks in the preview open in a new tab
        preview.querySelectorAll('a').forEach(link => {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        });
    } else {
        console.error("Texme is not defined or not initialized.");
    }

    // Hide input, show preview
    input.style.display = 'block';
    preview.style.display = 'block';

    // Reset and typeset MathJax
    window.MathJax.texReset();
    window.MathJax.typesetPromise([preview]);
}


function toggleMarkdownMode() {
    var inputs = document.querySelectorAll('[id^="mdinput"]');
    var previews = document.querySelectorAll('[id^="preview"]');
    inputs.forEach((input, index) => {
        var preview = previews[index];

        if (editMode) {
            // Show input, hide preview
            input.value = input.getAttribute('data-original') || '';
            input.style.display = 'block';
            preview.style.display = 'block';
        } else {
            // Store original markdown
            input.setAttribute('data-original', input.value);

            // Render content
            if (typeof texme !== 'undefined' && texme.render) {
                var output = texme.render(input.value);
                preview.innerHTML = output;
            } else {
                console.error("Texme is not defined or not initialized.");
            }
            input.style.display = 'none';
            preview.style.display = 'block';
        }
    });

    if (!editMode) {
        // Only reset and typeset MathJax once after all previews are updated
        window.MathJax.texReset();
        window.MathJax.typesetPromise();
    }

    // Toggle editMode after processing all elements
    editMode = !editMode;
}


function addControlPanel() {
	const controlPanel = document.createElement('div');
    controlPanel.id = 'controls';
    const navbar = document.getElementById('navbar');
    
    if (!navbar) {
        console.error("Navbar element not found");
        return;
    }

    const input = document.createElement('input');
    input.type = 'number';
    input.id = 'delay';
    input.placeholder = 'Step (ms)';
    input.min = '1';
    input.value = RUN_DELAY;
    input.addEventListener('change', function() {
        RUN_DELAY = parseInt(this.value) || 1000;
    });

    const runButton = document.createElement('button');
    runButton.id = 'runAllCellsButton';
    runButton.textContent = 'Run All Cells';

    const toggleNavbarButton = document.createElement('button');
    toggleNavbarButton.id = 'toggleNavbar';
    toggleNavbarButton.textContent = 'Toggle Bar';
    toggleNavbarButton.onclick = toggleNavbar;

    const editCellsButton = document.createElement('button');
    editCellsButton.id = 'editCells';
    editCellsButton.textContent = 'Edit Cells';
    editCellsButton.onclick = toggleEditMode;

    const exportButton = document.createElement('button');
    exportButton.id = 'exportCells';
    exportButton.textContent = 'Export';
    exportButton.onclick = downloadNotebookText;

    const importButton = document.createElement('button');
    importButton.id = 'importCells';
    importButton.textContent = 'Import';
    importButton.onclick =
      function() {
        // Create and trigger a file input
        const fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.accept = '.txt';
        fileInput.style.display = 'none';

        fileInput.onchange = function(event) {
            const file = event.target.files[0];
            if (file) {
                importNotebookFromFile(file);
            }
            document.body.removeChild(fileInput);
        };

        document.body.appendChild(fileInput);
        fileInput.click();
    };

    const aiSettingsButton = document.createElement('button');
    aiSettingsButton.id = 'aiSettings';
    aiSettingsButton.textContent = 'AI Settings';
    aiSettingsButton.onclick = createModalWindow;

    // Insert the new elements at the beginning of the navbar
    navbar.insertBefore(exportButton, navbar.firstChild);
    navbar.insertBefore(importButton, navbar.firstChild);
    navbar.insertBefore(aiSettingsButton, navbar.firstChild);
    navbar.insertBefore(editCellsButton, navbar.firstChild);
    navbar.insertBefore(input, navbar.firstChild);
    navbar.insertBefore(runButton, navbar.firstChild);

	
	controlPanel.appendChild(toggleNavbarButton);
	document.body.insertBefore(controlPanel, main);
    const linkElement = document.querySelector('link[href="https://dahn-research.eu/nbplayer/css/nbplayer.css"]');
    if (linkElement) {
        linkElement.href = "https://cdn.jsdelivr.net/gh/JupyterPER/SageMathApplications@main//NBplayerAI/css/nbplayer.css";
    }
    // Automatically click the Edit Cells button twice
    setTimeout(() => {
        editCellsButton.click();
        setTimeout(() => {
            editCellsButton.click();
        }, 100); // 100ms delay between clicks
    }, 100); // Wait 100ms after creation before first click
}


function toggleNavbar() {
    const navbar = document.getElementById('navbar');
    
    if (navbar.style.display === 'none') {
        navbar.style.display = '';
        navbar.style.visibility = 'visible';
        navbar.style.opacity = '1';
    } else {
        navbar.style.display = 'none';
        navbar.style.visibility = 'hidden';
        navbar.style.opacity = '0';
    }
}


const iconDictionary = {
    addBelow: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
        <path d="M9.25 10.0693H7.375V8.19434C7.375 7.98809 7.20625 7.81934 7 7.81934C6.79375 7.81934 6.625 7.98809 6.625 8.19434V10.0693H4.75C4.54375 10.0693 4.375 10.2381 4.375 10.4443C4.375 10.6506 4.54375 10.8193 4.75 10.8193H6.625V12.6943C6.625 12.9006 6.79375 13.0693 7 13.0693C7.20625 13.0693 7.375 12.9006 7.375 12.6943V10.8193H9.25C9.45625 10.8193 9.625 10.6506 9.625 10.4443C9.625 10.2381 9.45625 10.0693 9.25 10.0693Z" fill="#616161"/>
        <path fill-rule="evenodd" clip-rule="evenodd" d="M2.5 5.5V3.5H11.5V5.5H2.5ZM2 7C1.44772 7 1 6.55228 1 6V3C1 2.44772 1.44772 2 2 2H12C12.5523 2 13 2.44772 13 3V6C13 6.55229 12.5523 7 12 7H2Z" fill="#616161"/>
    </svg>`,
    addAbove: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
        <path d="M9.25 3.93066H7.375V5.80566C7.375 6.01191 7.20625 6.18066 7 6.18066C6.79375 6.18066 6.625 6.01191 6.625 5.80566V3.93066H4.75C4.54375 3.93066 4.375 3.76191 4.375 3.55566C4.375 3.34941 4.54375 3.18066 4.75 3.18066H6.625V1.30566C6.625 1.09941 6.79375 0.930664 7 0.930664C7.20625 0.930664 7.375 1.09941 7.375 1.30566V3.18066H9.25C9.45625 3.18066 9.625 3.34941 9.625 3.55566C9.625 3.76191 9.45625 3.93066 9.25 3.93066Z" fill="#616161"/>
        <path fill-rule="evenodd" clip-rule="evenodd" d="M2.5 8.5V10.5H11.5V8.5H2.5ZM2 7C1.44772 7 1 7.44772 1 8V11C1 11.5523 1.44772 12 2 12H12C12.5523 12 13 11.5523 13 11V8C13 7.44771 12.5523 7 12 7H2Z" fill="#616161"/></svg>`,
    moveDown: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none" data-icon="ui-components:move-down" class=""><path xmlns="http://www.w3.org/2000/svg" class="jp-icon3" d="M12.471 7.52899C12.7632 7.23684 12.7632 6.76316 12.471 6.47101V6.47101C12.179 6.17905 11.7057 6.17884 11.4135 6.47054L7.75 10.1275V1.75C7.75 1.33579 7.41421 1 7 1V1C6.58579 1 6.25 1.33579 6.25 1.75V10.1275L2.59726 6.46822C2.30338 6.17381 1.82641 6.17359 1.53226 6.46774V6.46774C1.2383 6.7617 1.2383 7.2383 1.53226 7.53226L6.29289 12.2929C6.68342 12.6834 7.31658 12.6834 7.70711 12.2929L12.471 7.52899Z" fill="#616161"></path></svg>`,
    moveUp: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none" data-icon="ui-components:move-up" class=""><path xmlns="http://www.w3.org/2000/svg" class="jp-icon3" d="M1.52899 6.47101C1.23684 6.76316 1.23684 7.23684 1.52899 7.52899V7.52899C1.82095 7.82095 2.29426 7.82116 2.58649 7.52946L6.25 3.8725V12.25C6.25 12.6642 6.58579 13 7 13V13C7.41421 13 7.75 12.6642 7.75 12.25V3.8725L11.4027 7.53178C11.6966 7.82619 12.1736 7.82641 12.4677 7.53226V7.53226C12.7617 7.2383 12.7617 6.7617 12.4677 6.46774L7.70711 1.70711C7.31658 1.31658 6.68342 1.31658 6.29289 1.70711L1.52899 6.47101Z" fill="#616161"></path></svg>`,
    bin: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16px" height="16px" data-icon="ui-components:delete" class=""><path xmlns="http://www.w3.org/2000/svg" d="M0 0h24v24H0z" fill="none"></path><path xmlns="http://www.w3.org/2000/svg" class="jp-icon3" fill="#626262" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"></path></svg>`,
    duplicate: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none" data-icon="ui-components:duplicate" class=""><path xmlns="http://www.w3.org/2000/svg" class="jp-icon3" fill-rule="evenodd" clip-rule="evenodd" d="M2.79998 0.875H8.89582C9.20061 0.875 9.44998 1.13914 9.44998 1.46198C9.44998 1.78482 9.20061 2.04896 8.89582 2.04896H3.35415C3.04936 2.04896 2.79998 2.3131 2.79998 2.63594V9.67969C2.79998 10.0025 2.55061 10.2667 2.24582 10.2667C1.94103 10.2667 1.69165 10.0025 1.69165 9.67969V2.04896C1.69165 1.40328 2.1904 0.875 2.79998 0.875ZM5.36665 11.9V4.55H11.0833V11.9H5.36665ZM4.14165 4.14167C4.14165 3.69063 4.50728 3.325 4.95832 3.325H11.4917C11.9427 3.325 12.3083 3.69063 12.3083 4.14167V12.3083C12.3083 12.7594 11.9427 13.125 11.4917 13.125H4.95832C4.50728 13.125 4.14165 12.7594 4.14165 12.3083V4.14167Z" fill="#616161"></path><path xmlns="http://www.w3.org/2000/svg" class="jp-icon3" d="M9.43574 8.26507H8.36431V9.3365C8.36431 9.45435 8.26788 9.55078 8.15002 9.55078C8.03217 9.55078 7.93574 9.45435 7.93574 9.3365V8.26507H6.86431C6.74645 8.26507 6.65002 8.16864 6.65002 8.05078C6.65002 7.93292 6.74645 7.8365 6.86431 7.8365H7.93574V6.76507C7.93574 6.64721 8.03217 6.55078 8.15002 6.55078C8.26788 6.55078 8.36431 6.64721 8.36431 6.76507V7.8365H9.43574C9.5536 7.8365 9.65002 7.93292 9.65002 8.05078C9.65002 8.16864 9.5536 8.26507 9.43574 8.26507Z" fill="#616161" stroke="#616161" stroke-width="0.5"></path></svg>`,
    aiComplete: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" class="">
    <path class="jp-icon3" d="m8 8-4 4 4 4m8 0 4-4-4-4m-2-3-4 14" stroke="#616161" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path></svg>`,
    aiFormat: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" class=""><path class="jp-icon3" d="M14 4.182A4.136 4.136 0 0 1 16.9 3c1.087 0 2.13.425 2.899 1.182A4.01 4.01 0 0 1 21 7.037c0 1.068-.43 2.092-1.194 2.849L18.5 11.214l-5.8-5.71 1.287-1.31.012-.012Zm-2.717 2.763L6.186 12.13l2.175 2.141 5.063-5.218-2.141-2.108Zm-6.25 6.886-1.98 5.849a.992.992 0 0 0 .245 1.026 1.03 1.03 0 0 0 1.043.242L10.282 19l-5.25-5.168Zm6.954 4.01 5.096-5.186-2.218-2.183-5.063 5.218 2.185 2.15Z" fill="#616161"></path></svg>`,
    aiExplain: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" class=""><path class="jp-icon3" d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10S2 17.523 2 12Zm9.008-3.018a1.502 1.502 0 0 1 2.522 1.159v.024a1.44 1.44 0 0 1-1.493 1.418 1 1 0 0 0-1.037.999V14a1 1 0 1 0 2 0v-.539a3.44 3.44 0 0 0 2.529-3.256 3.502 3.502 0 0 0-7-.255 1 1 0 0 0 2 .076c.014-.398.187-.774.48-1.044Zm.982 7.026a1 1 0 1 0 0 2H12a1 1 0 1 0 0-2h-.01Z" fill="#616161"></path></svg>`,
    addEditExcel: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" class=""><path class="jp-icon3" stroke="#616161" stroke-width="2" d="M3 11h18M3 15h18m-9-4v8m-8 0h16a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1Z"/></svg>`,
    markdownTips: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"><path d="M10 1c3.11 0 5.63 2.52 5.63 5.62 0 1.84-2.03 4.58-2.03 4.58-.33.44-.6 1.25-.6 1.8v1c0 .55-.45 1-1 1H8c-.55 0-1-.45-1-1v-1c0-.55-.27-1.36-.6-1.8 0 0-2.02-2.74-2.02-4.58C4.38 3.52 6.89 1 10 1zM7 16.87V16h6v.87c0 .62-.13 1.13-.75 1.13H12c0 .62-.4 1-1.02 1h-2c-.61 0-.98-.38-.98-1h-.25c-.62 0-.75-.51-.75-1.13z" fill="#616161"/></svg>`
};


function generateNewCellUpButtonHTML() {
    const svgIcon = `
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M4.75 4.93066H6.625V6.80566C6.625 7.01191 6.79375 7.18066 7 7.18066C7.20625 7.18066 7.375 7.01191 7.375 6.80566V4.93066H9.25C9.45625 4.93066 9.625 4.76191 9.625 4.55566C9.625 4.34941 9.45625 4.18066 9.25 4.18066H7.375V2.30566C7.375 2.09941 7.20625 1.93066 7 1.93066C6.79375 1.93066 6.625 2.09941 6.625 2.30566V4.18066H4.75C4.54375 4.18066 4.375 4.34941 4.375 4.55566C4.375 4.76191 4.54375 4.93066 4.75 4.93066Z" fill="#616161"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M11.5 9.5V11.5H2.5V9.5H11.5ZM12 8C12.5523 8 13 8.44772 13 9V12C13 12.5523 12.5523 13 12 13H2C1.44772 13 1 12.5523 1 12V9C1 8.44772 1.44771 8 2 8H12Z" fill="#616161"/>
        </svg>
    `;

    return `
    <button class="new-cell-up-button" title="New Cell Up">
        ${svgIcon}
    </button>`;
}

function generateNewCellDownButtonHTML() {
    const svgIcon = `
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M9.25 10.0693H7.375V8.19434C7.375 7.98809 7.20625 7.81934 7 7.81934C6.79375 7.81934 6.625 7.98809 6.625 8.19434V10.0693H4.75C4.54375 10.0693 4.375 10.2381 4.375 10.4443C4.375 10.6506 4.54375 10.8193 4.75 10.8193H6.625V12.6943C6.625 12.9006 6.79375 13.0693 7 13.0693C7.20625 13.0693 7.375 12.9006 7.375 12.6943V10.8193H9.25C9.45625 10.8193 9.625 10.6506 9.625 10.4443C9.625 10.2381 9.45625 10.0693 9.25 10.0693Z" fill="#616161"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.5 5.5V3.5H11.5V5.5H2.5ZM2 7C1.44772 7 1 6.55228 1 6V3C1 2.44772 1.44772 2 2 2H12C12.5523 2 13 2.44772 13 3V6C13 6.55229 12.5523 7 12 7H2Z" fill="#616161"/>
        </svg>
    `;

    return `
    <button class="new-cell-down-button" title="New Cell Down">
        ${svgIcon}
    </button>`;
}


function reprocessNotebook() {
  requestAnimationFrame(() => {
    // Standardize all cells, including newly created ones
    saveAddSageCells(".nb-code-cell", ".sagecell_input,.sagecell_output");
    
    // Remove zero-width spaces from all scripts
    $("script").each(function() {
        $(this).html($(this).html().replace(/\u200B/g, ""));
    });

    // Re-initialize the notebook

    makeSageCells(playerConfig);
	cleanupComputeDivs();
    launchPlayer();
    setupRunAllCells();
  });
}


document.addEventListener('DOMContentLoaded', function() {
    const navbar = document.getElementById('navbar');
    navbar.style.display = '';
    navbar.style.visibility = 'visible';
    navbar.style.opacity = '1';
});

function addConvertToMarkdownButtons() {
    const codeCells = document.querySelectorAll('.nb-cell.nb-code-cell');
    
    codeCells.forEach(cell => {
        if (!cell.querySelector('.convert-button')) {
            const convertButton = document.createElement('button');
            convertButton.className = 'convert-button';
            convertButton.textContent = 'Convert to Markdown';
            
            convertButton.addEventListener('click', () => {
                convertToMarkdown(cell);
            });
            
            cell.appendChild(convertButton);
        }
    });
}


function getCode(codeCell) {
    if (!codeCell) {
        console.error('No code cell provided');
        return '';
    }

    // Extract all lines of text from the code cell
    const codeLines = codeCell.querySelectorAll(".CodeMirror-code > div > pre > span");
    
    if (codeLines.length === 0) {
        console.warn('No code lines found in the provided cell');
        return '';
    }

    const codeText = Array.from(codeLines)
        .map(line => line.textContent)
        .join('\n');

    return codeText;    
}


function showCode(codeCell) {
    const code = getCode(codeCell);
    if (code) {
        // Assuming you have an element to display the code in
        const displayElement = document.getElementById('codeDisplay');
        displayElement.textContent = code;
        displayElement.style.display = 'block';
    }
}

function convertToMarkdown(codeCell) {
    // Extract all lines of text from the code cell
    const codeLines = codeCell.querySelectorAll(".CodeMirror-code > div > pre > span");
    const codeText = Array.from(codeLines)
        .map(line => line.textContent)
        .join('\n');

    const markdownCell = document.createElement('div');
    markdownCell.className = 'nb-cell nb-markdown-cell';
    markdownCell.innerHTML = `
		
        <textarea id="mdinput" placeholder="Enter your Markdown or HTML here" style="width: 100%; height:120px; display: none; font-family: Consolas, 'Courier New', monospace;" data-original=""></textarea>
        <div id="preview"><p><em></em></p></div>
    `;

    // Replace the code cell with the new markdown cell
    codeCell.parentNode.replaceChild(markdownCell, codeCell);

    // Get the textarea element
    const textarea = markdownCell.querySelector('textarea');

    // Set the extracted text as the value of the textarea
    textarea.value = codeText;

    // Update the data-original attribute
    textarea.setAttribute('data-original', codeText);

    //toggleEditMode();
	updateMarkdownPreview(markdownCell);
	addControlBar(markdownCell);
}




function initializeMarkdownCells() {
  var editCellsButton = document.getElementById('editCellsButton');
  var inputs = document.querySelectorAll('[id^="mdinput"]');
  var previews = document.querySelectorAll('[id^="preview"]');
  var editMode = false;

  editCellsButton.onclick = function () {
    editMode = !editMode;

    inputs.forEach((input, index) => {
      var preview = previews[index];

      if (editMode) {
        // Switch to edit mode
        input.value = input.getAttribute('data-original') || input.value;
        input.style.display = 'block';
        preview.style.display = 'none';
      } else {
        // Switch to preview mode
        input.setAttribute('data-original', input.value);

        if (typeof texme !== 'undefined' && texme.render) {
          var output = texme.render(input.value);
          preview.innerHTML = output;
        } else {
          console.error("Texme is not defined or not initialized.");
        }

        input.style.display = 'none';
        preview.style.display = 'block';
      }
    });

    if (!editMode) {
      // Only reset and typeset MathJax once after all previews are updated
      window.MathJax.texReset();
      window.MathJax.typesetPromise();
    }

    // Update button text based on mode
    editCellsButton.textContent = editMode ? 'Save Changes' : 'Edit Cells';
  }
}

function initializeCells() {
	const cells = document.querySelectorAll('.nb-cell.nb-code-cell, .nb-cell.nb-markdown-cell');
	cells.forEach(addControlBar);
}

function addControlBar(cell) {
    const controlBar = document.createElement('div');
    const controlAiBar = document.createElement('div');
    controlBar.className = 'control-bar';
    controlAiBar.className = 'control-ai-bar';

    const addAboveBtn = createButtonIco('Add Above', () => addCell(cell, 'above'), 'addAbove');
    const addBelowBtn = createButtonIco('Add Below', () => addCell(cell, 'below'), 'addBelow');
    const deleteBtn = createButtonIco('Delete', () => deleteCell(cell), 'bin');
    const moveUpBtn = createButtonIco('Move Up', () => moveCell(cell, 'up'), 'moveUp');
    const moveDownBtn = createButtonIco('Move Down', () => moveCell(cell, 'down'), 'moveDown');
    const duplicateBtn = createButtonIco('Duplicate', () => duplicateCell(cell), 'duplicate');

    if (cell.classList.contains('nb-code-cell')) {
        const convertToMarkdownBtn = createButton('Markdown', () => convertToMarkdown(cell));
        const aiCompleteBtn = createButtonIco('AI Complete', () => formatAndLoadCodeIntoCell(cell, `AI_complete`, CURRENT_MODEL, API_KEY), 'aiComplete');
        const aiFormatBtn = createButtonIco('AI Format', () => formatAndLoadCodeIntoCell(cell, `AI_format`, CURRENT_MODEL, API_KEY), 'aiFormat');
        const aiExplainBtn = createButtonIco('AI Explain', () => formatAndLoadCodeIntoCell(cell, `AI_explain`, CURRENT_MODEL, API_KEY), 'aiExplain');
        const excelJsonBtn = createButtonIco('Import/Export Excel', () => openExcelImportExportDialog(cell), 'addEditExcel');

        controlBar.appendChild(convertToMarkdownBtn);
        controlAiBar.appendChild(aiCompleteBtn);
        controlAiBar.appendChild(aiFormatBtn);
        controlAiBar.appendChild(aiExplainBtn);
        controlBar.appendChild(excelJsonBtn);
    } else if (cell.classList.contains('nb-markdown-cell')) {
        const previewBtn = createButton('Preview', () => updateMarkdownPreview(cell));
        controlBar.appendChild(previewBtn);
        const convertToCodeBtn = createButton('Code', () => convertToCode(cell));
        const markdownTipsBtn = createButtonIco('Markdown Tips', () => toggleMarkdownTips(cell), 'markdownTips');
        controlBar.appendChild(convertToCodeBtn);
        controlBar.appendChild(markdownTipsBtn);
    }

    controlBar.appendChild(duplicateBtn);
    controlBar.appendChild(addBelowBtn);
    controlBar.appendChild(addAboveBtn);
    controlBar.appendChild(moveDownBtn);
    controlBar.appendChild(moveUpBtn);
    controlBar.appendChild(deleteBtn);

    cell.insertBefore(controlBar, cell.firstChild);
    // Insert the control AI bar only if API_KEY is defined and not empty
    if (typeof API_KEY !== 'undefined' && API_KEY !== '') {
        cell.insertBefore(controlAiBar, controlBar.nextSibling);
    }
}

function formatAndLoadCodeIntoCell(cell, aiCommand, currentModel, apiKey) {
    const codeMirror = cell.querySelector('.CodeMirror').CodeMirror;
    if (!codeMirror) {
        console.error('CodeMirror instance was not founf');
        return;
    }
    let currentQuery = codeMirror.getValue();
    let previousCode = loadPreviousCodeCells(cell);
    // Ensure both currentQuery and previousCode are strings and replace all single quotes with double quotes
    currentQuery = String(currentQuery).replace(/'/g, '"');
    previousCode = String(previousCode).replace(/'/g, '"');

    const formattedCode = `# -START OF AI CELL-
current_query = r'''
${currentQuery}
'''
language = 'english'
model='${currentModel}'

url = 'https://raw.githubusercontent.com/JupyterPER/SageMathApplications/refs/heads/main/AIcommandsMistral%20NB%20player.py'
load(url)

previous_code = r'''
${previousCode}
'''

AIanswer = ${aiCommand}(language=language, model=model, NBplayer_code=previous_code+f'In[FOCUS]: {current_query}', api_key='${apiKey}')
print(AIanswer)
# -END OF AI CELL-`;

    // Vlož nový kód do aktuálnej bunky
    codeMirror.setValue(formattedCode);

    // Nájdite a kliknite na prislúchajúce tlačidlo vykonania kódu
    const nearestExecuteButton = cell.querySelector('.sagecell_evalButton.ui-button.ui-corner-all.ui-widget');
    if (nearestExecuteButton) {
        nearestExecuteButton.click();
    } else {
        console.error('Tlačidlo vykonania sa nenašlo');
    }
}


function loadPreviousCodeCells(focusedCell) {
    let allText = '';
    let currentCell = focusedCell.previousElementSibling;

    while (currentCell) {
        if (currentCell.classList.contains('nb-cell') && currentCell.classList.contains('nb-code-cell')) {
            const codeLines = currentCell.querySelectorAll(".CodeMirror-code > div > pre > span");
            const codeText = Array.from(codeLines)
                .map(line => line.textContent)
                .join('\n');

            allText = codeText + '\n\n' + allText;
        }
        currentCell = currentCell.previousElementSibling;
    }

    return allText.trim();
}


function removeAllControlBars() {
    const cells = document.querySelectorAll('.nb-cell');
    cells.forEach(removeControlBar);
}

function removeControlBar(cell) {
    const controlBar = cell.querySelector('.control-bar');
    const controlAiBar = cell.querySelector('.control-ai-bar');
    const mdTips = cell.querySelector('.inline-markdown-tips');
    if (controlBar) {
        controlBar.remove();
    }
    if (controlAiBar) {
        controlAiBar.remove();
    }
    if (mdTips) {
        mdTips.remove();
    }
}

function createButtonIco(text, onClick, iconType) {
  const button = document.createElement('button');
  button.innerHTML = iconDictionary[iconType];
  button.title = text;
  button.addEventListener('click', onClick);
  return button;
}
function createButton(text, onClick) {
	const button = document.createElement('button');
	button.textContent = text;
	button.addEventListener('click', onClick);
	return button;
}

function createBlankSageCell() {
	const codeCell = document.createElement('div');
	codeCell.className = 'nb-cell nb-code-cell';
	const content = document.createElement('div');
	content.className = 'cell-content';
	codeCell.appendChild(content);
	return codeCell;
	
}


function addCell(referenceCell, position) {
	const newCell = createBlankSageCell();
	

	if (position === 'above') {
		referenceCell.parentNode.insertBefore(newCell, referenceCell);
	} else {
		referenceCell.parentNode.insertBefore(newCell, referenceCell.nextSibling);
	}
	reprocessNotebook();
	addControlBar(newCell);
}

function deleteCell(cell) {
	cell.remove();
    reprocessNotebook();
}

function moveCell(cell, direction) {
	const parent = cell.parentNode;
	if (direction === 'up' && cell.previousElementSibling) {
		parent.insertBefore(cell, cell.previousElementSibling);
	} else if (direction === 'down' && cell.nextElementSibling) {
		parent.insertBefore(cell.nextElementSibling, cell);
	}
}

function duplicateCell(cell) {
	const newCell = cell.cloneNode(true);
	cell.parentNode.insertBefore(newCell, cell.nextSibling);
	reprocessNotebook();
	removeControlBar(newCell);
	addControlBar(newCell);	
}

function createCodeCell(content) {
    const codeCell = document.createElement('div');
    codeCell.className = 'nb-cell nb-code-cell';
    
    const computeDiv = document.createElement('div');
    computeDiv.className = 'compute';
    
    const script = document.createElement('nb-input');
    script.type = 'text/x-sage';
    script.textContent = content;
    
    computeDiv.appendChild(script);
    codeCell.appendChild(computeDiv);
    
    return codeCell;
}

function convertToCode(markdownCell) {
	const markdownTextRaw = markdownCell.querySelector('textarea').value;
	markdownText = markdownTextRaw.replace(/[\u200B]/g, '');
    const codeCell = createCodeCell(markdownText);
    const uniqueId = 'code-cell-' + Date.now();
    codeCell.id = uniqueId;
    markdownCell.parentNode.replaceChild(codeCell, markdownCell);

    reprocessNotebook();

    // Use setTimeout to delay our operations slightly
    setTimeout(() => {
        const reprocessedCell = document.getElementById(uniqueId);
        if (reprocessedCell) {
            const computeDivs = reprocessedCell.querySelectorAll('.compute.sagecell');
            if (computeDivs.length > 1) {
                computeDivs[computeDivs.length - 1].remove();
            }
            addControlBar(reprocessedCell);
        } else {
            console.error('Reprocessed cell not found');
        }
    }, 100); // 100ms delay, adjust as needed
}


function cleanupComputeDivs() {
    // Select all code cells
    const codeCells = document.querySelectorAll('.nb-code-cell');

    codeCells.forEach(cell => {
        // Find all compute divs within this cell
        const computeDivs = cell.querySelectorAll('.compute.sagecell');

        // If there's more than one compute div
        if (computeDivs.length > 1) {
            // Keep only the last one
            for (let i = 0; i < computeDivs.length - 1; i++) {
                computeDivs[i].remove();
            }
        }
    });
}

function loadPreviousCodeCells(focusedCell) {
    let currentCell = focusedCell;
    let cells = [];

    while (currentCell !== null) {
        currentCell = currentCell.previousElementSibling;
        if (!currentCell) break;
        if (currentCell.classList.contains('nb-code-cell')) {
            cells.unshift(currentCell);
        }
    }

    let allCode = cells
      .map((cell, index) => getCodeFromCell(cell, index))
      .join('\n\n')
      .replace(/'/g, '"');

    return allCode.trim();
}

function getCodeFromCell(codeCell, cellIndex) {
    let code = '';

    // First, try to get code from CodeMirror editor
    const cmEditor = codeCell.querySelector('.CodeMirror');
    if (cmEditor && cmEditor.CodeMirror) {
        code = cmEditor.CodeMirror.getValue();
    }
    // If CodeMirror is not available, try to get from textarea
    else {
        const textarea = codeCell.querySelector('textarea');
        if (textarea) {
            code = textarea.value;
        }
        // If neither is available, try to get from pre element
        else {
            const preElement = codeCell.querySelector('pre');
            if (preElement) {
                code = preElement.textContent;
            }
            else {
                console.warn('Could not find code in cell:', codeCell);
                return '';
            }
        }
    }

    // Add In[n] prefix
    return `In[${cellIndex + 1}]:\n${code}`;
}



function createModalWindow() {
    const currentApiKey = API_KEY
    // Remove any existing modal if present
    removeExistingModal();

    // Add styles
    const styleElement = document.createElement('style');
    styleElement.id = 'modalStyles';
    styleElement.textContent = `
        .modal {
            display: block;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
            border-radius: 5px;
             top: -40px;
        }
        .close {
            float: right;
            cursor: pointer;
            font-size: 28px;
            font-weight: bold;
        }
        .close:hover {
            color: #555;
        }
        .input-group {
            margin: 0px 0;
        }
        input, select {
            width: 100%;
            padding: 8px;
            margin: 8px 0;
            box-sizing: border-box;
        }
        button {
            padding: 8px 16px;
            cursor: pointer;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
        }
        button:hover {
            background-color: #45a049;
        }
    `;
    document.head.appendChild(styleElement);

    // Create modal HTML
    const modalDiv = document.createElement('div');
    modalDiv.id = 'apiKeyModal';
    modalDiv.className = 'modal';
    modalDiv.innerHTML = `
        <div class="modal-content">
            <span class="close" onclick="removeExistingModal()">&times;</span>
            <h3>AI Settings</h3>
            <div class="input-group">
                <label for="modelSelect">Select Mistral Model:</label>
                <select id="modelSelect">
                    <option value="mistral-small-latest">small</option>
                    <option value="mistral-medium-latest">medium</option>
                    <option value="mistral-large-latest">large</option>
                </select>
            </div>
            <div class="input-group">
                <label for="newKey">API Key:</label>
                <input type="text" id="newKey" value="${currentApiKey}" placeholder="Enter API key">
            </div>
            <div class="warning-message" style="color: #e74c3c; margin: 15px 0; padding: 10px; background: #fdecea; border-left: 4px solid #e74c3c;">
                <strong>⚠️ Security Warning:</strong>
                <p style="margin: 5px 0;">Remember to remove your API key before sharing this notebook with others. Never share your API key with untrusted persons. Also delete all cells generated after clicking one of the AI buttons containing your API key.</p>
            </div>
            <button onclick="updateSettings()">Update</button>
        </div>
    `;

    document.body.appendChild(modalDiv);

    // Add click event listener to close modal when clicking outside
    modalDiv.addEventListener('click', function(event) {
        if (event.target === modalDiv) {
            removeExistingModal();
        }
    });
}

function removeExistingModal() {
    // Remove existing modal if present
    const existingModal = document.getElementById('apiKeyModal');
    if (existingModal) {
        existingModal.remove();
    }

    // Remove existing styles if present
    const existingStyles = document.getElementById('modalStyles');
    if (existingStyles) {
        existingStyles.remove();
    }
}

function updateSettings() {
    const newKey = document.getElementById('newKey').value;
    const selectedModel = document.getElementById('modelSelect').value;

    API_KEY = newKey;
    CURRENT_MODEL = selectedModel;
    removeExistingModal();
    console.log(`Updated! Model: ${CURRENT_MODEL}, API Key: ${API_KEY}`);
    removeAllControlBars();
    initializeCells();

}


// Initialize cells when the page loads
window.addEventListener('load', initializeCells);

/**
 * Existing function to extract code from a code cell.
 * Assumes that codeCell is a DOM element representing a code cell.
 * cellIndex is the index of the cell in the notebook (0-based).
 */
function getCodeFromCell(codeCell, cellIndex) {
    let code = '';

    // First, try to get code from CodeMirror editor
    const cmEditor = codeCell.querySelector('.CodeMirror');
    if (cmEditor && cmEditor.CodeMirror) {
        code = cmEditor.CodeMirror.getValue();
    }
    // If CodeMirror is not available, try to get from textarea
    else {
        const textarea = codeCell.querySelector('textarea');
        if (textarea) {
            code = textarea.value;
        }
        // If neither is available, try to get from pre element
        else {
            const preElement = codeCell.querySelector('pre');
            if (preElement) {
                code = preElement.textContent;
            }
            else {
                console.warn('Could not find code in cell:', codeCell);
                return '';
            }
        }
    }

    // Add In[n] prefix
    return `In[${cellIndex + 1}]:\n${code}`;
}


function collectNotebookText() {
    const cells = document.querySelectorAll('.nb-cell');
    const outputs = [];
    let codeCellCount = 1;

    cells.forEach((cell, index) => {
        let cellText = '';

        if (cell.classList.contains('nb-markdown-cell')) {
            // Try to get text from the hidden textarea
            const textarea = cell.querySelector('textarea');
            if (textarea) {
                // Remove zero-width spaces, if present
                const text = textarea.value.replace(/[\u200B]/g, '');
                cellText = `@Markdown[${index + 1}]:\n${text}`;
            }
        } else if (cell.classList.contains('nb-code-cell')) {
            // Use your existing function to extract code
            const codeText = getCodeFromCell(cell, codeCellCount - 1);
            cellText = `@${codeText}`;
            codeCellCount++;
        }

        if (cellText) {
            outputs.push(cellText);
        }
    });

    // Join each cell's content with the separator so it isn't added after the last cell.
    return outputs.join('\n@=================\n').trim();
}

function getFormattedDate() {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${year}_${month}_${day}_${hours}_${minutes}_${seconds}`;
}

function downloadNotebookText() {
    // Gather the text
    const notebookContent = collectNotebookText();

    // Create a Blob from the text
    const blob = new Blob([notebookContent], {type: 'text/plain'});
    const url = URL.createObjectURL(blob);

    // Create a temporary link to automatically download the file
    const link = document.createElement('a');
    link.href = url;
    link.download = 'notebook_export_' + getFormattedDate() + '.txt'; // Set the desired filename
    document.body.appendChild(link);
    link.click();

    // Clean up
    URL.revokeObjectURL(url);
    document.body.removeChild(link);
}

// Example of a simple createMarkdownCell function
function createMarkdownCell(content) {
    const markdownCell = document.createElement('div');
    markdownCell.className = 'nb-cell nb-markdown-cell';
    markdownCell.innerHTML = `
        <textarea id="mdinput" placeholder="Enter your Markdown or HTML here" 
                  style="width: 100%; height:120px; display: none; font-family: Consolas, 'Courier New', monospace;"
                  data-original="">
        </textarea>
        <div id="preview"><p><em></em></p></div>
    `;
    const textarea = markdownCell.querySelector('textarea');
    textarea.value = content;
    textarea.setAttribute('data-original', content);

    // Optionally call any helper functions you normally use:
    updateMarkdownPreview(markdownCell);
    addControlBar(markdownCell);

    return markdownCell;
}

/**
 * Main function to read and import text file data, then re-create cells in order.
 * @param {File} file - The text file object (from an <input type="file">, etc.)
 */
function importNotebookFromFile(file) {
    const reader = new FileReader();
    reader.addEventListener('load', event => {
        const fileContent = event.target.result;
        restoreNotebookFromText(fileContent);
        // Delay before the first reprocessing
        setTimeout(() => {
            reprocessNotebook();
            // Delay before the second reprocessing
            setTimeout(() => {
                reprocessNotebook();
            }, 1000); // 1000 ms delay between the first and second reprocessing
        }, 1000); // 1000 ms delay before the first reprocessing
    });
    reader.readAsText(file);
}

/**
 * Parse the text content and restore cells into #notebook-container in sequence.
 * @param {string} text - The text of the notebook_export_current_date.txt file (beta version)
 */
function restoreNotebookFromText(text) {
    // Find the container for appending cells
    const container = document.querySelector('.nb-worksheet');
    if (!container) {
        console.error('Could not find #notebook-container');
        return;
    }

    // Ask the user if they want to wipe out all previous content
    const shouldWipe = confirm("Do you want to wipe out all the previous content before loading the notebook?");
    if (shouldWipe) {
        // Clear the container
        container.innerHTML = "";
    }

    // Split blocks by our separator:
    const cellBlocks = text.split('@=================\n');

    cellBlocks.forEach(block => {
        const lines = block.split('\n');
        // The first line should have either "@Markdown[x]:" or "@In[x]:"
        const header = lines[0] || '';
        // Everything after the first line is the cell's content
        const content = lines.slice(1).join('\n');

        if (header.startsWith('@Markdown[')) {
            // Rebuild a Markdown cell
            const mdCell = createMarkdownCell(content);
            container.appendChild(mdCell);
        } else if (header.startsWith('@In[')) {
            // Rebuild a Code cell; here we also remove any problematic zero-width spaces
            const codeCell = createCodeCell(content.replace(/[\u200B]/g, ''));
            container.appendChild(codeCell);
            addControlBar(codeCell);
        } else {
            // If the header doesn't match known patterns,
            // handle it as you wish or log a warning
            console.warn(`Unrecognized cell header format: "${header}"`);
        }
    });
}


// New function to import an Excel file, convert it to JSON, and load it into the current code cell
function importExcelJsonToCell(cell) {
    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    // Accept only Excel files
    fileInput.accept = '.xlsx,.xls';
    fileInput.style.display = 'none';

    fileInput.addEventListener('change', function(event) {
        const file = event.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = function(e) {
            const data = e.target.result;
            try {
                // Using SheetJS (XLSX) library to parse the file
                const workbook = XLSX.read(data, { type: 'binary' });
                // Get the first worksheet
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                // Convert the worksheet to JSON (array of arrays)
                const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
                // Format and load the resulting JSON into the code cell
                formatAndLoadExcelJsonIntoCell(cell, jsonData);
            } catch (error) {
                console.error("Error converting Excel to JSON:", error);
                alert("Failed to convert Excel file to JSON.");
            }
        };
        reader.readAsBinaryString(file);
    });

    document.body.appendChild(fileInput);
    fileInput.click();
    document.body.removeChild(fileInput);
}

// New function similar to formatAndLoadCodeIntoCell but for Excel JSON data
function formatAndLoadExcelJsonIntoCell(cell, jsonData) {
    const jsonString = JSON.stringify(jsonData, null, 2);
    const formattedCode = `# Specify the DataFrame name ('df' is for default)
dataframe_name = "df"  
import pandas as pd, json

data_raw = r'''
${jsonString}
'''
# Dynamically create the DataFrame with the specified name
data_json = json.loads(data_raw)
globals()[dataframe_name] = pd.DataFrame(data_json[1:], columns=data_json[0])

# Access the dynamically created DataFrame
print(f"The DataFrame '{dataframe_name}' has been created successfully.")
print(f"Shape of the DataFrame: {globals()[dataframe_name].shape}")
print(f"Columns in the DataFrame: {', '.join(map(str, globals()[dataframe_name].columns))}")`;

    const codeMirrorElem = cell.querySelector('.CodeMirror');
    if (codeMirrorElem && codeMirrorElem.CodeMirror) {
        const codeMirror = codeMirrorElem.CodeMirror;
        codeMirror.setValue(formattedCode);
        // Automatically click the execute button if available
        const executeButton = cell.querySelector('.sagecell_evalButton.ui-button.ui-corner-all.ui-widget');
        if (executeButton) {
            executeButton.click();
        } else {
            console.error('Execute button not found in cell.');
        }
    } else {
        console.error('CodeMirror instance not found in cell.');
    }
}
// NEW FUNCTION: Open a popup window that lets the user choose to Import, Export, or Edit Excel JSON data.
function openExcelImportExportDialog(cell) {
    // Create a modal overlay
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.id = 'excelImportExportModal';
    modal.style.position = 'fixed';
    modal.style.top = '0';
    modal.style.left = '0';
    modal.style.width = '100%';
    modal.style.height = '100%';
    modal.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
    modal.style.display = 'flex';
    modal.style.alignItems = 'center';
    modal.style.justifyContent = 'center';
    modal.style.zIndex = '10000';

    // Create modal content container
    const modalContent = document.createElement('div');
    modalContent.style.backgroundColor = '#fff';
    modalContent.style.padding = '20px';
    modalContent.style.borderRadius = '5px';
    modalContent.style.minWidth = '300px';
    modalContent.style.textAlign = 'center';

    // Title
    const title = document.createElement('h3');
    title.textContent = 'Data Options';
    modalContent.appendChild(title);

    // Instruction
    const instruction = document.createElement('p');
    instruction.textContent = 'Choose an action for data:';
    modalContent.appendChild(instruction);

    // Import button
    const importBtn = document.createElement('button');
    importBtn.textContent = 'Import Excel';
    importBtn.style.margin = '10px';
    importBtn.onclick = function () {
        document.body.removeChild(modal);
        importExcelJsonToCell(cell);
    };
    modalContent.appendChild(importBtn);

    // Edit button
    const editBtn = document.createElement('button');
    editBtn.textContent = 'Edit Data';
    editBtn.style.margin = '10px';
    editBtn.onclick = function () {
        document.body.removeChild(modal);
        openExcelEditorDialog(cell);
    };
    modalContent.appendChild(editBtn);

    // Export button
    const exportBtn = document.createElement('button');
    exportBtn.textContent = 'Export Excel';
    exportBtn.style.margin = '10px';
    exportBtn.onclick = function () {
        document.body.removeChild(modal);
        exportExcelJsonFromCell(cell);
    };
    modalContent.appendChild(exportBtn);

    // Cancel button
    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Cancel';
    cancelBtn.style.margin = '10px';
    cancelBtn.onclick = function () {
        document.body.removeChild(modal);
    };
    modalContent.appendChild(cancelBtn);

    modal.appendChild(modalContent);
    document.body.appendChild(modal);
}

// NEW FUNCTION: Open a modal editor to let the user edit Excel JSON data as a table.
// The user can add/delete rows and columns and then save changes back into the code cell.
function openExcelEditorDialog(cell) {
    // Try to extract JSON data from the cell.
    const codeMirrorElem = cell.querySelector('.CodeMirror');
    let codeContent = "";
    if (codeMirrorElem && codeMirrorElem.CodeMirror) {
        codeContent = codeMirrorElem.CodeMirror.getValue();
    } else {
        codeContent = cell.textContent;
    }
    const regex = /data_raw\s*=\s*r'''([\s\S]*?)'''/;
    let jsonData;
    const match = codeContent.match(regex);
    if (match && match[1]) {
        try {
            jsonData = JSON.parse(match[1]);
        } catch (error) {
            console.error("Error parsing JSON data from cell:", error);
            alert("Failed to parse existing JSON data. Starting with an empty table.");
            jsonData = [];
        }
    } else {
        // If no JSON found, initialize with a default header and one empty row.
        jsonData = [["Column1", "Column2"], ["", ""]];
    }

    // Create a modal overlay for the editor
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.id = 'excelEditorModal';
    modal.style.position = 'fixed';
    modal.style.top = '0';
    modal.style.left = '0';
    modal.style.width = '100%';
    modal.style.height = '100%';
    modal.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
    modal.style.display = 'flex';
    modal.style.alignItems = 'center';
    modal.style.justifyContent = 'center';
    modal.style.zIndex = '11000';

    const modalContent = document.createElement('div');
    modalContent.style.backgroundColor = '#fff';
    modalContent.style.padding = '20px';
    modalContent.style.borderRadius = '5px';
    modalContent.style.minWidth = '400px';
    modalContent.style.textAlign = 'center';

    const title = document.createElement('h3');
    title.textContent = 'Edit Data';
    modalContent.appendChild(title);

    // Create a container for the editable table.
    const tableContainer = document.createElement('div');
    tableContainer.style.maxHeight = '400px';
    tableContainer.style.overflow = 'auto';
    tableContainer.style.marginBottom = '10px';

    // Function to render the table from jsonData (array of arrays)
    // Inside the openExcelEditorDialog function, update the renderTable function as follows:
    function renderTable() {
        tableContainer.innerHTML = "";
        const table = document.createElement('table');
        table.style.width = '100%';
        table.style.borderCollapse = 'collapse';
        table.style.marginBottom = '10px';
        table.style.fontFamily = 'Arial, sans-serif';

        jsonData.forEach((row, rowIndex) => {
            const tr = document.createElement('tr');
            // Apply zebra striping for non-header rows
            tr.style.backgroundColor =
                rowIndex === 0 ? '#4CAF50' : (rowIndex % 2 === 0 ? '#f9f9f9' : '#ffffff');

            row.forEach((cellValue, colIndex) => {
                const td = document.createElement('td');
                td.style.border = '1px solid #ddd';
                td.style.padding = '8px';
                // For the header row, update styling
                if (rowIndex === 0) {
                    td.style.color = '#fff';
                    td.style.textAlign = 'center';
                    td.style.fontWeight = 'bold';
                }
                const input = document.createElement('input');
                input.type = 'text';
                input.value = cellValue;
                input.style.width = '100%';
                input.style.boxSizing = 'border-box';
                input.style.border = 'none';
                input.style.outline = 'none';
                input.style.padding = '4px';
                input.style.fontFamily = 'inherit';
                // Update jsonData when the cell is edited
                input.onchange = function () {
                    jsonData[rowIndex][colIndex] = input.value;
                };
                td.appendChild(input);
                tr.appendChild(td);
            });
            table.appendChild(tr);
        });
        tableContainer.appendChild(table);
    }
    renderTable();
    modalContent.appendChild(tableContainer);

    // Buttons for modifying rows/columns
    const rowControls = document.createElement('div');
    rowControls.style.margin = '10px 0';
    const addRowBtn = document.createElement('button');
    addRowBtn.textContent = 'Add Row';
    addRowBtn.style.margin = '0 5px';
    addRowBtn.onclick = function () {
        // Create an empty row with the same number of columns as header
        const numCols = jsonData[0] ? jsonData[0].length : 1;
        const newRow = Array(numCols).fill("");
        jsonData.push(newRow);
        renderTable();
    };
    const deleteRowBtn = document.createElement('button');
    deleteRowBtn.textContent = 'Delete Last Row';
    deleteRowBtn.style.margin = '0 5px';
    deleteRowBtn.onclick = function () {
        if (jsonData.length > 1) {
            jsonData.pop();
            renderTable();
        } else {
            alert("Cannot delete the header row.");
        }
    };
    rowControls.appendChild(addRowBtn);
    rowControls.appendChild(deleteRowBtn);
    modalContent.appendChild(rowControls);

    const colControls = document.createElement('div');
    colControls.style.margin = '10px 0';
    const addColBtn = document.createElement('button');
    addColBtn.textContent = 'Add Column';
    addColBtn.style.margin = '0 5px';
    addColBtn.onclick = function () {
        // Add an empty cell to each row
        jsonData.forEach((row, index) => {
            row.push(index === 0 ? "New Column" : "");
        });
        renderTable();
    };
    const deleteColBtn = document.createElement('button');
    deleteColBtn.textContent = 'Delete Last Column';
    deleteColBtn.style.margin = '0 5px';
    deleteColBtn.onclick = function () {
        if (jsonData[0] && jsonData[0].length > 1) {
            jsonData.forEach(row => row.pop());
            renderTable();
        } else {
            alert("Cannot delete all columns.");
        }
    };
    colControls.appendChild(addColBtn);
    colControls.appendChild(deleteColBtn);
    modalContent.appendChild(colControls);

    // Save and Cancel buttons for the editor
    const editorControls = document.createElement('div');
    editorControls.style.marginTop = '15px';
    const saveBtn = document.createElement('button');
    saveBtn.textContent = 'Save Changes';
    saveBtn.style.margin = '0 5px';
    saveBtn.onclick = function () {
        // Convert the updated jsonData to a formatted JSON string.
        const newJsonString = JSON.stringify(jsonData, null, 2);
        // Create the formatted code block with the updated JSON string.
        const formattedCode = `# Specify the DataFrame name ('df' is default)
dataframe_name = "df"  
import pandas as pd, json

data_raw = r'''
${newJsonString}
'''
# Dynamically create the DataFrame with the specified name
data_json = json.loads(data_raw)
globals()[dataframe_name] = pd.DataFrame(data_json[1:], columns=data_json[0])

# Access the dynamically created DataFrame
print(f"The DataFrame '{dataframe_name}' has been created successfully.")
print(f"Shape of the DataFrame: {globals()[dataframe_name].shape}")
print(f"Columns in the DataFrame: {', '.join(map(str, globals()[dataframe_name].columns))}")`;
        // Update the code cell via CodeMirror
        const cmElem = cell.querySelector('.CodeMirror');
        if (cmElem && cmElem.CodeMirror) {
            cmElem.CodeMirror.setValue(formattedCode);
            // Optionally trigger the execute button
            const executeButton = cell.querySelector('.sagecell_evalButton.ui-button.ui-corner-all.ui-widget');
            if (executeButton) {
                executeButton.click();
            }
        } else {
            console.error("CodeMirror instance not found in cell.");
        }
        document.body.removeChild(modal);
    };
    const cancelEditorBtn = document.createElement('button');
    cancelEditorBtn.textContent = 'Cancel';
    cancelEditorBtn.style.margin = '0 5px';
    cancelEditorBtn.onclick = function () {
        document.body.removeChild(modal);
    };
    editorControls.appendChild(saveBtn);
    editorControls.appendChild(cancelEditorBtn);
    modalContent.appendChild(editorControls);

    modal.appendChild(modalContent);
    document.body.appendChild(modal);
}


function importExcelJsonToCell(cell) {
    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    // Accept only Excel files
    fileInput.accept = '.xlsx,.xls';
    fileInput.style.display = 'none';

    fileInput.addEventListener('change', function (event) {
        const file = event.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = function (e) {
            const data = e.target.result;
            try {
                // Using SheetJS (XLSX) library to parse the file
                const workbook = XLSX.read(data, { type: 'binary' });
                // Get the first worksheet
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                // Convert the worksheet to JSON (array of arrays)
                const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
                // Format and load the resulting JSON into the code cell
                formatAndLoadExcelJsonIntoCell(cell, jsonData);
            } catch (error) {
                console.error("Error converting Excel to JSON:", error);
                alert("Failed to convert Excel file to JSON.");
            }
        };
        reader.readAsBinaryString(file);
    });

    document.body.appendChild(fileInput);
    fileInput.click();
    document.body.removeChild(fileInput);
}


function exportExcelJsonFromCell(cell) {
    const codeMirrorElem = cell.querySelector('.CodeMirror');
    let codeContent = "";
    if (codeMirrorElem && codeMirrorElem.CodeMirror) {
        codeContent = codeMirrorElem.CodeMirror.getValue();
    } else {
        codeContent = cell.textContent;
    }

    // Extract the JSON data from between r''' ... '''
    const regex = /data_raw\s*=\s*r'''([\s\S]*?)'''/;
    const match = codeContent.match(regex);
    if (match && match[1]) {
        const jsonString = match[1];
        try {
            const jsonData = JSON.parse(jsonString);
            // Create a new workbook and worksheet using SheetJS (XLSX)
            var wb = XLSX.utils.book_new();
            var ws = XLSX.utils.aoa_to_sheet(jsonData);
            XLSX.utils.book_append_sheet(wb, ws, "Sheet1");
            // Write the workbook to a binary string
            var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'binary' });
            // Helper function to convert a binary string to an ArrayBuffer
            function s2ab(s) {
                var buf = new ArrayBuffer(s.length);
                var view = new Uint8Array(buf);
                for (var i = 0; i < s.length; i++) {
                    view[i] = s.charCodeAt(i) & 0xFF;
                }
                return buf;
            }
            // Use FileSaver to prompt a download of the workbook as an XLSX file
            saveAs(new Blob([s2ab(wbout)], { type: "application/octet-stream" }), "exported_data.xlsx");
        } catch (error) {
            console.error("Error parsing JSON data:", error);
            alert("Failed to parse JSON data from the cell.");
        }
    } else {
        alert("No Excel JSON data found in the selected cell.");
    }
}

function toggleMarkdownTips(cell) {
    let tipsPanel = cell.querySelector('.inline-markdown-tips');
    if (tipsPanel) {
        // Toggle the panel's display.
        tipsPanel.style.display = (tipsPanel.style.display === 'none') ? 'block' : 'none';
    } else {
        // Create the tips panel if it doesn't exist.
        tipsPanel = document.createElement('div');
        tipsPanel.className = 'inline-markdown-tips';
        tipsPanel.style.border = '1px solid #ccc';
        tipsPanel.style.backgroundColor = '#f9f9f9';
        tipsPanel.style.padding = '8px';
        tipsPanel.style.marginTop = '5px';
        tipsPanel.style.fontSize = '12px';
        tipsPanel.innerHTML = `
      <strong>Markdown Tips:</strong>
      <ul style="padding-left:16px; margin:5px 0;">
        <li>Use <code>*asterisks*</code> for <em>italics</em>.</li>
        <li>Use <code>**double asterisks**</code> for <strong>bold</strong> text.</li>
        <li>Start lines with <code>#</code> for headers (e.g. <code># Header1</code> or <code>## Header2</code>).</li>
        <li>Use <code>-</code> or <code>*</code> for list items.</li>
        <li>Insert <code>![alt text for figure](url or path to figure)</code> for inserting figures. Examples:</li>
        <ul style="padding-left:16px; margin:5px 0;">
            <li><code>![Figure 1](https://i.postimg.cc/jdThVHFH/elastic-pendulum.png)</code> for figures from online source.</li>
            <li><code>![Figure 2](elastic-pendulum.png)</code> for locally stored figures (in the same directory as this notebook).</li>
          </ul>
        <li>Use <code>\`code\`</code> for inline code.</li>
        <li>
          Use <code>$...$</code> for inline LaTeX formulas. Examples:
          <ul style="padding-left:16px; margin:5px 0;">
            <li><code>$x^2$</code>, <code>$x^{2+i}$</code>, <code>$x_1$</code>, <code>$x_{n+1}$</code> for superscripts and subscripts.</li>
            <li><code>$\\frac{a}{b}$</code>, <code>$\\dfrac{a}{b}$</code>, <code>$a \\cdot b$</code> for fractions and multiplications.</li>
            <li><code>$\\alpha \\beta \\gamma \\Gamma \\rho \\phi \\Phi \\varphi \\omega \\Omega$</code> for lowercase and uppercase greek letters.</li>
            <li><code>$\\sin \\cos \\tan \\exp \\ln$</code> for some elementary functions.</li>
            <li><code>$A \\! B \\, C \\:D \\; E \\ F \\quad G \\qquad H \\hspace{1cm} I ~ J$</code> for various types of spaces.</li>
            <li><code>$a=3~\\mathrm{m \\cdot s^{-2}}$</code> for physical quantities.</li>
          </ul>
        </li>
        <li>
          Use <code>$$...$$</code> for display math formulas.
        </li>
      </ul>
    `;
        // Insert the tips panel just after the control bar (assumed to be the first child).
        cell.insertBefore(tipsPanel, cell.children[1] || null);
    }
}