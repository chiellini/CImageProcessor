warning('off','all')

%% change all in order
% seg_path = "D:\Paper\NMethod\DemoFigureUpdate\181210plc1p2Resilts";
% [root_folder, embryo_name, ~] = fileparts(seg_path);
% save_folder = fullfile(root_folder, embryo_name + '_RGBTif');
% if ~isfolder(save_folder)
%     mkdir(save_folder); 
% end
% 
% seg_lists = dir(fullfile(seg_path, '*.nii.gz'));
% for i = 1: length(seg_lists)
%     seg_file = fullfile(seg_path, "181210plc1p2_" +  num2str(i,'%03.f') + "_segCell.nii.gz");
%     seg = niftiread(seg_file);
%     
%     %% revise for visual effects
%     [sr, sc, sz] = size(seg);
%     %seg = flip(seg, 3);
%     revised_seg = seg;
% %     revised_seg(floor(sr/2): sr, :, :) = 0;
% %     revised_seg(:, floor(sc/2):sc, :) = 0;
% %     revised_seg(:, :, 1: floor(sz/2)) = 0;
%     uni_labels = rem(unique(revised_seg), 256);
%     if i == 1
%         fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'w');
%         fprintf(fid, "%d\n", uni_labels(2));
%         fclose(fid);
%     else
%         fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'a');
%         fprintf(fid, "%d\n", uni_labels(2));
%         fclose(fid);
%     end
%     
%     save_name = fullfile(save_folder, "membT" + num2str(i) + ".tif");
%     saveTifAsRGB(revised_seg, save_name);
%     i
% end

%% get comparison 3D
reduce_scale = 0.5;
seg_path = "D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\7_CNS\Dataset\200113plc1p3\SegCellTimeCombinedLabelUnified";
root_folder = "D:\OneDriveBackup\OneDrive - City University of Hong Kong\paper\7_CNS\Code\TimeLapseVideo\Videos\TifColors";
[~, embryo_name, ~] = fileparts(seg_path);
save_folder = fullfile(root_folder, "200113plc1p3" + '_RGBTif');
if ~isfolder(save_folder)
    mkdir(save_folder); 
end

seg_lists = dir(fullfile(seg_path, '*.nii.gz'));
for i = 1: length(seg_lists)
    base_name = split(seg_lists(i).name, ".");
    base_name = base_name{1}
    seg_file = fullfile(seg_path, seg_lists(i).name);
    seg = niftiread(seg_file);
    
    %% reduce to ratio == reduce_scale
    seg = imresize3(seg, reduce_scale, "nearest");
    
    %% revise for visual effects
    [sr, sc, sz] = size(seg);
    %seg = flip(seg, 3);
    revised_seg = seg;
    % revised_seg(1:floor(sr/2), 1:floor(sc/2), floor(sz/2):sz) = 0;
    uni_labels = rem(unique(revised_seg), 256);
    uni_labels(uni_labels == 0) = [];
    if i == 1
        fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'w');
        fprintf(fid, "%d\n", uni_labels(1));
        fclose(fid);
    else
        fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'a');
        fprintf(fid, "%d\n", uni_labels(1));
        fclose(fid);
    end
    
    save_name = fullfile(save_folder, base_name + ".tif");
    saveTifAsRGB(revised_seg, save_name);
    i
end


%% change some 

% seg_path = "D:\Paper\NMethod\Division\3DImagePlus";
% [root_folder, embryo_name, ~] = fileparts(seg_path);
% save_folder = fullfile(root_folder, embryo_name + '_RGBTif');
% if ~isfolder(save_folder)
%     mkdir(save_folder); 
% end
% 
% seg_lists = dir(fullfile(seg_path, '*.nii.gz'));
% for i = 1: length(seg_lists)
%     file = seg_lists(i);
%     file_name = file.name;
%     seg_file = fullfile(seg_path, file_name);
%     seg = niftiread(seg_file);
%     
%     %% revise for visual effects
%     [sr, sc, sz] = size(seg);
%     %seg = flip(seg, 3);
%     revised_seg = zeros(sr, sc, sz);
%     revised_seg = seg;
%    % revised_seg(floor(sr/2): sr, floor(sc/2):sc, 1:floor(sz/2)) = 0;
%     uni_labels = rem(unique(revised_seg), 256);
%     if i == 1
%         fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'w');
%         fprintf(fid, "%d\n", uni_labels(2));
%         fclose(fid);
%     else
%         fid = fopen(fullfile(root_folder, embryo_name + ".txt"), 'a');
%         fprintf(fid, "%d\n", uni_labels(2));
%         fclose(fid);
%     end
%     [~, base_name, ~] = fileparts(file_name);
%     [~, base_name, ~] = fileparts(base_name);
%     save_name = fullfile(save_folder, strcat(base_name, ".tif"));
%     saveTifAsRGB(revised_seg, save_name);
%     
%     i
% end


