// Copyright (c) 2020 snomiao@gmail.com. All rights reserved.
// LICENSED BY GNU GENERAL PUBLIC LICENSE v3

const lang = navigator.language || navigator.userLanguage
// ["ja"
// "en-US"
// "ja-HK"
// "zh-HK"
// "zh"
// "en"
// "zh-CN"]

const NoteC_G = new Audio("NoteC_G.mp3");
const NoteG_C = new Audio("NoteG_C.mp3");
const 边沿检测器 = (初始值) => (新值) => (初始值 != 新值 ? (初始值 = 新值) : undefined)
const 番茄状态检查 = () => ((new Date().getMinutes()) % 30 < 25) && "工作时间" || "休息时间";
const 今天的第几个番茄 = () => (new Date() - new Date(new Date().toDateString())) / 1000 / 60 / 30 | 0

const 提示元素 = document.querySelector('#tips')
const 边沿检测 = 边沿检测器()

const 状态动作表 = {
    '工作时间': async () => await NoteC_G.play(),
    '休息时间': async () => await NoteG_C.play(),
};

const loop = async () => {
    // 对齐到下一秒的0毫秒
    setTimeout(loop, 1000 - (+new Date() % 1000))

    const 番茄状态 = 番茄状态检查()
    const 状态动作 = 状态动作表[边沿检测(番茄状态)];
    if (!状态动作) return; // 边沿触发
    await 状态动作();

    if (!提示元素) return; // 只在弹出菜单有提示元素
    提示元素.innerText = '现在是：' + 番茄状态
}
// 启动
loop()
