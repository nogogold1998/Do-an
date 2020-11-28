function showImageWithLabel(table)
    collection = cell.empty();
    for i = 1:height(table)
        image = normalize(table{i, 1}{1, 1}, 'range', [0 1]);
        label = double(table{i,2}{1, 1}) -1;
        c = labeloverlay(image,label,'ColorMap', [0.2 0.2 0.2; 0 0 1]);
        whos c
        collection{i} = c(:,:,1);
    end
    whos collection
    imshow(horzcat(collection{:}));
end

