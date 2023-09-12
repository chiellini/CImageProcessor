import os
import glob
import pickle
import warnings
import shutil

from skimage.morphology import ball

warnings.filterwarnings("ignore")
import numpy as np
from PIL import Image
import nibabel as nib
import pandas as pd
from skimage.exposure import rescale_intensity

import pandas
from tqdm import tqdm
import multiprocessing as mp
from skimage.transform import resize
from scipy import ndimage

from utils.utils import check_folder
from utils.data_structure import read_cd_file
from utils.data_io import nib_save

def combine_slices(config):
    """
    Combine slices into stack images
    :param config: parameters
    :return:
    """
    # signal.emit(True,'sss')
    num_slice = config["num_slice"]
    embryo_names = config["embryo_names"]
    max_times = config["max_times"]
    xy_res = config["xy_resolution"]
    z_res = config["z_resolution"]
    out_size = config["out_size"]
    raw_folder = config["raw_folder"]
    stack_folder = config["target_folder"]
    is_save_nuc_channel = config["save_nuc"]
    is_save_memb_channel = config["save_memb"]
    is_save_seg_cell_with_cd_file=config["lineage_file"]
    cd_file_path=config['cd_file_path']

    # get output size
    # raw_memb_files = glob.glob(os.path.join(raw_folder, embryo_names[0], "tifR", "*.tif"))
    # print(raw_memb_files)
    # raw_size = list(np.asarray(Image.open(raw_memb_files[0])).shape) + [int(num_slice * z_res / xy_res)]
    raw_size=[512,712,int(num_slice * z_res / xy_res)]
    out_res = [res * in_scale / out_scale for res, in_scale, out_scale in zip([xy_res, xy_res, xy_res], raw_size, out_size)]

    # multiprocessing
    mpPool = mp.Pool(mp.cpu_count() - 1)

    for idx_embryo,embryo_name in enumerate(embryo_names):
        lineage_file_path = os.path.join(cd_file_path, embryo_name + '.csv')

        # ======================= || save nucleus
        if is_save_nuc_channel:
            origin_folder = os.path.join(raw_folder, embryo_name, "tif")
            target_folder = os.path.join(stack_folder, embryo_name, "RawNuc")
            if not os.path.isdir(target_folder):
                os.makedirs(target_folder)

            configs = []
            for tp in range(1, max_times[idx_embryo] + 1):
                configs.append((origin_folder, target_folder, embryo_name, tp, out_size, num_slice, out_res))

            for idx, _ in enumerate(tqdm(mpPool.imap_unordered(stack_nuc_slices, configs), total=len(configs),
                                         desc="1/3 Stack nucleus of {}".format(embryo_name))):
                pass

        # =============================
        if is_save_memb_channel:
            origin_folder = os.path.join(raw_folder, embryo_name, "tifR")
            target_folder = os.path.join(stack_folder, embryo_name, "RawMemb")
            if not os.path.isdir(target_folder):
                os.makedirs(target_folder)

            configs = []
            for tp in range(1, max_times[idx_embryo] + 1):
                configs.append((origin_folder, target_folder, embryo_name, tp, out_size, num_slice, out_res))
                # stack_memb_slices(configs[0])
            for idx, _ in enumerate(tqdm(mpPool.imap_unordered(stack_memb_slices, configs), total=len(configs),
                                         desc="2/3 Stack membrane of {}".format(embryo_name))):
                # TODO: Process Name: `2/3 Stack membrane`; Current status: `idx`; Final status: max_time
                pass

        # save nucleus
        if is_save_seg_cell_with_cd_file:
            assert lineage_file_path is not None
            target_folder = os.path.join(stack_folder, embryo_name)
            if not os.path.isdir(target_folder):
                os.makedirs(target_folder)
            pd_lineage = read_cd_file(lineage_file_path)
            number_dictionary_path = config["name_dictionary"]
            label_name_dict = pd.read_csv(number_dictionary_path, index_col=0).to_dict()['0']
            name_label_dict = {value: key for key, value in label_name_dict.items()}

            configs_sphere = []
            for tp in range(1, max_times[idx_embryo] + 1):
                configs_sphere.append([embryo_name, name_label_dict, pd_lineage, tp, raw_size, out_size, out_res,
                                     xy_res / z_res, target_folder])

            # labeling as sphere
            for idx, _ in enumerate(tqdm(mpPool.imap_unordered(save_nuc_seg, configs_sphere), total=len(configs_sphere),
                                         desc="3/3 Construct spherical nucleus location of {}".format(embryo_name))):
                # TODO: Process Name: `3/3 Construct nucleus location`; Current status: `idx`; Final status: max_time
                pass

            #shutil.copy(lineage_file_path, os.path.join(stack_folder, embryo_name))


