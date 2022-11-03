clc; clear; close all
%% This programe is used to evaluate 3DMMS algorithm

%%  results folder
data_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
for j = 1:length(data_names)
    data_name = data_names{j};
    save_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew');
    gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'CellProcessed');
    map_folder = fullfile(save_folder, data_name, 'ResultProcessed');
    bin_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew', data_name, '\ResultProcessed');

    DICES = [];
    cell_num = [];
    FP_cells = [];
    gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
    map_names = dir(fullfile(map_folder, '*.nii.gz'));
    bin_names =  dir(fullfile(bin_folder, '*.nii.gz'));
    for i = 1 : length(gt_names)
        gt_name = gt_names(i);
        map_name = map_names(i);
        bin_name = bin_names(i);
        %  load data
        gt_file = fullfile(gt_folder, gt_name.name);
        map_file = fullfile(map_folder, map_name.name);
        bin_file = fullfile(bin_folder, bin_name.name);
        GT = load_nii(gt_file);
        map_data = load_nii(map_file);
        bin_data = load_nii(bin_file);
        GT = GT.img;
        map_data = map_data.img;
        bin_data = bin_data.img;

        %  Calculate dice ratio with thin membrane
        [cell_dices, FP_cell] = calculate_cell_dice(GT, map_data);
        bin_ratio = calculate_dice(GT, bin_data);

        %  Combine results
        DICES = [DICES, cell_dices]; %, bin_ratio];
        cell_num = [cell_num, length(unique(GT)) - 1];
        FP_cells = [FP_cells, FP_cell];
    end

    save_name = fullfile(save_folder, strcat(data_name, '_IoU_F1.mat'));
    save(save_name, 'DICES', 'cell_num', 'FP_cells')

end


%% combine F1 results
thresholds = 0.5:0.05:0.95;
% folders = {"C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result", ...
%     "C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults", ...
%     "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\Segmented", ...
%     "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\FusionNet\Segmented", ...
%     "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE\segmented",
%     ...
%     "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell2D",
%     "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell3D"
%     };
folders = {
    "C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\FusionNet\Segmented", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE\segmented", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell2D", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\CellProfiler\Segmented", ...
    "C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result"
};
F1_scores = [];
for t = thresholds
    F1s = [];
    for m = 1:length(folders)
        TP = [];
        FN = [];
        FP = [];
        for d = 1 : length(data_names)
            data_file = fullfile(folders{m}, strcat(data_names{d}, '_IoU_F1.mat'));
            load(data_file, "cell_num", "DICES", "FP_cells");
            TP = [TP, sum(DICES >t )];
            FN = [FN, sum(DICES <= t)];
            FP = [FP, sum(abs(FP_cells))];
        end
        F1 = 2 * TP / (2 * TP + FN + FP);
        F1s = [F1s, F1];
    end
    F1_scores = [F1_scores; F1s];
end
save("C:\Users\bcc\Desktop\MapNetEvaluation\overall_F1_scores.mat", "F1_scores", "thresholds");
