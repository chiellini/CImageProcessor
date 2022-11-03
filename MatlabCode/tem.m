
%% get average nucleus radius
% times = [24, 34, 54, 64, 74, 84];
% embryos = ["170704plc1p2", "181210plc1p3", "190314plc1p3"];
% embryo_folder = "C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result";
% radius = [];
% for i = 1:length(embryos)
%    for j = 1 : length(times)
%        embryo_file = fullfile(embryo_folder, embryos(i), "ResultProcessed", strcat("membt", num2str(times(j)), "CellwithMmeb.nii.gz"));
%        embryo_img = niftiread(embryo_file);
%        labels = unique(embryo_img);
%        labels(labels==0) = [];
%        [sr, sc, sz] = size(embryo_img);
%        for label = labels'
%             tem0 = zeros(sr, sc, sz);
%             tem0(embryo_img == label) = 1;
%             bwtem = bwdist(tem0);
%             radius = [radius, max(bwtem, [], "all")];
%        end
%    end
% end
% mean_radius = mean(radius) * 0.22


%% save nii as tif
% aa = niftiread("C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw\181210plc1p3\raw\181210plc1p3_084_rawMemb.nii.gz");
% target_file = "./181210plc1p2_82_raw.tif";
% target_size = size(aa);
% for slice = 1 : target_size(3)
%     imwrite(uint8(aa(:, :, slice)), target_file, 'WriteMode','append')
% end


%% unify the result label derived from varied train ratio results

% clc; clear all; close all
% 
% % load ground truth
% data_names = {"170704plc1p2", "181210plc1p3", "190314plc1p3"};
% train_ratio = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10"};
% for k = 1:length(train_ratio)
%     for j = 1:length(data_names)
%         data_name = data_names{j};
%         gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name,'CellProcessed');
%         seg_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\TrainRatio',...
%             strcat("TR", train_ratio{k}), strcat(data_name, train_ratio{k}));
%         save_folder = fullfile(seg_folder, 'ResultProcessed');
%         if ~isfolder(save_folder)
%             mkdir(save_folder)
%         end
% 
%         gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
%         seg_names = dir(fullfile(seg_folder, '*.nii.gz'));
%         for i = 1 : length(gt_names)
%             gt_name = gt_names(i);
%             seg_name = seg_names(i);
%             gt_file = fullfile(gt_folder, gt_name.name);
%             seg_file = fullfile(seg_folder, seg_name.name);
%             GT = niftiread(gt_file);
%             DMMS = niftiread(seg_file);
%             labels = unique(GT(:));
%             labels(labels == 0)= [];
%             uni_DMMS = zeros(size(DMMS));
%             tem_DMMS = DMMS;
%             for label = labels'
%                 cell_mask = GT == label;
%                 label_in_race = tem_DMMS(cell_mask);
%                 label_in_race(label_in_race == 0) = [];
%                 if isempty(label_in_race)
%                     continue;
%                 elseif sum(GT == label, 'all') > 5 * length(label_in_race(:))
%                     continue;
%                 end
%                 mode_label = mode(label_in_race(:));
%                 uni_DMMS(tem_DMMS == mode_label) = label;
%                 tem_DMMS(tem_DMMS == mode_label) = 0;
%             end
% 
%             other_labels = DMMS;
%             other_labels(uni_DMMS~=0) = 0; 
%             others = unique(other_labels(:));
%             others(others==0) = [];
%             if ~isempty(others)
%                 largest_label = max(labels);
%                 for add_label = others'
%                     largest_label = largest_label + 1;
%                     uni_DMMS(DMMS==add_label) = largest_label;
%                 end
%             end
%             
%             name_splits = split(gt_name.name, ".");
%             save_file = fullfile(save_folder, strcat(name_splits{1}, ".nii"));
%             niftiwrite(uni_DMMS, save_file, 'Compressed',true)
%         end
%         display(strcat(train_ratio{k}, ": ", data_name))
%     end
% end


