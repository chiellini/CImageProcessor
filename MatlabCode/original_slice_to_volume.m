%%  settings for which to save
slice_num = 92;
xy_res = 0.09;
z_res = 0.42;
max_time = 195;
embryo_name = "200122plc1lag1ip1";
target_embryo = "200122plc1lag1ip1";
save_folder = "D:\ProjectData\AllDataPacked";
save_label_folder = "D:\ProjectData\AllDataPackedWithLabel";

save_raw_memb = True;
save_raw_nuc = True;
save_seg_nuc = true;

take_raw_label_together = True;
label_path = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D";

%% get the target volume size
% Get target shape
mask_name = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\170614plc1p2\mask\membT1s.nii.gz";
target_volume = niftiread(mask_name);
target_size = [256, 356, 214];

%% save raw membrane
if save_raw_memb
    raw_memb_folder = fullfile(save_folder, embryo_name, "RawMemb");
    if ~exist(raw_memb_folder, 'dir')
        mkdir(raw_memb_folder)
    end
    raw_memb_path = fullfile("D:\ProjectData\AllRawData", embryo_name, "tifR");
    for time = 1 : max_time
        embryo = [];
        for slice = 1:slice_num
            t_str = strcat(repmat('0', 1, 3-length(num2str(time))), num2str(time));
            s_str = strcat(repmat('0', 1, 2-length(num2str(slice))), num2str(slice));
            %slice_name = strcat("170704plc1deconp1_L1-t", t_str, "-p", s_str,".tif");
            slice_name = strcat(embryo_name, "_L1-t", t_str, "-p", s_str, ".tif");
            image_file = fullfile(raw_memb_path, slice_name);
            slice_matrix = imread(image_file);
            slice_matrix = imadjust(slice_matrix, [0, 0.95]);
            embryo = cat(3, slice_matrix, embryo);
        end
        embryo = imresize3(embryo, target_size, 'linear');  % 
        niftiwrite(embryo, fullfile(raw_memb_folder, strcat(embryo_name, "_", num2str(time, "%03d"), "_rawMemb.nii")), "Compressed", true)
    %     save_path = strcat(save_folder, '\membt',repmat('0', 1,nL),num2str(time_point),'.mat');
    %     save(save_path, 'embryo');
    end
end

%% save nucleus raw
if save_raw_nuc
    raw_nuc_folder = fullfile(save_folder, embryo_name, "RawNuc");
    if ~exist(raw_nuc_folder, 'dir')
        mkdir(raw_nuc_folder)
    end
    raw_nuc_path = fullfile("D:\ProjectData\AllRawData", embryo_name, "tif");
    parfor time = 1 : max_time
        embryo = [];
        for slice = 1:slice_num
            t_str = strcat(repmat('0', 1, 3-length(num2str(time))), num2str(time));
            s_str = strcat(repmat('0', 1, 2-length(num2str(slice))), num2str(slice));
%             slice_name = strcat("170704plc1deconp1_L1-t", t_str, "-p", s_str,".tif");
            slice_name = strcat(embryo_name, "_L1-t", t_str, "-p", s_str, ".tif");
            slice_matrix = imread(fullfile(raw_nuc_path, slice_name));
            embryo = cat(3, slice_matrix, embryo);
        end
        embryo = imresize3(embryo, target_size, "linear");
        niftiwrite(embryo, fullfile(raw_nuc_folder,strcat(embryo_name, "_", num2str(time, "%03d"), "_rawNuc.nii")), "Compressed", true)
    %     save_path = strcat(save_folder, '\membt',repmat('0', 1,nL),num2str(time_point),'.mat');
    %     save(save_path, 'embryo');
    end
end


%% save nucleus
if save_seg_nuc
    seg_nuc_folder = fullfile(save_folder, embryo_name, "SegNuc");
    if ~exist(seg_nuc_folder, 'dir')
        mkdir(seg_nuc_folder)
    end
    nucPath = fullfile("D:\ProjectData\AllRawData", embryo_name, "aceNuc", strcat("CD", embryo_name, ".csv"));
    fid = fopen(nucPath, 'r');
    if fid == -1
        error('Error, these is no such file');
    else
        formatSpec = '%*s %s %u16 %*s %*s %*s %*s %*s %4.1f %4.1f %4.1f %*s %*s %*s';
        s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
        nucName0 = s{1};    %string cell array
        nucTime0 = s{2};    %which time point the cell exists
        nucZ0 = s{3};       %nuc absolute location
        nucY0 = s{4};       %exchange the number of x and y
        nucX0 = s{5};
    end
    fclose(fid);
    xyreduceRatio = target_size(1) / 512;
    zreduceRatio = target_size(3) / slice_num;
    [nucName, nucLabel] = get_name_dictionary();
    parfor time = 1 : max_time
        indx0 = find(nucTime0 == time);
        names = nucName0(indx0);
        nucXAtT = uint16(nucX0(indx0) * xyreduceRatio);
        nucYAtT = uint16(nucY0(indx0) * xyreduceRatio);
        nucZAtT = uint16(nucZ0(indx0) * zreduceRatio);
        segNuc = zeros(target_size);
        for i = 1 : length(nucXAtT)
