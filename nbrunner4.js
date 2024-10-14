function getBrowserLanguage() {
    return (navigator.language || navigator.userLanguage).substring(0, 2)
}

function makeMenu() {
    var e = getBrowserLanguage();
    $("head").first().append('<link rel="stylesheet" href="custom.css"'), $("body").first().append('<script src="custom.js"><\/script>');
    var t = "de" == e ? "Code ausblenden/einblenden" : "Show / Hide Code",
        n = "de" == e ? "Code-Zellen in der gegebenen Reihenfolge ausfĂĽhren!" : "Execute Cells in the Sequence Given!",
        a = "de" == e ? "Speichern" : "Save",
        s = '<a href="#" role="button" id="read-button" class="btn btn-primary" onclick="setView()">' + ("de" == e ? "Lesen" : "Read") + "</a>",
        o = '<a href="#" role="button" id="execute-button" class="btn btn-primary" onclick="setExecute()">' + ("de" == e ? "AusfĂĽhren" : "Execute") + "</a>",
        l = '<div id="navbar">' + ("Exec" == playerConfig.panes ? "" : s + o) + '<a href="#" role="button" class="btn btn-primary" onclick="toggleInput()">' + t + '</a>\n  <a href="#" role="button" class="btn btn-primary" onclick="saveHtml()">' + a + "</a>" + (playerConfig.linked ? '<a id="evalWarning" href="#" role="button" class="btn btn-warning" style="display: none;">' + n + "</a>" : "") + '\n  <img style="float: right; margin-right: 70px;" src="https://www.upjs.sk/app/uploads/sites/10/2023/02/PriF_ENG_frame.svg" alt="PriF ENG frame" height="53" /></img>\n  </div>';
    $("body").prepend(l), $("#main").addClass("belowMenu")
}

function scrollFunction() {
    var e = document.getElementById("navbar"),
        t = e.offsetTop;
    window.pageYOffset >= t ? e.classList.add("sticky") : e.classList.remove("sticky")
}

