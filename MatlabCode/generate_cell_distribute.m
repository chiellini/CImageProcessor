clc; clear;
tps = [24, 34, 44, 54, 64, 74, 84];
gt_folder = "D:\ProjectData\AllDataPackedWithLabel\170614plc1p1\SegCell"
gt_names = dir(fullfile(gt_folder, '*.nii.gz'));
cells = [];
for tp = 1 : length(gt_names)
    gt_name = gt_names(tp);
%     gt_file = fullfile(path, strcat("membt", num2str(tp),"CellwithMmeb.nii.gz"));
    gt_file = fullfile(gt_folder, gt_name.name);
    GT = niftiread(gt_file);
    cells = [cells,length(unique(GT))-1];
end
cells = sort(cells)