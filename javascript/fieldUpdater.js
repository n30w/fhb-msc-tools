javascript: (function() {

    const myTimeout = (fn, t = 300) => {
        return new Promise((resolve) => {
            setTimeout(() => {
                fn();
                resolve("done timing out");
            }, t);
        });
    };

    const copyToClipboard = str => {
        if (navigator && navigator.clipboard && navigator.clipboard.writeText)
            return navigator.clipboard.writeText(str);
        return Promise.reject('The Clipboard API is not available.');
    };

    const getSingleNode = (sel) => {
        return document.evaluate(sel, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    };

    const buildXPath = (elm, prop, val) => {
        return `//${elm}[@${prop}='${val}']`;
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
                copyToClipboard("changed");
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

    const editFields = (edit, fn) => {
        if (edit === false) {
            return new Promise((resolve) => {
                resolve(edit);
            });
        } else {
            return new Promise((resolve) => {
                fn();
                resolve(edit);
            });
        }
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

    function buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate) {
        let m = new Map();
        let defaultHeaderFields = ["dba", "wpmid", "fdmid", "chain", "superChain", "tin", "dda", "openDate", "closedDate", "conversionDate"];
        let pageFields = [accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate];
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
        console.log("start");

        let inputString = ""; /* get clipboard string here */
        let allEqual = true;
        
        let accountName = new sfElm("Account Name");
        let wpmid = new sfElm("WP MID", "Merchant_Id__c");
        let fdmid = new sfElm("FD MID");
        let openDate = new sfElm("Open Date", "Merchant_Open_Date__c");
        let closedDate = new sfElm("Closed Date", "Merchant_Closed_Date__c");
        let conversionDate = new sfElm("FD Conversion Date");
        let chain = new sfElm("WP Chain ID", "Chain_ID__c");
        let superChain = new sfElm("WP Super Chain ID");
        let dda = new sfElm("DDA");
        let tin = new sfElm("TIN");

        let fieldRef = buildFieldRefMap(accountName, wpmid, fdmid, chain, superChain, tin, dda, openDate, closedDate, conversionDate);

        await navigator.clipboard
            .readText()
            .then((clipText) => {
                inputString = clipText;
            });
        
        console.log(inputString);

        let fieldValuesFromInputString = inputString.split("+")[0].split(",");
        let headerFieldsFromInputString = inputString.split("+")[1].split(",");
        /* console.log(fieldValuesFromInputString); */
        /* console.log(headerFieldsFromInputString); */

        /* Check if any fields are not equal to any fields in the inputString given by AHK. */
        await myTimeout(() => {
            headerFieldsFromInputString.forEach(async function(val, i) {
                let fr = fieldRef.get(val);
                let elm1 = await waitForElm(recordLayoutItemField(fr.propFieldLabel));
                fr.value = elm1.childNodes[0].value;
                if (fieldValuesFromInputString[i] !== fr.value) {
                    allEqual = false;
                    fr.isEqual = false;
                    fr.newValue = fieldValuesFromInputString[i];
                    console.log(fr);
                }
            });
        }, 400);

        /* Exit program if equal */
        const exitPromise = await assertEqual(allEqual);
        const editSF = await editFields(exitPromise, () => {
            headerFieldsFromInputString.forEach(async function(val, i) {
                fr = fieldRef.get(val);
                if (fr.isEqual === false) {
                    if (i == 0) { /* turn Salesforce into edit mode for fields. */
                         /* await clickButton(exitPromise, "title", fr.btnTitle); */
                        await myTimeout(() => {
                            let selection = document.evaluate(buttonField("title", fr.btnTitle), document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                            selection.click();
                            copyToClipboard("changed");
                        });
                    }
                    /*let selection = getSingleNode(inputField(this.textInput));*/
                    let selection = document.evaluate(inputField(fr.textInput), document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                    console.log("editing text " + selection);
                    selection.value = fr.newValue;
                    await this.setNewValue();
                    return await myTimeout(() => {
                        selection.dispatchEvent(new Event("change"));
                    }, 500);
                }
            });
        });
        await clickButton(editSF, "name", "SaveEdit");
        
        console.log("finished");
    }

    main();

})();