import os
import random
from glob import glob

import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
from numba import jit
from scipy.ndimage import generate_binary_structure
from numba import cuda
from tqdm import tqdm
import time

# ====================================
# Concatnate the raw and gt image
# ====================================



# ===================================
# instance to binary boundary
# ===================================
def boundary_of_label_map(image_path, saved_path):
    image = np.array(Image.open(image_path))

    padded = np.pad(image, 3, mode='edge')

    border_pixels = np.logical_and(
        np.logical_and( image == padded[:-6, 3:-3], image == padded[6:, 3:-3] ),
        np.logical_and( image == padded[3:-3, :-6], image == padded[3:-3, 6:] )
        )

    # border_pixels = np.logical_not(border_pixels).astype(np.uint8)
    border_pixels = border_pixels.astype(np.uint8)
    border_pixels[image==0] = 0
    border_pixels1 = np.zeros_like(border_pixels)
    border_pixels1[border_pixels == 0] = 1

    im = Image.fromarray(border_pixels * 255)
    # im.show()
    im.save(saved_path, 'png')


if __name__ == '__main__':
    # image_path = '/home/duanbin/Downloads/experimental_projects/EM/trials/EM_Instance_Segmentation_pytorch/datasets/train/gt/FIB25/0108.png'
    #
    # coloring(image_path, 'test.png')
    root = r"D:\OneDriveBackup\OneDrive - City University of Hong Kong\Dataset\Nerve Segmentation\test\gt"
    log_path = './unfinished.log'
    for dst in ['CREMI_A', 'CREMI_B', 'CREMI_C', 'FIB25', 'SNEMI3D']:
    # for dst in ['SNEMI3D']:
        root_dst = os.path.join(root, dst)
        gt_list = sorted(glob(os.path.join(root_dst, '*.png')))
        saved_root_dst = root_dst.replace('gt', 'gt_boundary')
        if not os.path.exists(saved_root_dst):
            os.makedirs(saved_root_dst)

        for g in tqdm(gt_list):
            boundary_of_label_map(g, g.replace('gt', 'gt_boundary'))


