function image = customlabelreader(imagePath, pixelClassificationThreshold, sigma)
    i = imread(imagePath);
    i1 = double(i);
    i2 = imgaussfilt(i1, sigma);
    i3 = i2;
    i3(i3 > pixelClassificationThreshold) = 1;
    i3(i3 <= pixelClassificationThreshold) = 0;
    image = uint8(i3);
end