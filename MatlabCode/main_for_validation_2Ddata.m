% This function is used to sample 2D layers (raw and mask) from 3D volume
% to train 2D layer-based network
close all; clear;
data_name = '181215plc1p1';
raw_volume_folder = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\181215plc1p1\raw');
mask_volume_folder = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\181215plc1p1\mask');

save2D_raw_folder = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data2D', data_name, 'training\raw');
save2D_mask_folder = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data2D', data_name, 'training\mask');
if isfolder(save2D_raw_folder)
    rmdir(save2D_raw_folder, 's');
    mkdir(save2D_raw_folder);
else
    mkdir(save2D_raw_folder)
end
if isfolder(save2D_mask_folder)
    rmdir(save2D_mask_folder, 's')
    mkdir(save2D_mask_folder);
else
    mkdir(save2D_mask_folder)
end

all_3D_raws = dir(fullfile(raw_volume_folder, '*.nii'));

f = waitbar(0, 'Please wait...');
for file_index = 1:length(all_3D_raws)
    raw_file = all_3D_raws(file_index).name;
    if length(raw_file) < 3
        continue
    end
    [~, base_name, extension] = fileparts(raw_file);
    mask_name = fullfile(mask_volume_folder ,strcat(base_name, 's.nii'));
    raw_name = fullfile(raw_volume_folder, raw_file);
    
    % find slices where mask exists
    raw_data = load_nii(raw_name);
    raw_data = raw_data.img;
    mask_data = load_nii(mask_name);
    mask_data = mask_data.img;
    
    slice_sum = squeeze(sum(sum(mask_data, 2), 1));
    target_slices = find(slice_sum);
    for slice = datasample(target_slices(5:end-5), 3)'
        raw_img = raw_data(:,:,slice);
        mask_img = mask_data(:,:,slice) * 255;
        save_raw_name = fullfile(save2D_raw_folder, strcat(data_name, base_name,...
            '_', num2str(slice), '.tif'));
        save_mask_name = fullfile(save2D_mask_folder, strcat(data_name, base_name,...
            '_', num2str(slice), '.tif'));
        imwrite(raw_img, save_raw_name);
        imwrite(mask_img, save_mask_name);
    end
    
    waitbar(file_index/length(all_3D_raws), f);
end

close(f);
