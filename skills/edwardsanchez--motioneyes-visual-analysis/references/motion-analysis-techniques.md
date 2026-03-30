# Motion Analysis Techniques (Condensed)

## Vision Guidance

- Limit frame count when asking a vision model to describe motion; use key frames (start/mid/end).
- Label frames explicitly and describe order (left-to-right or top-to-bottom).
- Prefer sprite sheets or grids for temporal relationships.
- Avoid alpha-blended stacks of frames; they obscure details.
- Treat `diff` as evidence of change, not full semantic context.
- Use a two-pass read: first `grid`/`sprite` (and `diff_grid` when needed), then `frames` + `diff` if overlays obscure subtle details.

## Deterministic Computer Vision

### Frame Differencing

- Convert frames to grayscale.
- Compute absolute diff between consecutive frames.
- Threshold diff to create a binary mask.
- Apply morphology (dilate/close) to reduce noise.
- Extract contours and bounding boxes.

### Affine Estimation

- Extract feature points between the first and last frame.
- Estimate affine transform to infer translation, rotation, and scale.

## Best Practice

- Use CV to generate diffs and metrics first.
- Use vision-style summary only after you have highlighted changes.
- Keep key frames for summary even when analyzing all frames.
- Start with keyframe pairs, then escalate to neighboring pairs and `--all-pairs` only when confidence is low.
- For each major claim, cite frame pair(s), artifact type(s), and confidence.
