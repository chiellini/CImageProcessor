clc; clear 
%% delete empty slices and cut one embryo into LR and HR volumes. Prepare 
% data for GAN LR-->HR transformation
% number_embryos = 120; % 1~~
% embryo_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\181210plc1p1\validation\raw";
% save_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3DHalf\cycleGAN\181210plc1p1";
% embryo_files = dir(fullfile(embryo_folder, "*.nii.gz"));
% 
% % read a few stacks first and fine the embryo boundary
% sum_stack = [];
% for i = 1:15
%     single_file = embryo_files(i);
%     tem = niftiread(fullfile(single_file.folder, single_file.name));
%     if i == 1
%         sum_stack = tem;
%     else
%         sum_stack = sum_stack + tem;
%     end
% end
% [sr, sc, sz] = size(sum_stack);
% slice_pixel_sum = squeeze(sum(sum_stack, [1, 2]))'/sz;
% slice_mask = slice_pixel_sum > 500;
% [labeledVector, numRegions] = bwlabel(slice_mask);
% measurements = regionprops(labeledVector, [1:sz], 'Area', 'PixelValues');
% maximum_length = 0;
% slice_group = [];
% for k = 1 : numRegions
%   if measurements(k).Area >= maximum_length
%       maximum_length = measurements(k).Area;
%       slice_group = measurements(k).PixelValues;
%   end
% end
% up_slice = max(min(slice_group) - 3, 1);
% down_slice = min(max(slice_group) + 3, sz);
% if rem(down_slice - up_slice+1, 2) ~= 0 
%     down_slice = down_slice - 1;
% end
% middle_slice = (up_slice + down_slice - 1) / 2;
% 
% % cut layers and save to different folders "A"--> LR; "B"-->HR
% disorder_number = randperm(number_embryos);
% f = waitbar(0, 'Please wait...');
% for i = 1: number_embryos
%     embryo_order = disorder_number(i);
%     embryo_file = fullfile(embryo_folder, "membT" + num2str(embryo_order) + ".nii.gz");
%     embryo_data = niftiread(embryo_file);
%     HR_embryo = embryo_data(1:sr, 1:sc, middle_slice+1:down_slice);
%     LR_embryo = embryo_data(1:sr, 1:sc, up_slice:middle_slice);
%     % save evaluation
%     
%     HR_embryo = imresize3(HR_embryo, [192, 256, 64]);
%     LR_embryo = flip(imresize3(LR_embryo, [192, 256, 64]), 3); % flip through the 3rd dimension
%     % change the data into specific size ()
%     if i < number_embryos * 0.1
%         niftiwrite(LR_embryo, fullfile(save_folder, "valA", "18plc2_memb_T"+num2str(embryo_order)+"_A.nii.gz"));
%         niftiwrite(HR_embryo, fullfile(save_folder, "valB", "18plc2_memb_T"+num2str(embryo_order)+"_B.nii.gz"));
%     elseif (i >= number_embryos * 0.1) && (i < number_embryos * 0.3)
%         niftiwrite(LR_embryo, fullfile(save_folder, "testA", "18plc2_memb_T"+num2str(embryo_order)+"_A.nii.gz"));
%         niftiwrite(HR_embryo, fullfile(save_folder, "testB", "18plc2_memb_T"+num2str(embryo_order)+"_B.nii.gz"));        
%     else
%         niftiwrite(LR_embryo, fullfile(save_folder, "trainA", "18plc2_memb_T"+num2str(embryo_order)+"_A.nii.gz"));
%         niftiwrite(HR_embryo, fullfile(save_folder, "trainB", "18plc2_memb_T"+num2str(embryo_order)+"_B.nii.gz"));
%     end
%     waitbar(i/number_embryos, f);
% end
% close(f);


