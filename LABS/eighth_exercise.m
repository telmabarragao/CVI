clear all;

N = 100;

img1 = imread('ped7c1352.tif');
%figure, imshow(img1);

[rows cols dummy] = size(img1);

npixels = rows*cols;

hr = imhist(img1(:,:,1),N)/npixels;
hg = imhist(img1(:,:,2),N)/npixels;
hb = imhist(img1(:,:,3),N)/npixels;

hist = [hr' hg' hb']
figure, bar(hist);

% 2nd image
img2 = imread('ped7c1350.tif');
%figure, imshow(img2);

[rows cols dummy] = size(img2);

npixels = rows*cols;

hr = imhist(img2(:,:,1),N)/npixels;
hg = imhist(img2(:,:,2),N)/npixels;
hb = imhist(img2(:,:,3),N)/npixels;

hist2 = [hr' hg' hb']
figure, bar(hist2);

%taiga
img3 = imread('Tiger2.jpg');
%figure, imshow(img3);

[rows cols dummy] = size(img3);

npixels = rows*cols;

hr = imhist(img3(:,:,1),N)/npixels;
hg = imhist(img3(:,:,2),N)/npixels;
hb = imhist(img3(:,:,3),N)/npixels;

hist3 = [hr' hg' hb']
figure, bar(hist3);

%%%%%%%%%%%%%%%%%%%%%%%%%

%match operation
d12 = sum(abs(hist-hist2))/length(hist);
d13 = sum(abs(hist-hist3))/length(hist);

figure, bar(d12);
figure, bar(d13);