function [nucleusStack] = getNuc(timePoint, memb_size, nucPath)
%GETNUC is to extact nucleus location information with ACEtree
%INPUT
%timePoint:     series image stack on which time point you want
%nucPath:       filePath of the nucleus from ACETree. E.g:'.\data\aceNuc\CD170704plc1deconp1.csv'

%OUTPUT
%nucleusStack   nucleus stack which has labels at the nucleus, from which
%               we can find their names 
%divRelationMatrix  division relation of nucleus in the nucleus stack;

%% read .csv files
    %open the file and read location information
    
origin_size = [512, 712, 70];
reduces = memb_size ./ origin_size;
fid = fopen(nucPath, 'r');
if fid == -1
    disp('Error, these is no such file');
else
    formatSpec = '%*s %s %u16 %*s %*s %*s %*s %*s %4.1f %4.1f %4.1f %*s %*s %*s';
    s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
    nucTime0 = s{2};    %which time point the cell exists
    nucZ0 = s{3};       %nuc absolute location
    nucY0 = s{4};       %exchange the number of x and y
    nucX0 = s{5};
end
fclose(fid);

%% Construct nucleus seeds for watershed segmentation
%extract location information matrix at one time point. And the matrix should have
%non-zero value at the nuc. What's more, the larger the order of the
%nuclei, it should have larger value.

indx0 = find(nucTime0 == timePoint);
%cellNameAtT = nucName(indx);
nucXAtT = uint16(nucX0(indx0)*reduces(1));
nucYAtT = uint16(nucY0(indx0)*reduces(2));
nucZAtT = uint16(nucZ0(indx0)*reduces(3));

    %construct nucleus matrix
nucleusStack = zeros(memb_size);
indx = sub2ind(memb_size, nucXAtT, nucYAtT, nucZAtT);
for i = 1:numel(indx)
    nucleusStack(indx(i)) = 255;
end
SE = strel('sphere', 3);
nucleusStack = imdilate(nucleusStack, SE);
