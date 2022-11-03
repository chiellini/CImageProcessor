function [split_ratio, merge_ratio] = get_split_merge(gt, seg)
% GET_SPLIT_MERGE is used to get the split and merge ratio in the segmentation

gt_labels = unique(gt(:));
gt_labels(gt_labels == 0) = [];
seg_labels = unique(seg);
seg_labels(seg_labels == 0) = [];

%% get split ratio
split_num = 0;
for gt_label = gt_labels'
    labels = unique(seg(gt == gt_label));
    labels(labels == 0) = [];
    updated_labels = [];
    if isempty(labels)
        continue;
    end
    
    for label = labels'
        if sum((seg == label) & (gt == gt_label), "all") > 0.1 * sum((seg == label) | (gt == gt_label), "all")
            updated_labels = [updated_labels, label];
        end
    end
    if length(updated_labels) > 1
        split_num = split_num + 1;
    end
end
split_ratio = split_num * 1.0 / length(gt_labels);
split_ratio = min(split_ratio, 2 - split_ratio);

%% get merge ratio
merge_num = 0;
for seg_label = seg_labels'
    labels = unique(gt(seg == seg_label));
    labels(labels == 0) = [];
    updated_labels = [];
    if isempty(labels)
        continue;
    end
    for label = labels'
        if sum((seg == seg_label) & (gt == label), "all") > 0.1 * sum((gt == label) | (seg == seg_label), "all")
            updated_labels = [updated_labels, label];
        end
    end
    if length(updated_labels) > 1
        merge_num = merge_num + 1;
    end
end
merge_ratio = merge_num * 1.0 / length(gt_labels);
merge_ratio = min(merge_ratio, 2 - merge_ratio);
