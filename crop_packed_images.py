import os

from utils.data_io import nib_save, nib_load


def crop_packed_4d_images():
    # num_slice = 30,
    embryo_names = {
                       # 'uncompressedEMB0102': ['uncompressedEMB01', 'uncompressedEMB02'],
                       'uncompressedEMB0304': ['uncompressedEMB03', 'uncompressedEMB04'],
                       'uncompressedEMB0607': ['uncompressedEMB06', 'uncompressedEMB07']
                   }
    max_times = {
                    # 185,
        'uncompressedEMB0304':185,
        'uncompressedEMB0607': 180,
    }
    cropping_yx={
        'uncompressedEMB03':[192,376,26,326],
        'uncompressedEMB04': [114,426,306,506],
        'uncompressedEMB06': [192,436,166,426],
        'uncompressedEMB07': [56,280,97,371],

    }
    # =================================================

    operating_folder = r"E:\ProjectData\MembraneProject\AllRawDataPacked"

    for whole_image_name, m_embryo_names in embryo_names.items():
        for tp in range(1, max_times[whole_image_name] + 1):
            original_raw_nuclei_image_path = os.path.join(operating_folder, whole_image_name, 'RawNuc',
                                                          '{}_{}_rawNuc.nii.gz'.format(whole_image_name,
                                                                                       str(tp).zfill(3)))
            original_annotated_nuclei_image_path = os.path.join(operating_folder, whole_image_name, 'AnnotatedNuc',
                                                                '{}_{}_annotatedNuc.nii.gz'.format(whole_image_name,
                                                                                                   str(tp).zfill(3)))

            origianl_raw_nuc=nib_load(original_raw_nuclei_image_path)
            origianl_annotated_nuc=nib_load(original_annotated_nuclei_image_path)

            for embryo_name in m_embryo_names:
                y0,y1,x0,x1=cropping_yx[embryo_name]
                cropped_raw_nuclei=origianl_raw_nuc[x0:x1,y0:y1,:]
                cropped_annotated_nuclei=origianl_annotated_nuc[x0:x1,y0:y1,:]

                cropped_raw_nuclei_image_path=os.path.join(operating_folder,embryo_name,'RawNuc','{}_{}_rawNuc.nii.gz'.format(embryo_name,str(tp).zfill(3)))
                cropped_annotated_nuclei_image_path=os.path.join(operating_folder,embryo_name,'AnnotatedNuc','{}_{}_annotatedNuc.nii.gz'.format(embryo_name,str(tp).zfill(3)))

                nib_save(cropped_raw_nuclei,cropped_raw_nuclei_image_path)
                nib_save(cropped_annotated_nuclei,cropped_annotated_nuclei_image_path)

if __name__ == "__main__":

    crop_packed_4d_images()