%% Dice ratio of varied train ratio
% %  results folder
% data_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
% train_ratios = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10'};
% for k = 1:length(train_ratio)
%     for j = 1:length(data_names)
%         data_name = data_names{j};
%         save_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\TrainRatio', strcat('TR', train_ratios{k}));
%         gt_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw', data_name, 'CellProcessed');
%         map_folder = fullfile(save_folder, strcat(data_name, train_ratios{k}), 'ResultProcessed');
%     %     bin_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults', data_name, '\ResultProcessed');
% 
%         DICES = [];
%         cell_num = [];
%         gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
%         map_names = dir(fullfile(map_folder, '*.nii.gz'));
%     %     bin_names =  dir(fullfile(bin_folder, '*.nii.gz'));
%         for i = 1 : length(gt_names)
%             gt_name = gt_names(i);
%             map_name = map_names(i);
%     %         bin_name = bin_names(i);
%             %  load data
%             gt_file = fullfile(gt_folder, gt_name.name);
%             map_file = fullfile(map_folder, map_name.name);
%     %         bin_file = fullfile(bin_folder, bin_name.name);
%             GT = load_nii(gt_file);
%             map_data = load_nii(map_file);
%     %         bin_data = load_nii(bin_file);
%             GT = GT.img;
%             map_data = map_data.img;
%     %         bin_data = bin_data.img;
% 
%             %  Calculate dice ratio with thin membrane
%             map_ratio = calculate_dice(GT, map_data);
%     %         bin_ratio = calculate_dice(GT, bin_data);
% 
%             %  Combine results
%             DICES = [DICES; map_ratio]; %, bin_ratio];
%             cell_num = [cell_num; length(unique(GT)) - 1];
%             fprintf('%s, precision: %5.4f, %5.4f\n', gt_file, map_ratio)
%         end
% 
%         save_name = fullfile(save_folder, strcat(data_name, '.mat'));
%         save(save_name, 'DICES', 'cell_num')
% 
%     end
% end

%% save *.mat figure as nii
% cell_names = {"Eala", "Ealp", "Eara", "Earp", "Epla", "Eplp", "Epra", "Eprp"};
% cell_labels = [5546, 5553, 5567, 5582, 5595, 5602, 5618, 5631];
% 
% for j = 1 : length(cell_names)
%     cell_name = cell_names{j};
%     cell_label = cell_labels(j);
%     path_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphology\CellMorphology", cell_name);
%     save_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphologyE\TifFile", cell_name);
%     if ~isfolder(save_folder)
%         mkdir(save_folder)
%     end
%     mat_files = dir(fullfile(path_folder, '*.mat'));
%     k = 1;
%     for i = 1:length(mat_files)
%         mat_file = mat_files(i);
%         mat_name = mat_file.name;
%         base_name = split(mat_name, ".");
%         mat_file = fullfile(path_folder, mat_name);
%         load(mat_file);
%         cell_mask = zeros(size(Seg));
%         cell_mask(Seg==cell_label) = rem(cell_label, 256);
%         if k == 1
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphology\TifFile", strcat(cell_name, ".txt")), 'w');
%             fprintf(fid, "%d\n", rem(cell_label, 256));
%             fclose(fid);
%         else
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphology\TifFile", strcat(cell_name, ".txt")), 'a');
%             fprintf(fid, "%d\n", rem(cell_label, 256));
%             fclose(fid);
%         end
% 
%         save_file = fullfile(save_folder, strcat(cell_name, base_name{1}, ".tif"));
%         saveTifAsRGB(cell_mask, save_file);
%         k = k + 1;
%     end
% end


