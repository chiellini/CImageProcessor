clc; clear;

slice_nums = [70, 68, 68];
embryo_names = {'170704plc1p2', '181210plc1p3', '190314plc1p3'};
raw_folder = "C:\Users\bcc\Desktop\MapNetEvaluation\Results\ResultReal\raw";
target_folder = "C:\Users\bcc\Desktop\MapNetEvaluation\OtherProgram\CellProfiler\Data";

options.append = false;
options.overwrite = true;

tps = [24, 34, 44, 54, 64, 74, 84];
for i = 1 : length(embryo_names)
    embryo_name = embryo_names{i};
    slice_num = slice_nums(i);
    for tp = tps
        %% get raw membrane data
        raw_file = fullfile(raw_folder, embryo_name, "raw", strcat("membT", num2str(tp), ".nii"));
        nuc_file = fullfile(raw_folder, embryo_name, "AceNucleus", strcat("CD", embryo_name, ".csv"));
        raw = niftiread(raw_file);
        target_size = size(raw);
        target_file = fullfile(target_folder, embryo_name, "RawMemb", strcat("membT", num2str(tp), ".tif"));
        if ~exist(fullfile(target_folder, embryo_name,  "RawMemb"), 'dir')
            mkdir(fullfile(target_folder, embryo_name, "RawMemb"))
        end
        if exist(target_file)
            delete(target_file)
        end
        for slice = 1 : target_size(3)
            imwrite(uint8(raw(:, :, slice)), target_file, 'WriteMode','append')
        end
        
        %% get nucleus data
        fid = fopen(nuc_file, 'r');
        if fid == -1
            error('Error, these is no such file');

        else
            formatSpec = '%*s %s %u16 %*s %*s %*s %*s %*s %4.1f %4.1f %4.1f %*s %*s %*s';
            s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
            nucName0 = s{1};    %string cell array
            nucTime0 = s{2};    %which time point the cell exists
            nucZ0 = s{3};       %nuc absolute location
            nucY0 = s{4};       %exchange the number of x and y
            nucX0 = s{5};
        end
        fclose(fid);
        xyreduceRatio = target_size(1) / 512;
        zreduceRatio = target_size(3) / slice_num;
        [nucName, nucLabel] = get_name_dictionary();
        indx0 = find(nucTime0 == tp);
        names = nucName0(indx0);
        nucXAtT = uint16(nucX0(indx0) * xyreduceRatio);
        nucYAtT = uint16(nucY0(indx0) * xyreduceRatio);
        nucZAtT = uint16(nucZ0(indx0) * zreduceRatio);
        segNuc = zeros(target_size);
        for i = 1 : length(nucXAtT)
            indx = find(strcmp(nucName, names(i)));
            segNuc(nucXAtT(i), nucYAtT(i),nucZAtT(i)) = nucLabel(indx);
        end
        target_nuc_file = fullfile(target_folder, embryo_name, "SegNuc", strcat("nucT", num2str(tp), ".tif"));
        
        sphere_el = strel("sphere", 3);
        segNuc = imdilate(segNuc, sphere_el);
        if ~exist(fullfile(target_folder, embryo_name, "SegNuc"), 'dir')
            mkdir(fullfile(target_folder, embryo_name, "SegNuc"))
        end
        if exist(target_nuc_file)
            delete(target_nuc_file)
        end
        segNuc(1:2, :, :) = 10000;segNuc(:, 1:2, :) = 10000;segNuc(:, :, 1:2) = 10000;
        segNuc(end-1:end, :, :) = 10000;segNuc(:, end-1:end, :) = 10000;segNuc(:, :, end-1:end) = 10000;
        
        for slice = 1 : target_size(3)
            imwrite(uint16(segNuc(:, :, slice)), target_nuc_file, 'WriteMode','append')
        end
        tp
    end
end
