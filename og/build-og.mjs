// Renders chalk.wgsl headless (Dawn, no browser) into the real share image.
// node build-og.mjs  ->  ../og-board.png (shader only), then ffmpeg lays the chalk title on top.
import { writeFileSync } from "node:fs";
import { PNG } from "pngjs";
import { fileURLToPath } from "node:url";
import { resolveShader } from "@vgpu/wgsl/runtime";
import { prepareShader } from "@vgpu/wgsl/prepare";
import { init, effect, target } from "vgpu/node";

const W = 1200, H = 630;
const gpu = await init();
try {
  const { wgsl } = await resolveShader({ entry: fileURLToPath(new URL("./chalk.wgsl", import.meta.url)) }); // inlines @vgpu/wgsl-std imports
  const out = target(gpu, { size: [W, H], format: "rgba8unorm" });
  const fx = effect(gpu, prepareShader(wgsl), { label: "chalk-helix" });
  fx.set({ params: { time: 2.4, aspect: W / H, residues: 31, pad: 0 } });
  fx.draw({ target: out });
  const png = new PNG({ width: W, height: H });
  png.data.set(await out.color.read({ mipLevel: 0, region: "all" }));
  writeFileSync(new URL("../og-board.png", import.meta.url), PNG.sync.write(png));
  console.log("wrote og-board.png", W, "x", H);
} finally {
  gpu.dispose(); // stops Dawn polling, or the process never exits
}
