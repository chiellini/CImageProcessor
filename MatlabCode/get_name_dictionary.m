function [nucName, nucLabel] = get_name_dictionary()
    fid = fopen("D:\ProjectCode\PreprocessLib\number_dictionary.csv", 'r');
    if fid == -1
        disp('Error, these is no such file');
    else
        formatSpec = '%s %u16';
        s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
        nucName = s{1};    %string cell array
        nucLabel = s{2};    %which time point the cell exists
    end
  