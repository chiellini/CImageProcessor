

%% This program is used to postprocess ground truth to filter lister noise
% spots.
clc; clear all;
ground_truth = load_nii('C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\GroundTruth\ZHAO1\membt074sr.nii');
ground_truth = ground_truth.img;

close_ground_truth = ground_truth;
labels = unique(ground_truth(:));
labels(labels == 0) = [];
SE = strel('sphere', 3);
for label = labels'
    tem = ground_truth == label;
    close_ground_truth(tem) = 0;
    close_tem = imclose(tem, SE);
    close_ground_truth(close_tem) = label;
end

seg_nii = make_nii(close_ground_truth, [1,1,1],[0,0,0], 4);  %512---uint16
save_file = 'C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\GroundTruth\ZHAO1\MatlabProcessed\membt074sr.nii';
save_nii(seg_nii, save_file)