%             %  add for error
%             if (strcmp(names(i), "ABall"))
%                 segNuc(nucXAtT(i), nucYAtT(i), target_size(3) - nucZAtT(i)) = 1888;
%                 continue
%             end
%             if (strcmp(names(i), "ABalr"))
%                 segNuc(nucXAtT(i), nucYAtT(i), target_size(3) - nucZAtT(i)) = 1999;
%                 continue
%             end
            indx = find(strcmp(nucName, names(i)));
            if isempty(indx)
                names(i)
                continue
            end
            segNuc(nucXAtT(i), nucYAtT(i), target_size(3) - nucZAtT(i)) = nucLabel(indx);
        end
        niftiwrite(segNuc, fullfile(seg_nuc_folder, strcat(embryo_name, "_", num2str(time, "%03d"), "_segNuc.nii")), "Compressed", true)        
    end
end

%% take raw data with label together
if take_raw_label_together
    mask_list = dir(fullfile(label_path, embryo_name, "mask", "*.nii.gz"));
    cell_list = dir(fullfile(label_path, embryo_name, "cells", "*.nii.gz"));
    for i = 1 : length(mask_list)
        mask_name = mask_list(i).name;
        time_point = mask_name(6:end-8);
        % raw memb
        raw_memb_name = strcat(target_embryo, "_T", time_point, "_rawMemb.nii.gz");
        copyfile(fullfile(save_folder, target_embryo, "RawMemb", raw_memb_name), fullfile(save_label_folder, target_embryo, "RawMemb", raw_memb_name))
        % raw nucleus
        raw_nuc_name = strcat(target_embryo, "_T", time_point, "_rawNuc.nii.gz");
        copyfile(fullfile(save_folder, target_embryo, "RawNuc", raw_nuc_name), fullfile(save_label_folder, target_embryo, "RawNuc", raw_nuc_name))
        % seg nucleus 
        seg_nuc_name = strcat(target_embryo, "_T", time_point, "_segNuc.nii.gz");
        copyfile(fullfile(save_folder, target_embryo, "SegNuc", seg_nuc_name), fullfile(save_label_folder, target_embryo, "SegNuc", seg_nuc_name))
        % cell memb
        cell_file = cell_list(i);
        cell_save_file = fullfile(save_label_folder, target_embryo, "SegCell", strcat(target_embryo, "_", time_point, "_segCell.nii"));
        source_file = fullfile(cell_file.folder, cell_file.name);
        cell = niftiread(source_file);
        cell_new = imresize3(flip(cell, 3), target_size, 'nearest');
        niftiwrite(cell_new, cell_save_file, "Compressed", true);
        % cell memb
        mask_file = mask_list(i);
        memb_save_file = fullfile(save_label_folder, target_embryo, "SegMemb", strcat(target_embryo, "_", time_point, "_segMemb.nii"));
        source_file = fullfile(mask_file.folder, mask_file.name);
        memb = niftiread(source_file);
        memb_new = imresize3(flip(memb, 3), target_size, 'nearest');
        niftiwrite(memb_new, memb_save_file, "Compressed", true);
        
    end
end

%%  
% embryo_names = ["181210plc1p1", "181210plc1p3"];
% root_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D";
% target_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\AllMembraneTrain\ValidateSet\raw";
% for i = 1:length(embryo_names)
%     embryo_name = embryo_names(i);
%     embryo_folder = fullfile(root_folder, embryo_name, "validation", "raw");
%     embryo_files = dir(fullfile(embryo_folder, "*.nii.gz"));
%     for j = 1:length(embryo_files)
%         single_file = embryo_files(j);
%         tem = niftiread(fullfile(single_file.folder, single_file.name));
%         niftiwrite(tem, fullfile(target_folder, strcat(embryo_name, '_', single_file.name(1:end-7), ".nii")), "Compressed", true)
%     end
% end

