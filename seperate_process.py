import os.path
import numpy as np
from skimage.transform import resize, rescale
import glob

from utils.data_io import nib_load, nib_save
from utils.obj_visulization import combine_objs, rename_objs
from utils.utils import get_boundary


def resize_the_segcell_niigz():
    embryo_names = ['221017plc1p2']
    root_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\Embryo pre segmented\CMap'
    target_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\Embryo pre segmented\CMap_whole'
    target_shape_scale = 2
    for embryo_name in embryo_names:
        seg_file_paths = glob.glob(os.path.join(root_path, embryo_name, 'SegCell','*_segCell.nii.gz'))
        for seg_file_path in seg_file_paths:
            seg_array = nib_load(seg_file_path)
            resize_seg_array = rescale(seg_array, scale=target_shape_scale,preserve_range=True, mode='constant',order=0)
            name_tp=os.path.basename(seg_file_path)
            save_path = os.path.join(target_path, embryo_name,'SegCell', name_tp)
            nib_save(resize_seg_array, save_path)
            print(name_tp,seg_array.shape,'_->>>',resize_seg_array.shape)


def set_up_new_training_and_evaluation_data():
    # =================================================
    #  Set new training evaluation dataset
    # =================================================
    embryo_name_to_save='181210plc1p3'
    root_path=r'C:\Users\zelinli6\Downloads\OneDrive_1_8-20-2023\EvaluationData\Sample04\SegCell'
    target_path=r'C:\Users\zelinli6\Downloads\OneDrive_1_8-20-2023\EvaluationData\Sample04\FilppedZSegCell'
    niigz_paths=glob.glob(os.path.join(root_path,'*.nii.gz'))
    for niigz_path in niigz_paths:
        # print(niigz_path,os.path.basename(niigz_path))
        embryo_name,tp=os.path.basename(niigz_path).split('.')[0].split('_')[:2]
        arraythis=nib_load(niigz_path)
        # nib_save(os.path.join(target_path,os.path.basename(niigz)),array)

        arraythis=np.flip(arraythis,2)
        img_stack = resize(image=arraythis, output_shape=(184,256,114), preserve_range=True, mode='constant',cval=0,order=0,anti_aliasing=False).astype(np.int16)

        nib_save(img_stack,os.path.join(target_path, "{}_{}_segCell.nii.gz".format(embryo_name_to_save, tp)))

    #-----------generate seg memb-----------------------------------------
    trainin_seg_folder = r"C:\Users\zelinli6\Downloads\OneDrive_1_8-20-2023\EvaluationData\Sample04\FilppedZSegCell"
    traingi_memb_dst_folder = r"C:\Users\zelinli6\Downloads\OneDrive_1_8-20-2023\EvaluationData\Sample04\FilppedZSegCell"
    # embryo_name = "170704plc1p1"

    seg_cell_file_paths = glob.glob(os.path.join(trainin_seg_folder,"*segCell.nii.gz"))

    for seg_file_path in seg_cell_file_paths:
        seg = nib_load(seg_file_path)
        memb = get_boundary(seg).astype(np.int16)
        embryo_name,tp=os.path.basename(seg_file_path).split('.')[0].split('_')[:2]
        # save_name_cell = os.path.join(dst_folder, "{}_{}_segCell.nii.gz".format(embryo_name, tp))
        save_seg_memb_path = os.path.join(traingi_memb_dst_folder, "{}_{}_segMemb.nii.gz".format(embryo_name_to_save, tp))
        # nib_save(save_name_cell, seg)
        nib_save(memb,save_seg_memb_path)

def check_new_training_evaluating_data():
    # ==============================================
    # check new training data and validation data
    # ==============================================
    root_path = r'F:\TrainingandEvaluation\training'
    raw_niigz_paths = glob.glob(os.path.join(root_path, 'RawMemb', '*.nii.gz'))
    for niigz in raw_niigz_paths:
        embryo_name, tp = os.path.basename(niigz).split('.')[0].split('_')[:2]
        print(embryo_name, tp)
        raw_memb_shape = nib_load(niigz).shape
        nuc_path = os.path.join(root_path, 'RawNuc', '{}_{}_rawNuc.nii.gz'.format(embryo_name, tp))
        raw_nuc_shape = nib_load(nuc_path).shape
        seg_cell_path = os.path.join(root_path, 'SegCell', '{}_{}_segCell.nii.gz'.format(embryo_name, tp))
        seg_cell_shape = nib_load(seg_cell_path).shape
        seg_nuc_path = os.path.join(root_path, 'SegNuc', '{}_{}_segNuc.nii.gz'.format(embryo_name, tp))
        seg_nuc_shape = nib_load(seg_nuc_path).shape
        assert raw_memb_shape == raw_nuc_shape
        assert raw_nuc_shape == seg_nuc_shape
        assert seg_cell_shape == seg_nuc_shape
        print(seg_nuc_shape)
        assert len(np.unique((nib_load(seg_nuc_path)))) > 2


if __name__ == "__main__":
    check_new_training_evaluating_data()
