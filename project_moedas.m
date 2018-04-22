close all, clear all;

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

%fills any holes in the regions
% I suggest we use this, but I commented it because the teacher might not
% like it
%BW = imfill(BW, 'holes');

%objects of image
[lb num] = bwlabel(BW);

figure; imshow(label2rgb(lb));  title('Colored Objects with centroid');

%get the centroid, perimeter and area information of each object
stats = regionprops(lb, 'Centroid', 'Perimeter', 'Area');
objectCount = size(stats,1);

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

%figure;imshowpair(BWedges1,BWedges2,'montage');title('Sobel Filter                                   Canny Filter');
%figure; imshow(BWedges); title('Derivative');

%for comparing 2 histograms, these functions will help
%h1 = hist(img);
%h2 = hist(img2);
%d = pdist2(h1',h2');

%-------------------------------------------
% This section draws a green boundary around each object
figure;
imshow(BW);
hold on;
boundaries = bwboundaries(BW);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off;
%-------------------------------------------

%-------------------------------------------
% This section draws each detected object individually
% will be useful when we want to order them by some criteria
% like area, value, etc
stats = regionprops(lb,'BoundingBox');
figure;
for k = 1 : objectCount
    bbox = stats(k).BoundingBox;
    subImage = imcrop(orig, bbox);
    subplot(3,4,k);
    imshow(subImage);
end
%-------------------------------------------





