import nibabel
from skimage import io as ski_io
import glob
import os
import numpy as np

# ------user's packages------
from utils.utils import save_indexed_tif,scale2index


def tiff2nifti(root,target):
    tiff_file_paths=glob.glob(os.path.join(root,'*.tif'))
    for tiff_file_path in tiff_file_paths:
        tiff_file_arr=ski_io.imread(tiff_file_path)
        print(tiff_file_path,np.max(tiff_file_arr),np.min(tiff_file_arr))
        # my_utils.nib_save(tiff_file_arr,os.path.join(target,os.path.basename(tiff_file_path)))
def nifti2tiff(root,target,segmented):
    nifti_file_paths=glob.glob(os.path.join(root,'*.nii.gz'))
    for nifti_file_path in nifti_file_paths:
        nifti_file_arr=nibabel.load(nifti_file_path).get_fdata()
        print(nifti_file_arr.shape)
        # print(np.unique(nifti_file_arr))
        # nifti_file_arr=scale2index(nifti_file_arr)
        # print(np.unique(nifti_file_arr))
        save_file_path = os.path.join(target, os.path.basename(nifti_file_path).split(".")[0] + ".tif")
        save_indexed_tif(save_file_path, nifti_file_arr,segmented=segmented)


if __name__ == "__main__":
    print('3d format transforming')
    # tiff2nifti(r'C:\Users\zelinli6\Downloads\demo3D\train\images',None)
    # nifti2tiff(r'C:\Users\zelinli6\Downloads\stardist_3d_data\trainnifti\images',r'C:\Users\zelinli6\Downloads\stardist_3d_data\train\images',segmented=False)
    nifti2tiff(r'C:\Users\zelinli6\Downloads\stardist_3d_data\trainnifti\masks',r'C:\Users\zelinli6\Downloads\stardist_3d_data\train\masks',segmented=True)