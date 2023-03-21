import os.path

from skimage.transform import resize, rescale
import glob

from utils.data_io import nib_load, nib_save


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
    resize_the_segcell_niigz()
