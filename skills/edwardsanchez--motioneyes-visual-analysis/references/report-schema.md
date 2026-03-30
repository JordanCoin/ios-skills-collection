# Report Schema

`analysis.json` is the canonical output. All fields are optional if the underlying algorithm fails, but the keys should remain stable.

## Top-Level Shape

```json
{
  "metadata": {
    "source": "video|frames|macos",
    "fps": 15,
    "duration": 1.0,
    "raw_frame_count": 12,
    "frame_count": 8,
    "resolution": {"width": 1170, "height": 2532},
    "resized": false,
    "trim": {
      "enabled": true,
      "trimmed": true,
      "start": 2,
      "end": 9,
      "threshold": 3.0,
      "relative": 0.35
    }
  },
  "frames": [
    {"index": 0, "timestamp": 0.0, "path": "frames/frame_000.png"}
  ],
  "pairwise_diffs": [
    {
      "pair": [0, 1],
      "mean_abs_diff": 12.4,
      "diff_bboxes": [{"x": 120, "y": 340, "w": 86, "h": 40}]
    }
  ],
  "pairwise_rendered": [0, 3, 6],
  "motion": {
    "affine_dx": 5.1,
    "affine_dy": -0.8,
    "rotation_deg": 1.6,
    "scale_ratio": 1.02,
    "opacity_delta": -0.08,
    "color_delta": {"h": 2.1, "s": -0.03, "v": 0.01}
  },
  "key_frames": {
    "start": 0,
    "mid": 4,
    "end": 7,
    "top_delta": [3, 5]
  }
}
```

## Human Summary

`summary.md` is a short narrative derived from the metrics, for example:

```text
The primary motion is rightward (~5 px) with slight upward drift. Diff deltas peak at frames 3 and 5, indicating the most visible change during the mid animation. Opacity decreases slightly and there is minimal color shift.
```

## Evidence Expectations for `summary.md`

To improve reliability, major claims should include:

- frame pair reference (for example `pair 3->4`)
- artifact reference (`frames`, `diff`, `grid`, `diff_grid`, or `sprite`)
- confidence score (`0.0-1.0`)

Example style:

```text
Claim: The card moves rightward between frames 3->4.
Evidence: frames/frame_003.png + frames/frame_004.png + diff/diff_3_4.png.
Confidence: 0.86.
```

If confidence is low (<0.7), expand inspection to neighboring pairs or rerun with `--all-pairs` before finalizing conclusions.
