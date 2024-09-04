import glob
import os

# import nibabel
# from PIL import Image
import numpy as np
# tif_path_raw=r'C:\Users\zelinli6\Downloads\StarryNite\Demo_4D_series\tif\081505_L1-t001-p18.tif'
#
# tif_path_raw=r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33.tif'
# tif_path_output=r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33-output.tif'
#
# # pil_image_raw=Image.open(tif_path_raw)
#
# # pil_array=Image.fromarray(np.asanyarray(pil_image_raw), mode="L")
#
# # pil_array.save(r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33-output.tif',format='TIFF')
#
# import json
#
# import tifffile  # http://www.lfd.uci.edu/~gohlke/code/tifffile.py.html
#
# image_raw_array=tifffile.imread(tif_path_raw)
# options=dict(
#
# )
# tifffile.imwrite(tif_path_output,image_raw_array,
#
#
# byteorder='>',
#                  # bigtiff=True,
#                  imagej=True,
#                  # ome=True,
# resolution=(10.981529,10.981529),
#                      # 'info':{'compression':'raw'},
#                            metadata={'size':(712,512),
#                            'height':512,
#                            'width':712,
#                            'use_load_libtiff':False,
#                            'tile':[('raw',(0,0,712,512),396,('L',0,1))]}
#
#
# )
#
# image_output=tifffile.TiffFile(tif_path_output)
# image_raw=tifffile.TiffFile(tif_path_raw)
#
# pil_image_raw=Image.open(tif_path_raw)
#
# pil_image_output=Image.open(tif_path_output)
# print('ararar')
# from utils.data_io import nib_load, nib_save
#
# arr_this=nib_load(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\10 nucleus tracing enhancement\Figure1\200326plc1p4_030_rawNuc_predNuc.nii.gz')
# arr_to_save=np.zeros(arr_this.shape)
# arr_to_save[arr_this>0]=255
# nib_save(arr_to_save.astype(np.uint8),r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\10 nucleus tracing enhancement\Figure1\200326plc1p4_030_predNuc.nii.gz')

# Online Python - IDE, Editor, Compiler, Interpreter
# import numpy as np
# A=np.array([[0,-1,0,1,0,0],[-2,1,0,0,0,0],[0,0,-1,0,1,0],[0,-2,1,0,0,0],[0,0,0,-1,0,1],[0,0,-2,1,0,0]]).T
# #a=np.array([127.3,-25,0,-118.7,1,-96.3])
# # a=np.array([[76.4,-25,8,-16.8,1,-45.4]])
#
# B=np.array([50,85,66,30,8,1]).T
# print(np.linalg.solve(A,B,))

# import os
# from skimage.transform import resize
#
# from preprocess_slice import nib_save
#
# out_size=[256,356,214]
# out_stack=[]
# save_file_name = "{}_{}_enhancedNuc.nii.gz".format('200326plc1p4', str(30).zfill(3))
# for i_slice in range(1, 92 + 1):
#     # raw_file_name = "{}deconp1_L1-t{}-p{}.tif".format(embryo_name[:-2], str(tp).zfill(3), str(i_slice).zfill(2))
#     raw_file_name = "{}_L1-t{}-p{}.tif".format('200326plc1p4', str(30).zfill(3), str(i_slice).zfill(2))
#
#     img = np.asanyarray(Image.open(os.path.join(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\10 nucleus tracing enhancement\Figure1\reultitff\200326plc1p4', raw_file_name)))
#     out_stack.insert(0, img)
# img_stack = np.transpose(np.stack(out_stack), axes=(1, 2, 0))
# img_stack = resize(image=img_stack, output_shape=out_size, preserve_range=True, order=1).astype(np.int16)
# # nib_stack = nib.Nifti1Image(img_stack, np.eye(4))
# # nib_stack.header.set_xyzt_units(xyz=3, t=8)
# # nib_stack.header["pixdim"] = [1.0, res[0], res[1], res[2], 0., 0., 0., 0.]
# save_file = os.path.join(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\10 nucleus tracing enhancement\Figure1', save_file_name)
# # check_folder(save_file)
# nib_save(save_file,img_stack)
# from utils.data_io import nib_load
#
# the_cell_numbers=0
# root_this=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\WebData_CMap_cell_label_deleted'
# for embryoname_this in glob.glob(r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\WebData_CMap_cell_label_deleted\*'):
#
#     if os.path.isdir(embryoname_this):
#         niigz_paths=glob.glob(os.path.join(embryoname_this,'SegCell','*.nii.gz'))
#         for niigz_path in niigz_paths:
#             cell_number_this=len(np.unique(nib_load(niigz_path)))-1
#             # print(niigz_path,cell_number_this)
#             the_cell_numbers+=cell_number_this
#         print(embryoname_this,the_cell_numbers)

# =================================================================================================
# import pandas as pd
# cd_file_this=r'E:\ProjectData\MembraneProject\AllRawData\180913plc1p1\aceNuc\CD180913plc1p1.csv'
# df_cd_file=pd.read_csv(cd_file_this)
#
# this_cell_num=0
# previous_cell_num=0
# for time_tem in range(210,220):
#     this_cell_num=len(df_cd_file[df_cd_file['time']==time_tem])
#     if previous_cell_num<=550 and this_cell_num>=550:
#
#         print(time_tem,previous_cell_num,this_cell_num)
#         break
#     else:
#         previous_cell_num=this_cell_num
# ================================================================================================


# =================================================================================================
import pandas as pd
cd_file_this=r'E:\ProjectData\MembraneProject\AllRawData\200710hmr1plc1p3\aceNuc\CD200710hmr1plc1p3.csv'
df_cd_file=pd.read_csv(cd_file_this)
max_time=max(df_cd_file['time'])
print(max_time)

max_cells=0
the_most_cell_tp=0
for time_tem in range(max_time-50,max_time):
    this_cell_num=len(df_cd_file[df_cd_file['time']==time_tem])
    print(time_tem,this_cell_num)
    if this_cell_num>max_cells:
        max_cells=this_cell_num
        the_most_cell_tp=time_tem
print(the_most_cell_tp,max_cells)
# ================================================================================================