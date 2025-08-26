S = [1 0 1 1];

im = im2double(imread("IMG20231029135749.jpg"));
im = imresize(im, [16,16]);

imshow(im)

imwrite(im, "toy_img.png")

%%
clear;clc
% path = "toy_img.png";
path =  "IMG20231209125836.jpg";
% path_to_secret = "Original_Doge_meme.jpg";
path_to_secret = "toy_img.png";
secret_size = 16;
block_size = 64;

toy = im2double(imread(path));
[toy_secret, secret_image] = ECC(path_to_secret, secret_size);
S = toy_secret(:);

enc = ssis_encode(path, S, 5, 123,block_size);

figure(1)
subplot(1,2,1)
imshow(toy)
subplot(1,2,2)
imshow(enc)

% figure(2)
% imshow(abs(enc-toy))


%% Decode
% imwrite(enc, "toy_secret.png")
decoded = ssis_decode("toy_secret.png", length(S), 123, block_size);
S_hat = reshape(decoded, size(toy_secret));
S_hat = decode(S_hat, 7, 4);
S_hat = bit2int(S_hat',4);
S_hat = im2double(reshape(S_hat, secret_size, secret_size));

figure(2)
imshowpair(secret_image, S_hat, 'montage')
disp(mean(abs(double(secret_image)-S_hat), 'all'))
