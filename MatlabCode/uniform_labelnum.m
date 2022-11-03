function uni_seg = uniform_labelnum(seg)
% UNIFORM_LABELNUM is used to uniform skipped label numbers to consective
% numbers

labels = unique(seg(:));
labels(labels == 0) = [];
copy_seg = seg;
uni_seg = seg;
i_label = 0;
for label = labels'
    i_label = i_label + 1;
    uni_seg(copy_seg == label) = i_label;
end