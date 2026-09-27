// Copyright (c) 2020 snomiao@gmail.com. All rights reserved.
// LICENSED BY GNU GENERAL PUBLIC LICENSE v3

export const 番茄状态检查 = () =>
    (new Date().getMinutes() % 30 < 25 && "工作时间") || "休息时间";

// 当前状态还剩几分钟（向上取整）
export const 剩余分钟 = () => {
    const 分 = new Date().getMinutes() % 30;
    return 分 < 25 ? 25 - 分 : 30 - 分;
};
