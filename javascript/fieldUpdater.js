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

    const inputField = (val) => {
        return buildXPath("input", "name", val);
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

    function buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID, closureReason) {
        let m = new Map();
        let defaultHeaderFields = ["dba", "wpmid", "fdmid", "chain", "superChain", "tin", "dda", "openDate", "closedDate", "conversionDate", "fdChainID", "fdCorpID", "closureReason"];
        let pageFields = [accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID, closureReason];
        defaultHeaderFields.forEach(function(val, i) {
            m.set(val, pageFields[i]);
        });
        return m;
    }

    const elmType = Object.freeze({
        INPUT_FIELD: Symbol("inputField"),
        DROPDOWN_MENU: Symbol("dropdown")
    });

    class sfElm {
        constructor(fieldLabel, inputFieldName = "none", type = elmType.INPUT_FIELD) {
            this.propFieldLabel = fieldLabel;
            this.btnTitle = "Edit " + fieldLabel;
            this.textInput = (inputFieldName === "none" ? fieldLabel.split(' ').join('_') + "__c" : inputFieldName );
            this.value = "none";
            this.newValue = "none";
            this.isEqual = true;
            this.type = type;
        }

        async getValue() {
            let elm1 = await waitForElm(recordLayoutItemField(this.propFieldLabel));
            this.value = elm1.childNodes[0].value;
        }
    }

    async function main() {
        let accountName = new sfElm("Account Name");
        let wpmid = new sfElm("WP MID", "Merchant_Id__c");
        let fdmid = new sfElm("FD MID");
        let openDate = new sfElm("Open Date", "Merchant_Open_Date__c");
        let closedDate = new sfElm("Closed Date", "Merchant_Closed_Date__c");
        let conversionDate = new sfElm("FD Conversion Date");
        let chain = new sfElm("WP Chain ID", "Chain_ID__c");
        let superChain = new sfElm("WP Super Chain ID");
        let fdChainID = new sfElm("FD Chain ID", "FD_Chain_ID__c");
        let fdCorpID = new sfElm("FD Corp ID", "FD_Corp_ID__c");
        let dda = new sfElm("DDA");
        let tin = new sfElm("TIN #", "TIN__c");

        let closureReason = new sfElm("Closure Reason", "none", elmType.DROPDOWN_MENU);

        let fieldRef = buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID, closureReason);

        let inputString = ""; /* get clipboard string here */
        let allEqual = true;

        let fieldValuesFromInputString;
        let headerFieldsFromInputString;

        /* Wait for arbitrary field to load so DOM can refocus */
        console.log("=== START ===");
        
        const elm = await waitForElm("//records-record-layout-item[@field-label='Closed Date']");

        navigator.clipboard
            .readText()
            .then((clipText) => {
                inputString = clipText;
                console.log("RECEIVED: " + clipText);
                fieldValuesFromInputString = inputString.split("+")[0].split(",");
                headerFieldsFromInputString = inputString.split("+")[1].split(",");
                console.log("FIELDS: " + fieldValuesFromInputString);
                console.log("HEADERS: " + headerFieldsFromInputString);
            });
        
        /* Check if any fields are not equal to any fields in the inputString given by AHK. */
        await myTimeout(() => {
            headerFieldsFromInputString.forEach(async function(val, i) {
                let fr = fieldRef.get(val);
                let elm1 = await waitForElm(recordLayoutItemField(fr.propFieldLabel));
                fr.value = await myTimeoutVal(elm1.childNodes[0].value);
                if (fieldValuesFromInputString[i] !== fr.value && fieldValuesFromInputString[i] !== "none") {
                    allEqual = false;
                    fr.isEqual = false;
                    fr.newValue = fieldValuesFromInputString[i];
                    if (fr.value == null) {
                        fr.value = "--None--";
                    }
                    console.log("INEQUALITY FOUND: " + val + " (" + fr.value + " => " + fr.newValue + ")");        
                }
            });
        }, 300);

        await myTimeout(async () => {
            /* Edit HTML to add values */
            try {
                /* Exit program if equal */
                const exitPromise = await assertEqual(allEqual);
                /* arbitrary edit button selection, just needs to get Salesforce page into edit field mode*/
                await clickButton(exitPromise, "title", "Edit Closure Reason");
                await myTimeout(async () => {
                    if (!exitPromise) {
                        const editBtn = await waitForElm("//button[@name='SaveEdit']");
                        myTimeout(() => {
                            headerFieldsFromInputString.forEach(async function(val) {
                                let fr = fieldRef.get(val);
                                if (!fr.isEqual) {
                                    switch (fr.type) {
                                        case elmType.INPUT_FIELD:
                                            let selection = getSingleNode(inputField(fr.textInput));
                                            selection.value = fr.newValue;
                                            selection.dispatchEvent(new Event("change"));
                                        case elmType.DROPDOWN_MENU:
                                            const dropdown = await waitForElm("//button[@aria-label='" + fr.propFieldLabel + ", " + fr.value + "']");
                                            await myTimeout(() => {
                                                dropdown.click();
                                            }, 400);
                                            const dropdownItem = await waitForElm("//lightning-base-combobox-item[@data-value='" + fr.newValue +"']");
                                            await myTimeout(() => {
                                                dropdownItem.click();
                                            });
                                    }
                                }
                            }, 300);
                        }).then(() => {
                            myTimeout(() => {
                                editBtn.click();
                                copyToClipboard("changed");
                                console.log("CHANGE SUCCESS");
                            }, 1200);
                        });
                    }
                });
            } catch(e) {
                console.log(e);
            }
        }, 1000);
    }

    main();

})();