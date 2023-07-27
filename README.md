# Automation Tools for Merchant Services

This repository contains various AutoHotkey (AHK), Python, Javascript (JS), Bash, Powershell, and Visual Basic (VBA) scripts that enable quick and semi-automated updates, creations, and deletions of Salesforce data. It also provides the user with tools that speed up the process of finding merchant information through hotkeys. This project was created for aiding the Merchant Conversion Process at FHB in 2023.

---

## Program Structure

AHK controls all of the scripting and data manipulation; all of the program's thinking is done in AHK. It uses the scripts from the other aforementioned programming languages to execute tasks.

Tasks is a broad term, so execution of there are three terms that form the logic of this program, which follows a bottom-up approach: actions, routines, and workflows. An action is like a block of lego. Stringing together actions builds a routine, similar to how connecting lego bricks creates an object with form. A routine run periodically with the goal of manipulating large sets of data is a workflow. Routines can be coded to be manually triggered via hotkey and only perform its actions once. A workflow can also be triggered with a hotkey, but performs a routine many times, perhaps also combining routines and actions together to make a cohesive, repeatable sequence of events to accomplish a large scale goal. 

Each program that AHK manipulates has its own AHK file located in the ```apps``` directory in this repository. They all have their own file because each program has its own set of actions. For example, to click a certain button or move the mouse to a certain area, or with more complexity, execute a script.

This program's entry point is ```main.ahk```, an AHK file. A shortcut to the file was placed in the startup folder for Windows, starting ```main.ahk``` the first time a user logs into the computer from a fresh startup or reboot.