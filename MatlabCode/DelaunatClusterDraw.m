%% This function is used to draw the demo for Delaunay triangularization

clc; clear; close all

% This is used for processing pans segmentation
dismap_nii = 'C:\Users\bcc\Desktop\membt044.nii.gz';
dismap_img = load_nii(dismap_nii);
dismap_img = dismap_img.img;

slice_img = dismap_img(:,:,81);
figure(1); imshow(double(slice_img)/15);
colormap(jet(256));
colorbar;


largest_dis = slice_img == 15;

figure(2); imshow(largest_dis);


%% integrate intensiity along the lines of the local minima
D = bwdist(largest_dis);  % distance transform
[sr, sc] = size(D);
local_max = imregionalmax(D);  % local maximum
figure(3); imshow(local_max)
[max_x, max_y] = find(local_max);
TRI = delaunay(max_x, max_y);  

% get all lines
line_list = [TRI(1, 1), TRI(1, 2); TRI(1, 1), TRI(1, 3); TRI(1, 2), TRI(1, 3)];
for tri_num = 2:length(TRI)
    % for first line
    start_point = TRI(tri_num, 1); end_point = TRI(tri_num,2);
    if (~ismember([start_point, end_point], line_list, 'rows')) &&(~ismember([end_point, start_point], line_list, 'rows')) 
        line_list = [line_list; start_point, end_point];
    end
    
    start_point = TRI(tri_num, 1); end_point = TRI(tri_num,3);
    if (~ismember([start_point, end_point], line_list, 'rows')) &&(~ismember([end_point, start_point], line_list, 'rows')) 
        line_list = [line_list; start_point, end_point];
    end
    
    start_point = TRI(tri_num, 2); end_point = TRI(tri_num,3);
    if (~ismember([start_point, end_point], line_list, 'rows')) &&(~ismember([end_point, start_point], line_list, 'rows')) 
        line_list = [line_list; start_point, end_point];
    end
end

% integrate along line
line_weight = [];
for line_num = 1 : length(line_list)
    weight = 0;
    start_point = line_list(line_num, 1);
    end_point = line_list(line_num, 2);
    if start_point == 49 || end_point == 49
        a = 1
    end
    Pmatrix = [round(linspace(max_x(start_point),max_x(end_point),400));
               round(linspace(max_y(start_point),max_y(end_point),400))]';
    Pmatrix = unique(Pmatrix, 'rows');
    if length(Pmatrix) > 2
        for p_num = 2:length(Pmatrix)-1
            weight = weight + largest_dis(Pmatrix(p_num, 1), Pmatrix(p_num, 2));
        end
    end
    boun_start = [max_x(start_point)==1, max_x(start_point)==sr,max_y(start_point)==1, max_y(start_point)==sc];
    boun_end = [max_x(end_point)==1,max_x(end_point)==sr, max_y(end_point)==1, max_y(end_point)==sc];
    if (sum(boun_start) ~= 0) && (sum(boun_end) ~= 0)
       weight = 0;
    end
    
    line_weight = [line_weight; weight];
end

%% plot final image
figure(4); imshow(largest_dis); hold on;
plot(max_y, max_x, '.', 'MarkerSize',12, 'Color', 'r'); hold on;
for i = 1 : length(line_weight)
    start_point = line_list(i, 1);
    end_point = line_list(i, 2);
    if line_weight(i) > 0
%         plot([max_y(start_point), max_y(end_point)], [max_x(start_point), max_x(end_point)], ....
%            'color', 'red');
%         hold on
    else
        plot([max_y(start_point), max_y(end_point)], [max_x(start_point), max_x(end_point)], ....
           'color', 'green', 'LineWidth', 2);
        hold on
    end
    
end

seg_nii = make_nii(dismap_img, [1,1,1],[0,0,0], 512);  %512---uint16
save_file = fullfile('PansResult.nii.gz');
save_nii(seg_nii, save_file)