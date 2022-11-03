clc; clear;

%% add just image contrast
% image_file_high = "D:\ProjectData\NewStrainRawData\191022plc1pop1ip2\tifR\191022plc1pop1ip2_L1-t001-p20.tif";
% image_file_low = "D:\ProjectData\NewStrainRawData\191022plc1pop1ip2\tifR\191022plc1pop1ip2_L1-t180-p23.tif";
% im =  imread(image_file_low);
% im_contrast = imadjust(im, [0, 0.9]);
% imshow(im)
% figure;
% imshow(im_contrast)

%% combine slices to volume (0.09, 0.42) --> (0.36, 0.36) || (128, 178, 80)
embryo_folder = "D:\ProjectData\NewStrainRawData\200113plc1p2";
save_folder = "D:\ProjectData\AllDataPacked";

TPs = 278;
slices = 92;
target_size = [192, 256, 160];

[~, embryo_name, ~] = fileparts(embryo_folder);
nucleus_folder = fullfile(embryo_folder, "tif");
membrane_folder = fullfile(embryo_folder, "tifR");
for tp = 1 : TPs
    membrane = [];
    nucleus = [];
    for slice = 1 : slices
        nucleus_file = fullfile(nucleus_folder, "_L1-t", num2str(tp, '%03d'), "-p", num2str(slice, "%02d"), '.tif');
        membrane_file = fullfile(membrane_folder, "_L1-t", num2str(tp, '%03d'), "-p", num2str(slice, "%02d"), '.tif');
        nucleus_im = imread(nucleus_file);
        membrane_im = imread(membrane_file);
        membrane_im = imadjust(membrane_im, [0.1, 0.95]);
        membrane = cat(3, membrane_im, membrane);
        nucleus = cat(3, nucleus_im, nucleus);
    end
    membrane = imresize3(membrane, target_size);
    nucleus = imresize3(nucleus, target_size); %"181210plc1p2_T1_rawMemb.nii.gz"
    
    niftiwrite(membrane, fullfile(save_folder, embryo_name, "RawMemb", strcat(embryo_name, "_T",num2str(tp, "%03d"), "_rawMemb.nii")), "Compressed", true)
    niftiwrite(nucleus, fullfile(save_folder, embryo_name, "RawNuc", strcat(embryo_name, "_T",num2str(tp, "%03d"), "_rawNuc.nii")), "Compressed", true)
    
end
