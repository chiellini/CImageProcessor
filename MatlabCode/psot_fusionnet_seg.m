clc; clear; close all

%% nucleus seeded watershed segmentation for FusionNet and 3DUnet binary result

data_dir = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\BinaryResized';
save_dir = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\Segmented';
nuc_folder = 'D:\ProjectCode\PresegmentationLabel\data\aceNuc';
embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
times = [24:10:84];

parfor i = 1 : length(embryo_names)
    embryo_name = embryo_names{i};
    nuc_file = fullfile(nuc_folder, embryo_name, strcat('CD', embryo_name, '.csv'));
    all_files = dir(fullfile(data_dir, embryo_name, '*.nii.gz'));
    for j = 1 : length(all_files)
        one_file = all_files(j);
        bin_seg_data = load_nii(fullfile(one_file.folder, one_file.name));
        bin_seg_data = bin_seg_data.img;
        
        % get nucleus stack
        name_tem = one_file.name;
        TimePoint = str2num(name_tem(6:7));
        [nucSeg0, ~] = getNuc(TimePoint, embryo_name, nuc_file, bin_seg_data);

        %get the seeds for watershed and Euclidean distance transformation from
%         %nucleus stack images.
%         SE = strel('sphere', 4);
%         nucSeg = imdilate(nucSeg0, SE);
        EDT = bwdist(bin_seg_data ~= 0);
        maxDist = max(EDT(:));
        reverseEDT = maxDist - EDT;
        marker = nucSeg0;
            %mannually add background seed.
        marker(:,:,1) = 1;marker(:,:,end) = 1;
        marker(1,:,:) = 1;marker(end,:,:) = 1;
        marker(:,1,:) = 1;marker(:, end, :) = 1;
        withMinMemb = imimposemin(reverseEDT, logical(marker), 26);
        membSeg0 = watershed(withMinMemb, 26);
            %set the back ground as 0.
        membSeg0(membSeg0 == mode(membSeg0(:))) = 0; 
        
        % save file
        save_file = fullfile(save_dir, embryo_name);
        if ~exist(save_file, 'dir')
            mkdir(save_file);
        end
        seg_nii = make_nii(uint16(membSeg0), [1,1,1],[0,0,0], 512);  %512---uint16
        save_nii(seg_nii, fullfile(save_file, name_tem));
        display(strcat('Finished ---', fullfile(save_file, name_tem)))       
        
    end
end

%% resize binary results of 3DUnet
% data_dir = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\BinarySeg';
% save_dir = 'C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\3DUnet\BinaryResized';
% GT_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw';
% embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
% 
% % get one referred shape from ground truth
% GT_files = dir(fullfile(GT_folder, embryo_names{1},'CellProcessed', '*.nii'));
% GT_file = GT_files(1);
% GT_data = load_nii(fullfile(GT_folder,  embryo_names{1},'CellProcessed', GT_file.name));
% GT_data = GT_data.img;
% [sr, sc, sz] = size(GT_data);
% for embryo_name = embryo_names
%     embryo_name = embryo_name{1};
%     embryo_folder = fullfile(data_dir, embryo_name);
%     all_files = dir(fullfile(embryo_folder, '*.nii.gz'));
%     for one_file = all_files'
%         seg_data0 = load_nii(fullfile(embryo_folder, one_file.name));
%         seg_data1 = seg_data0.img;
%         seg_data = imresize3(seg_data1, [sr, sc, sz], 'nearest');
%         
%         % save resize volume
%         img = make_nii(seg_data, [1,1,1],[0,0,0], 2);  %512---uint16
%         save_file = fullfile(save_dir, embryo_name, one_file.name);
%         if ~exist(fullfile(save_dir, embryo_name), 'dir')
%             mkdir(fullfile(save_dir, embryo_name))
%         end
%         save_nii(img, save_file)
%         display(save_file)
%     end 
% end




