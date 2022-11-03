% directly use segmentation results (origin size to generate segmentation)

%This program is used to generate images used for manually segmentation.
%The raw image are dowmsample with ratio 0.5 at x-y plane. After isosample
%on z direction, the image stack is reduced by 0.8. The result image
%includeing:
%[raw membrane image,nuclei information, automatically segmentation reference]

%% 
clc; clear;

%% data path 
embryo_path = 'D:\ProjectCode\PresegmentationLabel\results\resultWithMerge\informationForMerge\181210plc1p3';
nuc_path = 'D:\ProjectCode\PresegmentationLabel\data\aceNuc\181210plc1p3\CD181210plc1p3.csv';
seg_path = 'D:\ProjectCode\PresegmentationLabel\results\resultWithMerge\informationForMerge\181210plc1p3';
save_memb_path = 'D:\ProjectData\dataSetLabel\toBeLabelled\181210plc1p3';

%% prepare folder
if ~isfolder(save_memb_path)
    mkdir(save_memb_path)
end

%% merge files
label_times = [24, 34, 44, 54, 64, 74, 84];
for t = label_times
    display(strcat('Processing T:', num2str(t), '....'));
    
    %% Get segmentation
    nL = 3-length(num2str(t));
    seg_file = fullfile(seg_path, strcat('T',repmat('0', 1,nL),num2str(t),'_infor.mat'));
    membSeg = load(seg_file, 'membSeg');
    membSeg = membSeg.membSeg;
    
    %% Get rawMembrane
    memb_file = fullfile(embryo_path, strcat('T',repmat('0', 1,nL),num2str(t),'_infor.mat'));
    memb_raw = load(memb_file, 'membStack0');
    memb_raw = memb_raw.membStack0;
    
    %% find nucleus
    nuc_file = nuc_path;
    [nucSeg0, ~] = getNuc(t, nuc_file, memb_raw);

    %get the seeds for watershed and Euclidean distance transformation from
    %nucleus stack images.
    SE = strel('sphere', 4);
    nucSeg = imdilate(nucSeg0, SE);
    nucSeeds = nucSeg > 0;
    memb_raw(nucSeeds) = 255;
    
    %% save membrane image
    memb_nii = make_nii(uint8(memb_raw), [1,1,1], [0,0,0], 2);
    save_file = fullfile(save_memb_path, strcat('membT', num2str(t), '.nii'));
    save_nii(memb_nii, save_file);
    
    %% save segmentation
    % uniform membrane segmentation label (begin from 1)
    labels = unique(membSeg(:));
    labels(labels == 0) = [];
    new_label = 1;
    for label = labels'
        membSeg(membSeg == label) = new_label;
        new_label = new_label + 1;
    end
    
    seg_nii = make_nii(membSeg, [1,1,1],[0,0,0], 4);  %512---uint16
    save_file = fullfile(save_memb_path, strcat('membT', num2str(t), 's.nii'));
    save_nii(seg_nii, save_file)
end

