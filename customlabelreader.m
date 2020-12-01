function out = customlabelreader(image, pixelClassificationThreshold, sigma)
    i2 = imgaussfilt(image, sigma);
    i3 = i2;
    i3(i3 > pixelClassificationThreshold) = 1;
    i3(i3 <= pixelClassificationThreshold) = 0;
    out = uint8(i3);
end