%% save cell E shape
% cell_labels = [5546, 5553, 5567, 5582, 5595, 5602, 5618, 5631];
% 
% path_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphologyE\MatFile");
% save_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphologyE\TifFile");
% 
% if ~isfolder(save_folder)
%     mkdir(save_folder)
% end
% mat_files = dir(fullfile(path_folder, '*.mat'));
% k = 1;
% for i = 1:length(mat_files)
%     mat_file = mat_files(i);
%     mat_name = mat_file.name;
%     base_name = split(mat_name, ".");
%     mat_file = fullfile(path_folder, mat_name);
%     load(mat_file);
%     cell_mask = zeros(size(Seg));
%     for cell_label = cell_labels
%         cell_mask(Seg==cell_label) = rem(cell_label, 256);
%     end
%     if k == 1
%         fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphologyE", strcat(cell_name,".txt")), 'w');
%         fprintf(fid, "%d\n", rem(cell_label, 256));
%         fclose(fid);
%     else
%         fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\CellMorphologyE", strcat(cell_name,".txt")), 'a');
%         fprintf(fid, "%d\n", rem(cell_label, 256));
%         fclose(fid);
%     end
% 
%     save_file = fullfile(save_folder, strcat(cell_name, base_name{1}, ".tif"));
%     saveTifAsRGB(cell_mask, save_file);
%     k = k + 1;
% end

%% save dynamics
% pre_fix = "Seg_2_";
% cell_names = {"ABpl"};
% cell_labels = [2796];
% 
% for j = 1 : length(cell_names)
%     cell_name = cell_names{j};
%     cell_label = cell_labels(j);
%     path_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\ABplDynamics\MatFile");
%     save_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\ABplDynamics\TifFile", pre_fix);
%     
%     if ~isfolder(save_folder)
%         mkdir(save_folder)
%     end
%     mat_files = dir(fullfile(path_folder, strcat(pre_fix, '*.mat')));
%     k = 1;
%     for i = 1:length(mat_files)
%         mat_file = mat_files(i);
%         mat_name = mat_file.name;
%         base_name = split(mat_name, ".");
%         mat_file = fullfile(path_folder, mat_name);
%         load(mat_file);
%         cell_mask = zeros(size(Seg));
%         cell_mask(Seg==2796) = rem(cell_label, 256); % ABpl
%         cell_mask(Seg==3931) = rem(3931, 256); % ABpr
%         cell_mask(Seg==2795) = rem(2795, 256); % ABp
%         uni_labels = rem(unique(cell_mask), 256);
%         if k == 1
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\ABplDynamics", strcat(pre_fix,".txt")), 'w');
%             fprintf(fid, "%d\n", uni_labels(2));
%             fclose(fid);
%         else
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\ABplDynamics", strcat(pre_fix,".txt")), 'a');
%             fprintf(fid, "%d\n", uni_labels(2));
%             fclose(fid);
%         end
%             
% 
%         save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%         saveTifAsRGB(cell_mask, save_file);
%         k = k + 1;
%     end
% end


%% ABpl, ABp, ABpr nucleus
% cell_labels = [2796, 3931, 2795];
% 
% path_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\Nucleus\MatFile");
% save_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\Nucleus\TifFile");
% 
% if ~isfolder(save_folder)
%     mkdir(save_folder)
% end
% mat_files = dir(fullfile(path_folder, '*.mat'));
% k = 1;
% for i = 1:length(mat_files)
%     mat_file = mat_files(i);
%     mat_name = mat_file.name;
%     base_name = split(mat_name, ".");
%     mat_file = fullfile(path_folder, mat_name);
%     load(mat_file);
%     cell_mask = zeros(size(Seg));
%     for cell_label = cell_labels
%         cell_mask(Seg==cell_label) = rem(cell_label, 256);
%     end
%     if k == 1
%         fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\Nucleus", "all.txt"), 'w');
%         fprintf(fid, "%d\n", rem(cell_label, 256));
%         fclose(fid);
%     else
%         fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\Nucleus", "all.txt"), 'a');
%         fprintf(fid, "%d\n", rem(cell_label, 256));
%         fclose(fid);
%     end
% 
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%     saveTifAsRGB(cell_mask, save_file);
%     k = k + 1;
% end



