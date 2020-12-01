function showImageWithLabel(table)
    padding = 20;
    pairs = cell.empty();
    h = height(table);
    [imHeight, imWidth] = size(table{1, 1}{1, 1}(:,:,1));
    n = ceil(sqrt(h));
    for i = 1:n
        pair = cell.empty();
        for j = 1:n
            x = (i - 1) * n + j;
            if x <= h
                bands = {table{x, 1}{1, 1}(:,:,1), table{x,1}{1,1}(:,:,2)};
                bands = {normalize(double(bands{1}), 'range', [0 1]), normalize(double(bands{2}), 'range', [0 1])};
                label = table{x,2}{1, 1};
                c = labeloverlay(uint8(bands{2}*255),label,'ColorMap', [0.7 0.7 0.7; 0 0 1]);
            else
                c = ones(imHeight, imWidth, 3) * 255;
                bands = {c, c};
            end
            r = ones(imHeight, imWidth, 3)*255;
            temp = cat(2,bands{1}.*r, bands{2}.*r, c, ones(imHeight, padding, 3)*255);
            pair{j} = cat(1, temp, ones(padding, width(temp), 3) * 255);
        end
        pairs{i} = cat(2,pair{:,:,:});
    end
    imshow(cat(1, pairs{:}));
end

