# Localhost File Server

This is the server directory that http-server should point to. This is where all the files are stored for the JavaScript bookmarklets to access.

## Possible Errors

### Content Security Policy

Note that some sites like Salesforce restrict what scripts can and cannot be loaded. The error "... because it violates the following content security policy directive" occurs when trying to inject a foreign script into the webpage by appending it to ```document```. In this case, the only automation that can be done is to use a bookmarklet that doesn't load any external scripts, and instead just manipulates the bare HTML.

The aforementioned error occurred when trying to load the JS library D3, both remotely and locally, to parse CSV files. A solution could be to just do a fetch request and parse a CSV in the bookmarklet without using a library. Better yet, you could turn the CSV into a JSON.

### Cross-Origin Resource Sharing (CORS) is disabled

Ensure the web server has CORS enabled. This can be done by adding the command line flag ```--cors``` when starting the server with ```npx```.

### Server not hosting or updating local files

This error could occur because the cache is set too high (the default is 3600 seconds, or 60 minutes). To fix this, add the command line flag ```-c10``` when starting the server with ```npx```. This sets the cache to 10 seconds.

---

[HTTP Server Documentation and GitHub page](https://github.com/http-party/http-server)