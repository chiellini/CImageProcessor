
close all; clear

%% data path
%D:\ProjectData\OriginMembData2\180913plc1p1\tif
dataset_name = '180913plc1';
embryo_no = 'p1';
slice_num = 70;



validation_num = 15;
train_time_points = [24:10:74];
nucleus_path = fullfile('D:\ProjectData\OriginMembData2\180913plc1p1\tif'); % Origin slice images
raw_train_path = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D',...
    '170704plc1p2','training', 'raw'); % for finding size
save_validation_path = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\Nucleus',...
    strcat(dataset_name, embryo_no));


%% Build data folder
raw_folder = fullfile(save_validation_path);
if ~isfolder(raw_folder)
    mkdir(raw_folder);
else
    rmdir(raw_folder, 's');
    mkdir(raw_folder);
end

%% Get training data size
train_raw_lists = dir(fullfile(raw_train_path, '*.nii'));
raw_nii = load_nii(fullfile(raw_train_path, train_raw_lists(1).name));
train_raw_img = raw_nii.img;
train_size = size(train_raw_img);

%% Prepare data for traing without repeat time points in training
tem_timepoints = setdiff([1:95], train_time_points);
rand_indx = randi([1, length(tem_timepoints)], 1, validation_num);
validation_time_points = tem_timepoints(rand_indx);

f = waitbar(0, 'Please wait...');
validation_time_points = 24:10:74;
for  i = 1:length(validation_time_points)
    
    time_point = validation_time_points(i);
    raw_arr = [];
    for slice = 1 : slice_num
        tem_time_str = num2str(time_point);
        time_str = strcat(repmat('0', 1, 3 - length(tem_time_str)), tem_time_str);
        tem_slice_str = num2str(slice);
        slice_str = strcat(repmat('0', 1, 2 - length(tem_slice_str)), tem_slice_str);
        image_name = strcat(dataset_name,embryo_no, '_L1-t', time_str, '-p', slice_str, '.tif');
        slice_arr = imread(fullfile(nucleus_path, image_name));
        raw_arr = cat(3, raw_arr, slice_arr);
    end
    
    resize_raw = imresize3(raw_arr, train_size, 'linear');
    
    raw_nii = make_nii(uint8(resize_raw), [1,1,1],[0,0,0], 2);
    save_file = fullfile(save_validation_path, strcat('membT', tem_time_str, '.nii'));
    save_nii(raw_nii, save_file)
    waitbar(i/length(validation_time_points), f);
end
disp(strcat("Finished preprocessing, image are save in ", save_validation_path));
close(f)

