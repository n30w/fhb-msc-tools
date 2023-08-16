# Automation Tools for Merchant Services

This repository contains various AutoHotkey (AHK), Python, Javascript (JS), Bash, Powershell, and Visual Basic (VBA) scripts that enable quick and semi-automated updates, creations, and deletions of Salesforce data. It also provides the user with tools that speed up the process of finding merchant information through hotkeys. This project was created for aiding the Merchant Conversion Process at FHB in 2023.

---

## Program Structure

AHK controls all of the scripting and data manipulation; all of the program's thinking is done in AHK. It uses the scripts from the other aforementioned programming languages to execute tasks.

Tasks is a broad term, so execution of there are three terms that form the logic of this program, which follows a bottom-up approach: actions, routines, and workflows. An action is like a block of lego. Stringing together actions builds a routine, similar to how connecting lego bricks creates an object with form. A routine run periodically with the goal of manipulating large sets of data is a workflow. Routines can be coded to be manually triggered via hotkey and only perform its actions once. A workflow can also be triggered with a hotkey, but performs a routine many times, perhaps also combining routines and actions together to make a cohesive, repeatable sequence of events to accomplish a large scale goal. 

Each program that AHK manipulates has its own AHK file located in the ```apps``` directory in this repository. They all have their own file because each program has its own set of actions. For example, to click a certain button or move the mouse to a certain area, or with more complexity, execute a script.

This program's entry point is ```main.ahk```, an AHK file. A shortcut to the file was placed in the startup folder for Windows, starting ```main.ahk``` the first time a user logs into the computer from a fresh startup or reboot.

---

## Good Resources

### AutoHotkey

- [Miscellaneous AutoHotkey Notes](https://renenyffenegger.ch/notes/tools/autohotkey/index)
- [Enum tutorial](https://www.autohotkey.com/boards/viewtopic.php?t=88725)
- [Enum examples](https://github.com/ahk-v2-kb/internals/blob/master/Enumerator/04_Enumerator_Collection.ahk)

### JavaScript

- [JS Map Reference W3 Schools](https://www.w3schools.com/js/js_object_maps.asp) and [MDN web docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)
- [Wait for element to load in](https://stackoverflow.com/a/61511955/20087581)
- [CSV parsing with D3](https://jwood206.medium.com/csv-file-parsing-with-d3-db37a8ab1111)
- [Redirecting a webpage with JS](https://www.w3schools.com/howto/howto_js_redirect_webpage.asp)
- [Chaining async functions](https://stackoverflow.com/questions/38644754/chain-async-functions)
- [XPath Expressions Small Reference by IBM](https://www.ibm.com/docs/en/psfa/7.2.1?topic=functions-xpath-expressions)

### Python

-

### PowerShell

-

### Windows

- [Installing NodeJS without admin rights as a local user](https://stackoverflow.com/questions/37029089/how-to-install-nodejs-lts-on-windows-as-a-local-user-without-admin-rights)
- [Creating an HTTP server to serve files to JS](https://stackoverflow.com/questions/39007243/cannot-open-local-file-chrome-not-allowed-to-load-local-resource)