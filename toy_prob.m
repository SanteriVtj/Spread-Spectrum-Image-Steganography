clear;clc

path =  "IMG20231209125836.jpg";

% imwrite([1 0; 1 1], "small.png")
% path_to_secret = "small.png";
path_to_secret = "Original_Doge_meme.jpg";

secret_size = 128;
block_size = 8;
alpha = 1;

toy = im2double(imread(path));

%% Decoding
[toy_secret, secret_image] = ECC(path_to_secret, secret_size);
S = toy_secret(:);

%% Nondecoding

toy_secret = imread(path_to_secret);
toy_secret = imresize(rgb2gray(toy_secret), [secret_size, secret_size]);
secret_image = toy_secret;
si = idivide(toy_secret, 16,"floor");
si = dec2bin(si, 4)-'0';
S = si(:);

%%
[enc, params] = ssis_encode(path, S, alpha, 123,block_size);

figure(1)
subplot(1,2,1)
imshow(toy)
subplot(1,2,2)
imshow(enc)

imwrite(enc, "toy_secret.png")

[decoded, paramsd] = ssis_decode("toy_secret.png", length(S), 123, alpha, block_size);

%% Decoding | Incorrect bits 4429/16384

S_hat = reshape(decoded, size(toy_secret));
S_hat = decode(S_hat, 7, 4);
disp("Wrong bits: "+sum(abs(S_hat-decode(toy_secret,7,4)),'all'))
S_hat = bit2int(S_hat',4);
S_hat = im2double(reshape(S_hat, secret_size, secret_size));

%% Nondecoding | Incorrect bits 6703/16384

S_hat = reshape(decoded, size(si));
disp("Wrong bits: "+sum(abs(S_hat-si),'all'))
S_hat = bit2int(S_hat', 4);
S_hat = im2double(reshape(S_hat, secret_size, secret_size));

%%

figure(2)
subplot(1,2,1)
imshow(rescale(secret_image))
subplot(1,2,2)
imshow(rescale(S_hat))

disp(mean(abs(double(secret_image)-S_hat), 'all'))