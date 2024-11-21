/* Add your Javascript code here */

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

function removeCellEditingButtons() {
    removeNewCellUpButtons();
    removeNewCellDownButtons();
    removeDeleteCellButtons();
}

let editMode = true;

function toggleEditMode() {
    if (editMode) {
		refreshNewCellButtons();
        editMode = false;
    } else {
		removeCellEditingButtons();
        editMode = true;
    }
}

function addControlPanel() {
    const controlPanel = document.createElement('div');
    controlPanel.id = 'controls';

    const input = document.createElement('input');
    input.type = 'number';
    input.id = 'delay';
    input.placeholder = 'Step (ms)';
    input.min = '1';
    input.value = '900';
    input.className = 'control-item';

    const runButton = document.createElement('button');
    runButton.id = 'button1';
    runButton.textContent = 'Run All Cells';
    runButton.className = 'control-item control-button';

    const toggleNavbarButton = document.createElement('button');
    toggleNavbarButton.id = 'toggleNavbar';
    toggleNavbarButton.textContent = 'Toggle Bar';
    toggleNavbarButton.onclick = toggleNavbar;
    toggleNavbarButton.className = 'control-item control-button';

    const editCellsButton = document.createElement('button');
    editCellsButton.id = 'editCells';
    editCellsButton.textContent = 'Edit Cells';
    editCellsButton.onclick = toggleEditMode;
    editCellsButton.className = 'control-item control-button';

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
    // Add delete buttons only to cells that don't have them
    const cells = document.querySelectorAll('.nb-cell.nb-code-cell:not(:has(.delete-button))');
    cells.forEach(cell => {
        const deleteButton = document.createElement('button');
        deleteButton.className = 'delete-button';
        deleteButton.textContent = 'Delete';
        
        cell.appendChild(deleteButton);
    });
}

function deleteCell(event) {
    if (event.target.classList.contains('delete-button')) {
        const cellToDelete = event.target.closest('.nb-cell.nb-code-cell');
		
        if (cellToDelete) {
            cellToDelete.remove();
			refreshNewCellButtons();
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {document.body.addEventListener('click', deleteCel);
})

function generateNewCellUpButtonHTML() {
    return '<button class="new-cell-button new-cell-up-button">New Cell Up</button>';
}

function generateNewCellDownButtonHTML() {
    return '<button class="new-cell-button new-cell-down-button">New Cell Down</button>';
}

function addNewCellUpButtons() {
    $('.nb-cell.nb-code-cell').before(generateNewCellUpButtonHTML());
}

function addNewCellDownButtons() {
    $('.nb-cell.nb-code-cell').after(generateNewCellDownButtonHTML());
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

function refreshNewCellButtons() {
	removeDeleteCellButtons();
	addDeleteButtonsToCodeCells();
	removeNewCellUpButtons();
    addNewCellUpButtons();
	removeNewCellDownButtons();
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


