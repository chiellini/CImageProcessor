import numpy as np

from utils.data_io import nib_load, nib_save


def relabel_the_seg_nuc_by_name_dictionary(name_dictionary,embryo_names,source_root,target_root):
    number_dictionary_path = config["name_dictionary"]
    label_name_dict = pd.read_csv(number_dictionary_path, index_col=0).to_dict()['0']
    name_label_dict = {value: key for key, value in label_name_dict.items()}