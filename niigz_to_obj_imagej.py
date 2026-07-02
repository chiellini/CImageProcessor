"""
One-click driver for the ORIGINAL three-stage ImageJ mesh pipeline (Option B).

It just chains the three steps that used to be run by hand, so the meshes are
byte-for-byte the ImageJ ones (unlike niigz_to_obj.py, which rebuilds them in
pure Python and looks slightly different):

    step 1  niigz --> separated indexed .tif        (Python: nifti2tiff_seperated)
    step 2  .tif   --> separated .obj               (ImageJ 3D Viewer, driven here)
    step 3  rename + combine --> one named .obj      (Python: rename_objs/combine_objs)

IMPORTANT - ImageJ version: this must be driven with the OLD Fiji (ImageJ 1.52p,
e.g. C:\\Users\\User\\Downloads\\fiji-win64\\Fiji.app\\ImageJ-win64.exe). Newer Fiji
opens the multi-page palette TIFF as 8-bit GRAYSCALE, and "Show Color Surfaces"
then refuses it ("only works with 8-bit indexed color images"); 1.52p keeps the
color LUT so the surfaces work. The 3D Viewer also needs a real display, so this
runs Fiji headed (a window flashes) and CANNOT run on a headless server.

Download the known-good old Fiji (archived 2019-10-27, ImageJ 1.52p) here:
    https://downloads.imagej.net/fiji/archive/20191027-2045/
Unzip it and point `fiji_exe` at its ImageJ-win64.exe.

The first Fiji launch is slow (~3-4 min of init); give it a generous timeout.
"""

import os
import re
import glob
import shutil
import subprocess

from image2d3d_format_transformation import nifti2tiff_seperated
from utils.obj_visulization import rename_objs, combine_objs

HERE = os.path.dirname(os.path.abspath(__file__))
MACRO_TEMPLATE = os.path.join(HERE, 'macros', 'draw3DObject.ijm')


def _alias(name):
    """Alphanumeric-only alias for an embryo name. The repo's filename parsing
    (save_indexed_tif, the .ijm macro) assumes the embryo is a single clean token:
    names with '_' or '.' (e.g. 'MT_wee-1.1_1') break tif naming / map.txt / obj
    naming. We run the pipeline under the alias and rename outputs back afterwards."""
    return re.sub(r'[^A-Za-z0-9]', '', name)


def _parse_tp_suffix(niigz_path):
    """(tp, suffix) from {embryo}_{tp}_{suffix}.nii.gz, robust to '_'/'.' in embryo."""
    stem = os.path.basename(niigz_path)
    for ext in ('.nii.gz', '.nii'):
        if stem.endswith(ext):
            stem = stem[:-len(ext)]
            break
    parts = stem.split('_')
    return parts[-2], parts[-1]


def _max_tp(seg_root):
    """Largest time point present, from {embryo}_{tp}_segCell.nii.gz names."""
    tps = []
    for f in glob.glob(os.path.join(seg_root, '*.nii.gz')):
        try:
            tps.append(int(os.path.basename(f).split('_')[1]))
        except (IndexError, ValueError):
            pass
    return max(tps) if tps else 0


def _build_macro(tif_root, obj_root, embryo_names, out_path):
    """Reuse the repo's draw3DObject.ijm, just swapping the hardcoded header and
    appending run("Quit") so Fiji exits when done (so subprocess returns)."""
    with open(MACRO_TEMPLATE) as f:
        macro = f.read()
    fwd = lambda p: p.replace('\\', '/')
    names = ','.join('"{}"'.format(e) for e in embryo_names)
    # anchor at line start (?m) so commented-out // lines are not matched
    macro = re.sub(r'(?m)^root_tiff_input_path\s*=\s*".*?"',
                   'root_tiff_input_path="{}"'.format(fwd(tif_root)), macro, count=1)
    macro = re.sub(r'(?m)^root_obj_output_path\s*=\s*".*?"',
                   'root_obj_output_path="{}"'.format(fwd(obj_root)), macro, count=1)
    macro = re.sub(r'(?m)^embryonames_list\s*=\s*newArray\(.*?\);',
                   'embryonames_list = newArray({});'.format(names), macro, count=1)
    macro = macro.rstrip() + '\n\nrun("Quit");\n'
    with open(out_path, 'w') as f:
        f.write(macro)
    return out_path


