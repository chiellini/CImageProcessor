%This program is used to generate images used for manually segmentation.
%The raw image are dowmsample with ratio 0.5 at x-y plane. After isosample
%on z direction, the image stack is reduced by 0.8. The result image
%includeing:
%[raw membrane image,nuclei information, automatically segmentation reference]

%% 
clc; clear;

slice_num = 70;                     %slice number on each stack
resolution.xy = 0.09;
resolution.z = 0.43;
rescale = 0.4;

%% data path 
embryo_path = 'D:\ProjectData\originMembData1\170704plc1p2\tifR';
nuc_path = 'D:\ProjectData\originMembData1\170704plc1p2\aceNuc\CD170704plc1deconp1.csv';
seg_path = 'D:\ProjectCode\DTwatershed\results\resultWithMerge\matFile';
save_memb_path = 'D:\ProjectData\dataSetLabel\toBeLabelled\170704plc1p1_memb1';

%% prepare data
img_lists = dir(fullfile(embryo_path, '*.tif'));
imInfo = imfinfo(fullfile(embryo_path, img_lists(1).name));
Width = imInfo.Width;
Height = imInfo.Height;

to_shape = [];
to_shape = [ceil(rescale*Height), ceil(rescale*Width), ceil(rescale * slice_num * resolution.z/resolution.xy)]; % shape of the target file

label_times = [1:4:57, 63:6:135];
for t = label_times
    display(strcat('Processing T:', num2str(t), '....'));
    
    %% prepare raw membrane stack
    embryo0 = [];
    for i = 1 : slice_num
        img = imread(fullfile(embryo_path, img_lists(slice_num * (t-1) + i).name));
        img = imresize(double(img), [ceil(rescale*Height), ceil(rescale*Width)], 'bilinear');
        embryo0 = cat(3, embryo0, img);
    end
    
    % save membrane image
    embryo0 = imresize3(double(embryo0), to_shape);
    nuc_stack = getNuc(t, size(embryo0), nuc_path);
    nuc_stack = imresize3(nuc_stack, to_shape, 'nearest');
    embryo00 = embryo0;
    embryo00(nuc_stack ~= 0) = 255;
    memb_nii = make_nii(uint8(embryo00), [1,1,1], [0,0,0], 2);
    save_file = fullfile(save_memb_path, strcat('membT', num2str(t), '.nii'));
    save_nii(memb_nii, save_file);
    
    %  Get largest conencted membrane
    nL = 3 - length(num2str(t));
    load_folder = fullfile( seg_path, strcat('T', repmat('0', 1,nL),num2str(t), '_membSeg.mat'));
    membSeg0 = load(load_folder, 'membSeg');
    membSeg = membSeg0.membSeg;
    membSeg = uint16(imresize3(double(membSeg), size(embryo00),'nearest'));
    membSeg = uniform_labelnum(membSeg);
    %tem = membSeg;
    %uni_membSeg = uint8(rem(membSeg, 255));
    
    seg_nii = make_nii(membSeg, [1,1,1],[0,0,0], 4);  %512---uint16
    save_file = fullfile(save_memb_path, strcat('membT', num2str(t), 's.nii'));
    save_nii(seg_nii, save_file)
end

%% write paramters into *.txt file
save_parameters_files = fullfile(save_memb_path, 'parameters.txt');
fid = fopen(save_parameters_files, 'wt');
fprintf(fid, 'Data path\n');
fprintf(fid, 'Raw embryo images: %s\n', embryo_path);
fprintf(fid, 'Reference segmentation: %s\n\n', seg_path);

fprintf(fid, 'Parameters used in generating data\n');
fprintf(fid, 'label_times:');
fprintf(fid, '%5.2d', label_times);
fclose(fid);
