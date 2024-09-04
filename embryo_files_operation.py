import glob
import os
import pandas as pd
import shutil
import time

# ======================================================
# rename
# move
# check files list
# to csv
# ======================================================


# ================re name the expression embryos' raw images==========================
# # file_paths=[r'F:\ExpRawImage','E:\zelin']
# # file_paths=[r'E:\testing']
# file_paths=[r'F:\appendedExpRawImage',r'F:\appendedExpRawImage']
#
# embryo_list_path1=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\04paper CMap coroperation\document\expression Table S13.xlsx'
#
# #
# # embryo_names=[]
# # for file_path in file_paths:
# #     embryo_names_tem=os.listdir(file_path)
# #     embryo_names=embryo_names+embryo_names_tem
#
# # embryo_names=set(embryo_names)
# # print(len(embryo_names))
#
# embryo_list_in_list1=pd.read_excel(embryo_list_path1)
# embryo_list_in_list1=embryo_list_in_list1[embryo_list_in_list1['Data source']=='This paper\'']
# embryo_list_in_list1['purename']=embryo_list_in_list1['Embryo file name'].apply(lambda x:x[2:-5]).to_list()
#
# # renamed_raw_tiffs=r'E:\renamed_raw_tiffs'
#
# naming_dictionary={}
#
# expression_calculation={}
#
# for emb_idx, embryo_name in enumerate(embryo_list_in_list1['purename']):
#     embryo_raw_path=os.path.join(file_paths[0],embryo_name)
#     if not os.path.exists(embryo_raw_path):
#         embryo_raw_path = os.path.join(file_paths[1], embryo_name)
#     if not os.path.exists(embryo_raw_path):
#         continue
#
#     expression_name=embryo_name[6:-2].lower()
#     if expression_name[-2]!='-':
#         if expression_name[3].isdigit():
#             expression_name=expression_name[:3]+'-'+expression_name[3:]
#         elif expression_name[3].isalpha():
#             expression_name = expression_name[:4] + '-' + expression_name[4:]
#     # print(expression_name)
#     if expression_name not in expression_calculation.keys():
#         expression_calculation[expression_name]=1
#     else:
#         expression_calculation[expression_name]+=1
#     new_embryo_name='EXP_{}_Sample{}'.format(expression_name,str(expression_calculation[expression_name]))
#     print(embryo_name,new_embryo_name)
#     naming_dictionary[embryo_name]=new_embryo_name
#
#     for other_dirs in glob.glob(f'{embryo_raw_path}/*'):
#         if os.path.basename(other_dirs) not in ['tifR','tif']:
#             if os.path.isdir(other_dirs):
#                 shutil.rmtree(other_dirs)
#             elif os.path.isfile(other_dirs):
#                 os.remove(other_dirs)
#
#
#     for membrane_tiff in glob.glob(f'{embryo_raw_path}/tifR/*.tif'):
#         tp_this_tem,pic_idx_tem=os.path.basename(membrane_tiff).split('_')[1].split('-')[1:3]
#         tp_this=tp_this_tem[1:]
#         pic_idx_this=pic_idx_tem[1:3]
#         new_tiff_name=f'{new_embryo_name}-T{tp_this}-P{pic_idx_this}'
#         dir_this=os.path.dirname(membrane_tiff)
#         os.rename(membrane_tiff, os.path.join(dir_this, new_tiff_name+'.tif'))
#         # print(membrane_tiff, os.path.join(dir_this, new_tiff_name+'.tif'))
#     os.rename(f'{embryo_raw_path}/tifR',f'{embryo_raw_path}/Membrane')
#     print(f'{embryo_raw_path}/tifR',f'{embryo_raw_path}/Membrane')
#
#     for nucleus_tiff in glob.glob(f'{embryo_raw_path}/tif/*.tif'):
#         tp_this_tem,pic_idx_tem=os.path.basename(nucleus_tiff).split('_')[1].split('-')[1:3]
#         tp_this=tp_this_tem[1:]
#         pic_idx_this=pic_idx_tem[1:3]
#         new_tiff_name=f'{new_embryo_name}-T{tp_this}-P{pic_idx_this}'
#         dir_this=os.path.dirname(nucleus_tiff)
#         os.rename(nucleus_tiff, os.path.join(dir_this, new_tiff_name+'.tif'))
#         # print(nucleus_tiff, os.path.join(dir_this, new_tiff_name+'.tif'))
#     os.rename(f'{embryo_raw_path}/tif',f'{embryo_raw_path}/Nucleus')
#     print(f'{embryo_raw_path}/tif',f'{embryo_raw_path}/Nucleus')
#     # print(f'{embryo_raw_path}',f'{os.path.dirname(embryo_raw_path)}/{new_embryo_name}')
#     os.rename(f'{embryo_raw_path}',f'{os.path.dirname(embryo_raw_path)}/{new_embryo_name}')
#     print(f'{embryo_raw_path}',f'{os.path.dirname(embryo_raw_path)}/{new_embryo_name}')

