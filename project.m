clear;clc;

message = randi([0,1], 10, 1);
crypt = randi([0,1], 10, 1);
encrypted = xor(message, crypt);

[message crypt encrypted];

u = linspace(0,1,10);
gu = g(u);
d = abs(u-gu);
[u;gu;d];

unifs = rand(10,1);
encoded = message.*unifs+(1-message).*g(unifs);

%%

phi_inv = @(p) norminv(p);

G = phi_inv(unifs);

scatter(unifs, G, [], [1 0 0])
hold on
scatter(unifs, phi_inv(g(unifs)), [], [0 1 0])

%%

% im = randi([0,255], 10);
im = double(rgb2gray(imread("IMG20231029135749.jpg")));
message = rgb2gray(im2double(imread("IMG20231209125836.jpg")));
message = (message<.5).*message;
% message = randi([0,1],10);
imshowpair(rescale(im), rescale(message), 'montage')

%%
alpha = 10.0;
U = rand(size(message));
gaussians = phi_inv(message.*U+(1-message).*g(U));
stego_im = clip(im+alpha*gaussians, 0, 255);

imshowpair(rescale(im), rescale(stego_im), "montage")

%%

gaussians_hat = (stego_im-im)/alpha;

g0 = phi_inv(g(U));
g1 = phi_inv(U);

x0 = abs(g0-gaussians_hat);
x1 = abs(g1-gaussians_hat);

message_hat = x0>x1;
errors = mean(abs(message-message_hat), "all");

disp("errror: "+errors)

figure(1)
imshowpair(rescale(message), rescale(message_hat), 'montage')
figure(2)
imshowpair(rescale(message), rescale(message_hat), 'diff')

%%
function gu=g(u)
    gu = (u+0.5).*(u<0.5)+(u-0.5).*(u>=0.5);
end