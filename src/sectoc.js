// Courtesy to main author Martin Schmelzer schmelzer.martin@gmx.de
// Modified by Javad Razavian javadr@gmail.com

// Code chunks worth copying, and the page regions they may be copied from.
const CODE_SELECTOR = 'pre, span > code, p > code, li > code';
const CONTAINER_SELECTOR = 'div.qa-part-q-view, div.qa-part-a-list, div#question, div#answers, div.qist-data';

const HOVER_CLASS = 'parsilatex-code-save-hover';
const FLASH_CLASS = 'soctoc';
const FAIL_CLASS = 'parsilatex-code-save-failed';
const FLASH_MS = 410;

// Events are delegated from document rather than bound to a one-time snapshot
// of the containers, so the handlers still work when a container is rendered
// after this script runs. jQuery used to provide that delegation; it is done
// by hand now so no third-party bundle ships with the add-on.
//
// A delegated handler sees the innermost element the event hit, so walk up
// from it to the chunk that should be acted on.
function codeChunk(target) {
	for (let el = target instanceof Element ? target : null; el !== null; el = el.parentElement) {
		if (el.matches(CODE_SELECTOR)) {
			return el;
		}
	}

	return null;
}

// Keeps the original scope of acting on Q&A content only.
function inContent(chunk) {
	return chunk.closest(CONTAINER_SELECTOR) !== null;
}

// mouseover/mouseout bubble, and they also fire while the pointer moves
// between a chunk and its own descendants (a <code> inside a <pre>). Testing
// the related target restores mouseenter/mouseleave semantics, so the
// highlight does not flicker when the pointer moves inside one chunk.
function crossesBorder(chunk, related) {
	return !(related instanceof Node && chunk.contains(related));
}

// Legacy copy path: execCommand over a scratch textarea. The textarea is kept
// off-screen and readonly so focusing it neither scrolls the page nor lets the
// user type into it. Returns true when the browser reports a successful copy.
function copyWithExecCommand(text) {
	const scratch = document.createElement('textarea');
	scratch.value = text;
	scratch.setAttribute('readonly', '');
	scratch.style.cssText = 'position: fixed; top: 0; left: 0; opacity: 0;';
	document.body.appendChild(scratch);
	scratch.select();

	let copied;
	try {
		copied = document.execCommand('copy');
	} catch {
		copied = false;
	} finally {
		scratch.remove();
	}

	return copied;
}

// execCommand is deprecated but is still the most reliable path inside a
// content script, so it runs first; the async Clipboard API takes over when it
// reports failure. Either way the outcome is reported instead of failing
// silently.
function copyText(text, onResult) {
	if (copyWithExecCommand(text)) {
		onResult(true);
		return;
	}

	if (typeof navigator.clipboard !== 'undefined' && typeof navigator.clipboard.writeText === 'function') {
		navigator.clipboard.writeText(text).then(
			() => {
				onResult(true);
			},
			() => {
				onResult(false);
			}
		);
		return;
	}

	onResult(false);
}

// Brief visual confirmation: flash on success, outline on failure.
function flash(chunk, className) {
	chunk.classList.add(className);
	setTimeout(() => {
		chunk.classList.remove(className);
	}, FLASH_MS);
}

// The following lines highlight what elements got selected
document.addEventListener('mouseover', (event) => {
	const chunk = codeChunk(event.target);
	if (chunk === null || !inContent(chunk) || !crossesBorder(chunk, event.relatedTarget)) {
		return;
	}

	chunk.classList.add(HOVER_CLASS);
});

document.addEventListener('mouseout', (event) => {
	const chunk = codeChunk(event.target);
	if (chunk === null || !crossesBorder(chunk, event.relatedTarget)) {
		return;
	}

	chunk.classList.remove(HOVER_CLASS);
});

// Main part which copies the text to the clipboard
document.addEventListener('dblclick', (event) => {
	const chunk = codeChunk(event.target);
	if (chunk === null || !inContent(chunk)) {
		return;
	}

	// A <pre> keeps its code in a nested <code>, which is the part worth
	// copying; every other matched chunk holds its own text directly.
	const nested = chunk.tagName === 'PRE' ? chunk.querySelector('code') : null;
	const holder = nested === null ? chunk : nested;

	copyText(holder.textContent, (copied) => {
		flash(chunk, copied ? FLASH_CLASS : FAIL_CLASS);
	});
});
