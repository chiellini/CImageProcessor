import nibabel
from skimage import io as ski_io
import glob
import os
import numpy as np

from scipy.ndimage.morphology import binary_closing
from skimage.transform import resize

# ------user's packages------
from utils.utils import save_indexed_tif, scale2index, nib_save


def tiff2nifti(root, target):
    tiff_file_paths = glob.glob(os.path.join(root, '*.tif'))
    for tiff_file_path in tiff_file_paths:
        tiff_file_arr = ski_io.imread(tiff_file_path)
        print(tiff_file_path, np.max(tiff_file_arr), np.min(tiff_file_arr))
        namelist = os.path.basename(tiff_file_path).split('.')[0].split('_')
        save_name = namelist[1] + '_' + namelist[2]
        # nib_save(tiff_file_arr,os.path.join(target,os.path.basename(tiff_file_path)))
        nib_save(os.path.join(target, save_name + '_segCell.nii.gz'), np.transpose(tiff_file_arr, axes=(1, 2, 0)))


def nifti2tiff(root, target, segmented):
    nifti_file_paths = glob.glob(os.path.join(root, '*.nii.gz'))
    for nifti_file_path in nifti_file_paths:
        nifti_file_arr = nibabel.load(nifti_file_path).get_fdata()
        # print(np.unique(nifti_file_arr,return_counts=True))
        # target_shape = [int(x / 2) for x in nifti_file_arr.shape]
        # nifti_file_arr = resize(image=nifti_file_arr, output_shape=target_shape, preserve_range=True, order=0).astype(np.uint8)

        if segmented is False and np.max(nifti_file_arr) < 255:
            nifti_file_arr = (nifti_file_arr * 255 / np.max(nifti_file_arr)).astype(np.uint)
        print(nifti_file_arr.shape)
        # print(np.unique(nifti_file_arr,return_counts=True))
        # print(np.unique(nifti_file_arr))
        # nifti_file_arr=scale2index(nifti_file_arr)
        # print(np.unique(nifti_file_arr))
        embryo_name = os.path.basename(nifti_file_path).split(".")[0].split('_')[0]
        tp = os.path.basename(nifti_file_path).split(".")[0].split('_')[1]
        save_file_path = os.path.join(target, os.path.basename(nifti_file_path).split(".")[0] + ".tif")
        save_indexed_tif(save_file_path, nifti_file_arr, segmented=segmented)


def nift2npy(root, target):
    nifti_file_paths = glob.glob(os.path.join(root, '*.nii.gz'))
    for nifti_file_path in nifti_file_paths:
        nifti_file_arr = nibabel.load(nifti_file_path).get_fdata()
        embryo_name = os.path.basename(nifti_file_path).split(".")[0].split('_')[0]
        tp = os.path.basename(nifti_file_path).split(".")[0].split('_')[1]
        save_file_path = os.path.join(target, embryo_name + '_' + tp + ".npy")
        np.save(save_file_path, nifti_file_arr)


def nift2npy_3type(root, target):
    nifti_file_paths = glob.glob(os.path.join(root, 'SegCell/*.nii.gz'))
    for nifti_file_path in nifti_file_paths:
        nifti_file_arr = nibabel.load(nifti_file_path).get_fdata()
        embryo_name = os.path.basename(nifti_file_path).split(".")[0].split('_')[0]
        tp = os.path.basename(nifti_file_path).split(".")[0].split('_')[1]
        # -------------
        save_file_path_1 = os.path.join(target, 'masks', embryo_name + '_' + tp + "_foreground.npy")
        foreground_arr = nifti_file_arr.copy()
        foreground_arr[nifti_file_arr != 0] = 1
        print('foreground', np.unique(foreground_arr, return_counts=True))
        np.save(save_file_path_1, foreground_arr)
        # -----------------
        save_file_path_2 = os.path.join(target, 'masks', embryo_name + '_' + tp + "_background.npy")
        background_arr = np.ones(nifti_file_arr.shape)
        binary_closing_arr_back = binary_closing(nifti_file_arr != 0, iterations=5)
        background_arr[binary_closing_arr_back] = 0
        np.save(save_file_path_2, background_arr)
        print('backgaround', np.unique(background_arr, return_counts=True))
        # ------------------
        save_file_path_3 = os.path.join(target, 'masks', embryo_name + '_' + tp + "_membrane.npy")
        nifti_file_path_membrane = os.path.join(root, 'SegMemb', embryo_name + '_' + tp + '_segMemb.nii.gz')
        nifti_file_arr_membrane = nibabel.load(nifti_file_path_membrane).get_fdata()
        np.save(save_file_path_3, nifti_file_arr_membrane)
        print('membrane', np.unique(nifti_file_arr_membrane, return_counts=True))


if __name__ == "__main__":
    print('3d format transforming')
    # ---------------transform tissue to obj to draw------------------
    # root_tmp = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Tissue\niigz'
    # label = 4
    # embryo_name = '200326plc1p4_190_segCell.nii.gz'
    # nifti_file_path = os.path.join(root_tmp, embryo_name)
    # arr = nibabel.load(nifti_file_path).get_fdata().astype(np.uint8)
    # mask = np.logical_and(arr != label, arr != 0)
    # arr[mask] = 100
    # nib_save(os.path.join(
    #     r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Tissue\niigz_uni',
    #     embryo_name), arr)

    nifti2tiff(
        root=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Tissue\niigz_uni',
        target=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Tissue\tiff',
        segmented=True)

    # -----------------groundtruth nii.gz to tiff--------------------
    # nifti2tiff(root=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Ground\Groundniigz',
    #            target=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Ground\GroundTif',
    #            segmented=True)
    # --------------raw niigz to tiff -----------------------------
    # nifti2tiff(
    #     root=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Rawniigz',
    #     target=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\RawTif',
    #     segmented=False)

    # tiff2nifti(r'F:\test',r'F:\test')
    # nifti2tiff(r'C:\Users\zelinli6\Downloads\stardist_3d_data\testnifti\images',r'C:\Users\zelinli6\Downloads\stardist_3d_data\test\images',segmented=False)
    # nifti2tiff(r'C:\Users\zelinli6\Downloads\stardist_3d_data\trainnifti\masks',r'C:\Users\zelinli6\Downloads\stardist_3d_data\train\masks',segmented=True)

    # 3dcellseg dataset preparation
    # nift2npy(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\DataSource\170614plc1p1\RawMemb',r'C:\Users\zelinli6\Downloads\3dcellseg_data\trainnpy\images')
    # nift2npy(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\DataSource\170704plc1p1\RawMemb',r'C:\Users\zelinli6\Downloads\3dcellseg_data\trainnpy\images')
    # nift2npy(r'D:\MembraneProjectData\DataSource\170614plc1p1\SegCell', r'F:\3dcellseg_data\trainnpy\masks')
    # nift2npy(r'D:\MembraneProjectData\DataSource\170704plc1p1\SegCell', r'F:\3dcellseg_data\trainnpy\masks')

    # nift2npy_3type(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\DataSource\170704plc1p1',r'C:\Users\zelinli6\Downloads\3dcellseg_data\trainnpy')
    # nift2npy_3type(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\DataSource\170614plc1p1',r'C:\Users\zelinli6\Downloads\3dcellseg_data\trainnpy')

    # nift2npy(r'C:\Users\zelinli6\Downloads\3dcellseg_data\testnifti\images', r'F:\3dcellseg_data\testnpy\images')
