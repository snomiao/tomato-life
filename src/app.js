// Copyright (c) 2020 snomiao@gmail.com. All rights reserved.
// LICENSED BY GNU GENERAL PUBLIC LICENSE v3

import { 番茄状态检查, 剩余分钟 } from "./tomato.js";

const 提示元素 = document.querySelector("#tips");

const loop = () => {
    // 对齐到下一秒的0毫秒
    setTimeout(loop, 1000 - (+new Date() % 1000));
    提示元素.innerText = `现在是：${番茄状态检查()}（还剩 ${剩余分钟()} 分钟）`;
};
// 启动
loop();
