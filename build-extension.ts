import { zipSync } from "fflate";
import { mkdir, readFile, writeFile } from "fs/promises";

export const ZIP_PATH = "dist/TomatoLife.zip";

// Zip src/ with forward-slash entry names on every OS (Chrome can't resolve backslash paths)
export async function buildExtension() {
    const files: Record<string, Uint8Array> = {};
    for await (const f of new Bun.Glob("**/*").scan({ cwd: "src", onlyFiles: true })) {
        files[f.replaceAll("\\", "/")] = await readFile(`src/${f}`);
    }
    await mkdir("dist", { recursive: true });
    await writeFile(ZIP_PATH, zipSync(files, { level: 9 }));
    return ZIP_PATH;
}

if (import.meta.main) console.log(await buildExtension());
