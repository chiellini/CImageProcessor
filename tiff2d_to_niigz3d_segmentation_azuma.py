import os
import glob
import pickle
import warnings
import shutil

from utils.data_io import nib_save
from utils.generate_name_dictionary import add_number_dict

warnings.filterwarnings("ignore")
import numpy as np
from PIL import Image
# import nibabel as nib
import pandas as pd
from skimage.exposure import rescale_intensity
from skimage.morphology import ball

import pandas
from tqdm import tqdm
import multiprocessing as mp
from skimage.transform import resize
from scipy import ndimage

from utils.utils import check_folder
from utils.data_structure import read_cd_file, read_txt_cd_file


def combine_slices(config):
    """
    Combine slices into stack images
    :param config: parameters
    :return:
    """
    # signal.emit(True,'sss')
    # num_slice = config["num_slice"]
    embryo_names = config["embryo_names"]
    # max_times = config["max_times"]
    # xy_pixel_num=config['xy_pixel_num']
    xy_res = config["xy_resolution"]
    z_res = config["z_resolution"]
    # out_size = config["out_size"]
    raw_folder = config["raw_folder"]
    stack_folder = config["target_folder"]



    # multiprocessing
    mpPool = mp.Pool(mp.cpu_count() - 1)

    for idx_embryo, embryo_name in enumerate(embryo_names):
        embryo_name=str(embryo_name)

        # get output size
        seg_cell_image_files = glob.glob(os.path.join(raw_folder, embryo_name, "*.tif"))
        _, str_max_time, str_num_slice = os.path.basename(seg_cell_image_files[-1]).split('.')[0].split('_')
        max_time = int(str_max_time[1:])
        num_slice = int(str_num_slice[1:])
        raw_size = list(np.asarray(Image.open(seg_cell_image_files[0])).shape) + [int(num_slice * z_res / xy_res)]
        # out_size=z_number_this_img*z_res/xy_res
        out_size = raw_size
        out_res = [res * in_scale / out_scale for res, in_scale, out_scale in
                   zip([xy_res, xy_res, xy_res], raw_size, out_size)]

        origin_folder = os.path.join(raw_folder, embryo_name)
        target_folder = os.path.join(stack_folder, embryo_name, "SegCell")
        if not os.path.isdir(target_folder):
            os.makedirs(target_folder)

        configs = []
        for tp in range(0, max_time + 1):
            configs.append((origin_folder, target_folder, embryo_name, tp, out_size, num_slice, out_res))
            # stack_memb_slices(configs[0])
        for idx, _ in enumerate(tqdm(mpPool.imap_unordered(stack_memb_slices, configs), total=len(configs),
                                     desc="2/3 Stack segcell of {}".format(embryo_name))):
            # TODO: Process Name: `2/3 Stack membrane`; Current status: `idx`; Final status: max_time
            pass



# ============================================
# save raw membrane stack
# ============================================
def stack_memb_slices(para):
    [raw_folder, save_folder, embryo_name, tp, out_size, num_slice, res] = para

    out_stack = []
    save_file_name = "{}_{}_segCell.nii.gz".format(embryo_name, str(tp).zfill(3))
    for i_slice in range(0, num_slice + 1):
        # r"D:\TemDownload\201112plc1_late_Lng\tifR\c elegans 3.lif_Series001_Lng_001_t00_z08_ch01.tif"
        # raw_file_name = "{}deconp1_L1-t{}-p{}.tif".format(embryo_name[:-2], str(tp).zfill(3), str(i_slice).zfill(2))
        raw_file_name = "img_t{}_z{}.tif".format(str(tp).zfill(3), str(i_slice).zfill(3))

        # transform the image to array and short them in a list
        img = np.asanyarray(Image.open(os.path.join(raw_folder, raw_file_name)))
        if img.shape != (256, 256):
            print('ERRORRRRR', img.shape, raw_file_name)
        out_stack.insert(0, img)
    img_stack = np.transpose(np.stack(out_stack), axes=(1, 2, 0))  # trasnpose the image from zxy to xyz
    # print(save_file_name,len(np.unique(img_stack)))

    # v_min, v_max = np.percentile(img_stack, (0.2, 99.9))  # erase the outrange grayscale
    # img_stack = rescale_intensity(img_stack, in_range=(v_min, v_max), out_range=(0, 255.0))
    # cut xy, interpolate z
    img_stack = resize(image=img_stack, output_shape=out_size, preserve_range=True, order=0).astype(np.int16)
    # nib_stack = nib.Nifti1Image(img_stack, np.eye(4))
    # nib_stack.header.set_xyzt_units(xyz=3, t=8)
    # nib_stack.header["pixdim"] = [1.0, res[0], res[1], res[2], 0., 0., 0., 0.]
    save_file = os.path.join(save_folder, save_file_name)
    nib_save(img_stack, save_file)

if __name__ == "__main__":


    config = dict(
        # ==========================================================================================
        # num_slice=94,
        embryo_names=range(73,75),
        # max_times=[240],
        xy_resolution=0.444,
        z_resolution=0.5,
        # out_size=[256, 356, 224],
        # todo: need to be MANUALLY calculated with the vertical image amount
        # ===========================================================================================

        raw_folder=r'C:\Users\zelinli6\Downloads\azuma_seg',
        target_folder=r"C:\Users\zelinli6\Downloads\pack_azuma_seg",
    )

    combine_slices(config)
