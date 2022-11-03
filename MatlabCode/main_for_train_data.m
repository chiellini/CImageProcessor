

%% data path
dataset_name = '170614plc1p2';
embryo_path = fullfile('D:\ProjectCode\PresegmentationLabel\data\membrane', dataset_name); % Origin slice images
annotation_path = fullfile('D:\ProjectData\dataSetLabel\manual\FinishedAnnotation','170704plc1p2'); % segmentation path
save_memb_path = fullfile('D:\ProjectData\dataSetLabel\ToBeTrained\Data3D', dataset_name); % path for saveing data


%% Build data folder
raw_folder = fullfile(save_memb_path, 'raw');
if ~isfolder(raw_folder)
    mkdir(raw_folder);
end
mask_folder = fullfile(save_memb_path, 'mask');
if ~isfolder(mask_folder)
    mkdir(mask_folder); 
end
target_cell_folder = fullfile(save_memb_path, 'cells');
if ~isfolder(target_cell_folder)
    mkdir(target_cell_folder); 
end


%% prepare data
img_lists = dir(fullfile(embryo_path, '*.mat'));
seg_lists = dir(fullfile(annotation_path, '*sr.nii'));

f = waitbar(0, 'Please wait...');
for t = 1:length(seg_lists)
    % Get time point in annoations
    PAT = '[\d]';
    file_name = seg_lists(t).name;
    time_point = file_name(regexp(file_name, PAT));
    
    
    % transform annotation from semantic annotation to membrane
    mask_file = fullfile(annotation_path, file_name);
    mask_nii = load_nii(mask_file);
    mask_cell = mask_nii.img;
    % Preprocess annotation. Close all single cell mask and combine all
    % cell boundaries into one membrane stack
    memb_annotation_stack = zeros(size(mask_cell));
    labels = unique(mask_cell(:));
    labels(labels == 0) = [];
    for label = labels'
        % Close each cell
        one_cell_mask = mask_cell == label * 1;
        SE = strel('sphere', 2);
        one_cell_mask_closed = imclose(one_cell_mask, SE);
        mask_cell(one_cell_mask~=0) = 0;
        mask_cell(one_cell_mask_closed~=0) = label;
        one_cell_mask_boundary = imdilate(one_cell_mask_closed, SE);
        % Generate membrane stack
        memb_annotation_stack(one_cell_mask_boundary ~= 0) = 1;
        memb_annotation_stack(one_cell_mask_closed ~= 0) = 0;
    end
    % delete small spots
    memb_labels = bwlabeln(memb_annotation_stack);
    all_labels = unique(memb_labels(:));
    if length(all_labels)~=2
        for label = all_labels(2:end)'
            label_mask = memb_labels == label;
            label_area = sum(label_mask(:));
            if label_area < 2000
                memb_annotation_stack(label_mask) = 0;
            end
        end
    end
    
    % Save final target cell instance segmentation results
    cell_nii = make_nii(mask_cell, [1,1,1],[0,0,0], 4);
    save_file = fullfile(target_cell_folder, strcat('membT', time_point, 'cell.nii'));
    save_nii(cell_nii, save_file)
    
    % Save membrane mask
    seg_nii = make_nii(memb_annotation_stack, [1,1,1],[0,0,0], 2);
    save_file = fullfile(mask_folder, strcat('membT', time_point, 's.nii'));
    save_nii(seg_nii, save_file)
    
    
    %% Generate raw image stack
    % load raw image
    file_name = fullfile(embryo_path, strcat('membt', repmat('0', 1, 3-length(time_point)), time_point, '.mat'));
    memb_raw = load(file_name, 'embryo');
    memb_raw = memb_raw.embryo;
    embryo = imresize3(double(memb_raw), size(memb_annotation_stack));
    
    raw_nii = make_nii(uint8(embryo), [1,1,1],[0,0,0], 2);
    save_file = fullfile(raw_folder, strcat('membT', time_point, '.nii'));
    save_nii(raw_nii, save_file)
    waitbar(t/max(length(seg_lists)), f);
end
disp(strcat("Finished preprocessing, image are save in ", save_memb_path));
close(f);

