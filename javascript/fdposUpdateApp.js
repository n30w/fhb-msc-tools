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

    class feature {
        constructor(fn, val, rt = null) {
            this.fn = fn;
            this.val = val;
            this.rt = rt;
        }
    }

    async function main() {
        /* https://jwood206.medium.com/csv-file-parsing-with-d3-db37a8ab1111 */
        let script = document.createElement('script');
        let dataArr = [];
        const userPrompt = prompt("file from web server", "test.csv");
        const fdposData = `http://127.0.0.1:8080/${userPrompt}`;

        await myTimeout(() => {
            script.src = "https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js";
            script.onload = function() {
                d3.csv(fdposData, data => dataArr.push(data));
                console.log(dataArr);
            };
        
            document.head.appendChild(script);
        });

        await myTimeout(async () => {
            for (let i = 0; i < dataArr.length; i++) {
                const headers =  Object.getOwnPropertyNames(dataArr[0]);
                const hl = headers.length;
                const EBT = [
                    new feature("AVS Mismatch Prompt", "N"),
                    new feature("AVS/Card Not Present", "Y"),
                    new feature("AVS/Card Present", "Y"),
                    new feature("Account Alias Name", dataArr[i].dba),
                    new feature("Allow Different Card Close Tab", "Y"),
                    new feature("Allow PIN Bypass for Chip", "N"),
                    new feature("Always Print Signature Line", "N"),
                    new feature("Authorization Tolerance", "00"),
                    new feature("Block Demo Mode", "Y"),
                    new feature("Bypass Card Present", "N"),
                    new feature("Bypass Tip on Sale", "N"),
                    new feature("Card Code Validation", "N"),
                    new feature("Card Present Default", "Y"),
                    new feature("Card Verification", "0"),
                    new feature("Cash Back Limit", "99999"),
                    new feature("Close Tab Print", "Y"),
                    new feature("Confirm Old Pre-Auth Delete", "Y"),
                    new feature("Credit Enable", "Y"),
                    new feature("Detail on Summary Report", "Y"),
                    new feature("Display Last 4 After Swipe", "N"),
                    new feature("Double Amount Entry", "N"),
                    new feature("Download Confirmation", "N"),
                    new feature("Download Time", "0000"),
                    new feature("Duplicate Invoice Check", "N"),
                    new feature("Duplicate Tran Check Mode", "0"),
                    new feature("Duplicate Transaction Check", "Y"),
                    new feature("E-Commerce Indicator", "N"),
                    new feature("E-commerce merchant type default", "7"),
                    new feature("Enter Tip After Sale", "N"),
                    new feature("Force Allowed", "N"),
                    new feature("IP Dial Backup", "Y"),
                    new feature("IRS Trac Reporting", "N"),
                    new feature("Key Invoice Number", "N"),
                    new feature("Manual Entry Password", "Y"),
                    new feature("Net Summary", "Y"),
                    new feature("No Signature Program", "2"),
                    new feature("Open Tab Print", "Y"),
                    new feature("Open Tab Signature Line", "N"),
                    new feature("Partial Reversal Percent", "00"),
                    new feature("Password map", "00001101031000110011"),
                    new feature("Pin Pad Cashback Entry", "N"),
                    new feature("Pin Pad Tip Entry", "N"),
                    new feature("Pre-Auth Age Limit", "00"),
                    new feature("Print 2nd Receipt on Voids", "N"),
                    new feature("Print ID Line", "N"),
                    new feature("Print Invoices", "Y"),
                    new feature("Print Phone # Line", "N"),
                    new feature("Print Promissory Footnote", "Y"),
                    new feature("Prompt For Table", "N"),
                    new feature("Purchase With Balance Return Allowed", "Y"),
                    new feature("Recurring Payment Indicator", "N"),
                    new feature("Server Entry", "N"),
                    new feature("Server Totals on Summary Report", "N"),
                    new feature("Settle With Open Tabs", "Y"),
                    new feature("Settle With Unadjusted Tips", "Y"),
                    new feature("Suggested Tip % 1", "00"),
                    new feature("Suggested Tip % 2", "00"),
                    new feature("Suggested Tip % 3", "00"),
                    new feature("Tax Exempt", "Y"),
                    new feature("Tip Entry", "N"),
                    new feature("Truncate Account# On Reports", "Y"),
                    new feature("Valuelink Alt MID", " ")
                ];
    
                const EBTSpecialFeatures = [
                    new feature("Download Type", "0", "AUTO DLL NOT REQUIRED"),
                    new feature("FPS printer option", "10", "Both Receipts w/ confirm"),
                    new feature("Footer Line 1", "0"),
                    new feature("Footer Line 2", "0"),
                    new feature("Header Line 1", "0"),
                    new feature("Header Line 2", "0"),
                    new feature("Invoice Text", "1", "INVOICE"),
                    new feature("IP Communication Type", "01", "DataWire"),
                    new feature("Pre Tip Text", "2", "MDSE/SERVICES"),
                    new feature("Server Text Long", "2", "CLERK"),
                    new feature("Tip Text", "1", "TIP")
                ];
        
                const Credit = [
                    new feature("AVS Mismatch Prompt", "N"),
                    new feature("AVS/Card Not Present", "Y"),
                    new feature("AVS/Card Present", "Y"),
                    new feature("Account Alias Name", dataArr[i].dba),
                    new feature("Allow Different Card Close Tab", "Y"),
                    new feature("Allow PIN Bypass for Chip", "Y"),
                    new feature("Always Print Signature Line", "N"),
                    new feature("Authorization Tolerance", "00"),
                    new feature("Block Demo Mode", "Y"),
                    new feature("Bypass Card Present", "N"),
                    new feature("Bypass Tip on Sale", "N"),
                    new feature("Card Code Validation", "N"),
                    new feature("Card Present Default", "Y"),
                    new feature("Card Verification", "0"),
                    new feature("Cash Back Limit", "99999"),
                    new feature("Close Tab Print", "Y"),
                    new feature("Confirm Old Pre-Auth Delete", "Y"),
                    new feature("Credit Enable", "Y"),
                    new feature("Detail on Summary Report", "Y"),
                    new feature("Display Last 4 After Swipe", "N"),
                    new feature("Double Amount Entry", "N"),
                    new feature("Download Confirmation", "N"),
                    new feature("Download Time", "0000"),
                    new feature("Duplicate Invoice Check", "N"),
                    new feature("Duplicate Tran Check Mode", "0"),
                    new feature("Duplicate Transaction Check", "Y"),
                    new feature("E-Commerce Indicator", "N"),
                    new feature("E-commerce merchant type default", "7"),
                    new feature("Enter Tip After Sale", "N"),
                    new feature("Force Allowed", "N"),
                    new feature("IP Dial Backup", "Y"),
                    new feature("IRS Trac Reporting", "N"),
                    new feature("Key Invoice Number", "N"),
                    new feature("Manual Entry Password", "Y"),
                    new feature("Net Summary", "Y"),
                    new feature("No Signature Program", "2"),
                    new feature("Open Tab Print", "Y"),
                    new feature("Open Tab Signature Line", "N"),
                    new feature("Partial Reversal Percent", "00"),
                    new feature("Password map", "00001101031000110011"),
                    new feature("Pin Pad Cashback Entry", "N"),
                    new feature("Pin Pad Tip Entry", "N"),
                    new feature("Pre-Auth Age Limit", "00"),
                    new feature("Print 2nd Receipt on Voids", "N"),
                    new feature("Print ID Line", "N"),
                    new feature("Print Invoices", "Y"),
                    new feature("Print Phone # Line", "N"),
                    new feature("Print Promissory Footnote", "Y"),
                    new feature("Prompt For Table", "N"),
                    new feature("Purchase With Balance Return Allowed", "Y"),
                    new feature("Recurring Payment Indicator", "N"),
                    new feature("Server Entry", "N"),
                    new feature("Server Totals on Summary Report", "N"),
                    new feature("Settle With Open Tabs", "Y"),
                    new feature("Settle With Unadjusted Tips", "Y"),
                    new feature("Suggested Tip % 1", "00"),
                    new feature("Suggested Tip % 2", "00"),
                    new feature("Suggested Tip % 3", "00"),
                    new feature("Tax Exempt", "Y"),
                    new feature("Tip Entry", "N"),
                    new feature("Truncate Account# On Reports", "Y"),
                    new feature("Valuelink Alt MID", " ")
                ];
        
                const CreditSpecialFeatures = [
                    new feature("Download Type", "0", "AUTO DLL NOT REQUIRED"),
                    new feature("FPS printer option", "10", "Both Receipts w/ confirm"),
                    new feature("Footer Line 1", "0"),
                    new feature("Footer Line 2", "0"),
                    new feature("Header Line 1", "0"),
                    new feature("Header Line 2", "0"),
                    new feature("Invoice Text", "1", "INVOICE"),
                    new feature("IP Communication Type", "01", "DataWire"),
                    new feature("Pre Tip Text", "2", "MDSE/SERVICES"),
                    new feature("Server Text Long", "2", "CLERK"),
                    new feature("Tip Text", "1", "TIP")
                ];
                
                console.log(`=== CURRENT: ${dataArr[i].dba}, ${dataArr[i].FDMID} ===`);
                
                const features = Credit;

                for (let j = hl-1; j > 2; j--) {
                    const m = dataArr[i][headers[j]];
                    const tidSearchInput = await waitForElm(`//input[@title="Only alphanumeric charecters allowed. Add '%' at the beginning to perform pattern like search."]`);
            
                    await myTimeout(() => {
                        tidSearchInput.value = m;
                        tidSearchInput.dispatchEvent(new Event("input"));
                    }, 1000);
            
                    const searchBtn = await waitForElm("//button[text() = 'Search']");

                    await myTimeout(() => {
                        console.log(`Accessing ${m}`);
                        searchBtn.click();
                    });
                    
                    const applicationBtn = await waitForElm("//div[@id=41]");
                    
                    await myTimeout(() => {
                        applicationBtn.click();
                    }, 2000);
                    
                    const appLink = await waitForElm("//a[@style='cursor: pointer']");

                    await myTimeout(() => {
                        appLink.click();
                    }, 1000);

                    const editBtn = await waitForElm("//button[@class='btn btn-primary' and text() = 'Edit']");
                    
                    await myTimeout(() => {
                        editBtn.click();
                    }, 1000);
                    
                    await waitForElm("//div[button[text() = 'Edit' and @disabled]]");

                    await myTimeout(async () => {
                        for (let i = 0; i < features.length; i++) {
                            let v = features[i];
                            let elm = `//tr[td[text() = '${v.fn}']]`;
                            let tr = await document.evaluate(elm, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                            if (tr !== null)
                            {
                                const input = tr.querySelector("input");
                                input.value = v.val;
                                input.dispatchEvent(new Event("input"));
                            }
                        }
                    });

                    const saveBtn = await waitForElm("//button[@class='btn btn-success']");
                    
                    await myTimeout(() => {
                        saveBtn.removeAttribute("disabled");
                        saveBtn.click();
                    }, 1000).then(async () => {
                        await myTimeout(() => {
                            window.location.href = "https://fdpos.businesstrack.com/fdposng/#/search/main";
                        }, 2500);
                    });
                }
            }
        });
    }

    main();
})();