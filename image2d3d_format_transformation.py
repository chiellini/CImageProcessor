import nibabel
from skimage import io as ski_io
import glob
import os
import numpy as np

from scipy.ndimage.morphology import binary_closing
from skimage.transform import resize, rescale
from tifffile import imwrite

# ------user's packages------
from utils.utils import save_indexed_tif, scale2index
from utils.data_io import nib_save, nib_load, check_folder


def tiff2nifti(root, target):
    tiff_file_paths = glob.glob(os.path.join(root, 'instances*.tif'))
    for tiff_file_path in tiff_file_paths:
        tiff_file_arr = ski_io.imread(tiff_file_path)
        print(tiff_file_path, np.max(tiff_file_arr), np.min(tiff_file_arr))
        namelist = os.path.basename(tiff_file_path).split('.')[0].split('_')
        save_name = namelist[1] + '_' + namelist[2]
        # nib_save(tiff_file_arr,os.path.join(target,os.path.basename(tiff_file_path)))
        nib_save(np.transpose(tiff_file_arr, axes=(1, 2, 0)), os.path.join(target, save_name + '_segCell.nii.gz'))


def nifti2tiff_seperated(root, target, segmented, name_dictionary_path=None):
    nifti_file_paths = sorted(glob.glob(os.path.join(root, '*.nii.gz')))
    obj_selection_index_list = []
    saving_obj_selection_index_list = os.path.join(os.path.dirname(target), "{}_render_indexed.txt".format(
        os.path.basename(target).split('.')[0]))
    print(saving_obj_selection_index_list)
    for nifti_file_path in nifti_file_paths:
        nifti_file_arr = nib_load(nifti_file_path)

        # print(np.unique(nifti_file_arr,return_counts=True))
        # target_shape = [int(x / 2) for x in nifti_file_arr.shape]
        # nifti_file_arr = resize(image=nifti_file_arr, output_shape=target_shape, preserve_range=True, order=0).astype(np.uint8)

        if segmented is False and np.max(nifti_file_arr) < 255:
            # just for flatten the range of the grayscale
            nifti_file_arr = (nifti_file_arr * 255 / np.max(nifti_file_arr)).astype(np.uint)
        # print(nifti_file_arr.shape)
        # print(np.unique(nifti_file_arr,return_counts=True))
        # print(np.unique(nifti_file_arr))
        # nifti_file_arr=scale2index(nifti_file_arr)
        # print(np.unique(nifti_file_arr))
        # embryo_name = os.path.basename(nifti_file_path).split(".")[0].split('_')[0]
        # tp = os.path.basename(nifti_file_path).split(".")[0].split('_')[1]
        save_file_path = os.path.join(target, os.path.basename(nifti_file_path).split(".")[0] + ".tif")
        target_shape_scale = 0.5
        resize_seg_array = rescale(nifti_file_arr, scale=target_shape_scale, preserve_range=True, mode='constant',
                                   order=0, anti_aliasing=False)
        save_indexed_tif(save_file_path, resize_seg_array, segmented=segmented,
                         obj_selection_index_list=obj_selection_index_list, name_dictionary_path=name_dictionary_path)
        # Open the file for writing
    saving_obj_selection_index_list = os.path.join(os.path.dirname(target), "{}_render_indexed.txt".format(
        os.path.basename(target).split('.')[0]))

    if segmented:
        print(saving_obj_selection_index_list, len(obj_selection_index_list))
        print(target,len(os.listdir(target)))
        with open(saving_obj_selection_index_list, "w") as f:
            # Write each string to a new line in the file
            for string in obj_selection_index_list:
                f.write(string + "\n")
        assert len(os.listdir(target)) == len(obj_selection_index_list)



def nifti2tiff(root, target, segmented):
    nifti_file_paths = sorted(glob.glob(os.path.join(root, '*.nii.gz')))
    obj_selection_index_list = []
    saving_obj_selection_index_list = os.path.join(os.path.dirname(target), "{}_render_indexed.txt".format(
        os.path.basename(target).split('.')[0]))
    # print(saving_obj_selection_index_list)
    for nifti_file_path in nifti_file_paths:
        print(nifti_file_path)
        nifti_file_arr = nib_load(nifti_file_path).astype(int)
        # print(np.unique(nifti_file_arr,return_counts=True))
        # target_shape = [int(x / 2) for x in nifti_file_arr.shape]
        # nifti_file_arr = resize(image=nifti_file_arr, output_shape=target_shape, preserve_range=True, order=0).astype(np.uint8)

        if segmented is False and np.max(nifti_file_arr) < 255:
            nifti_file_arr = (nifti_file_arr * 255 / np.max(nifti_file_arr)).astype(np.uint)
        save_file_path = os.path.join(target, os.path.basename(nifti_file_path).split(".")[0] + ".tif")
        max_one = save_indexed_tif(save_file_path, nifti_file_arr, segmented=segmented,
                                   obj_selection_index_list=obj_selection_index_list, is_seperate=False)
        obj_selection_index_list.append(str(max_one))

    if segmented:
        # print(saving_obj_selection_index_list, len(obj_selection_index_list))
        assert len([name for name in os.listdir(target)]) == len(obj_selection_index_list)
        with open(saving_obj_selection_index_list, "w") as f:
            # Write each string to a new line in the file
            for string in obj_selection_index_list:
                f.write(string + "\n")


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


