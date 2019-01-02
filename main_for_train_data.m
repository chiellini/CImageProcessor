
train_data = false;  % data for training
slice_num = 70;  % # slices in stack image
to_shape = [512, 512, 70]; % shape of the target file
label_times = [1:8:100];
label_times = setdiff([2:10:92], label_times); % for test images

%% data path 
embryo_path = 'D:\ProjectData\originMembData1\170704plc1p2\tifR'; % Origin slice images
seg_path = 'D:\ProjectCode\DTwatershed\results\resultWithMerge\matFile'; % Original 3D segmented results as resized .mat file
save_memb_path = 'D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\170704plc1p2_memb1';


%% Build data folder
if train_data
    save_memb_path = fullfile(save_memb_path, 'Train');
    if ~isfolder(save_memb_path)
        mkdir(save_memb_path);
        mkdir(fullfile(save_memb_path, 'Image'));
        mkdir(fullfile(save_memb_path, 'Mask'));
    end
else
    save_memb_path = fullfile(save_memb_path, 'Test');
    if ~isfolder(save_memb_path)
        mkdir(save_memb_path);
        mkdir(fullfile(save_memb_path, 'Image'));
        mkdir(fullfile(save_memb_path, 'Mask'));
    end
end

%% prepare data
img_lists = dir(fullfile(embryo_path, '*.tif'));
seg_lists = dir(fullfile(seg_path, '*.mat'));

f = waitbar(0, 'Please wait...');
for t = label_times
    %% prepare raw membrane stack
    embryo = [];
    for i = 1 : slice_num
        img = imread(fullfile(embryo_path, img_lists(slice_num * (t-1) + i).name));
        img = imresize(double(img), to_shape(1:2));
        embryo = cat(3, embryo, uint8(img));
    end
    memb_nii = make_nii(embryo, [1, 1, 1], [0,0,0], 2);
    nl = length(num2str(t));
    save_file = fullfile(save_memb_path, 'Image', strcat('membT', num2str(t), '.nii'));
    save_nii(memb_nii, save_file);
    
    %% for segmentation reference
    % deal with label larger than 256
    load(fullfile(seg_path, seg_lists(t).name), 'membSeg');
    membSeg0 = close_embryo(membSeg);
    membSeg0 = get_membrane_from_cell(membSeg0);
    membSeg0 = imresize3(membSeg0*1, [to_shape(1:2), slice_num]);
    membSeg0 = ( membSeg0 > 0.5)*1;
    
    seg_nii = make_nii(membSeg0, [1,1,1],[0,0,0], 2);
    save_file = fullfile(save_memb_path, 'Mask', strcat('membT', num2str(t), 's.nii'));
    save_nii(seg_nii, save_file)
    waitbar(t/max(label_times), f);
end
disp(strcat("Finished preprocessing, image are save in ", save_memb_path));
close(f);

