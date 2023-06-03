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

const myTimeout = (fn) => {
    return new Promise((resolve) => {
        setTimeout(() => {
            fn;
            resolve("done timing out");
        }, 300);
    });
};

async function main() {
    console.log("start");
    let selection = "//records-record-layout-item[@field-label='Closed Date']";
    const elm = await waitForElm(selection);
    copyToClipboard(elm.childNodes[0].value);
    console.log("finished");
};

main();

})();

// async function GetClosedDate(s) {
//     console.log("ok");
//     let selection = "//records-record-layout-item[@field-label='Closed Date']";
//     const elm = await waitForElm(selection);
//     setTimeout(() => {
//         copyToClipboard(elm.childNodes[0].value);
//         console.log("copied");
//     }, 300);
//     console.log("finished");
// }