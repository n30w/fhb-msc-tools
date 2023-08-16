javascript: (function() {

    function myTimeout(fn, t = 300) {
        return new Promise((resolve) => {
            setTimeout(() => {
                fn();
                resolve("done timing out");
            }, t);
        });
    }

    const getSingleNode = (sel) => {
        return document.evaluate(sel, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
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

    const sf15to18 = (str) => {
        let output;
        if (str.length == 15) {
            var addon = "";
            for (var block = 0; block < 3; block++) {
                var loop = 0;
                for (var position = 0; position < 5; position++) {
                    var current = str.charAt(block * 5 + position);
                    if (current >= "A" && current <= "Z") loop += 1 << position;
                }
                addon += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(loop);
            }
            output = (str + addon);
        } else {
            console.log("Error : " + str + " isn't 15 characters (" + str.length + ")");
            return;
        }
        return output;
    };

    class feature {
        constructor(fn, val, rt = null) {
            this.fn = fn;
            this.val = val;
            this.rt = rt;
        }
    }

    async function main() {
        let script1 = document.createElement('script1');

        const userPrompt = prompt("file from web server", "test.csv");
        const dataArr = [];
        const mids = `http://127.0.0.1:8080/${userPrompt}`;
        
        await myTimeout(() => {
            script1.src = "http://127.0.0.1:8080/cdnjs.cloudflare.com_ajax_libs_d3_7.8.5_d3.min.js";
            script1.onload = function() {
                d3.csv(mids, data => dataArr.push(data));
                console.log(dataArr);
            };
        
            document.head.appendChild(script1);
        });

        let script2 = document.createElement('script2');

        const accIDs = new Map();
        const accountIDs = `http://127.0.0.1:8080/accountIDs.csv`;
        /* "https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js" */
        await myTimeout(() => {
            script2.src = "http://127.0.0.1:8080/cdnjs.cloudflare.com_ajax_libs_d3_7.8.5_d3.min.js";
            script2.onload = function() {
                d3.csv(accountIDs, merchant => accIDs.set(merchant.WPMID, merchant.AccountID));
                console.log(accIDs);
            };

            document.head.appendChild(script2);
        });

        await myTimeout(async () => {
            for (let i = 0; i < dataArr.length; i++) {

                let accountID;

                try {
                    accountID = sf15to18(accIDs.get(dataArr[i].WPMID));
                } catch (e) {
                    console.log(`${dataArr[i].WPMID} does not have a Salesforce Account ID`);
                    continue;
                }

                let idURL = `https://fhb.lightning.force.com/lightning/r/Account/${accountID}/view`;

                await myTimeout(() => {
                    window.location.href = idURL;
                }, 2500);

                console.log(`=== CURRENT: ${dataArr[i].WPMID} ===`);

                const closedDateElm = await waitForElm("//input[@name='Merchant_Closed_Date__c']");

                if (closedDateElm.value === '') {

                    const editBtn = await waitForElm("//button[@title='Edit Closed Date']");

                    await myTimeout(() => {
                        editBtn.click();
                    });

                    const dropdown = await waitForElm("//records-record-layout-item[@field-label='Closure Reason']").querySelector("button");
                    
                    await myTimeout(() => {
                        dropdown.click();
                    }, 1000);
                    
                    const dropdownItem = await waitForElm(`//lightning-base-combobox-item[@data-value='${dataArr[i].closureReason}']`);

                    await myTimeout(() => {
                        dropdownItem.click();
                    });
                    
                    const saveBtn = await waitForElm("//button[@name='SaveEdit']");
                    
                    await myTimeout(() => {
                        saveBtn.click();
                    }, 1000);
                }
            }
        });
    }

    main();
})();