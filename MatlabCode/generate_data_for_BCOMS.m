%% used to generate pre-segmentation ground truth for BMC revision

tiff_path = 'C:\Users\bcc\Desktop\BMCevaluation\BCOMS\PrepareDta';
save_tiff_path = 'C:\Users\bcc\Desktop\BMCevaluation\BCOMS\PrepareDta\CombinedData';
nuc_path = "D:\ProjectCode\DTwatershed\data\aceNuc\CD170704plc1deconp1.csv";

ts = [24,34,44,54,64,74];
for tt = ts
    memb_combine = [];
    nuc_combine = [];
    tt_str = num2str(tt);
    for t = tt-1:tt+1
        t_str = num2str(t);
        raw_path = fullfile(tiff_path, strcat('membt', repmat('0', 1, 3-length(t_str)),t_str,'.tif'));

        % resize image
        raw_memb = loadtiff(raw_path);
        seg_memb = loadtiff('C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\RawImages\membt024s.tif');
        raw_memb_resized = imresize3(raw_memb, size(seg_memb));
    
        % overlaid with nucleus image
        nuc_stack = getNuc(t, size(seg_memb), nuc_path);
        memb_combine = cat(3, memb_combine, raw_memb_resized);
        nuc_combine = cat(3, nuc_combine, nuc_stack);
    end
    memb_path = fullfile(save_tiff_path, strcat('membt', repmat('0', 1, 3-length(tt_str)),tt_str,'.tif'));
    nucleus_path = fullfile(save_tiff_path, strcat('nucleust', repmat('0', 1, 3-length(tt_str)),tt_str,'.tif'));
    saveastiff(memb_combine, memb_path);
    saveastiff(uint8(nuc_combine), nucleus_path);
end