# ============================================
# save raw nucleus stack
# ============================================
def stack_nuc_slices(para):
    [raw_folder, save_folder, embryo_name, tp, out_size, num_slice, res] = para

    out_stack = []
    save_file_name = "{}_{}_rawNuc.nii.gz".format(embryo_name, str(tp).zfill(3))
    for i_slice in range(1, num_slice + 1):
        # raw_file_name = "{}deconp1_L1-t{}-p{}.tif".format(embryo_name[:-2], str(tp).zfill(3), str(i_slice).zfill(2))
        raw_file_name = "{}_L1-t{}-p{}.tif".format(embryo_name, str(tp).zfill(3), str(i_slice).zfill(2))

        img = np.asanyarray(Image.open(os.path.join(raw_folder, raw_file_name)))
        out_stack.insert(0, img)
    img_stack = np.transpose(np.stack(out_stack), axes=(1, 2, 0))
    img_stack = resize(image=img_stack, output_shape=out_size, preserve_range=True, order=1).astype(np.int16)
    nib_stack = nib.Nifti1Image(img_stack, np.eye(4))
    nib_stack.header.set_xyzt_units(xyz=3, t=8)
    nib_stack.header["pixdim"] = [1.0, res[0], res[1], res[2], 0., 0., 0., 0.]
    save_file = os.path.join(save_folder, save_file_name)
    check_folder(save_file)
    nib.save(nib_stack, save_file)
    print('save success')

# ============================================
# save raw membrane stack
# ============================================

def stack_memb_slices(para):
    [raw_folder, save_folder, embryo_name, tp, out_size, num_slice, res] = para

    out_stack = []
    save_file_name = "{}_{}_rawMemb.nii.gz".format(embryo_name, str(tp).zfill(3))
    for i_slice in range(1, num_slice+1):
        #r"D:\TemDownload\201112plc1_late_Lng\tifR\c elegans 3.lif_Series001_Lng_001_t00_z08_ch01.tif"
        # raw_file_name = "{}deconp1_L1-t{}-p{}.tif".format(embryo_name[:-2], str(tp).zfill(3), str(i_slice).zfill(2))
        raw_file_name = "{}_L1-t{}-p{}.tif".format(embryo_name, str(tp).zfill(3), str(i_slice).zfill(2))

        # transform the image to array and short them in a list
        img = np.asanyarray(Image.open(os.path.join(raw_folder, raw_file_name)))
        if img.shape != (512,712):
            print('ERRORRRRR',raw_file_name)
        out_stack.insert(0, img)


    img_stack = np.transpose(np.stack(out_stack), axes=(1, 2, 0)) # trasnpose the image from zxy to xyz
    v_min, v_max = np.percentile(img_stack, (0.2, 99.9)) # erase the outrange grayscale
    img_stack = rescale_intensity(img_stack, in_range=(v_min, v_max), out_range=(0, 255.0))
    # cut xy, interpolate z
    img_stack = resize(image=img_stack, output_shape=out_size, preserve_range=True, order=1).astype(np.int16)
    nib_stack = nib.Nifti1Image(img_stack, np.eye(4))
    nib_stack.header.set_xyzt_units(xyz=3, t=8)
    nib_stack.header["pixdim"] = [1.0, res[0], res[1], res[2], 0., 0., 0., 0.]
    save_file = os.path.join(save_folder, save_file_name)
    check_folder(save_file)
    nib.save(nib_stack, save_file)

# =============================================
# save nucleus segmentation

