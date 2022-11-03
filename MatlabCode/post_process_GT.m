

%% This program is used to postprocess ground truth to filter lister noise
% spots.
clc; clear all;
seg_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw\190314plc1p3\cells';
[file_path, ~, ~] = fileparts(seg_folder);
save_file = fullfile(file_path, 'CellProcessed');
if ~isfolder(save_file)
    mkdir(save_file)
end
all_names = dir(fullfile(seg_folder, '*.nii'));
for i = 1 : length(all_names)
    one_name = all_names(i);
    gt_name = fullfile(seg_folder, one_name.name);
    load_file = fullfile(gt_name);
    ground_truth = load_nii(load_file);
    ground_truth = ground_truth.img;

    close_ground_truth = ground_truth;
    labels = unique(ground_truth(:));
    labels(labels == 0) = [];
    SE = strel('sphere', 3);
    for label = labels'
        tem = ground_truth == label;
        close_ground_truth(tem) = 0;
        close_tem = imclose(tem, SE);
        close_ground_truth(close_tem) = label;
    end

    seg_nii = make_nii(close_ground_truth, [1,1,1],[0,0,0], 4);  %512---uint16
    save_name = fullfile(save_file, one_name.name);
    save_nii(seg_nii, save_name)
    display(strcat('Finished --', one_name.name))
    
end
