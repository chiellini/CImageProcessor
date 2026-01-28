from utils.obj_visulization import combine_objs, rename_objs

if __name__ == "__main__":
    # resize_the_segcell_niigz()
    # embryo_names = ['compress1','Compressed2','Uncompressed1','Uncompressed2']
    # tps = [475,464,499,382]

    embryo_names = ['Sample04','Sample05', 'Sample06', 'Sample07', 'Sample08', 'Sample09', 'Sample10', 'Sample11', 'Sample12',
                    'Sample13', 'Sample14', 'Sample15', 'Sample16', 'Sample17', 'Sample18', 'Sample19', 'Sample20']
    tps = [150, 170, 210, 165, 160, 160, 160, 170, 165, 150, 155, 170, 160, 160, 160, 160, 170]

    # '191108plc1p1'，'200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
    # '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
    # '200117plc1pop1ip3']
    # tps = [205, 205, 255, 195, 195, 185, 220, 195, 195, 195, 140, 155]
    max_middle_num = 26
    # file_suffix= '' #'_merged' # _segCell
    file_suffix= '_segCell' #'_merged' # _segCell

    root = r'F:\temp\tif\obj_to_merge'
    tiff_map_txt_path = r'F:\temp\tif\tiff_to_merge\tiffmaptxt'
    rename_objs(embryo_names,tps,max_middle_num,root,tiff_map_txt_path,file_suffix=file_suffix)

    target_root = r'F:\temp\combined_obj'
    combine_objs(embryo_names,tps,max_middle_num,root,target_root,file_suffix=file_suffix)