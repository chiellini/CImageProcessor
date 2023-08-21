import nibabel

import numpy as np
path=r'C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Desktop\200113plc1p2_015_segNuc.nii.gz'
data=nibabel.load(path).get_fdata()

print(np.unique(data,return_counts=True))
