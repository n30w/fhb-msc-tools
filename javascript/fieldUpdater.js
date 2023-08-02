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

    function buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID) {
        let m = new Map();
        let defaultHeaderFields = ["dba", "wpmid", "fdmid", "chain", "superChain", "tin", "dda", "openDate", "closedDate", "conversionDate", "fdChainID", "fdCorpID"];
        let pageFields = [accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID];
        defaultHeaderFields.forEach(function(val, i) {
            m.set(val, pageFields[i]);
        });
        return m;
    }

    class sfElm {
        constructor(fieldLabel, inputFieldName = "none") {
            this.propFieldLabel = fieldLabel;
            this.btnTitle = "Edit " + fieldLabel;
            this.textInput = (inputFieldName === "none" ? fieldLabel.split(' ').join('_') + "__c" : inputFieldName );
            this.value = "none";
            this.newValue = "none";
            this.isEqual = true;
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

        let fieldRef = buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate, fdChainID, fdCorpID);

        let inputString = ""; /* get clipboard string here */
        let allEqual = true;

        let fieldValuesFromInputString;
        let headerFieldsFromInputString;

        console.log("=== START ===");

        /*await myTimeout(() => {
            console.log("Waiting for DOM focus...");
        }, 400);*/
        
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
        
        /** Wait for arbitrary field to load */
        
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
                    console.log("INEQUALITY FOUND: " + val + " (" + fr.value + " => " + fr.newValue + ")");
                }

            });
        }, 300);

        await myTimeout(async () => {
            /* Edit HTML to add values */
            try {
                /* Exit program if equal */
                const exitPromise = await assertEqual(allEqual);
                /* arbitrary button selection, just needs to get Salesforce page into edit field mode*/
                await clickButton(exitPromise, "title", "Edit Closed Date");
                await myTimeout(async () => {
                    if (!exitPromise) {
                        const editBtn = await waitForElm("//button[@name='SaveEdit']");
                        myTimeout(() => {
                            let fr;
                            headerFieldsFromInputString.forEach(async function(val) {
                                fr = fieldRef.get(val);
                                if (!fr.isEqual) {
                                    let selection = getSingleNode(inputField(fr.textInput));
                                    console.log("EDITING: " + fr.textInput);
                                    selection.value = fr.newValue;
                                    selection.dispatchEvent(new Event("change"));
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
        console.log("=== COMPLETE ===");
    }

    main();

})();