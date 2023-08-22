# ImagesPrepocessor
Pre-process the tiff images of membrane channel to NTFI {embryo_name}_{tp}.nii.gz (medical 3D MRT image).

## compact the 2D tiff image to 3D NTFT MRT file *.nii.gz.
* function **stack_memb_slices** in file **compose_slice.py**
    * using skimage.transform.resize: spline interpolation (z axis)
* according to their ratio of xy_resolution and z_resolution 


## conduct some traditional methods to enhance the images
* like 3DMNS density map

## transform 3D NTfTI MRT file *.nii.gz to 3D TIFF FILES
* Run 3D_format_transformation.py
* Add samples in list of embryo_names
* Run  def nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True)
* Seg_cell_root is input path and tiff_root is output path
* Input path contains floders of nii.gz files
* Output path contains .tiff floders and tiffmaptxt floders.
