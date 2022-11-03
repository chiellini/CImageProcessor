clc; clear; close all
%% This programe is used to calculate the precision and recall
get_sample = true;
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

            splits = [];
            merges = [];
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
                [split_ratio, merge_ratio] = get_split_merge(GT, map_data);
                
                %  Combine results
                splits = [splits; split_ratio];
                merges = [merges; merge_ratio];
                
            end
            
            
            save_name = fullfile(save_folder, strcat(data_name, '_split_merge.mat'));
            save(save_name, 'splits', "merges")

        end
    end
end
    
if get_summary
    %% combine F1 results
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
    split_criterios = [];
    merge_criterios = [];
    for m = 1:length(folders)
        split_criterio = [];
        merge_criterio = [];
        for d = 1 : length(data_names)
            data_file = fullfile(folders{m}, strcat(data_names{d}, '_split_merge.mat'));
            load(data_file, 'splits', 'merges');
            split_criterio = [split_criterio, mean(splits)];
            merge_criterio = [merge_criterio, mean(merges)];
        end
        split_criterio = mean(split_criterio);
        merge_criterio = mean(merge_criterio);
        split_criterios = [split_criterios; split_criterio];
        merge_criterios = [merge_criterios; merge_criterio];
    end
end
save(fullfile("C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result", "overall_split_merge.mat"), "split_criterios", "merge_criterios");

display("Split:\n")
display(split_criterios)
display("Merge:\n")
display(merge_criterios)


