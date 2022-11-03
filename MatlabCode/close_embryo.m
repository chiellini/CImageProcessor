function embryo_closed = close_embryo(embryo)
% CLOSE_ENBRYO closes gap between different part of one cell
    %INPUT:
    %  embryo:  embryo with gaps
    %OUTPUT:
    %  embryo_closed: embryo without gaps

    labels = unique(embryo(:));
    labels(labels==0) = [];
    embryo_closed = embryo;
    for idx = 1:length(labels)
        label = labels(idx);
        one_cell_embryo0 = 1*(embryo == label);
        SE = strel('sphere', 4);
        one_cell_embryo = imclose(one_cell_embryo0, SE);
        update_pixel = one_cell_embryo ~= one_cell_embryo;
        embryo_closed(update_pixel) = label;
    end
end