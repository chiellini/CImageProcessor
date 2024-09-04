# ImagesPrepocessor
A lot of biomedical image processing python scripts, like pre-process the tiff images of membrane channel to NTFI {embryo_name}_{tp}.nii.gz (medical 3D MRT image).
## The following Papers/Projects Used this Repository, and Please Cite Them if You Use Our Tools and Data
* Paper Tile: Cell lineage-resolved embryonic morphological map reveals novel signaling regulating cell fate and size asymmetry; Website: https://bcc.ee.cityu.edu.hk/cmos/index.html ; Code Link: https://github.com/cao13jf/CMap and https://github.com/chiellini/GUIData ; Related Data Link: https://figshare.com/s/fc9b67e91a38eea86bee .
* Paper Title: Deep Learning-based Enhancement of Fluorescence Labeling for Accurate Cell Lineage Tracing During Embryogenesis; Code Link: https://github.com/plcx/NucApp-develop ; Related Data Link: https://doi.org/10.6084/m9.figshare.26778475.v1 .
* Paper Title: EmbSAM: Cell boundary localization and Segment Anything Model for 3D fast-growing embryos; Website: https://bcc.ee.cityu.edu.hk/cmos/embsam/ ; Code Link: https://github.com/CunminZhao/EmbSAM; Related Data Link: https://portland-my.sharepoint.com/:f:/g/personal/zelinli6-c_my_cityu_edu_hk/Epj5LhqViNZCmNtmRZrE2D8BvvGTr09Jg9u9aFBstL-3cg .
## Compact the 2D tiff image to 3D NTFT MRT file *.nii.gz.
* Function **stack_memb_slices** in file **compose_slice.py**
    * Using skimage.transform.resize: spline interpolation (z axis)
* According to their ratio of xy_resolution and z_resolution 


## Conduct some traditional methods to enhance the images
* Like 3DMNS density map

## Transform 3D NTfTI MRT file *.nii.gz to 3D TIFF FILES
* Open file "image2d3d_format_transformation.py"
* Add all embryos in list of embryo_names.
* Run function "nifti2tiff_seperated(seg_cell_root, tiff_root, segmented=True)"
* Seg_cell_root is input path and tiff_root is output path
* Input path contains floders(samples) of nii.gz files
* Output path contains .tiff floders and tiffmaptxt floders.

  ![QQ截图20230824103857](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/dd1e9241-5215-4fe0-a43d-2de2e465910e)



## Transform 3D TIFF FILES to .obj FILES by ImageJ
* Modify draw3DObject.ijm
* Modify tiff_input path  which is output path contains .tiff floders and tiffmaptxt floders by 3D_format_transformation.py. and obj_output path in .ijm. Add embryos in embryonames_list.
   ![QQ截图20230824104248](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/c2ba0a83-5142-4d68-8988-91c02988908f)

* Open ImageJ click Plugions, Macros, Run and add draw3DObject.ijm.
  ![QQ截图20230824110956](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/7ee9aaea-ceb9-45f9-926e-5cf353305d42)

  
## Solve imageJ crash
* Run get_index.ijm and save log as txt.
  <img width="1082" alt="截屏2023-08-25 下午3 36 59" src="https://github.com/chiellini/ImagesPrepocessor/assets/52396207/35e57067-4459-405c-8fae-f6b3b07615ee">

* Find last output obj files and find its index.
* Because there are serval obj files in a index. Log has information to remapping it.
* Modify start index "i" in second for loop in draw3DObject.ijm.
  ![QQ截图20230825154510](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/3233036b-bcf6-4ee1-99e1-9e03a4939fb3)

* ImageJ can continue generating obj after last time.

## Combine the Seperated Objs into one and assign the cell Name
* run file "generate_obj_from_seperated_objs.py"
 
## Obj view in ImageJ
   ![QQ截图20230823170900](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/bc13599d-6638-4140-be28-6cab9f517b0d)

## File structure
   ![QQ截图20230824115042](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/2b5bbaef-bcb9-4b14-9b93-7f3af6e02816)






   


  

