clear;clc;

% load image and downsize to (R,C) gray image
im = imresize(rgb2gray(imread("IMG20231029135749.jpg")), [1024,1024]);
% reduce to 4-bit image
im = idivide(im, 16,"floor");
% encode each 4-bit pixel with hamming code to 7-bit vectors
im_bin = encode(dec2bin(im, 4)-'0',7,4);

message = [1 0 1 1]
C = encode(message,7,4)

E = [ 0 0 0 1 0 0 0];
CC = bitxor(C,E)

decode(CC,7,4)

%%

function message = ECC(path, N)
    % load image and downsize to (R,C) gray image
    im = imresize(rgb2gray(imread(path)), [N,N]);
    % reduce to 4-bit image
    im = idivide(im, 16,"floor");
    % encode each 4-bit pixel with hamming code to 7-bit vectors
    message = encode(dec2bin(im, 4)-'0',7,4);
end