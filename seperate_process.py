import os.path

from skimage.transform import resize, rescale
import glob

from utils.data_io import nib_load, nib_save
from utils.obj_visulization import combine_objs, rename_objs


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

    # root_path=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\CShaperRawLabelData'
    # target_path=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapEvaluationData\CShaperRawLabelData\tem'
    # niigz_paths=glob.glob(os.path.join(root_path,'*.nii.gz'))
    # for niigz in niigz_paths:
    #     arraythis=nib.load(niigz).get_fdata()
    #     # nib_save(os.path.join(target_path,os.path.basename(niigz)),array)
    #     # arraythis=np.flip(arraythis,0)
    #     # arraythis=np.flip(arraythis,1)
    #     arraythis=np.flip(arraythis,2)
    #     img_stack = resize(image=arraythis, output_shape=(205,285,134), preserve_range=True, order=1).astype(np.uint8)

    #     nib_save(os.path.join(target_path,os.path.basename(niigz)),img_stack)
    # -----------generate seg memb-----------------------------------------
    # trainin_seg_folder = r"F:\TrainingandEvaluation\evaluation\SegCell"
    # traingi_memb_dst_folder = r"F:\TrainingandEvaluation\evaluation\SegMemb"
    # # embryo_name = "170704plc1p1"
    #
    # seg_cell_file_paths = glob.glob(os.path.join(trainin_seg_folder,"*.nii.gz"))
    #
    # for seg_file_path in seg_cell_file_paths:
    #     seg = nib.load(seg_file_path).get_fdata()
    #     memb = get_boundary(seg).astype(np.uint8)
    #     embryo_name,tp=os.path.basename(seg_file_path).split('.')[0].split('_')[:2]
    #     # save_name_cell = os.path.join(dst_folder, "{}_{}_segCell.nii.gz".format(embryo_name, tp))
    #     save_seg_memb_path = os.path.join(traingi_memb_dst_folder, "{}_{}_segMemb.nii.gz".format(embryo_name, tp))
    #     # nib_save(save_name_cell, seg)
    #     nib_save(save_seg_memb_path, memb)

    # ==============================================
    # check new training data and validation data
    # ==============================================
    root_path = r'F:\TrainingandEvaluation\evaluation'
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


if __name__ == "__main__":
    # resize_the_segcell_niigz()
    embryo_names = ['191108plc1p1','200109plc1p1']
    # '191108plc1p1'，'200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    # '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
    # '200117plc1pop1ip3']
    tps = [205, 205, 255, 195, 195, 185, 220, 195, 195, 195, 140, 155]
    max_middle_num = 5
    root = r'F:\obj_web_visulizaiton\obj_seperated'
    tiff_map_txt_path = r'F:\obj_web_visulizaiton\tiff\tiffmaptxt'
    rename_objs(embryo_names,tps,max_middle_num,root,tiff_map_txt_path)

    target_root = r'F:\obj_web_visulizaiton\obj_combined'
    combine_objs(embryo_names,tps,max_middle_num,root,target_root)
