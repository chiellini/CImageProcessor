%% Used for preparing PANS data for segmentation in MapNet
% clc; clear; close all;
% raw_data_folder = 'D:\ProjectData\PNASPlant\PNAS\plant1\processed_tiffs';
% seg_data_folder = 'D:\ProjectData\PNASPlant\PNAS\plant1\segmentation_tiffs';
% save_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData';
% 
% times = [0:4:76];
% all_raw_files = dir(fullfile(raw_data_folder, '*acylYFP.tif'));
% all_seg_files = dir(fullfile(seg_data_folder, '*.tif'));
% 
% for i = 1 : length(all_seg_files)
%     raw_file = fullfile(raw_data_folder, all_raw_files(i).name);
%     seg_file = fullfile(seg_data_folder, all_seg_files(i).name);
%     [~, raw_name, ~] = fileparts(raw_file);
%     [~, seg_name, ~] = fileparts(seg_file);
%     raw_data = loadtiff(raw_file);
%     seg_data = loadtiff(seg_file);
%     memb = pans_get_memb_from_cell(seg_data);
%     
%     % expend raw_file for MapNet
%     [sr, sc, sz] = size(raw_data);
%     extend_part = zeros(sr, sc, 10);
%     extend_raw = cat(3, extend_part, raw_data);
%     
%     % save file
%     raw_nii = make_nii(raw_data, [1,1,1],[0,0,0], 2);  %512---uint16
%     save_file = fullfile(save_folder, 'Raw', strcat(raw_name, '.nii.gz'));
%     save_nii(raw_nii, save_file)
%     seg_nii = make_nii(seg_data, [1,1,1],[0,0,0], 512);  %512---uint16
%     save_file = fullfile(save_folder, 'PansResult', strcat(seg_name, '.nii.gz'));
%     save_nii(seg_nii, save_file)
%     mask_nii = make_nii(uint8(memb), [1,1,1],[0,0,0], 2);  %512---uint16
%     save_file = fullfile(save_folder, 'mask', strcat(seg_name, '.nii.gz'));
%     save_nii(mask_nii, save_file)
%     raw_extend_nii = make_nii(extend_raw, [1,1,1],[0,0,0], 2);  %512---uint16
%     save_file = fullfile(save_folder, 'RawExtend', strcat('pad_', raw_name, '.nii.gz'));
%     save_nii(raw_extend_nii, save_file)
%     display(strcat('Finished  ', raw_name))
% end   
    

%% uniform Pans and MapNet segmentation labels
clc; clear all; close all

% load ground truth
gt_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\PansResult';
seg_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\MapNetResult\ResultRawWithBotton';
save_folder = fullfile(seg_folder, 'ResultProcessed');
if ~isfolder(save_folder)
    mkdir(save_folder)
end

data_names = [24:4:56, 64:4:76];

parfor i = 1 : length(data_names)
    j = data_names(i);
    seg_name = strcat(num2str(j),'hrs_plant1_trim-acylYFPCellwithMmeb.nii.gz');
    gt_name = strcat(num2str(j), 'hrs_plant1_trim-acylYFP_hmin_2_asf_1_s_2.00_clean_3.nii.gz');
    gt_file = fullfile(gt_folder, gt_name);
    seg_file = fullfile(seg_folder, seg_name);
    

    GT = load_nii(gt_file);
    DMMS = load_nii(seg_file);
    GT = GT.img;
    mode_label = mode(GT);
    GT(GT == mode_label) = 0;
    DMMS = DMMS.img;
    %DMMS = DMMS(:, :, 11:end);
    labels = unique(GT(:));
    labels(labels == 0)= [];
    uni_DMMS = zeros(size(DMMS));
    tem_DMMS = DMMS;
    for label = labels'
        cell_mask = GT == label;
        label_in_race = tem_DMMS(cell_mask);
        label_in_race(label_in_race == 0) = [];
        if isempty(label_in_race)
            continue;
        elseif sum(GT == label, 'all') > 5 * length(label_in_race(:))
            continue;
        end
        mode_label = mode(label_in_race(:));
        uni_DMMS(tem_DMMS == mode_label) = label;
        tem_DMMS(tem_DMMS == mode_label) = 0;
    end

    other_labels = DMMS;
    other_labels(uni_DMMS~=0) = 0; 
    others = unique(other_labels(:));
    others(others==0) = [];
    if ~isempty(others)
        largest_label = max(labels);
        for add_label = others'
            largest_label = largest_label + 1;
            uni_DMMS(DMMS==add_label) = largest_label;
        end
    end

    display(gt_file);
    fprintf('#labels in original RESULT: %d\n', length(unique(DMMS(:))) - 1 );
    fprintf('#labels in unified RESULT: %d\n', length(unique(uni_DMMS(:))) - 1);
    fprintf('#labels in GT: %d\n', length(labels));


