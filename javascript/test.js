javascript: (function() {

    function myTimeout(fn, t = 300) {
        return new Promise((resolve) => {
            setTimeout(() => {
                fn();
                resolve("done timing out");
            }, t);
        });
    }

    /* https://jwood206.medium.com/csv-file-parsing-with-d3-db37a8ab1111 */
    let script = document.createElement('script');
    script.src = "https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js";
    script.onload = function() {
        const fdposData = "http://localhost:8080";
        let arr = [];
        d3.csv(fdposData, data => arr.push(data));
        console.log(arr);
    };

    document.head.appendChild(script);

})();