import os.path
import skimage.morphology
import numpy as np
import pandas as pd
# from skimage.morphology import ball
from scipy import ndimage
import multiprocessing as mp
from tqdm import tqdm

from glob import glob

from utils.data_io import nib_load, nib_save, check_folder




def running_reassign_cellular_map(para):
    segCellniigzpath = para[0]
    embryo_name=para[1]
    annotated_root_path=para[2]
    output_saving_path=para[3]

    tp_this_str = os.path.basename(segCellniigzpath).split('_')[1]
    segmented_arr = nib_load(segCellniigzpath).astype(int)
    annotated_niigz_path = os.path.join(annotated_root_path, embryo_name, 'AnnotatedNuc',
                                        f'{embryo_name}_{tp_this_str}_annotatedNuc.nii.gz')
    annotated_nuc_arr = nib_load(annotated_niigz_path).astype(int)
    # nucleus_marker_footprint = skimage.morphology.ball(7 - int(int(tp_this_str) / 100))
    # annotated_nuc_arr = ndimage.grey_erosion(annotated_nuc_arr, footprint=nucleus_marker_footprint)

    new_cellular_arr = np.zeros(segmented_arr.shape)
    cells_list_this = np.unique(annotated_nuc_arr)[1:]
    mapping_cellular_dict = {}
    conflicting_pairs = []
    lossing_cells = []

    late_processing_cells = []  # the apoptotic cells should be processed in a biological manner
    # deal with
    for cell_index in cells_list_this:
        # this_cell_fate = cell2fate.get(label_name_dict[cell_index], 'Unspecified')
        # if this_cell_fate == 'Death':
        #     late_processing_cells += cell_index
        # else:
        locations_cellular = np.where(annotated_nuc_arr == cell_index)
        # centre_len_tmp = len(locations_cellular[0]) // 2
        centre_len_tmp = 0
        x_tmp = locations_cellular[0][centre_len_tmp]
        y_tmp = locations_cellular[1][centre_len_tmp]
        z_tmp = locations_cellular[2][centre_len_tmp]

        segmented_arr_index = int(segmented_arr[x_tmp, y_tmp, z_tmp])

        new_cellular_arr[segmented_arr == segmented_arr_index] = cell_index
        mapping_cellular_dict[int(segmented_arr_index)] = int(cell_index)
    nib_save(new_cellular_arr, os.path.join(output_saving_path, embryo_name, os.path.basename(segCellniigzpath)))



if __name__ == '__main__':
    embryo_names = ['190311plc1mp1', '190311plc1mp3']
    # ['170704plc1p1', '170614plc1p1',
    #             '190314plc1p3', '181210plc1p3', '181210plc1p1', '181210plc1p2',
    #             '200309plc1p1', '200309plc1p2', '200309plc1p3', '200311plc1p1', '200311plc1p3', '200312plc1p2',
    #             '200314plc1p1', '200314plc1p2', '200314plc1p3', '200315plc1p2', '200315plc1p3', '200316plc1p1',
    #             '200316plc1p2', '200316plc1p3', '191022plc1pop1ip1', '191022plc1pop1ip2',
    #
    #             '191108plc1p1', '200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    #             '200326plc1p3', '200326plc1p4',
    #             '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2', '200117plc1pop1ip3']
    segmented_root_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\02paper cunmin segmentation\segmentation results'
    annotated_root_path = r'F:\packed membrane nucleus 3d niigz'
    name_dictionary_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\02paper cunmin segmentation\segmentation results/name_dictionary_fast.csv'
    # cell_fate_dictionary = r'/home/cimda/INNERDisk1/ZELIN_MEMB_DATA/CMap CSahepr 34 packed membrane nucleus/CellFate.xls'

    output_saving_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\02paper cunmin segmentation\segmentation results\withcellidentity'

    # reading cell fate, first arrange other cells then apoptotic cells
    # =========================
    # read cell fate
    # =========================
    # cell_fate = pd.read_excel(cell_fate_dictionary, names=["Cell", "Fate"], converters={"Cell": str, "Fate": str},
    #                           header=None)
    # cell_fate = cell_fate.map(lambda x: x[:-1])
    # cell2fate = dict(zip(cell_fate.Cell, cell_fate.Fate))

    # label_name_dict = pd.read_csv(name_dictionary_path, index_col=0).to_dict()['0']
    # name_label_dict = {value: key for key, value in label_name_dict.items()}

    # mapping_dict = {}
    for embryo_name in embryo_names:
        segmented_cell_paths = sorted(glob(os.path.join(segmented_root_path, embryo_name, '*.nii.gz')),
                                      reverse=True)

        # file_names = glob(
        #     os.path.join(integrated_args.output_data_path, sub_embryo_folder, 'SegMemb', '*segMemb.nii.gz'))
        # saving_segCell_path = os.path.join(integrated_args.output_data_path, sub_embryo_folder, 'SegCell')
        # file_names=file_names+file_names_this

        # ========================================================================
        # embryo_egg_edge = None
        parameters = []
        for segmented_cell_file in segmented_cell_paths:
            # parameters.append([embryo_name, file_name, embryo_average_mask, args.is_nuc_labelled,args.get('mem_edt_threshold', None),args.predict_data_path])
            parameters.append([segmented_cell_file,embryo_name,annotated_root_path,output_saving_path])

            # segment_membrane([embryo_name, file_name, embryo_mask])
        mp_cpu_num = min(len(parameters), mp.cpu_count() // 2)
        print('all cpu process is ', mp.cpu_count(), 'we created ', mp_cpu_num)
        mpPool = mp.Pool(mp_cpu_num)
        for _ in tqdm(mpPool.imap_unordered(running_reassign_cellular_map, parameters), total=len(parameters),
                      desc="{} membrane --> cell, all cpu process is {}, we created {}".format('validating embryo',
                                                                                               str(mp.cpu_count()),
                                                                                               str(mp_cpu_num))):
            pass
