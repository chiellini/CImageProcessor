import os

root_dir=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\CMapSubmission\ApoptoticCellAnnotation3'

rename_dict = {'200113plc1p2': 'WT_Sample1',
               '200322plc1p2': 'WT_Sample2',
               '200323plc1p1': 'WT_Sample3',
               '200326plc1p3': 'WT_Sample4',
               '200326plc1p4': 'WT_Sample5',
               '191108plc1p1': 'WT_Sample6',
               '200109plc1p1': 'WT_Sample7',
               '200113plc1p3': 'WT_Sample8'}


for dir_this in os.listdir(root_dir):
    for file_name_this in os.listdir(os.path.join(root_dir,dir_this)):
        embryo_original_name,tp_this=file_name_this.split('_')[:2]
        if embryo_original_name in rename_dict.keys():
            os.rename(os.path.join(root_dir,dir_this,file_name_this),os.path.join(root_dir,dir_this,'{}_{}_segCell_G.nii.gz'.format(rename_dict[embryo_original_name],tp_this)))

for dir_this in os.listdir(root_dir):
    if dir_this in rename_dict:
        os.rename(os.path.join(root_dir, dir_this),os.path.join(root_dir,rename_dict[dir_this]))