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





if __name__ == "__main__":
    # resize_the_segcell_niigz()
    embryo_names = ['191108plc1p1']
    # '200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    # '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
    # '200117plc1pop1ip3']
    tps = [205, 205, 255, 195, 195, 185, 220, 195, 195, 195, 140, 155]
    max_middle_num = 5
    root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\obj_seperated'
    tiff_map_txt_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\tiff\tiffmaptxt'
    # rename_objs(embryo_names,tps,max_middle_num,root,tiff_map_txt_path)

    target_root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\obj_combined'
    combine_objs(embryo_names,tps,max_middle_num,root,target_root)