%% save dynamics last moment
% cell_names = {"ABpl"};
% cell_labels = [2796];
% 
% for j = 1 : length(cell_names)
%     cell_name = cell_names{j};
%     cell_label = cell_labels(j);
%     path_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\LastMoment\MatFile");
%     save_folder = fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\LastMoment\TifFile", pre_fix);
%     
%     if ~isfolder(save_folder)
%         mkdir(save_folder)
%     end
%     mat_files = dir(fullfile(path_folder, strcat('*.mat')));
%     k = 1;
%     for i = 1:length(mat_files)
%         mat_file = mat_files(i);
%         mat_name = mat_file.name;
%         base_name = split(mat_name, ".");
%         mat_file = fullfile(path_folder, mat_name);
%         load(mat_file);
%         cell_mask = zeros(size(Seg));
%         cell_mask(Seg==2796) = rem(cell_label, 256); % ABpl
%         cell_mask(Seg==3931) = rem(3931, 256); % ABpr
%         cell_mask(Seg==2795) = rem(2795, 256); % ABp
%         uni_labels = rem(unique(cell_mask), 256);
%         if k == 1
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\LastMoment", strcat("all",".txt")), 'w');
%             fprintf(fid, "%d\n", uni_labels(2));
%             fclose(fid);
%         else
%             fid = fopen(fullfile("D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GgyFigures\LastMoment", strcat("all.txt")), 'a');
%             fprintf(fid, "%d\n", uni_labels(2));
%             fclose(fid);
%         end
%             
% 
%         save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%         saveTifAsRGB(cell_mask, save_file);
%         k = k + 1;
%     end
% end




%% save cavity reproducibility
% folder_name = "D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\Revision_1th\GuoyeFigures\Reproducibility\24CellStage\MatFiles";
% [folder_dir, ~, ~] = fileparts(folder_name);
% save_folder = fullfile(folder_dir, "TifFiles");
% file_list = dir(fullfile(folder_name, "*.mat"));
% % get unique labels
% labels = [];
% for i = 1 : length(file_list)
%     file_str = file_list(i);
%     load(fullfile(folder_name, file_str.name));
%     if sum(Seg, 'all') == 0
%         continue;
%     end
%     
%     labels = [labels, unique(Seg)'];
% end
% labels = unique(labels);
% labels(labels==0) = [];
% labels = sort(labels);
% 
% % save tif files
% k = 1;
% for i = 1 : length(file_list)
%     file_str = file_list(i);
%     load(fullfile(folder_name, file_str.name));
%     if sum(Seg, 'all') == 0
%         continue;
%     end
%     
%     base_name = split(file_str.name, ".");
%     Seg = permute(Seg, [3, 1, 2]);
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%     
%     if ~isfolder(save_folder)
%         mkdir(save_folder)
%     end
% 
%     uni_labels = unique(Seg);
%     uni_labels(uni_labels==0) = [];
%     for label = uni_labels'
%         Seg(Seg == label) = find(labels == label);
%     end
%     
%     uni_labels = unique(Seg);
%     uni_labels(uni_labels==0) = [];
%     if k == 1
%         fid = fopen(fullfile(folder_dir, strcat("all",".txt")), 'w');
%         fprintf(fid, "%d\n",uni_labels(1));
%         fclose(fid);
%     else
%         fid = fopen(fullfile(folder_dir, strcat("all.txt")), 'a');
%         fprintf(fid, "%d\n", uni_labels(1));
%         fclose(fid);
%     end
%            
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%     saveTifAsRGB(Seg, save_file);
%     k = k + 1;
% end

%% resave Guoye data
% folder_name = "D:\TemDownload\HoleVideo\Material_CavityDynamics";
% save_folder = "D:\TemDownload\HoleVideo\Material_CavityDynamics";
% file_list = dir(fullfile(save_folder, "*.mat"));
% for i=1:length(file_list)
%     file_str = file_list(i);
%     load(fullfile(folder_name, file_str.name));
%     Seg(Seg == -1) = 10000;
%     base_name = split(file_str.name, ".");
%     Seg = permute(Seg, [3, 1, 2]);
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".nii"));
%     niftiwrite(Seg, save_file, "Compressed", true);
%     
% end

