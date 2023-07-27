javascript: (function() {

    function myTimeout(fn, t = 300) {
        return new Promise((resolve) => {
            setTimeout(() => {
                fn();
                resolve("done timing out");
            }, t);
        });
    }

    /** Returns a value from a timeout */
    function myTimeoutVal(v, t = 300) {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve(v);
            }, t);
        });
    }

    const copyToClipboard = str => {
        if (navigator && navigator.clipboard && navigator.clipboard.writeText)
            return navigator.clipboard.writeText(str);
        return Promise.reject('The Clipboard API is not available.');
    };

    const getSingleNode = (sel) => {
        return document.evaluate(sel, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    };

    const buildXPath = (elmXPath, prop, val) => {
        return `//${elmXPath}[@${prop}='${val}']`;
    };

    const buttonField = (prop, val) => {
        return buildXPath("button", prop, val);
    };

    const recordLayoutItemField = (val) => {
        return buildXPath("records-record-layout-item", "field-label", val);
    };

    const clickButton = async (x, prop, val) => {
        if (!x) {
            await myTimeout(() => {
                let selection = getSingleNode(buttonField(prop, val));
                selection.click();
            });
        }
        return new Promise((resolve) => {
            resolve(x);
        });
    };

    const assertEqual = (x) => {
        return new Promise((resolve) => {
            if (x) {
                console.log("all equal");
                copyToClipboard("equal");
            }
            resolve(x);
        });
    };

    /* This is from: https://stackoverflow.com/a/61511955/20087581 */
    function waitForElm(selector) {
        return new Promise(resolve => {
            if (getSingleNode(selector)) {
                return resolve(getSingleNode(selector));
            }

            const observer = new MutationObserver(() => {
                if (getSingleNode(selector)) {
                    resolve(getSingleNode(selector));
                    observer.disconnect();
                }
            });

            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        });
    }

    class sfDropdown {
        constructor(fieldLabel, childValue) {
            this.fieldLabel = fieldLabel;
            this.childValue = childValue;
            this.currentValue = "";
        }
    }

    async function main() {
        let statusDrop = new sfDropdown("Status", "Closed");
        let typeDrop = new sfDropdown("Type", "Closed on WP");
        let caseReasonDrop = new sfDropdown("Case Reason", "Will Not Convert");
        let caseOriginDrop = new sfDropdown("Case Origin", "Internal");

        const fields = [statusDrop, typeDrop, caseReasonDrop, caseOriginDrop];
        let fields2 = [];

        /* Check if each dropdown needs to be changed */
        await myTimeout(async () => {
            await myTimeout(() => {
                fields.forEach(async (f, i) => {
                    let elm1 = await waitForElm(recordLayoutItemField(f.fieldLabel));
                    let val = elm1.childNodes[0].value;
                    console.log(val);
                    if (val !== f.childValue) {
                        if (val == null) {
                            f.currentValue = "--None--";
                            fields2.push(f);
                        } else {
                            if (f.fieldLabel !== "Case Origin") {
                                f.currentValue = val;
                                fields2.push(f);
                            }
                        }
                        console.log(f.fieldLabel + ": " + f.currentValue);
                    }
                });
            });
        }, 300);

        /* If there are values that need to be changed, change them here */
        await myTimeout(async () => {
            try {
                const exitPromise = await assertEqual((fields2.length > 0));
                await clickButton(!exitPromise, "title", "Edit Status");
                await myTimeout(async () => {
                    if (fields2.length > 0) {
                        const editBtn = await waitForElm("//button[@name='SaveEdit']");
                        myTimeout(() => {
                            fields2.forEach(async (f, i) => {
                                const btn2 = await waitForElm("//button[@aria-label='" + f.fieldLabel + ", " + f.currentValue + "']");
                                await myTimeout(() => {
                                    btn2.click();
                                }, 400);
                                const btn3 = await waitForElm("//lightning-base-combobox-item[@data-value='" + f.childValue +"']");
                                await myTimeout(() => {
                                    btn3.click();
                                });
                            });
                        }, 500).then(() => {
                            myTimeout(() => {
                                editBtn.click();
                                copyToClipboard("changed");
                            }, 1200);
                        });
                    } else {
                        console.log("Nothing to change");
                        copyToClipboard("none");
                    }
                }, 400);
                
            } catch (e) {
                console.log(e);
            }
        }, 500);
    }

    main();

})();