clc; clear; close all
%% This programe is used to evaluate 3DMMS algorithm

%  results folder
data_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
for j = 1:length(data_names)
    data_name = data_names{j};
    save_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew');
    gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'CellProcessed');
    map_folder = fullfile(save_folder, data_name, 'ResultProcessed');
%     bin_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults', data_name, '\ResultProcessed');

    DICES = [];
    cell_num = [];
    gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
    map_names = dir(fullfile(map_folder, '*.nii.gz'));
%     bin_names =  dir(fullfile(bin_folder, '*.nii.gz'));
    for i = 1 : length(gt_names)
        gt_name = gt_names(i);
        map_name = map_names(i);
%         bin_name = bin_names(i);
        %%  load data
        gt_file = fullfile(gt_folder, gt_name.name);
        map_file = fullfile(map_folder, map_name.name);
%         bin_file = fullfile(bin_folder, bin_name.name);
        GT = load_nii(gt_file);
        map_data = load_nii(map_file);
%         bin_data = load_nii(bin_file);
        GT = GT.img;
        map_data = map_data.img;
%         bin_data = bin_data.img;

        %%  Calculate dice ratio with thin membrane
        map_ratio = calculate_dice(GT, map_data);
%         bin_ratio = calculate_dice(GT, bin_data);

        %%  Combine results
        DICES = [DICES; map_ratio]; %, bin_ratio];
        cell_num = [cell_num; length(unique(GT)) - 1];
        fprintf('%s, precision: %5.4f, %5.4f\n', gt_file, map_ratio)
    end

    save_name = fullfile(save_folder, strcat(data_name, '.mat'));
    save(save_name, 'DICES', 'cell_num')

end
