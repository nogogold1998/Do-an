function mask = getmask(image)
    mask = image;
    mask(~isnan(mask)) = 1;
    mask(isnan(mask)) = 0;
end

