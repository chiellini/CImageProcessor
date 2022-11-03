import os
import glob
import shutil
from tqdm import tqdm
import numpy as np
from PIL import Image
import nibabel as nib
from skimage.transform import resize
from skimage.exposure import rescale_intensity
from utils.utils import nib_load, nib_save, P, get_boundary

# src_folder = r"C:\Users\bcc\Desktop\tem\crop\train"
# dst_folder = r"C:\Users\bcc\Desktop\tem\crom17\train"
# target_str = "pm17"
#
# target_files = glob.glob(os.path.join(src_folder, "**"), recursive=True)
#
# target_files = [file for file in target_files if target_str in file]
#
# for file in tqdm(target_files, desc="Trans {}".format(src_folder)):
#     target_file = os.path.join(dst_folder, os.path.basename(os.path.dirname(file)), os.path.basename(file).replace("crop", "crom17"))
#     if not os.path.isdir(os.path.dirname(target_file)):
#         os.makedirs(os.path.dirname(target_file))
#     shutil.copyfile(src=file, dst=target_file)

# ########### Draw 3D images for thesis
# membrane_file = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Submission\CShaper Supplementary Data\Segmentation Results\RawData\Sample07\RawMemb\Sample07_020_rawMemb.nii.gz"
# nucleus_file = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Submission\CShaper Supplementary Data\Segmentation Results\RawData\Sample07\RawNuc\Sample07_020_rawNuc.nii.gz"
# save_file = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\study\Thesis\Tem\TemFigures\200309plc1p1_020_combined.tif"
# memb = nib_load(membrane_file)
# nucleus = nib_load(nucleus_file)
#
# combined_mask = np.zeros_like(memb, dtype=np.uint8)
# v_min, v_max = np.percentile(memb, (0.2, 99.9))
# memb = rescale_intensity(memb, in_range=(v_min, v_max)) * 255
# v_min, v_max = np.percentile(nucleus, (0.2, 99.9))
# nucleus = rescale_intensity(nucleus, in_range=(v_min, v_max)) * 255
#
# combined_mask[nucleus > 5] = 1
# combined_mask[memb > 35] = 2
#
# tif_imgs = []
# num_slices = combined_mask.shape[-1]
# for i_slice in range(num_slices):
#     tif_img = Image.fromarray(combined_mask[..., i_slice], mode="P")
#     tif_img.putpalette(P)
#     tif_imgs.append(tif_img)
#
# tif_imgs[0].save(save_file, save_all=True, append_images=tif_imgs[1:])

# ################# Draw videos
'''
src_folder = r"D:\tem\SegCellTimeCombinedLabelUnified"
dst_folder = r"D:\tem\3DLapseEmbryo\tif"

seg_files = sorted(glob.glob(os.path.join(src_folder, "*.nii.gz")))
label_file = os.path.join(os.path.dirname(dst_folder), "label.txt")

for idx, seg_file in enumerate(tqdm(seg_files, desc="Svaing to {}".format(dst_folder))):
    base_name = os.path.basename(seg_file).split(".")[0]

    seg0 = nib_load(seg_file)
    seg = seg0 % 255
    reduce_mask = np.logical_and(seg0!=0, seg==0)
    seg[reduce_mask] = 255
    seg = seg.astype(np.uint8)
    origin_shape = seg.shape
    out_size = [int(x / 1.5) for x in origin_shape]

    seg = resize(image=seg, output_shape=out_size, preserve_range=True, order=0).astype(np.uint8)


    seg = seg[..., :(out_size[-1] // 2)]
    tif_imgs = []
    num_slices = seg.shape[-1]
    for i_slice in range(num_slices):
        tif_img = Image.fromarray(seg[..., i_slice], mode="P")
        tif_img.putpalette(P)
        tif_imgs.append(tif_img)
    save_file = os.path.join(dst_folder, "_".join([base_name, "render.tif"]))
    if os.path.isfile(save_file):
        os.remove(save_file)

    label_num = np.unique(seg).tolist()[-1]
    if idx == 0:
        with open(label_file, "w") as f:
            f.write("{}\n".format(label_num))
    else:
        with open(label_file, "a") as f:
            f.write("{}\n".format(label_num))

    tif_imgs[0].save(save_file, save_all=True, append_images=tif_imgs[1:])
'''

# =================================================
# ============= write words
# =================================================
# src_folder = r"D:\tem\SegCellTimeCombinedLabelUnified"
# dst_folder = r"D:\tem\3DLapseEmbryo\tif"

# seg_files = sorted(glob.glob(os.path.join(src_folder, "*.nii.gz")))
# label_file = os.path.join(os.path.dirname(dst_folder), "label.txt")

# =================================================
#         get number of cells
# =================================================
# seg_files = glob.glob(os.path.join(r"D:\ProjectData\AllDataPacked\191108plc1p1\SegNuc", "*.nii.gz"))
# seg_files.sort()
# for tp, seg_file in enumerate(seg_files, start=1):
#     seg = np.unique(nib_load(seg_file)).tolist()
#     num_labels = len(seg) - 1
#     print(f"TP:  {tp}, cells: {num_labels}")

# =================================================
#  Set 3DMMS evaluation dataset for training CShaper
# =================================================
# tps = [24, 34, 44, 54, 64, 74]
# seg_folder = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\3_paper for DTwatershed\3DMMS\Evaluation\GroundTruth"
# dst_folder = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\study\Thesis\DefenseFigures\3DMMSDataset\170704plc1p1"
# embryo_name = "170704plc1p1"
#
# seg_files = glob.glob(os.path.join(seg_fo"*.nii"))
# # seg_files.sort()lder,
#
# for idx, seg_file in enumerate(seg_files):
#     seg = nib_load(seg_file)
#     memb = get_boundary(seg).astype(np.uint8)
#     save_name_cell = os.path.join(dst_folder, "{}_{}_segCell.nii.gz".format(embryo_name, str(tps[idx]).zfill(3)))
#     save_name_memb = os.path.join(dst_folder, "{}_{}_segMemb.nii.gz".format(embryo_name, str(tps[idx]).zfill(3)))
#     nib_save(save_name_cell, seg)
#     nib_save(save_name_memb, memb)

# ===============================
# Resave data
# ===============================
import pandas as pd
from utils.data_structure import read_new_cd
cd_file = r"C:\Users\bcc\Desktop\CD200113plc1p2.csv"
nuc_pd = read_new_cd(cd_file)
nuc_pd[["none",	"global", "local", "blot", "cross", "size", "gweight"]] = ""
nuc_pd = nuc_pd.rename(columns={"Cell & Time":"cellTime"})
nuc_pd = nuc_pd[['cellTime', 'cell', 'time', 'none', 'global', 'local',
       'blot', 'cross', 'z', 'x', 'y', 'size', 'gweight']]
nuc_pd.to_csv(cd_file, index=False)
print("test")