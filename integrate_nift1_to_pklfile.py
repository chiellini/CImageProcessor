'''
Preprocess for fast data reading
'''
#  Import dependency library
import os
import glob
from tqdm import tqdm

#  import user defined library
from utils.data_io import nib_load, normalize3d, pkl_save


def integrate_nift1_to_pkl(embryo_data_root_path, has_nuc_label=True, has_membrane_label=False, max_time=None):
    #  build pkl folder
    pkl_folder = os.path.join(embryo_data_root_path, "PklFile")
    if not os.path.isdir(pkl_folder):
        os.makedirs(pkl_folder)
    #  get data list
    raw_memb_list = sorted(glob.glob(os.path.join(embryo_data_root_path, "RawMemb", "*.gz")))[:max_time]
    raw_nuc_list = sorted(glob.glob(os.path.join(embryo_data_root_path, "RawNuc", "*.gz")))[:max_time]
    if has_nuc_label:
        seg_nuc_list = sorted(glob.glob(os.path.join(embryo_data_root_path, "SegNuc", "*.gz")))[:max_time]
    if has_membrane_label:
        seg_memb_list = sorted(glob.glob(os.path.join(embryo_data_root_path, "SegMemb", "*.gz")))[:max_time]
        seg_cell_list = sorted(glob.glob(os.path.join(embryo_data_root_path, "SegCell", "*.gz")))[:max_time]
    #  read nii and save data as pkl
    for i, raw_memb_file in enumerate(tqdm(raw_memb_list, desc="saving" + embryo_data_root_path)):
        base_name = os.path.basename(raw_memb_file).split("_")
        base_name = base_name[0] + "_" + base_name[1]
        raw_memb = nib_load(raw_memb_file)  #
        raw_nuc = nib_load(raw_nuc_list[i]) if len(raw_nuc_list) > 0 else None
        if has_nuc_label:
            seg_nuc = nib_load(seg_nuc_list[i]) if len(raw_nuc_list) > 0 else None
        if has_membrane_label:
            seg_memb = nib_load(seg_memb_list[i])
            seg_cell = nib_load(seg_cell_list[i])

        pickle_file_path = os.path.join(pkl_folder, base_name+'.pkl')
        if has_membrane_label:
            pkl_save(dict(raw_memb=raw_memb, raw_nuc=raw_nuc, seg_nuc=seg_nuc, seg_memb=seg_memb, seg_cell=seg_cell), pickle_file_path)
        elif has_nuc_label:
            pkl_save(dict(raw_memb=raw_memb, raw_nuc=raw_nuc, seg_nuc=seg_nuc), pickle_file_path)
        else:
            pkl_save(dict(raw_memb=raw_memb, raw_nuc=raw_nuc), pickle_file_path)

def do_integrating_pkl(target, embryo_names=None, max_times=None):
    #  get embryo list
    root, has_nuc_label,has_membrane_label = target["data_root_path"], target["has_nuc_label"],target['has_membrane_label']
    if embryo_names is None:
        embryo_names = [name for name in os.listdir(root) if os.listdir(os.path.join(root, name))]
    for i_embryo, embryo_name in enumerate(embryo_names):
        integrate_nift1_to_pkl(os.path.join(root, embryo_name), has_nuc_label, has_membrane_label,max_times[i_embryo])

if __name__ == "__main__":
    # embryo_names = ["191108plc1p1", "200109plc1p1", "200113plc1p2", "200113plc1p3", "200322plc1p2", "200323plc1p1", "200326plc1p3", "200326plc1p4"]
    # max_times = [205, 205, 255, 195, 195, 185, 220, 195]
    # embryo_names = ["200117plc1pop1ip2", "200117plc1pop1ip3"]
    # max_times = [140, 155]
    embryo_names = ["221017plc1p2"]
    max_times = [240]
    # doit(train_folder, embryo_names)
    # dataset folder
    # train_folder = dict(root="dataset/train", has_label=True)
    integrating_args = dict(data_root_path=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\DataSource', has_nuc_label=True, has_membrane_label=False)
    do_integrating_pkl(integrating_args, embryo_names, max_times=max_times)