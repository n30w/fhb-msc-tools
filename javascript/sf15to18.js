javascript: (function() {
    var input = prompt('Enter 15-character ID');
    var output;
    if (input.length == 15) {
        var addon = "";
        for (var block = 0; block < 3; block++) {
            var loop = 0;
            for (var position = 0; position < 5; position++) {
                var current = input.charAt(block * 5 + position);
                if (current >= "A" && current <= "Z") loop += 1 << position;
            }
            addon += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(loop);
        }
        output = (input + addon);
    } else {
        alert("Error : " + input + " isn't 15 characters (" + input.length + ")");
        return;
    }
    prompt('18-character ID:', output);
})();