function [message, im] = ECC(path, N)
    im = imread(path);
    if size(im,3) == 3
        im = rgb2gray(im);
    end
    % load image and downsize to (R,C) gray image
    im = imresize(im, [N,N]);
    % reduce to 4-bit image
    im = idivide(im, 16,"floor");
    % encode each 4-bit pixel with hamming code to 7-bit vectors
    message = encode(dec2bin(im, 4)-'0',7,4);
end