function saveHtml() {
    // Update the content of all input and preview elements
    document.querySelectorAll('[id^="input"]').forEach((input, index) => {
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

    var e = new Blob(["<!DOCTYPE html>\n<html>\n<head>" + $("head").html() + '</head>\n<body>\n<script src="https://cdn.jsdelivr.net/npm/texme@1.2.2"></script>\n<div id="main">' + $("#main").html() + '</div>\n  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js" integrity="sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW" crossorigin="anonymous"><\/script>\n  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"><\/script>\n  <script src="https://sagecell.sagemath.org/embedded_sagecell.js"><\/script>\n  <script src="' + playerConfig.playerPath + '/vendor/js/FileSaver.min.js"><\/script>\n  <script src="' + playerConfig.playerPath + '/nbplayerConfig.js"><\/script>\n  <script src="https://cdn.jsdelivr.net/gh/JupyterPER/SageMathApplications@main/nbrunner4.js"><\/script>\n  <script>\n    playerConfig=' + JSON.stringify(playerConfig) + ";\n    playerMode=" + JSON.stringify(playerMode) + ";\n    makeMenu();\n    localize();\n    loadStatus();\n    makeSageCells(playerConfig);\n    launchPlayer();\n    addControlPanel();\n    setupRunAllCells();\n    window.onload = initializeMarkdownCells;\n  <\/script>\n</body>\n</html>"], {
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
    function getElementsByXPath(xpath) {
        const result = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        const elements = [];
        for (let i = 0; i < result.snapshotLength; i++) {
            elements.push(result.snapshotItem(i));
        }
        return elements;
    }

    function runAllCells() {
        const delay = parseInt(document.getElementById('delay').value) || 1000;
        const executeButtons = getElementsByXPath("//button[text()='Execute']");
        
        executeButtons.forEach((button, index) => {
            setTimeout(() => {
                button.click();
            }, delay * (index + 1));
        });
    }

    document.getElementById('button1').addEventListener('click', runAllCells);
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

function removeCellEditingButtons() {
	removeConvertToMarkdownButtons();
    removeNewCellUpButtons();
    removeNewCellDownButtons();
    removeDeleteCellButtons();
}



let editMode = true;

function toggleEditMode() {
    if (editMode) {
		refreshNewCellButtons();
		toggleMarkdownMode();
        editMode = false;
    } else {
		removeCellEditingButtons();
		toggleMarkdownMode();
        editMode = true;
    }
}



function toggleMarkdownMode() {
    var inputs = document.querySelectorAll('[id^="input"]');
    var previews = document.querySelectorAll('[id^="preview"]');

    inputs.forEach((input, index) => {
        var preview = previews[index];

        if (editMode) {
            // Show input, hide preview
            input.value = input.getAttribute('data-original') || '';
            input.style.display = 'block';
            preview.style.display = 'none';
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
    controlPanel.style.cssText = `
        position: fixed;
        top: 0px;
        right: 0px;
        z-index: 100;
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 5px;
        padding: 5px;
        background-color: #1c8c4c;
        border-bottom-left-radius: 5px;
        outline: none;
    `;

    const commonStyles = `
        width: 100px;
        padding: 5px;
        font-size: 12px;
        border: 1px solid #ccc;
        border-radius: 3px;
        background-color: #f8f8f8;
        color: #333;
    `;

    const input = document.createElement('input');
    input.type = 'number';
    input.id = 'delay';
    input.placeholder = 'Step (ms)';
    input.min = '1';
    input.value = '900';
    input.style.cssText = commonStyles;

    const runButton = document.createElement('button');
    runButton.id = 'button1';
    runButton.textContent = 'Run All Cells';
    runButton.style.cssText = `
        ${commonStyles}
        cursor: pointer;
    `;

    const toggleNavbarButton = document.createElement('button');
    toggleNavbarButton.id = 'toggleNavbar';
    toggleNavbarButton.textContent = 'Toggle Bar';
    toggleNavbarButton.onclick = toggleNavbar;
    toggleNavbarButton.style.cssText = `
        ${commonStyles}
        cursor: pointer;
    `;

    const editCellsButton = document.createElement('button');
    editCellsButton.id = 'editCells';
    editCellsButton.textContent = 'Edit Cells';
    editCellsButton.onclick = toggleEditMode;
    editCellsButton.style.cssText = `
        ${commonStyles}
        cursor: pointer;
    `;

    const hoverEffect = (event) => {
        event.target.style.backgroundColor = '#e0e0e0';
    };

    const resetEffect = (event) => {
        event.target.style.backgroundColor = '#f8f8f8';
    };

    runButton.onmouseover = hoverEffect;
    runButton.onmouseout = resetEffect;
    toggleNavbarButton.onmouseover = hoverEffect;
    toggleNavbarButton.onmouseout = resetEffect;
    editCellsButton.onmouseover = hoverEffect;
    editCellsButton.onmouseout = resetEffect;

    controlPanel.appendChild(runButton);
	controlPanel.appendChild(input);
    controlPanel.appendChild(toggleNavbarButton);
    controlPanel.appendChild(editCellsButton);
	
    // Insert the control panel at the beginning of the body
    document.body.insertBefore(controlPanel, document.body.firstChild);
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



function addDeleteButtonsToCodeCells() {
    // Get all code cells
    const cells = document.querySelectorAll('.nb-cell.nb-code-cell, .nb-cell.nb-markdown-cell');
    
    cells.forEach(cell => {
        if (!cell.querySelector('.delete-button')) {
            // Create delete button
            const deleteButton = document.createElement('button');
            deleteButton.className = 'delete-button';
            deleteButton.textContent = 'Delete';
            
            // Set inline styles for the delete button
            Object.assign(deleteButton.style, {
                position: 'absolute',
                top: '-40px',
                right: '5px',
                padding: '5px 10px',
                backgroundColor: '#f0f0f0',
                border: '1px solid #ccc',
                borderRadius: '3px',
                cursor: 'pointer',
                fontSize: '12px'
            });
            
            // Add hover effect using event listeners
            deleteButton.addEventListener('mouseover', () => {
                deleteButton.style.backgroundColor = '#e0e0e0';
            });
            deleteButton.addEventListener('mouseout', () => {
                deleteButton.style.backgroundColor = '#f0f0f0';
            });
            
            // Ensure the cell has a relative positioning
            cell.style.position = 'relative';
            
            // Append the delete button to the cell
            cell.appendChild(deleteButton);
        }
    });
}

function deleteCell(event) {
    if (event.target.classList.contains('delete-button')) {
        const cellToDelete = event.target.closest('.nb-cell.nb-code-cell, .nb-cell.nb-markdown-cell');
		
        if (cellToDelete) {
            cellToDelete.remove();
			refreshNewCellButtons();
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {document.body.addEventListener('click', deleteCell);
})


		


function generateNewCellUpButtonHTML() {
    const styles = `
        display: block;
        margin: 10px auto;
        padding: 5px 10px;
        background-color: #f0f0f0;
        border: 1px solid #ccc;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
    `;

    const hoverStyles = `
        this.style.backgroundColor = '#e0e0e0';
    `;

    const resetStyles = `
        this.style.backgroundColor = '#f0f0f0';
    `;

    return `<button class="new-cell-up-button" style="${styles}" onmouseover="${hoverStyles}" onmouseout="${resetStyles}">New Cell Up</button>`;
}

function generateNewCellDownButtonHTML() {
    const styles = `
        display: block;
        margin: 10px auto;
        padding: 5px 10px;
        background-color: #f0f0f0;
        border: 1px solid #ccc;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
		position: relative;
        top: -30px;
    `;

    const hoverStyles = `
        this.style.backgroundColor = '#e0e0e0';
    `;

    const resetStyles = `
        this.style.backgroundColor = '#f0f0f0';
    `;

    return `<button class="new-cell-down-button" style="${styles}" onmouseover="${hoverStyles}" onmouseout="${resetStyles}">New Cell Down</button>`;
}


function addNewCellUpButtons() {
    $('.nb-cell.nb-code-cell, .nb-cell.nb-markdown-cell').before(generateNewCellUpButtonHTML());
}

function addNewCellDownButtons() {
    $('.nb-cell.nb-code-cell, .nb-cell.nb-markdown-cell').after(generateNewCellDownButtonHTML());
}

function removeNewCellUpButtons() {
    $('.new-cell-up-button').remove();
}

function removeNewCellDownButtons() {
    $('.new-cell-down-button').remove();
}

function removeDeleteCellButtons() {
    $('.delete-button').remove();
}

function removeConvertToMarkdownButtons() {
    $('.convert-button').remove();
}

function refreshNewCellButtons() {
	removeCellEditingButtons();
	addConvertToMarkdownButtons();
	addDeleteButtonsToCodeCells();
    addNewCellUpButtons();
    addNewCellDownButtons();
}

document.addEventListener('DOMContentLoaded', function() {
	document.body.addEventListener('click', replaceNewCellUpButton, refreshNewCellButtons);
})

document.addEventListener('DOMContentLoaded', function() {
	document.body.addEventListener('click', replaceNewCellDownButton, refreshNewCellButtons);
})



function createBlankSageCell() {
    const codeCell = document.createElement('div');
    codeCell.className = 'nb-cell nb-code-cell';

    return codeCell;
}
function replaceNewCellUpButton(event) {
    if (event.target.classList.contains('new-cell-up-button')) {
        const button = event.target;
        const newCell = createBlankSageCell();
        
        button.parentNode.insertBefore(newCell, button);

        // Reprocess the notebook to ensure all cells are properly linked
        reprocessNotebook();
		
    }
}

function replaceNewCellDownButton(event) {
    if (event.target.classList.contains('new-cell-down-button')) {
        const button = event.target;
        const newCell = createBlankSageCell();
        
        button.parentNode.insertBefore(newCell, button);

        // Reprocess the notebook to ensure all cells are properly linked
        reprocessNotebook();
		
    }
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
    localize();
    loadStatus();
    makeSageCells(playerConfig);
    launchPlayer();
    addControlPanel();
    setupRunAllCells();
	refreshNewCellButtons();
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
            
            Object.assign(convertButton.style, {
                position: 'absolute',
                top: '-40px',
                right: '60px',
                padding: '5px 10px',
                backgroundColor: '#f0f0f0',
                border: '1px solid #ccc',
                borderRadius: '3px',
                cursor: 'pointer',
                fontSize: '12px'
            });
            
            convertButton.addEventListener('mouseover', () => {
                convertButton.style.backgroundColor = '#e0e0e0';
            });
            convertButton.addEventListener('mouseout', () => {
                convertButton.style.backgroundColor = '#f0f0f0';
            });
            
            convertButton.addEventListener('click', () => {
                convertToMarkdown(cell);
            });
            
            // Ensure the cell has a relative positioning
            cell.style.position = 'relative';
            
            cell.appendChild(convertButton);
        }
    });
}

function convertToMarkdown(codeCell) {
    const markdownCell = document.createElement('div');
    markdownCell.className = 'nb-cell nb-markdown-cell';
    markdownCell.innerHTML = `
        <textarea id="input" placeholder="Enter your Markdown or HTML here" style="width: 100%; height:120px; display: none; font-family: Consolas, 'Courier New', monospace;" data-original=""></textarea>
        <div id="preview"><p><em></em></p></div>
    `;
    
    // Replace the code cell with the new markdown cell
    codeCell.parentNode.replaceChild(markdownCell, codeCell);
	toggleEditMode();
	toggleEditMode();
    
    // If you have a function to add delete buttons, call it here
    // For example: addDeleteButtonsToCells();
}

function initializeMarkdownCells() {
  var editCellsButton = document.getElementById('editCellsButton');
  var inputs = document.querySelectorAll('[id^="input"]');
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


