%% used to generate pre-segmentation ground truth for BMC revision

tiff_path = 'C:\Users\bcc\Desktop\PartialGroundTruth\RawImages';
nuc_path = "D:\ProjectCode\DTwatershed\data\aceNuc\CD170704plc1deconp1.csv";
nii_save_path = 'C:\Users\bcc\Desktop\PartialGroundTruth\RawImages\NiiFile';

ts = [24,34,44,54,64,74];
for t = ts
    t_str = num2str(t);
    raw_path = fullfile(tiff_path, strcat('membt', repmat('0', 1, 3-length(t_str)),t_str,'.tif'));
    seg_path = fullfile(tiff_path, strcat('membt', repmat('0', 1, 3-length(t_str)),t_str,'s.tif'));
    
    % resize image
    raw_memb = loadtiff(raw_path);
    seg_memb = loadtiff(seg_path);
    raw_memb_resized = imresize3(raw_memb, size(seg_memb));
    
    % overlaid with nucleus image
    nuc_stack = getNuc(t, size(seg_memb), nuc_path) > 0;
    raw_memb_resized(nuc_stack) = 255;
    
    % uniform label numbers
    seg_memb = uniform_labelnum(seg_memb);
    
    memb_nii = make_nii(raw_memb_resized, [1,1,1],[0,0,0], 2);
    save_file = fullfile(nii_save_path, strcat('membt', repmat('0', 1, 3-length(t_str)),t_str,'.nii'));
    save_nii(memb_nii, save_file)
    seg_nii = make_nii(seg_memb, [1,1,1],[0,0,0], 2);
    save_file = fullfile(nii_save_path, strcat('membt', repmat('0', 1, 3-length(t_str)),t_str,'s.nii'));
    save_nii(seg_nii, save_file)
    
end