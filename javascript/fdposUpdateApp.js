javascript: (function() {

    function myTimeout(fn, t = 300) {
        return new Promise((resolve) => {
            setTimeout(() => {
                fn();
                resolve("done timing out");
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

        const c = await navigator.clipboard
                    .readText()
                    .then((clipText) => {
                        return clipText.replace(/\s+$/, '');
                    });

        const EBT = [
            new feature("AVS Mismatch Prompt", "N"),
            new feature("AVS/Card Not Present", "Y"),
            new feature("AVS/Card Present", "Y"),
            new feature("Account Alias Name", c),
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
            new feature("Account Alias Name", "7-ELEVEN #<STORE#>"),
            new feature("Allow Different Card Close Tab", "Y"),
            new feature("Allow PIN Bypass for Chip", "Y"),
            new feature("Always Print Signature Line", "N"),
            new feature("Amex Prepaid Program Preference", "1"),
            new feature("Authorization Tolerance", "0"),
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
            new feature("Debit Cash Back", "N"),
            new feature("Detail on Summary Report", "Y"),
            new feature("Display Last 4 After Swipe", "N"),
            new feature("Double Amount Entry", "N"),
            new feature("Download Confirmation", "N"),
            new feature("Download Time", "0"),
            new feature("Download Type", "0 AUTO DLL NOT REQUIRED"),
            new feature("Duplicate Invoice Check", "N"),
            new feature("Duplicate Tran Check Mode", "0"),
            new feature("Duplicate Transaction Check", "Y"),
            new feature("E-Commerce Indicator", "N"),
            new feature("E-commerce merchant type default", "7"),
            new feature("Enter Tip After Sale", "N"),
            new feature("FPS printer option", "10 Both receipts w/confirm?"),
            new feature("Footer Line 1", "0"),
            new feature("Footer Line 2", "0"),
            new feature("Force Allowed", "N"),
            new feature("Header Line 1", "0"),
            new feature("Header Line 2", "0"),
            new feature("IP Communication Type", "01 DataWire"),
            new feature("IP Dial Backup", "Y"),
            new feature("IRS Trac Reporting", "N"),
            new feature("Invoice Text", "1", "INVOICE"),
            new feature("Key Invoice Number", "N"),
            new feature("Manual Entry Password", "Y"),
            new feature("Net Summary", "Y"),
            new feature("No Signature Program", "2"),
            new feature("Open Tab Print", "Y"),
            new feature("Open Tab Signature Line", "N"),
            new feature("Partial Reversal Percent", "0"),
            new feature("Password map", "00001101031000110011"),
            new feature("Pin Pad Cashback Entry", "N"),
            new feature("Pin Pad Tip Entry", "N"),
            new feature("Pre Tip Text", "2", "MDSE/SERVICES"),
            new feature("Pre-Auth Age Limit", "0"),
            new feature("Print 2nd Receipt on Voids", "N"),
            new feature("Print ID Line", "N"),
            new feature("Print Invoices", "Y"),
            new feature("Print Phone # Line", "N"),
            new feature("Print Promissory Footnote", "Y"),
            new feature("Prompt For Table", "N"),
            new feature("Purchase With Balance Return Allowed", "Y"),
            new feature("Recurring Payment Indicator", "N"),
            new feature("Server Entry", "N"),
            new feature("Server Text Long", "2", "CLERK"),
            new feature("Server Totals on Summary Report", "N"),
            new feature("Settle With Open Tabs", "Y"),
            new feature("Settle With Unadjusted Tips", "Y"),
            new feature("Suggested Tip % 1", "0"),
            new feature("Suggested Tip % 2", "0"),
            new feature("Suggested Tip % 3", "0"),
            new feature("Tax Exempt", "Y"),
            new feature("Tip Entry", "1"),
            new feature("Tip Text", "1", "TIP"),
            new feature("Truncate Account# On Reports", "Y"),
            new feature("Valuelink Alt MID","" ,"")
        ];

        const CreditSpecialFeatures = [];

        
        /*const editBtn = await waitForElm("//div[button[text() = 'Edit']]");*/
        /*const saveBtn = await waitForElm("//div[button[text() = 'Save']]");*/
        
        const editBtn = await waitForElm("//button[@class='btn btn-primary']");
        await myTimeout(() => {
            editBtn.click();
        });
        await waitForElm("//div[button[text() = 'Edit' and @disabled]]")
            .then(async () => {
                for (let i = 0; i < EBT.length; i++) {
                    let v = EBT[i];
                    let elm = `//tr[td[text() = '${v.fn}']]`;
                    let tr = await document.evaluate(elm, document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                    if (tr !== null)
                    {
                        console.log(v.fn);
                        console.log(tr);
                        const input = tr.querySelector("input");
                        console.log(input);
                        input.value = v.val;
                        input.dispatchEvent(new Event("input"));
                    }
                }
            }).then(async () => {
                const saveBtn = await waitForElm("//button[@class='btn btn-success']");
                saveBtn.removeAttribute("disabled");
                saveBtn.click();
            });
    }

    main();
})();