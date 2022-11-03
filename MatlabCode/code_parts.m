clc; clear;
%% Combine one point stack
% root_folder = "C:\Users\bcc\Desktop\191031plc1_single_tp_after";
% memb_list = dir(fullfile(root_folder, "*ch01.tif"));
% embryo = [];
% for i = 1:length(memb_list)
%     one_image = memb_list(i);
%     file_name = fullfile(one_image.folder, one_image.name);
%     img = imread(file_name);
%     embryo = cat(3, img, img, img, embryo);
% end
% embryo_name = split(one_image.name, "_");
% embryo_name = embryo_name(1);
% niftiwrite(embryo, fullfile(one_image.folder, strcat(embryo_name, ".nii")), "Compressed", true)

%% Read one stack for 3D projection
% raw_memb = niftiread("D:\ProjectData\AllDataPacked\181210plc1p3\RawMemb\181210plc1p3_T44_rawMemb.nii.gz");
% raw_nucleus = niftiread("D:\ProjectData\AllDataPacked\181210plc1p3\RawNuc\181210plc1p3_T44_rawNuc.nii.gz");
% combined = {};
% combined.memb = raw_memb;
% combined.nucleus = raw_nucleus;
% 
% save("C:\Users\bcc\Desktop\MapNetEvaluation\Template\GuoyeFiles\ForProjection\projection.mat", "raw_memb", "raw_nucleus")

%% read total number of cell in ground truth annotations
% folder_path = "C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw";
% embryo_names = {"170704plc1p2", "181210plc1p3", "190314plc1p3"};
% time_points = [24, 34, 44, 54, 64, 74, 84];
% cells = zeros(3, 7);
% for i = 1:3
%     embryo_name = embryo_names{i};
%     for j = 1:7
%         time_point = time_points(j);
%         file_name = fullfile(folder_path, embryo_name, "cells", strcat("membT", num2str(time_point), "s.nii"));
%         seg_memb = niftiread(file_name);
%         num_cells = length(unique(seg_memb(:))) - 1;
%         cells(i, j) = num_cells;
%     end
% end
% save("C:\Users\bcc\Desktop\MapNetEvaluation\Template\GuoyeFiles\ForEvalation\cellNo.mat", "cells")

%% Generate data for devision
% division_folder = "D:\Paper\NMethod\Division\ResultPlus";
% save_folder = "D:\Paper\NMethod\Division\3DImagePlus";
% embryos = [1, 2, 3, 4];
% time_points = [1,28,26,35,27,46,2];
% options.color = true;
% % ABp = 1397, ABpl = 1398, ABpr=2015
% %for embryo = embryos
%     for time_point = time_points
%         time_point
%         file_name = fullfile(division_folder, strcat("Seg_", num2str(time_point),".mat"));
%         seg = load(file_name);
%         seg = seg.Seg;
%         
%         % set keep index
%         keep_seg = zeros(size(seg));
%         
%         keep_seg(seg == 1397) = 1;
%         keep_seg(seg == 1398) = 2;
%         keep_seg(seg == 2015) = 3;
%         
%         % add coordinates
%         keep_seg(1:5, 1:5, 1:50) = 100;
%         keep_seg(1:5, 1:5, 1:50) = 100;
%         
%         %keep_seg = imresize3(keep_seg, 0.4, "method", 'nearest');
%         niftiwrite(uint8(keep_seg), fullfile(save_folder, strcat("Seg", num2str(time_point), ".nii")), "Compressed", true)
%     end
% %end

%% get hausdorff distance mean and variance
% embryos = ["170704plc1p2.mat", "181210plc1p3.mat", "190314plc1p3.mat"];
% HDis = [];
% for embryo = embryos
%     load(embryo);
%     HDis = [HDis; DICES];
% end
% 
% A = HDis;
% sum1=0;
% for i=1:length(A)
%   sum1=sum1+A(i);
% end
% M=sum1/length(A) %the mean
% sum2=0;
% for i=1:length(A)
%     sum2=sum2+ (A(i)-M)^2;
% end
% V=sum2/length(A) %Varaince

%% combine series slices for visual inspection
embryo_name = "181210plc1p2";
folder = fullfile("D:\ProjectData\AllRawData", embryo_name, "tifR");
embryo = [];
for t = 1:200
    file_name = fullfile(folder, strcat("181210plc1p2_L1-t", num2str(t, "%03d"), "-p40.tif"));
    slice_matrix = imread(file_name);
    embryo = cat(3, embryo, slice_matrix);
end

niftiwrite(embryo, strcat(embryo_name, "_seriesCom.nii"), "Compressed", true)



