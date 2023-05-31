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
    
    let selection = "//records-record-layout-item[@field-label='Open Date']";

    waitForElm(selection).then((elm) => {
        console.log("found label");
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            copyToClipboard(elm.childNodes[0].value);
        }, 300);
    });
})();

javascript: (function() {
    let selection = document.evaluate("//button[@title='Edit Open Date']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    
    selection.click();
})();

javascript: (function() {
    let selection = document.evaluate("//input[@name='Merchant_Open_Date__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    console.log("editing text");
    setTimeout(() => {
        navigator.clipboard
            .readText()
            .then((clipText) => {
                selection.value = clipText;
                selection.dispatchEvent(new Event("change"));
            });
    }, 700);
    
})();

javascript: (function() {
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

    let selection = "//button[@name='SaveEdit']";

    waitForElm(selection).then((elm) => {
        console.log('element found');
        /* Timeout because JS needs time to focus on the DOM */
        setTimeout(() => {
            elm.click();
        }, 200);
    });
    
})();