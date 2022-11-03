% This function is used for saving 3D raw images as 2D slices for
% segmentation. 

% embryo_names = {'170704plc1p1', '170614plc1p1'};
embryo_name = '170704plc1p1';
raw_3D_folder = fullfile('D:\ProjectData\AllDataPackedWithLabel', embryo_name, 'RawMemb');
seg_3D_folder = fullfile('D:\ProjectData\AllDataPackedWithLabel', embryo_name, 'SegMemb');
cell_3D_folder = fullfile('D:\ProjectData\AllDataPackedWithLabel', embryo_name, 'SegCell');
save_folder = 'D:\ProjectData\dataSetLabel\ToBeTrained\Data2D';

raw_list = dir(fullfile(raw_3D_folder, '*.nii.gz'));
for i = 1:length(raw_list)
    raw_file = raw_list(i);
    tp = split(raw_file.name, '_');
    tp = tp{2};
    tp = str2num(tp(2:end));
    raw_name = fullfile(raw_3D_folder, raw_file.name);
    seg_name = fullfile(seg_3D_folder, strcat(embryo_name, '_T', num2str(tp), '_segMemb.nii.gz'));
    cell_name = fullfile(cell_3D_folder, strcat(embryo_name, '_T', num2str(tp), '_segCell.nii.gz'));
    
    raw = niftiread(raw_name);
    seg = niftiread(seg_name);
    cell = niftiread(cell_name);
    
    display(strcat('Processing--- ', raw_file.name, '....'))
    [~, ~, sz] = size(raw);
    for z = randi([15, sz-15], 1, 20)
        
        x = randi([1, 6], 1); y = randi([1, 12], 1);
        raw_slice = squeeze(raw(x:x+191, y:y+255, z));
        seg_slice = bwdist(squeeze(seg(x:x+191, y:y+255, z)));
        cell_slice = squeeze(cell(x:x+191, y:y+255, z));
        if sum(cell_slice, "all") < 20
            continue;
        end
        
        if rand(1) > 0.9
            target_folder = "Test";
        else
            target_folder = "Train";
        end
        
        raw_save_file = fullfile(save_folder, target_folder, "Raw", strcat(embryo_name, "_T", num2str(tp,'%03.f'), "_", num2str(z,'%03.f'), ".tif"));
        seg_save_file = fullfile(save_folder, target_folder, "Seg", strcat(embryo_name, "_T", num2str(tp,'%03.f'), "_", num2str(z,'%03.f'), ".tif"));
        cell_save_file = fullfile(save_folder, target_folder, "Cell", strcat(embryo_name, "_T", num2str(tp,'%03.f'), "_", num2str(z,'%03.f'), ".tif"));

        save_tif(single(raw_slice), raw_save_file);
        save_tif(single(seg_slice), seg_save_file);
        save_tif(single(cell_slice), cell_save_file);
    end
end
