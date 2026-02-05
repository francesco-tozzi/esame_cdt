document.addEventListener('DOMContentLoaded', () => {
    console.log("TEI Digital Edition Loaded");
});

function handleZoneClick(zoneId) {
    console.log("Click rilevato su zona:", zoneId);
    const textBlocks = document.querySelectorAll('.text-block[data-facs]');
    let targetBlock = null;

    for (const block of textBlocks) {
        const facsAttr = block.getAttribute('data-facs');
        const ids = facsAttr.split(' ');
        
        if (ids.includes(zoneId)) {
            targetBlock = block;
            break;
        }
    }

    if (targetBlock) {
        console.log("Corrispondenza trovata:", targetBlock);
        
        targetBlock.scrollIntoView({ behavior: 'smooth', block: 'center' });
        targetBlock.classList.remove('temporary-highlight');

        void targetBlock.offsetWidth; 

        targetBlock.classList.add('temporary-highlight');

        setTimeout(() => {
            targetBlock.classList.remove('temporary-highlight');
        }, 2050); 

    } else {
        console.warn("ATTENZIONE: Nessun testo trovato per la zona:", zoneId);
    }
}


function setMode(mode) {
    if (mode === 'diplomatic') {
        document.body.classList.add('diplomatic-mode');
    } else {
        document.body.classList.remove('diplomatic-mode');
    }

    document.querySelectorAll('.mode-btn').forEach(btn => {
        btn.classList.remove('active');
    });

    const activeButton = document.querySelector(`button[onclick="setMode('${mode}')"]`);
    if (activeButton) {
        activeButton.classList.add('active');
    }
}

function toggleFilter(btn, filterType) {
    btn.classList.toggle('active');
    
    const className = 'show-' + filterType;
    
    if (btn.classList.contains('active')) {
        document.body.classList.add(className);
    } else {
        document.body.classList.remove(className);
    }
}

function toggleModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal.style.display === "block") {
        modal.style.display = "none";
    } else {
        modal.style.display = "block";
    }
}