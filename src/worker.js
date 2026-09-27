// Copyright (c) 2020 snomiao@gmail.com. All rights reserved.
// LICENSED BY GNU GENERAL PUBLIC LICENSE v3

import { 番茄状态检查, 剩余分钟 } from "./tomato.js";

// 每分钟整点触发一次
const 创建闹钟 = () =>
    chrome.alarms.create("tick", {
        when: Date.now() + 60000 - (Date.now() % 60000),
        periodInMinutes: 1,
    });
chrome.runtime.onInstalled.addListener(创建闹钟);
chrome.runtime.onStartup.addListener(创建闹钟);

const 更新徽标 = () => {
    const 番茄状态 = 番茄状态检查();
    chrome.action.setBadgeText({ text: String(剩余分钟()) });
    chrome.action.setBadgeBackgroundColor({
        color: 番茄状态 === "工作时间" ? "#d33" : "#393",
    });
};

// NOTE: Audio can't play at service worker, play it in an offscreen document
const 播放 = async (音符) => {
    const 已存在 = (
        await chrome.runtime.getContexts({ contextTypes: ["OFFSCREEN_DOCUMENT"] })
    ).length;
    if (!已存在) {
        await chrome.offscreen.createDocument({
            url: "offscreen.html",
            reasons: ["AUDIO_PLAYBACK"],
            justification: "Play a chime when work or rest time starts",
        });
    }
    await chrome.runtime.sendMessage({ 播放: 音符 });
};

chrome.alarms.onAlarm.addListener(async () => {
    更新徽标();
    // 边沿触发：只在每个番茄的第 0 分钟（开始工作）和第 25 分钟（开始休息）响
    const 分 = new Date().getMinutes() % 30;
    if (分 === 0) await 播放("NoteC_G"); // 升调
    if (分 === 25) await 播放("NoteG_C"); // 降调
});

更新徽标();
