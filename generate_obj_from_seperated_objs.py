from utils.obj_visulization import combine_objs, rename_objs

if __name__ == "__main__":
    # resize_the_segcell_niigz()
    embryo_names = ['compress1','Compressed2','Uncompressed1','Uncompressed2']
    tps = [475,464,499,382]

    # embryo_names = ['Uncompressed2']
    # tps = [499]

    # '191108plc1p1'，'200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    # '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
    # '200117plc1pop1ip3']
    # tps = [205, 205, 255, 195, 195, 185, 220, 195, 195, 195, 140, 155]
    max_middle_num = 1
    file_suffix= '' #'_merged' # _segCell
    root = r'H:\EmbSAM\revision\4data\tif\obj_to_merge'
    tiff_map_txt_path = r'H:\EmbSAM\revision\4data\tif\tiff_to_merge\tiffmaptxt'
    rename_objs(embryo_names,tps,max_middle_num,root,tiff_map_txt_path,file_suffix=file_suffix)

    target_root = r'H:\EmbSAM\revision\4data\tif\combined_obj'
    combine_objs(embryo_names,tps,max_middle_num,root,target_root,file_suffix=file_suffix)