def run_imagej_pipeline(embryo_names, niigz_root, work_root, name_dictionary_path,
                        fiji_exe, seg_subfolder='SegCell', max_middle_num=26,
                        tps=None, file_suffix='_segCell', timeout=7200,
                        do_step1=True, do_step2=True, do_step3=True):
    """Run the full niigz -> named .obj pipeline through ImageJ.

    :param work_root: scratch dir; gets tif/ (step1+maps), obj/ (step2), combined/ (step3).
    :param fiji_exe: path to the OLD Fiji's ImageJ-win64.exe (must be 1.52p, see module doc).
    :param tps: optional list of max time point per embryo for rename/combine; auto-detected
        from the niigz files when None.
    :param timeout: seconds to allow the ImageJ macro run (first launch is slow; batches long).
    """
    tif_root = os.path.join(work_root, 'tif')        # macro's root_tiff_input_path
    obj_root = os.path.join(work_root, 'obj')        # macro's root_obj_output_path
    combined_root = os.path.join(work_root, 'combined')
    map_txt_root = os.path.join(tif_root, 'tiffmaptxt')

    if tps is None:
        tps = [_max_tp(os.path.join(niigz_root, e, seg_subfolder)) for e in embryo_names]

    # ---- step 1: niigz -> separated indexed tif (+ map.txt + render_indexed.txt) ----
    if do_step1:
        for embryo in embryo_names:
            seg_root = os.path.join(niigz_root, embryo, seg_subfolder)
            target = os.path.join(tif_root, embryo)
            os.makedirs(target, exist_ok=True)
            print('[step1] {} -> tif'.format(embryo))
            nifti2tiff_seperated(seg_root, target, segmented=True,
                                 name_dictionary_path=name_dictionary_path)

    # ---- step 2: tif -> separated obj, via the old Fiji's 3D Viewer ----
    if do_step2:
        # ImageJ's File.makeDirectory is not recursive, so pre-create obj/{embryo}
        # here -- otherwise the macro silently fails to write any .obj.
        for embryo in embryo_names:
            os.makedirs(os.path.join(obj_root, embryo), exist_ok=True)
        macro_path = os.path.join(work_root, '_run_draw3d.ijm')
        _build_macro(tif_root, obj_root, embryo_names, macro_path)
        print('[step2] running ImageJ macro (a Fiji window will appear)...')
        print('        macro: {}'.format(macro_path))
        proc = subprocess.run([fiji_exe, '--console', '-macro', macro_path],
                              timeout=timeout)
        print('[step2] ImageJ exited with code {}'.format(proc.returncode))

    # ---- step 3: rename groups to cell names + combine per-time objs ----
    if do_step3:
        print('[step3] rename + combine')
        rename_objs(embryo_names, tps, max_middle_num, obj_root, map_txt_root,
                    file_suffix=file_suffix)
        combine_objs(embryo_names, tps, max_middle_num, obj_root, combined_root,
                     file_suffix=file_suffix)
        print('[step3] combined objs -> {}'.format(combined_root))


