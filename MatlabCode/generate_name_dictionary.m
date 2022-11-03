clc; clear;
name_file = "D:\ProjectData\WorkSpace_CellName0.mat";
cell_name = load(name_file);
cell_name = cell_name.CellName;

name_diction = {};

% additional cells
name_diction{1, 1} = 1; name_diction{1, 2} = 'P0';
name_diction{2, 1} = 2; name_diction{2, 2} = 'AB';
name_diction{3, 1} = 3; name_diction{3, 2} = 'P1';
count = 3;

for i = 1 : length(cell_name)
    cell_name_CELL0 = cell_name{i};
    if iscell(cell_name_CELL0)
        [I, J] = size(cell_name_CELL0);
        for i = 1 : I
            for j = 1 : J
                name = cell_name_CELL0{i, j};
                if ischar(name)
                    count = count + 1;
                    name_diction{count, 1} = count;
                    name_diction{count, 2} = name;
                end
            end
        end
    elseif ischar(cell_name_CELL0)
        count = count + 1;
        name_diction{count, 1} = count;
        name_diction{count, 2} = cell_name_CELL0;
    end
end