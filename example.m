clear; clc; close all;

%% --- Parameters ---
alpha = 0.02;             % Strength of embedded noise (tune for visibility)
key = 12345;              % Key for pseudorandom noise generator

coverFile  = 'IMG20231209125836.jpg';   % Path to cover image
secretFile = 'IMG20231029135749.jpg';  % Path to secret image
% stegoFile  = 'stego.png';   % Output stego image

%% --- Load and preprocess images ---
coverImg = im2double(imread(coverFile));
secretImg = im2double(imread(secretFile));

% Resize secret image to match cover dimensions
[rows, cols, ~] = size(coverImg);
secretImg = imresize(secretImg, [rows cols]);

% Convert secret image to binary bitstream
secretBits = secretImg(:) > 0.5;  % threshold for binary message
bitCount = numel(secretBits);

%% --- Pseudorandom spreading sequence ---
rng(key);                         % Seed RNG
pnSeq = 2 * randi([0 1], bitCount, 1) - 1;  % ±1 sequence

% Map bits (0 -> -1, 1 -> +1)
msgSignal = double(secretBits) * 2 - 1;

% Spread the message with PN sequence
spreadSignal = msgSignal .* pnSeq;

%% --- Embed into cover image ---
coverVec = coverImg(:);
coverVec = coverVec(1:bitCount);   % Ensure equal size

stegoVec = coverVec + alpha * spreadSignal;
stegoImg = coverImg;
stegoImg(1:bitCount) = stegoVec;   % Embed back

%% --- Save and show results ---

figure;
subplot(1,3,1); imshow(coverImg); title('Cover Image');
subplot(1,3,2); imshow(secretImg); title('Secret Image');
subplot(1,3,3); imshow(stegoImg); title('Stego Image');


%% --- Generate same pseudorandom sequence ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% ENCODING %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng(key);
pnSeq = 2 * randi([0 1], bitCount, 1) - 1;  % ±1 sequence

%% --- Extract spread signal ---
signalSegment = stegoVec(1:bitCount);

% Correlation with PN sequence
corrVals = signalSegment .* pnSeq;

% Recover bits by thresholding
recoveredBits = corrVals > 0;

%% --- Reshape into secret image size ---
recoveredImg = reshape(double(recoveredBits), size(secretImg));

%% --- Display result ---
figure;
subplot(1,2,1); imshow(stegoImg); title('Stego Image');
subplot(1,2,2); imshow(recoveredImg); title('Recovered Secret');