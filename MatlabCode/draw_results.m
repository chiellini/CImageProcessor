clear; close all; clc
%% draw comparison results of EDTMap constrained and free segmentations
% 
% bin_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults';
% all_results = dir(fullfile(bin_result_folder, '*.mat'));
% 
% dices = [];
% groups = {};
% times = []; 
% cell_num = [];
% for i = 1 : length(all_results)
%     file_name = fullfile(bin_result_folder, all_results(i).name);
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1); dices0(:, 2)];
%     groups = [groups; repelem({'MapNet'}, size(dices0, 1), 1); ; repelem({'Binary'}, size(dices0, 1), 1)];
%     times = [times; [24:10:84]';[24:10:84]'];
% end
% 
% clear g
% g = gramm('x',times,'y',dices,'color',groups);
% g.stat_summary('geom',{'bar','black_errorbar'});
% 
% g.set_names('x','Time','y','Dice ratio','color','Method');
% g.set_text_options('font', 'times', 'base_size', 14)
% g.draw()
% xticks([24:10:84])
% xticklabels({'24','34','44','54','64','74','84'})

%% This part is used to draw noise robustness
% gaussian_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\NoiseTest\Gaussian';
% all_results = dir(fullfile(gaussian_folder, '*.mat'));
% 
% times = [12, 26, 51, 97];
% noise = [0.4:0.4:4];
% 
% time_ID = [];
% noise_ID = [];
% dices = [];
% for time = times
%     j = 0;
%     for i = [20:29]
%         j = j + 1;
%         file_name = fullfile(gaussian_folder, strcat('SynthesisData', num2str(i) ,'.mat'));
%         data0 = load(file_name);
%         data0 = data0.DICES;
%         
%         dices = [dices; data0([1, 3, 5, 9])];
%         time_ID = [time_ID; times'];
%         noise_ID = [noise_ID; noise(j) * ones(length(times), 1)];
%     end  
% end
% 
% g = gramm('x',noise_ID, 'y',dices, 'color', time_ID);
% g.geom_point()
% g.stat_smooth('method', 'sgolay');
% g.set_stat_options( 'alpha', 1.00)
% g.set_names('x','Gaussian noise variance','y','Dice ratio','color','# cell');
% g.axe_property('YLim',[0.5 1]);
% g.set_text_options('font', 'times', 'base_size', 14)
% g.draw()


%% draw robustness on Poisson noise
% gaussian_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\NoiseTest\Poisson';
% all_results = dir(fullfile(gaussian_folder, '*.mat'));
% 
% times = [12, 26, 51, 97];
% noise = [5:5:50];
% 
% time_ID = [];
% noise_ID = [];
% dices = [];
% for time = times
%     j = 0;
%     for i = [30:39]
%         j = j + 1;
%         file_name = fullfile(gaussian_folder, strcat('SynthesisData', num2str(i) ,'.mat'));
%         data0 = load(file_name);
%         data0 = data0.DICES;
%         
%         dices = [dices; data0([2, 4, 6, 8])];
%         time_ID = [time_ID; times'];
%         noise_ID = [noise_ID; noise(j) * ones(length(times), 1)];
%     end  
% end
% 
% figure()
% g1 = gramm('x',noise_ID, 'y',dices, 'color', time_ID);
% g1.geom_point()
% g1.stat_smooth('method', 'sgolay');
% g1.set_stat_options( 'alpha', 1.00)
% 
% g1.set_names('x','Expectation ratio of the interval', 'y','Dice ratio','color','# cell');
% g1.axe_property('YLim',[0.5 1.0]);
% g1.set_text_options('font', 'times', 'base_size', 14)
% g1.draw()


%% draw segmentation results on Pans data
% clc; clear; close all;
% gaussian_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\PansResult\ResultProcessed';
% all_results = dir(fullfile(gaussian_folder, '*.mat'));
% 
% times = [0, 4, 8, 12, 16, 20];
% file_name = fullfile(all_results(1).folder, all_results(1).name);
% data0 = load(file_name);
% 
% g = gramm('x',times', 'y',data0.DICES);
% g.geom_point()
% g.stat_smooth();
% 
% 
% g.set_names('x','Expectation ratio of interval', 'y','Dice ratio','color','Time');
% g.set_title('Robustness of MapNet on Poisson noise');
% g.draw()


%% draw segmentation dice in Section RESULTS
% clc; clear; close all;
% gaussian_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultSynthetic\ResultSyn1\RawSyn1.mat';
% data0 = load(gaussian_folder);
% 
% times = [5:5:100];
% g = gramm('x',times', 'y',data0.DICES);
% g.geom_point()
% g.stat_smooth();
% 
% 
% g.set_names('x','Time', 'y','Dice ratio');
% g.axe_property('YLim',[0.5 1]);
% g.set_text_options('font', 'times', 'base_size', 14)
% g.draw()



%% draw results comparison on different methods

embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
col_name = {'Data1', 'Data2', 'Data3'};
dices = [];
data_names = {};
times = []; 
cell_num = [];
methods = {};

% % locate RACE result
% RACE_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\RACE\segmented';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(RACE_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'RACE'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end

% fusion_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\FusionNet\Segmented';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(fusion_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'FusionNet'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end


% % load 3D UNet result
% UNet_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\Segmented';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(UNet_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'3DUNet'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end

% % load single cell result
% singcle_cell_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell2D';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(singcle_cell_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'CellDetector'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end

% % load 3D single cell result
% singcle_cell_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\SingleCell3D';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(singcle_cell_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'CellDetector3D'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end

% % load deep watershed result
% singcle_cell_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\DeepWatershed';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(singcle_cell_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'Deep watershed'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end


% % loa B-CShaper result
% MapNet_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\BinaryAndDistanceBased\BinFinaleResults';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(MapNet_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'B-CShaper'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end

% % load CShaper result
% MapNet_result_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\result';
% 
% for i = 1 : length(embryo_names)
%     embryo_name = embryo_names{i};
%     file_name = fullfile(MapNet_result_folder, strcat(embryo_name, '.mat'));
%     dices_data = load(file_name);
%     dices0 = dices_data.DICES;
%     
%     dices = [dices; dices0(:, 1)];
%     tem = repelem({col_name{i}}, 1, length(dices0(:, 1)));
%     data_names = {data_names{:}, tem{:}};
%     times = [times; [24:10:84]'];
%     tem = repelem({'CShaper'}, 1, length(dices0));
%     methods = {methods{:}, tem{:}};
% end


% clear g
% g = gramm('x',times,'y',dices,'color',methods);
% % g.stat_bin('geom',{'bar', 'black_errorbar'});
% g.facet_grid([],data_names);
% g.geom_bar('dodge',0.7,'width',0.6);
% g.set_names('x','Time','y','Dice ratio','color','Method');
% 
% ticks = [24:10:84];
% % xtick_labels = {'24', '34', '44', '54', '64', '74', '84'};
% g.axe_property('YLim',[0 1], 'Ygrid','on');%, 'xticks', xticks,'xticklabels', xtick_labels);
% g.set_text_options('font', 'times', 'base_size', 14)
% g.draw();

%% draw comparison lines for distance weighted Dice lines
% map_dice_file = 'C:\Users\bcc\Desktop\MapNetEvaluation\DisEntropy\MapDice.csv';
% nomap_dice_file = 'C:\Users\bcc\Desktop\MapNetEvaluation\DisEntropy\NOMapDice.csv';
% 
% % read files
% formatSpec = '%u16 %4.3f %4.3f';
% fid1 = fopen(map_dice_file, 'r');
% fid2 = fopen(nomap_dice_file, 'r');
% s1 = textscan(fid1, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
% s2 = textscan(fid2, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
% epoch1 = s1{2}; 
% epoch2 = s2{2};
% map_dice = s1{3};  
% nomap_dice = s2{3};
% fclose(fid1);
% fclose(fid2);
% 
% % filter invalid points
% invalid_point1 = isnan(epoch1);
% invalid_point2 = isnan(epoch2);
% epoch1(invalid_point1 == 1) = [];
% epoch2(invalid_point2 == 1) = [];
% map_dice(invalid_point1 == 1) = [];
% nomap_dice(invalid_point2 == 1) = [];
% 
% epochs = [epoch1; epoch2];
% dicess = [map_dice; nomap_dice];
% groups = [repelem({'weighted by distance'}, length(map_dice), 1); repelem({'no weight'}, length(nomap_dice), 1)];
% 
% 
% g = gramm('x',epochs, 'y',dicess, 'color', groups);
% % g.stat_smooth('method', 'moving');
% g.geom_line();
% 
% 
% g.set_names('x','Time', 'y','Dice ratio');
% g.set_title('Comparison on training with and without distance weighted');
% g.axe_property('YLim',[0 1],'Ygrid','on');
% g.set_text_options('font', 'times', 'base_size', 14)
% g.draw()


%% draw the difference in PANS data
% MARS_file = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\PansResult\ResultProcessed\52hrs_plant1_trim-acylYFP_hmin_2_asf_1_s_2.00_clean_3.nii.gz';
% MapNet_file = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData\MapNetResult\ResultProcessed\52hrs_plant1_trim-acylYFPCellwithMmeb.nii.gz';
% save_dir= 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherApplication\PansData';
% 
% % load data
% Map_seg = load_nii(MapNet_file);
% MARS_seg = load_nii(MARS_file);
% Map_seg = Map_seg.img;
% MARS_seg = MARS_seg.img;
% 
% % draw difference
% seg_difference = uint8(Map_seg ~= MARS_seg);
% 
% % save difference
% seg_nii = make_nii(seg_difference, [1,1,1],[0,0,0], 4);  %512---uint16
% save_file = fullfile(save_dir, 'difference52h.nii.gz');
% save_nii(seg_nii, save_file)

%% draw IoU F1 score
embryos = {"170704plc1p2", "181210plc1p3", "190314plc1p3"};
root_result_folder = "C:\Users\bcc\Desktop\MapNetEvaluation\Template\GuoyeFiles\SectionResults";
threshods = [0.5:0.05:0.95];
methods = {"3DUNetNew", "B-CShaper", "CellProfiler", "CShaper", "FusionNet", "RACE", "SingleCellDetector"};
F1_matrix = zeros(length(threshods), length(methods));
for i = 1 : length(threshods)
    for j = 1:length(methods)
        F1_scores = [];
        for k = 1:length(embryos)
            result_file = fullfile(root_result_folder, methods{j}, strcat(embryos{k}, "_IoU_F1.mat"));
            load(result_file)
            TP = sum(DICES > threshods(i));
            FN = length(DICES) - TP;
            FP = FP_cells;
            F1_scores = [F1_scores, 2 * TP / (2 * TP + FN + sum(abs(FP)))];
        end
        F1_matrix(i, j) = mean(F1_scores);
    end
end
save("C:\Users\bcc\Desktop\MapNetEvaluation\Template\GuoyeFiles\SectionResults\F1_score_summary.mat", "F1_matrix")



%% draw train ratio result
% clc; clear; close all
% embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
% train_ratios = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10'};
% col_name = {'Data1', 'Data2', 'Data3'};
% dices = [];
% 
% for k = 1 : length(train_ratios)
%     % locate RACE result
%     result_folder = fullfile('C:\Users\bcc\Desktop\MapNetEvaluation\TrainRatio', strcat('TR', train_ratios{k}));
%     
%     embryo_dices = [];
%     for i = 1 : length(embryo_names)
%         embryo_name = embryo_names{i};
%         file_name = fullfile(result_folder, strcat(embryo_name, '.mat'));
%         dices_data = load(file_name);
%         dices0 = dices_data.DICES;
% 
%         embryo_dices = [embryo_dices, mean(dices0(:, 1))];
%     end
%     dices = [dices, mean(embryo_dices)];
% end
% plot(0.1:0.1:1, dices);
% ylim([0, 1])




