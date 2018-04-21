close all, clear all

img = imread('rabbit.jpg');
%img = imread('cherry.bmp');
%img = imread('textsheet.jpg');
%img = imread('airplane.jpg');
%img = imread('x-ray2.jpg');

figure, imshow(img);
figure, imhist(img); hold on
thr = graythresh(img)*255;
%hold on
plot(thr,0,'r.', 'markersize', 15);
bw = img > thr;
figure, imshow(bw);

[lb num] = bwlabel(bw);