def nift_2_4dtiff(root, target, embryo_names_tps_dict,img_type):

    if img_type == 1:
        suffix1='RawMemb'
        suffix2='rawMemb.nii.gz'
        suffix3='Membrane_image.tif'
    elif img_type == 2:
        suffix1='RawNuc'
        suffix2='rawNuc.nii.gz'
        suffix3='Nucleus_image.tif'
    elif img_type == 3:
        suffix1='AnnotatedNuc'
        suffix2='annotatedNuc.nii.gz'
        suffix3='Nucleus_segmentation.tif'

    for embryo_name, tps in embryo_names_tps_dict.items():
        time_series_3d_list=[]
        for tp_this in tps:
            niigz_path=os.path.join(root,embryo_name,suffix1,embryo_name+'_'+str(tp_this).zfill(3)+'_'+suffix2)
            array_this=nib_load(niigz_path).transpose([2,1,0])
            time_series_3d_list.append(array_this)
        this_4d_tiff=np.stack(time_series_3d_list,axis=0).astype(np.int16)
        saving_path_this=os.path.join(target,embryo_name,suffix3)
        check_folder(saving_path_this)
        imwrite(saving_path_this,this_4d_tiff,imagej=True)



if __name__ == "__main__":
    print('3d format transforming')
    # --------------transform 3d nitf to 3d tiff----------------
    # embryos_tps = {'200113plc1p2': [90, 123, 132, 166, 178, 185], '200109plc1p1': [78, 114, 123, 157, 172, 181]}
    # nift_2_4dtiff(
    #     r'F:\packed membrane nucleus 3d niigz',
    #     r'D:\Software\BCOMS2\CMapEva\Input', embryos_tps, 3)

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

    # nifti2tiff(
    #     root=r'F:\CMap_paper\Figures\Figure 6 major r1\niigz',
    #     target=r'F:\CMap_paper\Figures\Figure 6 major r1\tiff',
    #     segmented=True)

    # -----------------groundtruth nii.gz to tiff--------------------
    # nifti2tiff(root=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Ground\Groundniigz',
    #            target=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\Ground\GroundTif',
    #            segmented=True)
    # -----------------comparison method nii.gz to tiff--------------------
    # nifti2tiff(root=r'F:\CMap_paper\CMapEvaluation\3DCellSeg\niigz',
    #            target=r'F:\CMap_paper\CMapEvaluation\3DCellSeg\tiff',
    #            segmented=True)
    # nifti2tiff(root=r'F:\CMap_paper\CMapEvaluation\Cellpose3d\niigz',
    #            target=r'F:\CMap_paper\CMapEvaluation\Cellpose3d\tiff',
    #            segmented=True)
    # nifti2tiff(root=r'F:\CMap_paper\CMapEvaluation\VNet-CShaper\niigz',
    #            target=r'F:\CMap_paper\CMapEvaluation\VNet-CShaper\tiff',
    #            segmented=True)
    # nifti2tiff(root=r'F:\CMap_paper\CMapEvaluation\CShaper\niigz',
    #            target=r'F:\CMap_paper\CMapEvaluation\CShaper\tiff',
    #            segmented=True)
    # nifti2tiff(root=r'F:\CMap_paper\CMapEvaluation\Stardist3d\niigz',
    #            target=r'F:\CMap_paper\CMapEvaluation\Stardist3d\tiff',
    #            segmented=True)

    #
    # --------------raw niigz to tiff -----------------------------
    # nifti2tiff(
    #     root=r'F:\packed membrane nucleus 3d niigz\221017plc1p2RAWp1\RawMemb',
    #     target=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Temporary Sharing\MTBC Evaluation\raw evalution image\tiff_221017xx',
    #     segmented=False)

    # nifti2tiff_seperated(
    #     root=r'F:\CMap_paper\Figures\Figure 6 major r1\niigz_107',
    #     target=r'F:\CMap_paper\Figures\Figure 6 major r1\tiff_107',
    #     segmented=True,
    #     name_dictionary_path=r'F:\CMap_paper\Figures\Figure 6 major r1\name_dictionary.csv'
    # )

    # =============================== ctransformer data niigz to tiff ===========================
    # embryo_names = ['200113plc1p2']
    # root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Temporary Sharing\4DSWIN2023XXX'
    # target = r'F:\CTransformer_data\obj_visualization\seperated_tif'
    # for embryo_name in embryo_names:
    #     seg_cell_root = os.path.join(root, embryo_name, 'ApoptoticSegCell')
    #     tiff_root = os.path.join(target, embryo_name)
    #     nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True,name_dictionary_path=r'./necessary_files/name_dictionary.csv')
    # =============================== ctransformer data niigz to tiff ===========================

    # # ============================ niigz to tiff ============================
    # embryo_names = ['191108plc1p1', '200109plc1p1']
    # root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\TUNETr dataset\CTransformer embryos segmentation'
    # target = r'D:\project_tem\CTransformer visualization dataset\tif_to_merge'
    # for embryo_name in embryo_names:
    #     seg_cell_root = os.path.join(root, embryo_name, 'SegCell')
    #     tiff_root = os.path.join(target, embryo_name)
    #     nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True,
    #                          name_dictionary_path=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\Tables\name_dictionary.csv')
    # # ======================================================================

    # # ============================ niigz to tiff ============================
    embryo_names = ['Sample05', 'Sample06', 'Sample07', 'Sample08', 'Sample09', 'Sample10', 'Sample11', 'Sample12', 'Sample13',   'Sample14', 'Sample15', 'Sample16', 'Sample17', 'Sample18', 'Sample19', 'Sample20']
    # embryo_names = ['compress1','Compressed2','Uncompressed1','Uncompressed2']
    # embryo_names = ['Emb6', 'Emb7', 'Emb8', 'Emb9']
    root = r'F:\temp\Dataset'
    target = r'F:\temp\tif\tiff_to_merge'
    for embryo_name in embryo_names:
        seg_cell_root = os.path.join(root, embryo_name,'SegCell')
        tiff_root = os.path.join(target, embryo_name)
        if not os.path.exists(tiff_root):
            os.makedirs(tiff_root)
        nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True,
                             name_dictionary_path=r'F:\temp\Dataset\name_dictionary.csv')
    # # ======================================================================

    # ============================ niigz to tiff ============================
    # embryo_names = ['170704plc1p1','200113plc1p2']
    # root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\TUNETr dataset\ForTimelapseAnd2DEvaluation\CTransformer_unified'
    # target = r'D:\project_tem\TUNETr_imaging_seperated_tiff_obj_to_merge'
    # for embryo_name in embryo_names:
    #     seg_cell_root = os.path.join(root, embryo_name)
    #     tiff_root = os.path.join(target, embryo_name)
    #     nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True,name_dictionary_path=r'.\necessary_files\name_dictionary_TUNETr.csv')
    # ======================================================================

    # # =============================== cmap data niigz to tiff ===========================
    # embryo_names = ['191108plc1p1', '200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    #                 '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
    #                 '200117plc1pop1ip3']
    # root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\WebData_CMap_cell_label_v3'
    # target = r'F:\obj_web_visulizaiton\tiff'
    # for embryo_name in embryo_names:
    #     seg_cell_root = os.path.join(root, embryo_name, 'SegCell')
    #     tiff_root = os.path.join(target, embryo_name)
    #     nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True)
    # # =============================== cmap data niigz to tiff ===========================

    # =============================== fast imaging data niigz to tiff ===========================
    # embryo_names = ['190311plc1mp3', '190311plc1mp1']
    # root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\02paper cunmin segmentation\segmentation results\withcellidentity'
    # target = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\02paper cunmin segmentation\segmentation results\tiff'
    # for embryo_name in embryo_names:
    #     seg_cell_root = os.path.join(root, embryo_name)
    #     tiff_root = os.path.join(target, embryo_name)
    #     nifti2tiff(seg_cell_root, tiff_root, segmented=True)
    # =============================== cmap data niigz to tiff ===========================

    # tiff2nifti(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\TUNETr dataset\3DEvaluation\Cellpose3D\TIFF',
    #            r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\TUNETr dataset\3DEvaluation\Cellpose3D\SegCell')
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
