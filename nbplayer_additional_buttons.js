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

function addControlPanel() {
    const controlPanel = document.createElement('div');
    controlPanel.id = 'controls';
    controlPanel.style.cssText = 'position: fixed; top: 60px; left: 10px; z-index: 200;';

    const input = document.createElement('input');
    input.type = 'number';
    input.id = 'delay';
    input.placeholder = 'Insert time between computations in ms';
    input.min = '0';
    input.value = '1000';

    const button = document.createElement('button');
    button.id = 'button1';
    button.textContent = 'Start all';

    controlPanel.appendChild(input);
    controlPanel.appendChild(button);

    // Insert the control panel at the beginning of the body
    document.body.insertBefore(controlPanel, document.body.firstChild);
}
