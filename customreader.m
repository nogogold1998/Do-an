function C = customreader(filename)
    img = imread(filename);
    C = uint8(img + 1);
end