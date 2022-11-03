function [cell_IoUs, cell_num, label_FN, label_FP] = calculate_cell_IoU(ground_truth, segmentation)
% CALCULATE_CELL_IoU is used to calculate the dice ratio between two stacks(multi-label)
% INPUT:
%  ground_truth, segmentation:  two image(or 3D) with multiple labels

% OUTPUT:
%  dice_ratio:  DICE coefficient

gt_labels = unique(ground_truth(:));
gt_labels(gt_labels == 0) = [];
seg_labels = unique(segmentation);
seg_labels(seg_labels == 0) = [];

common_labels = intersect(gt_labels, seg_labels);
FN = setdiff(gt_labels, common_labels);
FP = setdiff(seg_labels, common_labels);

IoUs = [];
for label = common_labels'
    
    % labels are uniformed with function UNIFOR_LABELS, labels locate at the
    % same area
    GT_mask = ground_truth == label;
    SEG_mask = segmentation == label;
    one_IoU = sum(and(GT_mask, SEG_mask), "all")/sum(or(GT_mask, SEG_mask), "all");
    IoUs = [IoUs,one_IoU];
end

cell_IoUs = IoUs;
cell_num = length(common_labels);
label_FN = length(FN); % FN and FP cells without applying 
label_FP = length(FP);
