clear;clc;

n = 1024;
alpha = 0.05;

m = im2double(rgb2gray(imread("im2.png")));
m = double(m>0.5);
image = im2double(imread("im1.png"));
image_ycbcr = rgb2ycbcr(image);

%% encoding

U = rand(n);
encoded = m.*U + (1-m).*g(U);

gauss = norminv(encoded);

stego_image = image_ycbcr;
stego_image(:,:,1) = image_ycbcr(:,:,1)+alpha*gauss;
stego_image = clip(stego_image, 0, 1);

imshow(ycbcr2rgb(stego_image))

%% decoding

gh = (stego_image-image_ycbcr)/alpha;
gh = gh(:,:,1);

G0 = norminv(g(U));
G1 = norminv(U);

X0 = abs(G0-gh);
X1 = abs(G1-gh);

mh = double(X0>X1);
error = mean(abs(m-mh),"all");
disp(error)

subplot(1,2,1)
imshow(double(mh(:,:,1)))
subplot(1,2,2)
imshowpair(m, mh,'diff')

%%

function gu=g(u)
    gu = (u+0.5).*(u<0.5)+(u-0.5).*(u>=0.5);
end