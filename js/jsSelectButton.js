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
})();

javascript: (function() {
	var button = document.evaluate("//button[@id='combobox-button-947']", document.body, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; 

	button.click();
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