def run_imagej_pipeline_named(embryo_names, niigz_root, work_root, name_dictionary_path,
                              fiji_exe, seg_subfolder='SegCell', file_suffix='_segCell',
                              only_tps=None, cleanup_intermediates=True, **kwargs):
    """Like run_imagej_pipeline but tolerant of embryo names containing '_' or '.'
    (e.g. 'MT_wee-1.1_1'). It links the niigz under alphanumeric aliases, runs the
    pipeline, then renames the combined objs back to the real embryo names.

    :param only_tps: optional list of int time points to process (e.g. [50]); the rest
        are skipped. Handy for a quick single-timepoint run instead of the whole embryo.
    :param cleanup_intermediates: once the combined objs are fully built, delete the
        tif/, obj/ and niigz_alias/ work dirs (and the alias combined/ dirs), keeping
        only combined/{embryo}. This only runs on FULL completion, so an interrupted run
        keeps its intermediates for resume; and a call whose combined objs already exist
        is skipped up front, so cleanup never forces a redo.
    """
    aliases = {e: _alias(e) for e in embryo_names}
    combined_root = os.path.join(work_root, 'combined')

    def _expected_tps(embryo):
        out = set()
        for f in glob.glob(os.path.join(niigz_root, embryo, seg_subfolder, '*.nii.gz')):
            tp, _ = _parse_tp_suffix(f)
            if only_tps is None or int(tp) in only_tps:
                out.add(tp)
        return out

    def _done(embryo):
        exp = _expected_tps(embryo)
        have = glob.glob(os.path.join(combined_root, embryo, embryo + '_*.obj'))
        return len(exp) > 0 and len(have) >= len(exp)

    if all(_done(e) for e in embryo_names):
        print('[skip] combined objs already complete for {}'.format(embryo_names))
        return

    alias_niigz_root = os.path.join(work_root, 'niigz_alias')

    # link (or copy) each niigz to alias_niigz_root/{alias}/SegCell/{alias}_{tp}_{suffix}.nii.gz
    for embryo in embryo_names:
        a = aliases[embryo]
        src_seg = os.path.join(niigz_root, embryo, seg_subfolder)
        dst_seg = os.path.join(alias_niigz_root, a, seg_subfolder)
        os.makedirs(dst_seg, exist_ok=True)
        for src in glob.glob(os.path.join(src_seg, '*.nii.gz')):
            tp, suffix = _parse_tp_suffix(src)
            if only_tps is not None and int(tp) not in only_tps:
                continue
            dst = os.path.join(dst_seg, '{}_{}_{}.nii.gz'.format(a, tp, suffix))
            if os.path.exists(dst):
                continue
            try:
                os.link(src, dst)          # instant, same volume
            except OSError:
                shutil.copyfile(src, dst)  # cross-volume fallback

    run_imagej_pipeline(list(aliases.values()), alias_niigz_root, work_root,
                        name_dictionary_path, fiji_exe, seg_subfolder=seg_subfolder,
                        file_suffix=file_suffix, **kwargs)

    # rename combined outputs from alias back to the real embryo name
    for embryo, a in aliases.items():
        src_dir = os.path.join(combined_root, a)
        dst_dir = os.path.join(combined_root, embryo)
        if not os.path.isdir(src_dir):
            continue
        os.makedirs(dst_dir, exist_ok=True)
        for src in glob.glob(os.path.join(src_dir, a + '_*')):
            base = os.path.basename(src).replace(a, embryo, 1)  # only the leading alias
            dst = os.path.join(dst_dir, base)
            if src.endswith('.obj'):
                txt = open(src).read().replace('mtllib {}_'.format(a),
                                               'mtllib {}_'.format(embryo), 1)
                open(dst, 'w').write(txt)
            else:
                shutil.copyfile(src, dst)
        print('[rename] {} -> {}'.format(a, embryo))

    # drop the bulky intermediates only once EVERY expected time point has a combined
    # obj (ImageJ can crash mid-run and still exit non-zero, so trust the output, not
    # the return code); otherwise keep them so an interrupted run can resume.
    if cleanup_intermediates:
        if all(_done(e) for e in embryo_names):
            for d in ('tif', 'obj', 'niigz_alias'):
                shutil.rmtree(os.path.join(work_root, d), ignore_errors=True)
            for embryo, a in aliases.items():
                if a != embryo:
                    shutil.rmtree(os.path.join(combined_root, a), ignore_errors=True)
            print('[cleanup] removed tif/ obj/ niigz_alias/, kept combined/')
        else:
            print('[cleanup] SKIPPED - combined output incomplete; keeping intermediates for resume')


if __name__ == "__main__":
    FIJI = r"C:\Users\User\Desktop\Fiji.app\ImageJ-win64.exe"  # MUST be 1.52p (see module doc)

    # ---- MT_wee-1.1 (two embryos, shared dictionary) ----
    run_imagej_pipeline_named(
        embryo_names=['MT_wee-1.1_1', 'MT_wee-1.1_2'],
        niigz_root=r'C:\Users\User\Downloads\MT_wee-1.1_GUI_Data',
        work_root=r'C:\Users\User\Downloads\MT_wee-1.1_GUI_Data\new_pipeline_out',
        name_dictionary_path=r'C:\Users\User\Downloads\MT_wee-1.1_GUI_Data\name_dictionary.csv',
        fiji_exe=FIJI, timeout=86400,
    )

    # ---- Ablation (each embryo has its own root + dictionary) ----
    for n in (1, 2):
        base = r'C:\Users\User\Downloads\Ablation_GUI_Data\Abla_GUI_Data_{}'.format(n)
        run_imagej_pipeline_named(
            embryo_names=['Abla_MSpp_{}'.format(n)],
            niigz_root=base,
            work_root=os.path.join(base, 'new_pipeline_out'),
            name_dictionary_path=os.path.join(base, 'name_dictionary.csv'),
            fiji_exe=FIJI, timeout=86400,
        )
