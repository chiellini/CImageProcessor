
%% save *.nii images as *.tig images
% embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
% raw_folder0 = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw';
% save_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Template\RawTif';
% 
% for i = 1:length(embryo_names)
%     embryo_name = embryo_names{i};
%     raw_folder = fullfile(raw_folder0, embryo_name, 'nucleus');
%     raw_files = dir(fullfile(raw_folder, '*.nii'));
%     for j = 1:length(raw_files)
%         raw_file = raw_files(j);
%         file_name = fullfile(raw_folder, raw_file.name);
%         [~, base_name, ~] = fileparts(file_name);
%         raw_data = load_nii(file_name);
%         raw_data = raw_data.img;
%         save_file = fullfile(save_folder, embryo_name, 'nucleus', strcat(base_name, '.tif'));
%         options.overwrite = true;
% %         raw_data = imresize3(raw_data, 0.5);  % scale for computation
% %         raw_data = bwlabeln(raw_data);
%         saveastiff(uint8(raw_data), save_file, options);
%         display(save_file)
%     end
% end


%% save nucleus stacks for other methods
% clc; clear;
% 
% % data path 
% data_name = '190314plc1p3';
% nuc_path = fullfile('D:\ProjectCode\PresegmentationLabel\data\aceNuc', ...
%     data_name, strcat('CD', data_name, '.csv'));
% embryo_path = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'raw');
% save_nuc_path = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'nucleus');
% 
% 
% % prepare folder
% if ~isfolder(save_nuc_path)
%     mkdir(save_nuc_path)
% end
% 
% % merge files
% label_times = [24, 34, 44, 54, 64, 74, 84];
% for t = label_times
%     display(strcat('Processing T:', num2str(t), '....'));
%     
%     % Get rawMembrane
%     memb_file = fullfile(embryo_path, strcat('membT',num2str(t),'.nii'));
%     memb_raw = load_nii(memb_file);
%     memb_raw = memb_raw.img;
%     
%     % find nucleus
%     nuc_file = nuc_path;
%     [nucSeg0, ~] = getNuc(t, data_name, nuc_file, memb_raw);
% 
%     %get the seeds for watershed and Euclidean distance transformation from
%     %nucleus stack images.
%     SE = strel('sphere', 4);
%     nucSeg = imdilate(nucSeg0, SE);
%     nucSeeds = nucSeg > 0;
%     memb_raw(nucSeeds) = 255;
%     
%     %% save nucleus stacks for other methods
%     seg_nii = make_nii(uint8(nucSeeds)*255, [1,1,1],[0,0,0], 2);  %512---uint16
%     save_file = fullfile(save_nuc_path, strcat('membT', num2str(t), 'n.nii'));
%     save_nii(seg_nii, save_file)
%     
% end

%% build file for RACE
% times = 24:10:84;
% embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
% root_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE';
% for i = 1:length(embryo_names)
%     for time = times
%         folder_name = fullfile(root_folder, embryo_names{i}, strcat('T', num2str(time)));
%         if ~exist(folder_name, 'dir')
%             mkdir(folder_name)
%         else
%             rmdir(folder_name)
%             mkdir(folder_name)
%         end
%     end
% end


%% deal with reaults from RACE
clc; clear;close all;
RACE_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE';
embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
times = 24:10:84;
for i = 1:length(embryo_names)
    embryo_name = embryo_names{i};
    for t = times
        file_name = fullfile(RACE_folder, embryo_name, strcat('T', num2str(t)),...
            'item_0022_SliceBySliceFusionFilter', strcat('membT', num2str(t),...
            '_SliceBySliceFusionFilter_Out1.tif'));
        seg = loadtiff(file_name);
        save_folder = fullfile(RACE_folder, 'nii',embryo_name);
        if ~exist(save_folder, 'dir')
            mkdir(save_folder);
        end
        
        seg_nii = make_nii(uint16(seg), [1,1,1],[0,0,0], 512);  %512---uint16
        save_nii(seg_nii, fullfile(save_folder, strcat('membT', num2str(t), '.nii.gz')));
        
    end
end


