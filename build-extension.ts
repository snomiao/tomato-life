import zip from "cross-zip";
import { mkdir } from "fs/promises";
import { promisify } from "util";
await mkdir("dist", { recursive: true });
await promisify(zip.zip)("./src", "./dist/TomatoLife.zip");
