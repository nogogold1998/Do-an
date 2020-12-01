function out = custominputreader(image)
    t = normalize(image, 'scale', 0.25);
    t = normalize(t, 'center') + 256/2;
    out = uint8(t);
end