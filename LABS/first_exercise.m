clear all, close all

img = imread('eight.tif');
figure;
imagesc(img); colormap gray
imshow(img); colormap gray

%noise = round(randn(size(imgg))*50);
%imageN = max(min(imgg+uint8(noise),255),0);
%imageN = imnoise(img, 'gaussian',0,0.05);
%imageN = imnoise(img, 'salt & pepper', 0.6);
figure;
imshow(imageN);

%h = fspecial('average');
%imageF = imfilter(imageN, h);
%imageF = medfilt2(imageN);
%imageF = medfilt2(imageF);

%imageF1 = filter2(fspecial('average', 3),imageN);
%figure;
%imagesc(imageF1); colormap gray;

%imageF1 = imfilter(imageN, fspecial('average', 3));
%figure;
%imshow(imageF1);

imageF2 = medfilt2(imageN);
figure;
imshow(imageF2);