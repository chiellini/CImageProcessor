
clear; close all; close all

%% data path
% D:\ProjectData\OriginMembData5\181210plc1p3\tifR
dataset_name = '190712plc1p2';
validation_time_points = 1:130;
slice_num = 68;
raw_memb_path = fullfile('D:\ProjectData\190712plc1', dataset_name, '\tifR'); % Origin slice images
raw_nucleus_path = fullfile('D:\ProjectData\190712plc1', dataset_name, '\tif'); % Origin slice images

%%
raw_train_path = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D',...
    '170704plc1p2','training', 'raw'); % for finding size

save_validation_path = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D',...
    dataset_name,'validation');

%% Build data folder
raw_folder = fullfile(save_validation_path, 'raw');
if ~isfolder(raw_folder)
    mkdir(raw_folder);
end
raw_nucleus_folder = fullfile(save_validation_path, 'nucleus');
if ~isfolder(raw_nucleus_folder)
    mkdir(raw_nucleus_folder);
end

%% Get training data size
train_raw_lists = dir(fullfile(raw_train_path, '*.nii'));
raw_nii = load_nii(fullfile(raw_train_path, train_raw_lists(1).name));
train_raw_img = raw_nii.img;
train_size = size(train_raw_img);

%% Prepare data for traing without repeat time points in training

f = waitbar(0, 'Please wait...');
for  i = 1:length(validation_time_points)
    embryo_arr = [];
    nucleus_arr = [];
    for slice = 1 : slice_num
        time_point = validation_time_points(i);
        time_str = num2str(time_point);
        slice_str = num2str(slice);
        %  170704plc1deconp1_L1-t001-p03.tif
        %  D:\ProjectData\OriginMembData5\181210plc1p3\tifR\181210plc1p3_L1-t001-p02.tif
%         slice_file0 = strcat('170704plc1deconp1_L1-t', repmat('0', 1, 3-length(time_str)),...
%             time_str, '-p', repmat('0', 1, 2-length(slice_str)), slice_str, '.tif');
%         
        slice_file0 = strcat(dataset_name, '_L1-T', repmat('0', 1, 3-length(time_str)),...
            time_str, '-p', repmat('0', 1, 2-length(slice_str)), slice_str, '.tif');
        
        slice_file = fullfile(raw_memb_path, slice_file0);
        slice_nucleus_file = fullfile(raw_nucleus_path, slice_file0);
        slice_img = imread(slice_file);
        slice_nucleus = imread(slice_nucleus_file);
        embryo_arr = cat(3, embryo_arr, slice_img);
        nucleus_arr = cat(3, nucleus_arr, slice_nucleus);
        % load raw image
    end

    embryo = imresize3(double(embryo_arr), train_size, 'linear');
    nucleus = imresize3(double(nucleus_arr), train_size, 'linear');

    raw_nii = make_nii(uint8(embryo), [1,1,1],[0,0,0], 2);
    save_file = fullfile(raw_folder, strcat('membT', time_str, '.nii.gz'));
    save_nii(raw_nii, save_file)
    waitbar(i/length(validation_time_points), f);
    
    raw_nii = make_nii(uint8(nucleus), [1,1,1],[0,0,0], 2);
    save_file = fullfile(raw_nucleus_folder, strcat('membT', time_str, '.nii.gz'));
    save_nii(raw_nii, save_file)
    waitbar(i/length(validation_time_points), f);
end
disp(strcat("Finished preprocessing, image are save in ", save_validation_path));
close(f);


