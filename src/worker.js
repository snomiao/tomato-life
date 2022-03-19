// ref: [service worker 是什么？看这篇就够了 - 知乎]( https://zhuanlan.zhihu.com/p/115243059 )

if ("serviceWorker" in navigator) {
    window.addEventListener("load", function () {
        navigator.serviceWorker
            .register("./background.js", { scope: "./" })
            .then(function (registration) {
                console.log(
                    "ServiceWorker registration successful with scope: ",
                    registration.scope
                );
            })
            .catch(function (err) {
                console.log("ServiceWorker registration failed: ", err);
            });
    });
}
