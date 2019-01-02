function embryo = get_membrane_from_cell(embryo0)
    tem = (embryo0 >0)*1;
    SE = strel('sphere', 2);
    embryo0 = imdilate(tem, SE);
    embryo = embryo0 ~= tem;
end