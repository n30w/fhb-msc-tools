// FDMID folder on Edge.

// javascript: (function() {const copyToClipboard = str => {if (navigator && navigator.clipboard && navigator.clipboard.writeText)    return navigator.clipboard.writeText(str);return Promise.reject('The Clipboard API is not available.');}; var fdmidInputField = document.evaluate("//records-record-layout-item[@field-label='FD MID']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;copyToClipboard(fdmidInputField.childNodes[0].value);    setTimeout(function() {        copyToClipboard(fdmidInputField.childNodes[0].value);    }, 200);})();


// CheckFDMID: checks if FDMID exists on webpage using clipboard copy.
// Make sure lines are indented correctly. When it wasn't, it caused the unexpected end of input error.
javascript: (function() {
	const copyToClipboard = str => {
		if (navigator && navigator.clipboard && navigator.clipboard.writeText)
		    return navigator.clipboard.writeText(str);
		return Promise.reject('The Clipboard API is not available.');
	};
    
    /* This is from: https://stackoverflow.com/a/61511955/20087581 */
    function waitForElm(selector) {
        return new Promise(resolve => {
            if (document.evaluate(selector, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue) {
                return resolve(document.evaluate(selector, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue);
            }
    
            const observer = new MutationObserver(() => {
                if (document.evaluate(selector, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue) {
                    resolve(document.evaluate(selector, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue);
                    observer.disconnect();
                }
            });
    
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        });
    }
    
    let selection = "//records-record-layout-item[@field-label='FD MID']";

    waitForElm(selection).then((elm) => {
        console.log('element found');
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            copyToClipboard(elm.childNodes[0].value);
        }, 200);
    });

    selection = "//*[@title='Edit FD MID']";
    
    waitForElm(selection).then((elm) => {
        console.log('element found');
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            elm.click();
        }, 200);
    });

    selection = "//*[@name='FD_MID__c']";

    waitForElm(selection).then((elm) => {
        console.log('element found');
        navigator.clipboard
            .readText()
            .then((clipText) => {
                elm.value = clipText;
                elm.dispatchEvent(new Event("change"));
            });
    });

    selection = "//button[@name='SaveEdit']";

    waitForElm(selection).then((elm) => {
        console.log('element found');
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            elm.click();
        }, 200);
    });

})();