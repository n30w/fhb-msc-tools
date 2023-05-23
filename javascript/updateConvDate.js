// ConversionDate folder on Edge.

// Edits conversion date if needed.
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
    
    let selection = "//records-record-layout-item[@field-label='FD Conversion Date']";
    let comparison;
    let same = false;

    waitForElm(selection).then((elm) => {
        console.log("found label");
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            comparison = elm.childNodes[0].value;
            copyToClipboard(elm.childNodes[0].value);
        }, 300);

        /* This is where AutoHotkey pushes a value to the Clipboard */
        
        /* Compare AHK's value to the local one here */
        setTimeout(() => {
            navigator.clipboard
                .readText()
                .then((clipText) => {
                    if (clipText === comparison) {
                        /* JS replaces Clipboard so AutoHotkey can read it */
                        copyToClipboard("same");
                        same = true;
                        if (same)
                            return;
                    }
                });
        }, 600);
    });

    selection = "//*[@title='Edit FD Conversion Date']";
    
    waitForElm(selection).then((elm) => {
        console.log("clicking edit button");
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            elm.click();
        }, 200);
    });

    selection = "//*[@name='FD_Conversion_Date__c']";

    waitForElm(selection).then((elm) => {
        console.log("editing text");
        navigator.clipboard
            .readText()
            .then((clipText) => {
                elm.value = clipText;
                elm.dispatchEvent(new Event("change"));
            });
    });

    selection = "//button[@name='SaveEdit']";

    waitForElm(selection).then((elm) => {
        console.log("clicking save button");
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            elm.click();
            copyToClipboard("finished");
        }, 200);
    });

    setTimeout(() => {
        elm.click();
        copyToClipboard("");
    }, 200);

})();