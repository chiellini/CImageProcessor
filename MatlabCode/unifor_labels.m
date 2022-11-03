%% This program is used to unify labels in ground truth and segmentation results

clc; clear all; close all

% load ground truth
data_names = {"170704plc1p2", "181210plc1p3", "190314plc1p3"};
for j = 1:length(data_names)
    data_name = data_names{j};
    gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name,'CellProcessed');
    seg_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew', data_name);
    save_folder = fullfile(seg_folder, 'ResultProcessed');
    if ~isfolder(save_folder)
        mkdir(save_folder)
    end

    gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
    seg_names = dir(fullfile(seg_folder, '*.nii.gz'));
    for i = 1 : length(gt_names)
        gt_name = gt_names(i);
        seg_name = seg_names(i);
        gt_file = fullfile(gt_folder, gt_name.name);
        seg_file = fullfile(seg_folder, seg_name.name);
        GT = niftiread(gt_file);
        DMMS = niftiread(seg_file);
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

        save_file = fullfile(save_folder, gt_name.name);
        niftiwrite(uni_DMMS, save_file, 'Compressed',true)
    end
end