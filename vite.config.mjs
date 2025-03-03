import { walk } from "files";
import path, { resolve } from "path";
import { defineConfig } from "vite";

const root = resolve("src");
const htmlInputs = await walk(root)
    .filter(/\.html$/)
    .map((e) => [path.parse(e.replace(/[\/\\]index\.html$/, "")).name, e]);

const config = defineConfig({
    root,
    build: {
        outDir: resolve("extension"),
        rollupOptions: {
            input: {
                ...Object.fromEntries(htmlInputs),
            },
        },
    },
    publicDir: "./",
    assetsInclude: ["manifest.json"],
});
export default config;