%% save nii as tif
% folder_name = "D:\TemDownload\CavityCheck\Polar3\Nii";
% [folder_dir, ~, ~] = fileparts(folder_name);
% save_folder = fullfile(folder_dir, "TifFiles");
% file_list = dir(fullfile(folder_name, "*.nii.gz"));
% % get unique labels
% % load cavity
% cavity_file = "D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\6_NCommunication\RevisionData\SegmentedCell\200314plc1p2Cavity\200314plc1p2_035_segCavity.nii.gz";
% cavity = niftiread(cavity_file);
% cavity = permute(cavity, [3, 1, 2]);
% 
% labels = [];
% for i = 1 : length(file_list)
%     file_str = file_list(i);
%     Seg = niftiread(fullfile(folder_name, file_str.name));
%     if sum(Seg, 'all') == 0
%         continue;
%     end
%     
%     labels = [labels, unique(Seg)'];
% end
% % labels = [labels,10000];
% labels = unique(labels);
% labels(labels==0) = [];
% labels = sort(labels);
% 
% % save tif files
% k = 1;
% for i = 1 : length(file_list)
%     file_str = file_list(i);
%     Seg = niftiread(fullfile(folder_name, file_str.name));
%     if sum(Seg, 'all') == 0
%         continue;
%     end
%     
%     base_name = split(file_str.name, ".");
%     Seg = permute(Seg, [3, 1, 2]);
% %     Seg(cavity ~= 0) = 10000;
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%     
%     if ~isfolder(save_folder)
%         mkdir(save_folder)
%     end
% 
%     uni_labels = unique(Seg);
%     uni_labels(uni_labels==0) = [];
%     for label = uni_labels'
%         Seg(Seg == label) = find(labels == label);
%     end
%     
%     uni_labels = unique(Seg);
%     uni_labels(uni_labels==0) = [];
%     if k == 1
%         fid = fopen(fullfile(folder_dir, strcat("all",".txt")), 'w');
%         fprintf(fid, "%d\n",uni_labels(1));
%         fclose(fid);
%     else
%         fid = fopen(fullfile(folder_dir, strcat("all.txt")), 'a');
%         fprintf(fid, "%d\n", uni_labels(1));
%         fclose(fid);
%     end
%            
%     save_file = fullfile(save_folder, strcat(base_name{1}, ".tif"));
%     saveTifAsRGB(Seg, save_file);
%     k = k + 1;
% end

%% save all cell names
% load("D:\ProjectData\WorkSpace_CellName0.mat")
% row_num = length(CellName);
% cell_names = [];
% i = 0
% A = cell(1225, 1);
% for row = 1:row_num
%     row_cell = CellName{row};
%     [row_cell_row, row_cell_col] = size(row_cell);
%     for row1 = 1:row_cell_row   
%         for col1 = 1:row_cell_col
%             if ~ row_cell{row1, col1} == 0
%                 i = i+1;
%                 A{i} = row_cell{row1, col1};
%             end
%         end
%     end
% end
% 
% fname = 'D:\ProjectData\WorkSpace_CellName0.xlsx';
% sheet = 2;
% xlRange = 'A1';
% xlswrite(fname,A,sheet,xlRange)



%% Cell 2 csv
cell2csv('D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\7_AtlasCell\DatasetUpdated\QC\DeletedCellsRaw\c.csv', RecordNew)
