clc;

% load ground truth
GT = load_nii('C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\GroundTruth\ZHAO1\MatlabProcessed\membt074sr.nii');
GT = GT.img;
RACE = load_nii('C:\Users\bcc\Desktop\BMCevaluation\AllResults\RACE\membt074s.nii');
RACE = RACE.img;
labels = unique(GT(:));
labels(labels == 0)= [];
uni_race = zeros(size(RACE));
tem_race = RACE;
for label = labels'
    cell_mask = GT == label;
    label_in_race = tem_race(cell_mask);
    label_in_race(label_in_race == 0) = [];
    if isempty(label_in_race)
        continue;
    end
    mode_label = mode(label_in_race(:));
    uni_race(tem_race == mode_label) = label;
    tem_race(tem_race == mode_label) = 0;
end

other_labels = RACE;
other_labels(uni_race~=0) = 0; 
others = unique(other_labels(:));
others(others==0) = [];
if ~isempty(others)
    largest_label = max(labels);
    for add_label = others'
        largest_label = largest_label + 1;
        uni_race(RACE==add_label) = largest_label;
    end
end

fprintf('#labels in original RACE: %d\n', length(unique(RACE(:))) - 1 );
fprintf('#labels in unified RACE: %d\n', length(unique(uni_race(:))) - 1);
fprintf('#labels in GT: %d\n', length(labels));


seg_nii = make_nii(uni_race, [1,1,1],[0,0,0], 4);  %512---uint16
save_file = 'C:\Users\bcc\Desktop\BMCevaluation\AllResults\RACE\MatlabProcessed\membt074s.nii';
save_nii(seg_nii, save_file)