# def save_nuc_seg(para):
#     [embryo_name, name_dict, pd_lineage, tp, raw_size, out_size, out_res, dif_res, save_folder] = para
#
#     zoom_ratio = [y / x for x, y in zip(raw_size, out_size)]
#     tp_lineage = pd_lineage[pd_lineage["time"] == tp]
#     tp_lineage.loc[:, "x"] = (tp_lineage["x"] * zoom_ratio[0]).astype(np.int16)
#     tp_lineage.loc[:, "y"] = (np.floor(tp_lineage["y"] * zoom_ratio[1])).astype(np.int16)
#     tp_lineage.loc[:, "z"] = (out_size[2] - np.floor(tp_lineage["z"] * (zoom_ratio[2] / dif_res))).astype(np.int16)
#
#     # !!!! x <--> y !!!!!!!
#     nuc_dict = dict(
#         zip(tp_lineage["cell"], zip(tp_lineage["y"].values, tp_lineage["x"].values, tp_lineage["z"].values)))
#     #print(nuc_dict)
#     labels = [name_dict[name] for name in list(nuc_dict.keys())]
#     locs = list(nuc_dict.values())
#     # print(locs)
#     out_seg = np.zeros(out_size, dtype=np.int16)
#     for loc_idx,loc in enumerate(locs):
#
#         out_seg[int(loc[0]),int(loc[1]),int(loc[2])] = labels[loc_idx]
#
#     nucleus_marker_footprint = ball(7 - int(int(tp) / 100))
#     out_seg = ndimage.morphology.grey_dilation(out_seg, footprint=nucleus_marker_footprint)
#     #print(tuple(zip(*locs)))
#
#     #print(out_seg[:, :, :])
#     #nucleus_marker_footprint = ball(7 - int(int(tp) / 100))
#     #out_seg = ndimage.morphology.grey_dilation(out_seg, footprint=nucleus_marker_footprint)
#
#
#     save_file_name = "_".join([embryo_name, str(tp).zfill(3), "segNuc.nii.gz"])
#     save_file = os.path.join(save_folder, save_file_name)
#     nib.save(out_seg, save_file)



def save_nuc_seg(para):
    [embryo_name, name_dict, pd_lineage, tp, raw_size, out_size, out_res, dif_res, save_folder] = para
    zoom_ratio = [y / x for x, y in zip(raw_size, out_size)]
    tp_lineage = pd_lineage[pd_lineage["time"] == tp]
    tp_lineage.loc[:, "x"] = (tp_lineage["x"] * zoom_ratio[0]).astype(np.int16)
    tp_lineage.loc[:, "y"] = (np.floor(tp_lineage["y"] * zoom_ratio[1])).astype(np.int16)
    tp_lineage.loc[:, "z"] = (out_size[2] - np.floor(tp_lineage["z"] * (zoom_ratio[2] / dif_res))).astype(np.int16)

    # !!!! x <--> y !!!!!!!
    nuc_dict = dict(
        zip(tp_lineage["cell"], zip(tp_lineage["y"].values, tp_lineage["x"].values, tp_lineage["z"].values, tp_lineage["size"].values)))
    # labels = [name_dict[name] for name in list(nuc_dict.keys())]
    # locs = list(nuc_dict.values())

    # result = [int(item) for item in list_of_floats]

    out_seg = np.zeros(out_size, dtype=np.int16)
    for cell_name,cell_info in nuc_dict.items():
        cell_x = int(cell_info[0])
        cell_y = int(cell_info[1])
        cell_z = int(cell_info[2])

       
        cell_radius = int(cell_info[3]/4)#size is diameter /2,2 time small zoom,/2
        for x in range(cell_x - cell_radius, cell_x + cell_radius):
            for y in range(cell_y - cell_radius, cell_y + cell_radius):
                for z in range(cell_z - cell_radius, cell_z + cell_radius):
                    distance = np.sqrt((x - cell_x) ** 2 + (y - cell_y) ** 2 + (z - cell_z) ** 2)
                    if distance <= cell_radius:
                        out_seg[x, y, z] = 255

    # out_seg=out_seg-1
    save_file_name = "_".join([embryo_name, str(tp).zfill(3), "segNuc.nii.gz"])
    nib_stack = nib.Nifti1Image(out_seg, np.eye(4))
    nib_stack.header.set_xyzt_units(xyz=3, t=8)
    nib_stack.header["pixdim"] = [1.0, out_res[0], out_res[1], out_res[2], 0., 0., 0., 0.]
    save_file = os.path.join(save_folder, save_file_name)
    check_folder(save_file)
    nib.save(nib_stack, save_file)


if __name__ == "__main__":

    config = dict(num_slice=92,
                  #embryo_names=['170614plc1p1', '170704plc1p1', '181210plc1p3', '190314plc1p3', '200109plc1p1', '200113plc1p2'],
                  embryo_names=['170614plc1p1', '170704plc1p1'],
                  #max_times = [240, 240, 240, 90, 205, 255],# length of embryo
                  max_times = [240, 240],# length of embryo
                  xy_resolution = 0.09,
                  z_resolution = 0.42,
                  out_size = [256, 356, 168], # todo: need to be calculated with the vertical image amount
                  raw_folder=r'  ',
                  target_folder=r"E:\NucleuLabeling\fulldataset\training\SegFullNuc",
                  save_nuc = False,
                  save_memb = False,
                  lineage_file = True,
                  cd_file_path = r'E:\NucleuLabeling\fulldataset\training\CDfiles',
                  name_dictionary = r"E:\NucleuLabeling\fulldataset\name_dictionary.csv"
                  )

    combine_slices(config)