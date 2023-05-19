javascript: (function() {
	var button = document.evaluate("//*[@title='Edit FD Conversion Date']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 

	button.click();
	
	var inputText = "4/13/2023";
	
	var inputField = document.evaluate("//*[@name='FD_Conversion_Date__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	inputField.value = inputText;
	inputField.dispatchEvent(new Event("change"));
	
	var editButton = document.evaluate("//button[@name='SaveEdit']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	
	editButton.click();
})();

javascript: (function() {
	var button = document.evaluate("//*[@title='Edit FD Conversion Date']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 

	button.click();
})();

javascript: (function() {
	var button = document.evaluate("//*[@title='Edit Status']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 

	button.click();

	var button2 = document.evaluate("//button[@class='slds-combobox__input slds-input_faux slds-combobox__input-value']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 
	
	button2.click();

	var button3 = document.evaluate("//*[@data-value='Closed']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 

	button3.click()

})();


javascript: (function() {
	var inputText = prompt('Enter 15-character ID');
	
	var inputField = document.evaluate("//*[@name='FD_Conversion_Date__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	inputField.value = inputText;
	inputField.dispatchEvent(new Event("change"));
})();

javascript: (function() {
	var inputText = prompt('Enter 15-character ID');
	
	var inputField = document.evaluate("//*[@name='FD_Conversion_Date__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	inputField.value = inputText;
	inputField.dispatchEvent(new Event("change"));
	
	var editButton = document.evaluate("//button[@name='SaveEdit']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	
	editButton.click();
})();


javascript: (function() {var button = document.evaluate("//*[@title='FD MID']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; button.click();})();

javascript: (function() {var inputText = prompt('Enter 15-character ID');var inputField = document.evaluate("//*[@name='FD_MID__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;inputField.value = inputText;inputField.dispatchEvent(new Event("change"));var editButton = document.evaluate("//button[@name='SaveEdit']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;editButton.click();})();

javascript: (function() {var inputText = prompt('Enter 15-character ID');var inputField = document.evaluate("//*[@name='FD_MID__c']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;inputField.value = inputText;inputField.dispatchEvent(new Event("change"));})();

javascript: (function() {var editButton = document.evaluate("//button[@name='SaveEdit']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;editButton.click();})();