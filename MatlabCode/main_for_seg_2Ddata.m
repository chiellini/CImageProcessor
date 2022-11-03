% This function is used for saving 3D raw images as 2D slices for
% segmentation. 

embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
raw_3D_folder = 'C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\';
save_folder = 'D:\ProjectData\dataSetLabel\ToBeTrained\Data2D\validation';

for i = 1:length(embryo_names)
    embryo_name = embryo_names{i};
    embryo_folder = fullfile(raw_3D_folder, embryo_name, 'raw');
    all_files = dir(fullfile(embryo_folder, '*.nii'));
    display(strcat('Processing--- ', embryo_name, '....'))
    for j = 1 : length(all_files)
        one_file = all_files(j);
        t_str = one_file.name;
        raw_3D_data = load_nii(fullfile(embryo_folder, one_file.name));
        raw_3D_data = raw_3D_data.img;
        [~, ~, sz] = size(raw_3D_data);
        for z = 1:sz
            slice_data = raw_3D_data(:, :, z);
            slice_data = imresize(slice_data, [256, 256]);
            save_file = fullfile(save_folder, embryo_name, strcat(embryo_name, '_', ...
                t_str(6:7), '_', num2str(z), '.png'));
            if ~exist(fullfile(save_folder, embryo_name), 'dir')
                mkdir(fullfile(save_folder, embryo_name))
            end
            imwrite(uint8(slice_data), save_file);
        end
    end
end