%% Generate binary raw and bindary volume
% number_embryos = 120; % 1~~
% embryo_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\DMapResult\181210plc1p2\Raw";
% seg_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\DMapResult\181210plc1p2\Segmentation";
% save_upper_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3DHalf\cycleGAN\FromMapNet\Upper";
% save_lower_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3DHalf\cycleGAN\FromMapNet\Lower";
% 
% embryo_files = dir(fullfile(embryo_folder, "*.nii.gz"));
% 
% % read a few stacks first and fine the embryo boundary
% sum_stack = [];
% for i = 1:15
%     single_file = embryo_files(i);
%     tem = niftiread(fullfile(single_file.folder, single_file.name));
%     if i == 1
%         sum_stack = tem;
%     else
%         sum_stack = sum_stack + tem;
%     end
% end
% [sr, sc, sz] = size(sum_stack);
% slice_pixel_sum = squeeze(sum(sum_stack, [1, 2]))'/sz;
% slice_mask = slice_pixel_sum > 500;
% [labeledVector, numRegions] = bwlabel(slice_mask);
% measurements = regionprops(labeledVector, [1:sz], 'Area', 'PixelValues');
% maximum_length = 0;
% slice_group = [];
% for k = 1 : numRegions
%   if measurements(k).Area >= maximum_length
%       maximum_length = measurements(k).Area;
%       slice_group = measurements(k).PixelValues;
%   end
% end
% up_slice = max(min(slice_group) - 3, 1);
% down_slice = min(max(slice_group) + 3, sz);
% if rem(down_slice - up_slice+1, 2) ~= 0 
%     down_slice = down_slice - 1;
% end
% middle_slice = (up_slice + down_slice - 1) / 2;
% 
% % cut layers and save to different folders "A"--> LR; "B"-->HR
% disorder_number = randperm(number_embryos);
% f = waitbar(0, 'Please wait...');
% for i = 1: number_embryos
%     embryo_order = disorder_number(i);
%     embryo_file = fullfile(embryo_folder, "membT" + num2str(embryo_order) + ".nii.gz");
%     seg_file = fullfile(seg_folder, "membT" + num2str(embryo_order) + "CellwithMmeb.nii.gz");
%     embryo_data = niftiread(embryo_file);
%     seg_data = niftiread(seg_file)~=0;
%     % membrane data from cell to membrane
%     se = strel('sphere', 2);
%     dilatedBW = imdilate(seg_data, se);
%     seg_data = double(dilatedBW ~= seg_data);
%     
%     upper_embryo = embryo_data(1:sr, 1:sc, middle_slice+1:down_slice);
%     lower_embryo = embryo_data(1:sr, 1:sc, up_slice:middle_slice);
%     upper_seg = seg_data(1:sr, 1:sc, middle_slice+1:down_slice);
%     lower_seg = seg_data(1:sr, 1:sc, up_slice:middle_slice);
%     
%     % resize and flip volumes
%     upper_embryo = imresize3(upper_embryo, [192, 256, 64]);
%     lower_embryo = flip(imresize3(lower_embryo, [192, 256, 64]), 3);
%     upper_seg = double(imresize3(upper_seg, [192, 256, 64], "linear")~=0);
%     lower_seg = flip(double(imresize3(lower_seg, [192, 256, 64], "linear")~=0), 3); % flip through the 3rd dimension
%     % change the data into specific size ()
%     if i < number_embryos * 0.1
%         niftiwrite(upper_embryo, fullfile(save_upper_folder, "valA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(upper_seg, fullfile(save_upper_folder, "valB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true);
%         niftiwrite(lower_embryo, fullfile(save_lower_folder, "valA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(lower_seg, fullfile(save_lower_folder, "valB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true);
%     elseif (i >= number_embryos * 0.1) && (i < number_embryos * 0.3)
%         niftiwrite(upper_embryo, fullfile(save_upper_folder, "testA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(upper_seg, fullfile(save_upper_folder, "testB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true);
%         niftiwrite(lower_embryo, fullfile(save_lower_folder, "testA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(lower_seg, fullfile(save_lower_folder, "testB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true);       
%     else
%         niftiwrite(upper_embryo, fullfile(save_upper_folder, "trainA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(upper_seg, fullfile(save_upper_folder, "trainB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true);
%         niftiwrite(lower_embryo, fullfile(save_lower_folder, "trainA", "18plc2_T"+num2str(embryo_order)+"_A.nii"), "Compressed", true);
%         niftiwrite(lower_seg, fullfile(save_lower_folder, "trainB", "18plc2_T"+num2str(embryo_order)+"_B.nii"), "Compressed", true); 
%     end
%     waitbar(i/number_embryos, f);
% end
% close(f);


%% Change *.nii file to *.nii.gz file
% source_folder = "D:\ProjectData\dataSetLabel\ToBeTrained\Data3D\181215plc1p1\raw";
% embryo_files = dir(fullfile(source_folder, "*.nii"));
% for i = 1:length(embryo_files)
%     single_file = embryo_files(i);
%     tem = niftiread(fullfile(single_file.folder, single_file.name));
%     niftiwrite(tem, fullfile(source_folder, single_file.name), "Compressed", true)
% end
