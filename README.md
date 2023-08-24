# ImagesPrepocessor
Pre-process the tiff images of membrane channel to NTFI {embryo_name}_{tp}.nii.gz (medical 3D MRT image).

## Compact the 2D tiff image to 3D NTFT MRT file *.nii.gz.
* Function **stack_memb_slices** in file **compose_slice.py**
    * Using skimage.transform.resize: spline interpolation (z axis)
* According to their ratio of xy_resolution and z_resolution 


## Conduct some traditional methods to enhance the images
* Like 3DMNS density map

## Transform 3D NTfTI MRT file *.nii.gz to 3D TIFF FILES
* Run 3D_format_transformation.py
* Add all embryos in list of embryo_names.
* Run nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True)
* Seg_cell_root is input path and tiff_root is output path
* Input path contains floders(samples) of nii.gz files
* Output path contains .tiff floders and tiffmaptxt floders.

![QQ截图20230824103857](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/dd1e9241-5215-4fe0-a43d-2de2e465910e)



## Transform 3D TIFF FILES to .obj FILES by Fiji
* Modify draw3DObject.ijm
* Modify tiff_input path  which is output path contains .tiff floders and tiffmaptxt floders by 3D_format_transformation.py. and obj_output path in .ijm. Add embryos in embryonames_list.
   ![QQ截图20230824104248](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/c2ba0a83-5142-4d68-8988-91c02988908f)

* It takes a long time to generate obj files in each embryo. Set screen mode in system to avoid breaking generation. 
  ![QQ截图20230824105638](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/bc122013-48a4-405c-8737-67af34784937)
  
* Open ImageJ click Plugions, Macros, Run and add draw3DObject.ijm.
  ![QQ截图20230824110956](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/7ee9aaea-ceb9-45f9-926e-5cf353305d42)



   


  

