function memb = pans_get_memb_from_cell(cell)
% Used to get memb mask from  cell segmentations

[sr, sc, sz] = size(cell);
cell2 = permute(cell, [3, 2, 1]);
memb1 = zeros(size(cell));
memb2 = zeros(size(cell2));
for i = 1 : sz
    memb1(:, :, i) = boundarymask(cell(:, :, i));
end
    
for i = 1 : sr
    memb2(:, :, i) = boundarymask(cell2(:, :, i));
end
memb2 = permute(memb2, [3, 2, 1]);

memb = memb1 + memb2;
memb = uint8(memb ~= 0);