%     seg_nii = make_nii(GT, [1,1,1],[0,0,0], 512);  %512---uint16
%     save_file = fullfile(gt_folder, 'ResultRaw', gt_name);
%     save_nii(seg_nii, save_file)
%     
%     seg_nii = make_nii(DMMS, [1,1,1],[0,0,0], 512);  %512---uint16
%     save_file = fullfile(seg_folder, 'ResultRaw', seg_name);
%     save_nii(seg_nii, save_file)
    
    seg_nii = make_nii(uni_DMMS, [1,1,1],[0,0,0], 512);  %512---uint16
    save_file = fullfile(save_folder, seg_name);
    save_nii(seg_nii, save_file)
    
%     button_labels1 = unique(GT(:, :, 1:2));
%     button_labels2 = unique(GT(:, 1:2, :));
%     button_labels3 = unique(GT(1:2, :, :));
%     button_labels4 = unique(GT(:, :, end-1:end));
%     button_labels5 = unique(GT(:, end-1:end, :));
%     button_labels6 = unique(GT(end-1:end, :, :));
%     for label = [button_labels1; button_labels2; button_labels3; button_labels4; button_labels5; button_labels6]'
%         GT(GT == label) = 0;
%     end
    
%     seg_nii = make_nii(GT, [1,1,1],[0,0,0], 512);  %512---uint16
%     save_file = fullfile(gt_folder, 'ResultProcessed', gt_name);
%     save_nii(seg_nii, save_file)
end
    
%% the difference between Pans and DMapNet
% % DMapNet
% clc;
% 
% MARS_nii = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\PansResult\ResultProcessed\52hrs_plant1_trim-acylYFP_hmin_2_asf_1_s_2.00_clean_3.nii.gz';
% DMap_nii = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\MapNetResult\ResultProcessed\52hrs_plant1_trim-acylYFPCellwithMmeb.nii.gz';
% save_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData';
% % load imae
% MARS_seg = load_nii(MARS_nii);
% DMap_seg = load_nii(DMap_nii);
% MARS_seg = MARS_seg.img;
% DMap_seg = DMap_seg.img;
% 
% % delete cells the boundary
% [sr, sc, sz] = size(DMap_seg);
% boundary_mask = zeros([sr, sc, sz]);
% boundary_mask(1:2, :, :) = 1; boundary_mask(:, 1:2, :) = 1; boundary_mask(:, :, 1:2) = 1;
% boundary_mask(end-1:end, :, :) = 1; boundary_mask(:, end-1:end, :) =1; boundary_mask(:, :, end-1:end);
% 
% boundary_labels = DMap_seg(boundary_mask == 1);
% boundary_labels = unique(boundary_labels);
% boundary_labels(boundary_labels==0) = [];
% if length(boundary_labels) > 0
%     for label = boundary_labels'
%         DMap_seg(DMap_seg == label) = 0;
%     end
% end
% difference = zeros([sr, sc, sz]);
% difference(MARS_seg~=0) = 16;
% difference(MARS_seg ~= DMap_seg) = 1;
% difference(MARS_seg==0) = 0;
% difference(DMap_seg==0) = 0;
% 
% seg_nii = make_nii(uint8(difference), [1,1,1],[0,0,0], 2);  %512---uint16
% save_file = fullfile(save_folder, 'difference52h.nii.gz');
% save_nii(seg_nii, save_file)

    
