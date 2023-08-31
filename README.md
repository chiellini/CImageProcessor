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



## Transform 3D TIFF FILES to .obj FILES by ImageJ
* Modify draw3DObject.ijm
* Modify tiff_input path  which is output path contains .tiff floders and tiffmaptxt floders by 3D_format_transformation.py. and obj_output path in .ijm. Add embryos in embryonames_list.
   ![QQ截图20230824104248](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/c2ba0a83-5142-4d68-8988-91c02988908f)

* Open ImageJ click Plugions, Macros, Run and add draw3DObject.ijm.
  ![QQ截图20230824110956](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/7ee9aaea-ceb9-45f9-926e-5cf353305d42)

  
## Slove imageJ crash
* Run get_index.ijm and save log as txt.
  <img width="1082" alt="截屏2023-08-25 下午3 36 59" src="https://github.com/chiellini/ImagesPrepocessor/assets/52396207/35e57067-4459-405c-8fae-f6b3b07615ee">

* Find last output obj files and find its index.
* Because there are serval obj files in a index. Log has information to remapping it.
* Modify start index "i" in second for loop in draw3DObject.ijm.
  ![QQ截图20230825154510](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/3233036b-bcf6-4ee1-99e1-9e03a4939fb3)

* ImageJ can continue generating obj after last time.


## Obj view in ImageJ
   ![QQ截图20230823170900](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/bc13599d-6638-4140-be28-6cab9f517b0d)

## File structure
   ![QQ截图20230824115042](https://github.com/chiellini/ImagesPrepocessor/assets/52396207/2b5bbaef-bcb9-4b14-9b93-7f3af6e02816)




├── Input
│   ├── EmbryoFolder1
│   │   ├── File1.nii.gz
│   │   ├── File2.nii.gz
│   │   └── ...
│   ├── EmbryoFolder2
│   │   ├── File1.nii.gz
│   │   ├── File2.nii.gz
│   │   └── ...
│
├── Output
│   ├── EmbryoFolder1
│   │   ├── File1.tiff
│   │   ├── File2.tiff
│   │   └── ...
│   │    
│   ├── EmbryoFolder2
│   │   ├── File1.tiff
│   │   ├── File2.tiff
│   │   └── ...  
│   │   │  
│   │   │   
│   ├── tiffmaptxt
│   │   ├── EmbryoFolder01
│   │   │   ├── Embryo01_001_map.txt
│   │   │   ├── Embryo01_002_map.txt
│   │   │   └── ... 
│   │   │  
│   │   ├── EmbryoFolder02
│   │   │   ├── Embryo02_001_map.txt
│   │   │   ├── Embryo02_002_map.txt
│   │   │   └── ...
│   │   
│   └── ...
│
├── Embryo01_render_indexed.txt
├── Embryo02_render_indexed.txt
│
├── obj
│   ├── objEmbryo1
│   │   ├── objs
│   │ 
│   ├── objEmbryo2
│   │   ├── objs
│   │ 
└── ...

   


  

