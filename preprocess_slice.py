import os
import shutil
import numpy as np
import nibabel as nib
from glob import glob
from tqdm import tqdm
from skimage.exposure import rescale_intensity

# import user defined library
from utils.slices import stack_membrane_image
from utils.utils import isotropic_resolution

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


def stack_slices(config):

    stack_membrane_image(config, **config["image_header"])


if __name__ == "__main__":
    print("test")
    # ==========================
    # 1. Combine slices
    # ==========================
    image_header = dict(pixdim=[1.0, 0.18, 0.18, 0.18, 0., 0., 0., 0.],
                        xyzt_units=11)

    # for embryo in ["181210plc1p1", "181210plc1p2", "181210plc1p3"]:
    #     config = dict(src_folder="D:/TemDownload/181210plc1/{}/tifR".format(embryo),
    #                   dst_folder="D:/TemDownload/BeforeDeconv",
    #                   str_char=["*_L1*.tif"],
    #                   resize_image=False,
    #                   start_tp=-1,
    #                   max_tp=-1,
    #                   image_header=image_header)
    #
    #     stack_slices(config)

    # =============================
    # 2. Resize volume
    # =============================
    # isotropic_resolution(src_folder=r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\Dataset\FluorescentImaging\DenoiseStack\TestData",
    #                      target_res=0.18)
    # isotropic_resolution(src_folder="/Users/jeff/OneDrive - City University of Hong Kong/Dataset/FluorescentImaging/DenoiseStack/TrainData/LowResolution",
    #                      target_res=0.18)

    # =============================
    # 3. Normalize the volume
    # =============================
    src_folder = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\Dataset\FluorescentImaging\DenoiseStack\TestData"
    src_files = glob(os.path.join(src_folder, "*.nii.gz"))
    for src_file in tqdm(src_files):
        img = nib.load(src_file)
        data = img.get_fdata()
        vmin, vmax = np.percentile(data, (0.3, 99.7))
        data = rescale_intensity(data, in_range=(vmin, vmax), out_range=(0, 255.0))
        nib_save(src_file, data.astype(np.uint8), **image_header)

    # ==============================
    # rescale intensity
    # ==============================