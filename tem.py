import os
import glob
import shutil
from tqdm import tqdm
import numpy as np
from PIL import Image
import nibabel as nib
from skimage.transform import resize
from skimage.exposure import rescale_intensity
from utils.utils import nib_save, get_boundary
from seperate_process import set_up_new_training_and_evaluation_data

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


set_up_new_training_and_evaluation_data()

