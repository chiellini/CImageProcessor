clc; clear; close all
%% This programe is used to calculate the precision and recall
get_sample = false;
get_summary = true;
save_folders = {
    "C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUNetNew", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\FusionNet\Segmented", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE\segmented", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell2D", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\CellProfiler\Segmented", ...
        "C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result"
    };
data_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};

if get_sample
    for k = 1 : length(save_folders)
        save_folder = save_folders{k};
        %%  results folder
        for j = 1:length(data_names)
            data_name = data_names{j};
            gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'CellProcessed');
            map_folder = fullfile(save_folder, data_name, 'ResultProcessed');
            display(map_folder)

            cell_IoUs = [];
            cell_nums = [];
            label_FPs = [];
            label_FNs = [];
            gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
            map_names = dir(fullfile(map_folder, '*.nii.gz'));
            for i = 1 : length(gt_names)
                gt_name = gt_names(i);
                map_name = map_names(i);
                %  load data
                gt_file = fullfile(gt_folder, gt_name.name);
                map_file = fullfile(map_folder, map_name.name);
                GT = uint16(niftiread(gt_file));
                map_data = uint16(niftiread(map_file));

                %  Calculate dice ratio with thin membrane
                [cell_IoU, cell_num, cell_FN, cell_FP] = calculate_cell_IoU(GT, map_data);

                %  Combine results
                cell_IoUs = [cell_IoUs, cell_IoU]; 
                cell_nums = [cell_nums, cell_num];
                label_FPs = [label_FPs, cell_FP];
                label_FNs = [label_FNs, cell_FN];
            end

            save_name = fullfile(save_folder, strcat(data_name, '_IoU_Precision_Recall.mat'));
            save(save_name, 'cell_IoUs', 'cell_nums', 'label_FPs', 'label_FNs')

        end
    end
end
    
if get_summary
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
    precisions = [];
    recalls = [];
    for m = 1:length(folders)
        for threshold = 0.7  % thresholds
            precision = [];
            recall = [];
            for d = 1 : length(data_names)
                data_file = fullfile(folders{m}, strcat(data_names{d}, '_IoU_Precision_Recall.mat'));
                load(data_file, 'cell_IoUs', 'cell_nums', 'label_FPs', 'label_FNs');
                TP = sum(cell_IoUs > threshold);
                % FN = length(cell_IoUs);
                FP = sum(cell_IoUs <= threshold);
                precision = [precision, TP * 1.0 / (TP + FP)];
                recall = [recall, TP * 1.0 / (length(cell_IoUs) + sum(label_FNs))];
            end
            precision = mean(precision);
            recall = mean(recall);
        end
        precisions = [precisions; precision];
        recalls = [recalls; recall];
    end
end
save(fullfile("C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result", "over_PR_curve.mat"), "precision", "recall", "threshold");

display("Precision:\n")
display(precisions)
display("recalls\n")
display(recalls)


