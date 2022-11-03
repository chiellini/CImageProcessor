import os
import re
import shutil
import numpy as np
from glob import glob
from tqdm import tqdm
from PIL import Image
from skimage.transform import resize

import nibabel as nib


def check_folder(file_folder, overwrite=False):
    if "." in os.path.basename(file_folder):
        file_folder = os.path.dirname(file_folder)
    if os.path.isdir(file_folder) and overwrite:
        shutil.rmtree(file_folder)
    elif not os.path.isdir(file_folder):
        os.makedirs(file_folder)

def nib_save(file_name, data, **kwargs):
    """
    Write Nifti image with image header
    :param file_name:
    :param data:
    :param overwrite:
    :return:
    """
    check_folder(file_name, overwrite=False)

    # generate header
    img = nib.Nifti1Image(data, np.eye(4))

    for key, value in kwargs.items():
        if key in img.header:
            img.header[key] = value

    nib.save(img, file_name)

def get_num_slice(regex_char, files):
    """
    Get the number of slices
    :param regex_char:
    :param files:
    :return:
    """
    slice_char = re.compile(regex_char)
    slice_num = -1
    for img_file in files:
        try:
            num = int(slice_char.search(img_file).group(1))
            if num > slice_num:
                slice_num = num
            else:
                return slice_num + 1
        except:
            raise ValueError("Cannot find slice string in {}".format(img_file))

    return slice_num + 1


def stack_membrane_image(config, **kwargs):
    """
    Combine membrane slices
    :param config:
    :param kwargs:
    :return:
    """
    src_files = []
    for str_char in config["str_char"]:
        src_files += glob(os.path.join(config["src_folder"], str_char))
    src_files.sort()
    embryo_name = re.search("([a-zA-Z0-9]*)_L1", src_files[0]).group(1)

    # get the number of slices
    slice_num = get_num_slice(regex_char="-p([0-9]*).tif", files=src_files) - 1

    # get start tp
    start_tp = config["start_tp"]
    if start_tp < 0:
        start_tp = len(glob(os.path.join(config["dst_folder"], embryo_name, "*.nii.gz"))) + 1
    max_tp = config["max_tp"]
    if max_tp < 0:
        max_tp = int(len(src_files) / slice_num)

    file_idx = 0
    for tp in tqdm(range(start_tp, start_tp + max_tp, 1), desc="Saving to {}".format(config["dst_folder"])):
        img_stack = []
        for slice_idx in range(slice_num):
            img = np.asarray(Image.open(src_files[file_idx]))
            img_stack.insert(0, img)
            file_idx += 1
        img_stack = np.transpose(np.stack(img_stack), axes=[1, 2, 0])

        if config["resize_image"]:
            img_stack = resize(img_stack, config["resize_image"], preserve_range=True, order=1)

        base_name = "{}_{}_rawMemb.nii.gz".format(embryo_name, str(tp).zfill(3))
        save_file = os.path.join(config["dst_folder"], embryo_name, base_name)
        nib_save(save_file, img_stack, overwrite=True, **kwargs)
