import os

from utils.utils import check_folder


def read_map_file_as_dict(txt_file,max_middle_num):
    with open(txt_file) as f:
        lines = f.readlines()
    map_list= [line.strip() for line in lines]
    map_this={}
    for i in range(1,max_middle_num+1):

        map_this[i]={}
    for i in range(0,len(map_list),2):
        cell_label,middle_num,middle_label=map_list[i+1].split(':')
        map_this[int(middle_num)][middle_label]=[cell_label,map_list[i]]
    return map_this

def rename_objs(embryo_names,tps,max_middle_num,root,tiff_map_txt_path):

    for idx,embryo_name in enumerate(embryo_names):
        for tp in range(1,tps[idx]+1):
            map_path=os.path.join(tiff_map_txt_path,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_map.txt')
            map_dict=read_map_file_as_dict(map_path,max_middle_num)
            for middle_idx in range(1,max_middle_num+1):
                obj_file_path=os.path.join(root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell_'+str(middle_idx)+'.obj')
                if os.path.exists(obj_file_path):
                    with open(obj_file_path) as f:
                        lines = f.readlines()
                    with open(obj_file_path, 'w') as f:
                        for line in lines:
                            if line.startswith('g Smoothed'):
                                middle_label=line.split('_')[-1].split('\n')[0]
                                cell_label,cell_name=map_dict[middle_idx][middle_label]
                                print(embryo_name,tp,middle_idx,middle_label,cell_label,cell_name)
                                f.write('g '+ cell_name+'_'+cell_label+'\n')
                            else:
                                f.write(line)

def combine_objs(embryo_names,tps,max_middle_num,root,target_root):
    for idx,embryo_name in enumerate(embryo_names):
        for tp in range(1,tps[idx]+1):
            output_obj_path=os.path.join(target_root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell.obj')
            output_mtl_path=os.path.join(target_root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell.mtl')
            check_folder(output_obj_path)

            vertex_offset = 0
            vertex_offset_calculation=0

            with open(output_obj_path, 'w') as outfile:
                outfile.write('# OBJ File\n')
                outfile.write('mtllib {}_{}_segCell.mtl\n'.format(embryo_name,str(tp).zfill(3)))
                for middle_idx in range(1,max_middle_num+1):
                    obj_file_path=os.path.join(root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell_'+str(middle_idx)+'.obj')
                    if os.path.exists(obj_file_path):
                        with open(obj_file_path) as infile:
                            lines = infile.readlines()
                        for line in lines:
                            if line.startswith('# ') or line.startswith('mtllib '):
                                continue
                            elif line.startswith('f'):
                                indices = [float(i.split('/')[0]) for i in line.split()[1:]]
                                indices = [str(i + vertex_offset) for i in indices]
                                outfile.write('f ' + ' '.join(indices) + '\n')
                            elif line.startswith('v'):
                                outfile.write(line)
                                vertex_offset_calculation += 1
                            else:
                                outfile.write(line)
                        vertex_offset=vertex_offset_calculation
            with open(output_mtl_path, 'w') as outfile:
                outfile.write('# MTL File\n')
                outfile.write('\n')
                for middle_idx in range(1,max_middle_num+1):
                    mtl_file_path=os.path.join(root,embryo_name,embryo_name+'_'+str(tp).zfill(3)+'_segCell_'+str(middle_idx)+'.mtl')
                    if os.path.exists(mtl_file_path):
                        with open(mtl_file_path) as infile:
                            lines = infile.readlines()
                        for line in lines:
                            if line.startswith('# '):
                                continue
                            else:
                                outfile.write(line)