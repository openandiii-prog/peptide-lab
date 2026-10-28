// Chalkboard + shader-drawn alpha helix for the Peptide Lab share image.
import { fbmSimplex2d } from "@vgpu/wgsl-std/noise/simplex";
import { hash2 } from "@vgpu/wgsl-std/hash";
import { srgbToLinear3, linearToSrgb3 } from "@vgpu/wgsl-std/color";

struct Params { time: f32, aspect: f32, residues: f32, pad: f32 }
@group(0) @binding(0) var<uniform> params: Params;

// residue class palette, sRGB (yellow, blue, pink, orange, chalk, purple)
fn classColor(i: i32) -> vec3f {
  switch (i % 6) {
    case 0: { return vec3f(0.953, 0.827, 0.420); }
    case 1: { return vec3f(0.561, 0.784, 0.941); }
    case 2: { return vec3f(0.949, 0.608, 0.702); }
    case 3: { return vec3f(0.949, 0.651, 0.353); }
    case 4: { return vec3f(0.945, 0.937, 0.902); }
    default: { return vec3f(0.780, 0.627, 1.0); }
  }
}

// shaded ball: returns (coverage, lit shade)
fn ball(p: vec2f, c: vec2f, r: f32) -> vec2f {
  let d = distance(p, c);
  let cov = smoothstep(r, r * 0.86, d);
  let q = (p - c) / r;
  let z = sqrt(max(0.0, 1.0 - dot(q, q)));
  let n = vec3f(q.x, q.y, z);
  let lit = 0.35 + 0.65 * max(dot(n, normalize(vec3f(-0.5, -0.6, 0.7))), 0.0);
  return vec2f(cov, lit);
}

fn segment(p: vec2f, a: vec2f, b: vec2f, w: f32) -> f32 {
  let pa = p - a; let ba = b - a;
  let h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return smoothstep(w, w * 0.5, length(pa - ba * h));
}

@fragment fn main(@location(0) uv: vec2f) -> @location(0) vec4f {
  let p = vec2f(uv.x * params.aspect, uv.y);

  // board: green slate with smeared chalk dust
  var col = srgbToLinear3(vec3f(0.114, 0.227, 0.192));
  let smear = fbmSimplex2d(p * vec2f(2.2, 5.5) + vec2f(params.time, 0.0), 5, 2.0, 0.5);
  col += vec3f(0.035, 0.04, 0.038) * smoothstep(-0.1, 0.8, smear);
  let erased = fbmSimplex2d(p * vec2f(0.9, 2.6) + 7.3, 4, 2.0, 0.5);
  col += vec3f(0.02) * smoothstep(0.2, 0.9, erased);
  let speck = hash2(floor(uv * vec2f(1200.0, 630.0)));
  col += vec3f(0.06) * step(0.9965, speck.x);
  // vignette
  col *= 1.0 - 0.45 * pow(distance(uv, vec2f(0.5, 0.5)) * 1.25, 2.2);

  // alpha helix running diagonally across the right half
  let n = i32(params.residues);
  let a0 = vec2f(params.aspect * 0.60, 0.98);
  let a1 = vec2f(params.aspect * 0.97, 0.02);
  let axis = normalize(a1 - a0);
  let perp = vec2f(-axis.y, axis.x);
  var prevCa = a0;
  for (var i = 0; i < n; i++) {
    let t = f32(i) / f32(n - 1);
    let ang = f32(i) * 1.745; // 100 degrees per residue
    let depth = sin(ang);
    let ca = mix(a0, a1, t) + perp * cos(ang) * 0.075;
    let sc = ca + perp * cos(ang) * 0.07 + axis * 0.012 * depth;
    let scale = 1.0 + depth * 0.18;
    if (i > 0) {
      col = mix(col, srgbToLinear3(vec3f(0.91, 0.89, 0.84)) * 0.8, segment(p, prevCa, ca, 0.0042 * scale));
    }
    col = mix(col, srgbToLinear3(vec3f(0.74, 0.72, 0.65)) * 0.7, segment(p, ca, sc, 0.0022 * scale));
    let bb = ball(p, ca, 0.011 * scale);
    col = mix(col, srgbToLinear3(vec3f(0.91, 0.90, 0.84)) * bb.y, bb.x);
    let s = ball(p, sc, 0.018 * scale);
    col = mix(col, srgbToLinear3(classColor(i * 7 % 11)) * s.y, s.x);
    prevCa = ca;
  }
  return vec4f(linearToSrgb3(col), 1.0);
}
