close all, clean all

orig = imread('Moedas1.jpg');

%transform the image from rgb to grayscale
gray = rgb2gray(orig);
[row,col] = size(gray);

BW = gray > (graythresh(gray)*255);

se1 = strel('disk', 1); %moedas4 works well with size 7
se2 = strel('disk', 6);

%perform erosion with a disk mask on image BW
BW = imerode(BW, se1);
%perform dilation with a disk mask on image BW
BW = imdilate(BW, se2);

%objects of image
[lb num] = bwlabel(BW);

figure; imshow(label2rgb(lb));  title('Colored Objects with centroid');

%get the centroid, perimeter and area information of each object
stats = regionprops(lb, 'Centroid', 'Perimeter', 'Area');

%for each object draw the centroid 
hold on;
for k=1:num
    plot(stats(k).Centroid(1), stats(k).Centroid(2), 'k.', 'markersize',25);
    drawnow;
end
hold off;

%edge detection with sobel
BWedges1 = edge(BW,'sobel');
%edge detection with canny
BWedges2 = edge(BW,'canny');

figure;imshowpair(BWedges1,BWedges2,'montage');title('Sobel Filter                                   Canny Filter');


%figure; imshow(BWedges); title('Derivative');