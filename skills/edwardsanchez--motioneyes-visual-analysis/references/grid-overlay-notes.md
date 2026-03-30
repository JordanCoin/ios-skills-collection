# Grid Overlay Notes

This skill uses GridGPT as a git submodule at `third_party/GridGPT` and follows the same approach:

If the directory is missing after clone, run:

```bash
git submodule update --init --recursive
```

- Draw a light grid on top of the image.
- Label each cell with an alphanumeric identifier.
- Keep label opacity low to avoid obscuring UI.

The original GridGPT `main.py` (in `third_party/GridGPT/main.py`) uses a cell-size approach and `arial.ttf` for labeling. For 1080p, a 50px cell size works well; for 4K, 100px is typical. Adjust `--grid-cell` based on readability.

Use the grid overlay to reference coordinates in summaries (for example, “the element moved from cell 012 to 014”).
