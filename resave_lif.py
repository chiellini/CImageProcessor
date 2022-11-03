import os
import shutil
from tqdm import tqdm
import numpy as np
import utils.readlif as lif
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


save_folder = "D:/ProjectData/RawDada"
file_name = "D:/TemDownload/181210plc1.lif"

image_header = dict(pixdim=[1.0, 0.09, 0.09, 0.42, 0., 0., 0., 0.],
                    xyzt_units=11)

from readlif.reader import LifFile
new = LifFile(file_name)
embryo_pre = os.path.basename(file_name).split(".")[0]

i_embryo = 1
num_series = 1
for image in tqdm(new.get_iter_image(), desc="Decomposing lif"):
    if num_series == 6:
        i_embryo += 1
        num_series = 1

    embryo_name = embryo_pre + "p{}".format(i_embryo)
    save_file = os.path.join(save_folder, embryo_name)
    for frame in image.get_iter_t():
        print(image.name)

