# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A collection of **standalone biomedical image-processing scripts** for *C. elegans* embryo microscopy, supporting the CMap / TUNETr / EmbSAM / NucEnhance papers (see README.md for citations). Scripts convert between imaging formats, build 3D meshes for web visualization, assign cell identities, and prepare training/evaluation datasets for cell-segmentation deep-learning models.

This is **not an application or library with a public API**. It is a personal research toolbox. Each top-level `*.py` is an independent script driven by an `if __name__ == "__main__":` block.

## How scripts are run (read this first)

- **No CLI, no argparse, no config files.** To run a workflow you **edit the hardcoded absolute Windows paths** (e.g. `r'F:\temp\Dataset'`, `r'C:\Users\zelinli6\OneDrive...'`) inside the `__main__` block, comment/uncomment the relevant call, then run the file directly: `python image2d3d_format_transformation.py`.
- The `__main__` blocks accumulate many commented-out historical invocations. Only the last uncommented one runs. When asked to "run X," expect to update embryo names, time-point lists, and paths rather than pass arguments.
- **No `requirements.txt`, no tests, no linter, no CI.** Environment is a conda env (`.idea` references `Python 3.9 (CellShapeAnalysis)`). Core deps: `numpy`, `nibabel`, `scikit-image`, `pandas`, `Pillow`, `scipy`, `tqdm`, `tifffile`, `treelib`, `imageio`, `matplotlib`, `numba`.
- Run scripts from the **repo root** — relative paths like `./necessary_files/name_dictionary.csv` and the `utils` package import assume cwd is the repo root.

## Domain data model & file conventions

Files are named `{embryo_name}_{tp}_{suffix}.{ext}`, where `tp` (time point) is **zero-padded to 3 digits** (`str(tp).zfill(3)`), e.g. `200113plc1p2_078_segCell.nii.gz`.

- `embryo_name` examples: `200113plc1p2`, `Sample05`. Each embryo is a folder.
- Common suffixes: `rawMemb` / `rawNuc` (raw channels), `segCell` / `segMemb` / `segNuc` (segmentations), `annotatedNuc`.
- **Formats in play:** 2D `.tif` microscope slices → 3D `.nii.gz` (NIfTI medical volume) → 3D indexed `.tif` stacks → `.obj`/`.mtl` meshes. CD files (`CD{embryo}.csv`/`.txt` under `aceNuc/`) are AceTree/StarryNite nucleus-tracking lineage tables (cell, time, x, y, z).
- Volumes carry anisotropic resolution; conversions resize along z using `xy_resolution`/`z_resolution` ratios (spline interpolation for raw, nearest-neighbor `order=0` for labels).

### Cell label ↔ name dictionaries (`necessary_files/`)
- `name_dictionary.csv` / `number_dictionary.csv`: map integer voxel labels ↔ cell names. There are variant dictionaries per project (`_TUNETr`, `_cmap`) — **pick the one matching the dataset**; a mismatch silently mislabels cells.
- `daughter_mother_csv_celegans.csv`: lineage parent/child relationships.

## End-to-end visualization pipeline (the core workflow)

The README documents this; the moving parts span Python + ImageJ macros:

1. **Stack 2D → 3D NIfTI** — `tiff2d_to_niigz3d_*.py` / `compose_slice_nuc.py` (lib in `utils/preprocess_lib.py`). Multiprocessing over time points.
2. **3D NIfTI → indexed 3D TIFF** — `image2d3d_format_transformation.py::nifti2tiff_seperated` (core in `utils/utils.py::save_indexed_tif`). Writes `.tif` stacks plus a per-time `tiffmaptxt/{embryo}/{embryo}_{tp}_map.txt` and a `{embryo}_render_indexed.txt`.
3. **TIFF → .obj meshes** — ImageJ macros in `macros/` (`draw3DObject*.ijm`), run inside Fiji/ImageJ's 3D Viewer. Edit the `root_tiff_input_path` / `root_obj_output_path` and `embryonames_list` at the top of the `.ijm`. `get_index.ijm` is the recovery tool when ImageJ crashes mid-run (see README "Solve imageJ crash").
4. **Rename + combine objs** — `generate_obj_from_seperated_objs.py` → `utils/obj_visulization.py::rename_objs` then `combine_objs`. Renames mesh groups/materials to real cell names using the `map.txt`, then merges per-time `_NNN` objs into one `{embryo}_{tp}_segCell.obj`.

### The 256-color / "middle_num" label-splitting scheme (most non-obvious detail)

ImageJ's 3D Viewer supports only **256 color indices**, but embryos have far more than 255 cells. So `save_indexed_tif` splits each cell label into a group:

```
middle_num   = (label + 1) // 256 + 1   # which output file / "_NNN" suffix
middle_label = (label + 1) %  256        # the 0–255 color index within that file
```

Consequences you must preserve when touching this code:
- One `.nii.gz` becomes **multiple** `.tif` files suffixed `_000`, `_001`, … (`str(middle_idx).zfill(3)`). `_000` holds labels whose `middle_label == 0` (the mod-256 boundary case).
- `map.txt` records, per group, lines pairing `cell_name` with `cell_label:middle_num:middle_label`. `obj_visulization.py::read_map_file_as_dict` parses these in pairs (name line, then mapping line).
- `{embryo}_render_indexed.txt` lists, per generated tiff, the **max color index** the ImageJ macro must export (`ImageJ3DViewer ... colour index: <map_index>`). The macro reads this line-by-line aligned to the sorted tiff list.
- `max_middle_num` (e.g. `26`) in the obj scripts bounds how many `_NNN` groups exist; it must exceed `max_cell_label // 256`.
- `nifti2tiff_seperated` asserts `len(tiff files) == len(render_indexed lines)` — keep that invariant if you change file emission.

## `utils/` package

- `utils.py` — `save_indexed_tif` (the label-splitting/TIFF writer above), the 768-entry color palette `P`, `check_folder`, `isotropic_resolution`, `scale2index`, `get_boundary`.
- `data_io.py` — `nib_load`/`nib_save` (NIfTI with identity affine), `pkl_save`, `img_save`, `normalize3d`, CD-file reader.
- `data_structure.py` — CD-file readers (`read_cd_file` for CSV, `read_txt_cd_file` for whitespace TXT; **column orders differ** between lab CD formats), `construct_celltree` (treelib lineage).
- `generate_name_dictionary.py` — builds label↔name dicts from CD files + `necessary_files` dictionaries.
- `obj_visulization.py` — `rename_objs`, `combine_objs` (.obj/.mtl rewriting with vertex-offset accounting).
- `lineage_tree.py`, `draw_lib.py`, `slices.py`, `preprocess_lib.py` — lineage trees, plotting, slice helpers.
- `readlif.py` — vendored Leica `.lif` reader (used by `resave_lif.py`).

## Conventions to follow when editing

- New conversion scripts follow the existing pattern: a reusable function (often added to a `utils/` lib) plus a thin `__main__` block holding example invocations as comments. Don't introduce a CLI unless asked.
- When generating per-time-point filenames, always `str(tp).zfill(3)`; when generating `_NNN` mesh/group suffixes, `str(idx).zfill(3)`. Inconsistent padding is a recurring source of bugs in this repo (see recent commit history).
- Label arrays are nearest-neighbor resized (`order=0`, `anti_aliasing=False`); raw intensity images use `order=1`. Never blur labels.
- `scratch`/experimental files (`tem.py`, `tem2.py`, `New Text Document.txt`) are throwaway — don't treat them as part of the pipeline.