# ===============================================================================================================

# ===========zip all the images==================
# # file_paths=[r'F:\ExpRawImage','E:\zelin']
# # embryo_paths=glob.glob(f'{file_paths[0]}\*')+glob.glob(f'{file_paths[1]}\*')
#
#
#
# file_paths=[r'F:\appendedExpRawImage']
# embryo_paths=glob.glob(f'{file_paths[0]}\*')
# zipped_target_folder=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\04paper CMap coroperation\Dataset raw images'
#
# # embryo_paths=glob.glob(r'E:\testing\*')
# # zipped_target_folder=r'E:\testing'
#
# for embryo_name_path in embryo_paths:
#     t0 = time.time()
#
#     print(embryo_name_path)
#     embryo_name_this=os.path.basename(embryo_name_path)
#     shutil.make_archive(os.path.join(zipped_target_folder,f'{embryo_name_this}'),'zip',embryo_name_path)
#     print(time.time()-t0)
# =============================================



# pd.DataFrame.from_dict(naming_dictionary,orient='index').to_csv(os.path.join(os.path.dirname(embryo_list_path1),'EXP_embryo_renaming.csv'))



# ============================================================================


# # ================check the expression embryos' list==========================
# file_paths=[r'D:\ExpRawImage',r'F:\ExpRawImage',r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\04paper CMap coroperation\Dataset raw images']
#
# embryo_list_path1=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\04paper CMap coroperation\document\expression Table S.xlsx'
#
#
# embryo_names=[]
# for file_path in file_paths:
#     embryo_names_tem=os.listdir(file_path)
#     embryo_names=embryo_names+embryo_names_tem
#
# embryo_names=set(embryo_names)
# # print(len(embryo_names))
#
# embryo_list_in_list1=pd.read_excel(embryo_list_path1)
# embryo_list_in_list1=embryo_list_in_list1[embryo_list_in_list1['Data source']=='This paper\'']
# embryo_list_in_list1=set(embryo_list_in_list1['Embryo file name'].apply(lambda x:x[2:-5]).to_list())
#
# # print(embryo_list_in_list1)
# print(sorted(embryo_list_in_list1-embryo_names),len(embryo_list_in_list1-embryo_names))
#
# # ============================================================================



# ============================================================================
# root_dir=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapSubmission\ApoptoticCellAnnotation3'
#
# rename_dict = {'200113plc1p2': 'WT_Sample1',
#                '200322plc1p2': 'WT_Sample2',
#                '200323plc1p1': 'WT_Sample3',
#                '200326plc1p3': 'WT_Sample4',
#                '200326plc1p4': 'WT_Sample5',
#                '191108plc1p1': 'WT_Sample6',
#                '200109plc1p1': 'WT_Sample7',
#                '200113plc1p3': 'WT_Sample8'}
#
#
# for dir_this in os.listdir(root_dir):
#     for file_name_this in os.listdir(os.path.join(root_dir,dir_this)):
#         embryo_original_name,tp_this=file_name_this.split('_')[:2]
#         if embryo_original_name in rename_dict.keys():
#             os.rename(os.path.join(root_dir,dir_this,file_name_this),os.path.join(root_dir,dir_this,'{}_{}_segCell_G.nii.gz'.format(rename_dict[embryo_original_name],tp_this)))
#
# for dir_this in os.listdir(root_dir):
#     if dir_this in rename_dict:
#         os.rename(os.path.join(root_dir, dir_this),os.path.join(root_dir,rename_dict[dir_this]))
# ============================================================================

# ============================================================================
root_dir=r'D:\project_tem\GroundTruthTrainingDataset6EmbZhaoLab'

rename_dict = {
                   '170614plc1p1': 'NucEmb1',
'170704plc1p1': 'NucEmb2',
               '181210plc1p3': 'NucEmb3',
    '190314plc1p3': 'NucEmb4',
    '200109plc1p1': 'NucEmb5',
    '200113plc1p2': 'NucEmb6',

}


for dir_this in os.listdir(root_dir):
    for file_name_this in os.listdir(os.path.join(root_dir,dir_this)):
        # embryo_original_nameL,tp_thisL,z_thisL=file_name_this.split('-')[:3]
        # tp_this=tp_thisL[1:]
        # z_this=z_thisL[1:3]
        # embryo_original_name=embryo_original_nameL.split('_')[0]
        embryo_original_name, tp_this = file_name_this.split('_')[:2]
        if embryo_original_name in rename_dict.keys():
            raw_path=os.path.join(root_dir,dir_this,file_name_this)
            new_path=os.path.join(root_dir,dir_this,'{}_{}.tif'.format(rename_dict[embryo_original_name],tp_this))
            os.rename(raw_path,new_path)

for dir_this in os.listdir(root_dir):
    if dir_this in rename_dict:
        os.rename(os.path.join(root_dir, dir_this),os.path.join(root_dir,rename_dict[dir_this]))
# ============================================================================
