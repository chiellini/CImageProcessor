from PIL import Image
import numpy as np
# tif_path_raw=r'C:\Users\zelinli6\Downloads\StarryNite\Demo_4D_series\tif\081505_L1-t001-p18.tif'

tif_path_raw=r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33.tif'
tif_path_output=r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33-output.tif'

# pil_image_raw=Image.open(tif_path_raw)

# pil_array=Image.fromarray(np.asanyarray(pil_image_raw), mode="L")

# pil_array.save(r'C:\Users\zelinli6\Downloads\181210plc1p3_L1-t001-p33-output.tif',format='TIFF')

import json

import tifffile  # http://www.lfd.uci.edu/~gohlke/code/tifffile.py.html

image_raw_array=tifffile.imread(tif_path_raw)
options=dict(

)
tifffile.imwrite(tif_path_output,image_raw_array,


byteorder='>',
                 # bigtiff=True,
                 imagej=True,
                 # ome=True,
resolution=(10.981529,10.981529),
                     # 'info':{'compression':'raw'},
                           metadata={'size':(712,512),
                           'height':512,
                           'width':712,
                           'use_load_libtiff':False,
                           'tile':[('raw',(0,0,712,512),396,('L',0,1))]}


)

image_output=tifffile.TiffFile(tif_path_output)
image_raw=tifffile.TiffFile(tif_path_raw)

pil_image_raw=Image.open(tif_path_raw)

pil_image_output=Image.open(tif_path_output)
print('ararar')