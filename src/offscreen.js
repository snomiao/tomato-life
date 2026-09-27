// 由 worker.js 通知播放提示音
chrome.runtime.onMessage.addListener(({ 播放 }) => {
    if (播放) new Audio(`./assets/${播放}.mp3`).play();
});
