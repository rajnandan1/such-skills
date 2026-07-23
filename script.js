(function () {
    'use strict';

    var toast = document.getElementById('copyToast');
    var toastTimer = null;
    function showToast() {
        if (toastTimer) clearTimeout(toastTimer);
        toast.classList.add('show');
        toastTimer = setTimeout(function () {
            toast.classList.remove('show');
        }, 1600);
    }

    function handleCopy(cmdEl) {
        var text = cmdEl.querySelector('.cmd-text').textContent.replace(/\s+/g, ' ').trim();
        navigator.clipboard.writeText(text).then(
            function () {
                cmdEl.classList.add('copied');
                var hint = cmdEl.querySelector('.copy-hint');
                if (hint) hint.textContent = 'copied';
                setTimeout(function () {
                    cmdEl.classList.remove('copied');
                    if (hint) hint.textContent = 'copy';
                }, 1600);
                showToast();
            },
            function () {
                // Fallback: select the text for manual copy
                var range = document.createRange();
                range.selectNodeContents(cmdEl.querySelector('.cmd-text'));
                var sel = window.getSelection();
                sel.removeAllRanges();
                sel.addRange(range);
            }
        );
    }

    document.querySelectorAll('.cmd').forEach(function (cmdEl) {
        cmdEl.addEventListener('click', function () {
            handleCopy(cmdEl);
        });
        cmdEl.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                handleCopy(cmdEl);
            }
        });
    });

    console.log(
        '%csuch-skills%c\nClaude Code plugins by Raj Nandan Sharma\nhttps://github.com/rajnandan1/such-skills',
        'color:#F08A24;font-size:16px;font-weight:bold;font-family:monospace',
        'color:#888;font-size:12px;font-family:monospace'
    );
})();
