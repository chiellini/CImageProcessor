import os
import bpy


def check_folder(file_folder, overwrite=False):
    if "." in os.path.basename(file_folder):
        file_folder = os.path.dirname(file_folder)
    if os.path.isdir(file_folder) and overwrite:
        shutil.rmtree(file_folder)
    elif not os.path.isdir(file_folder):
        os.makedirs(file_folder)

embryo_names = ['191108plc1p1']
# '200109plc1p1', '200113plc1p2', '200113plc1p3', '200322plc1p2', '200323plc1p1',
# '200326plc1p3', '200326plc1p4', '200122plc1lag1ip1', '200122plc1lag1ip2', '200117plc1pop1ip2',
# '200117plc1pop1ip3']
tps = [205, 205, 255, 195, 195, 185, 220, 195, 195, 195, 140, 155]
max_middle_num = 5
root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\obj_seperated'
tiff_map_txt_path = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\tiff\tiffmaptxt'

target_root = r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\MembraneProjectData\GUIData\tem\obj_combined'
for idx,embryo_name in enumerate(embryo_names):
    for tp in range(1,tps[idx]+1):
        
        
        imported_obj_files=[]

        for middle_idx in range(1,max_middle_num+1):
            obj_file_path=os.path.join(root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell_'+str(middle_idx)+'.obj')
            if os.path.exists(obj_file_path):
                imported_obj_files.append(os.path.basename(obj_file_path))
                bpy.ops.import_scene.obj(filepath=obj_file_path)
        
        for imported_obj in imported_obj_files:
            bpy.data.objects[imported_obj[:-4]].select_set(True)
#        bpy.context.view_layer.objects.active = bpy.data.objects[imported_obj_files[0][:-4]]

        # Combine all objects into one object
#        bpy.ops.object.select_all(action='SELECT')
#        bpy.ops.object.join()
        
        # Export combined object as obj file
        output_obj_path=os.path.join(target_root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell.obj')
        check_folder(output_obj_path)
        bpy.ops.export_scene.obj(filepath=output_obj_path)
        
        # Deselect all objects
        bpy.context.view_layer.objects.active = bpy.data.objects[imported_obj_files[0][:-4]]
        bpy.ops.object.select_all(action='DESELECT')

        # Select all imported objects
        for obj_file in imported_obj_files:
            bpy.data.objects[obj_file[:-4]].select_set(True)

        # Delete selected objects
        bpy.ops.object.delete()