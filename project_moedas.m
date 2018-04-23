close all, clear all;

orig = imread('Moedas1.jpg');

money = 0.0;

orderBy = 'Area';
%orderBy = 'Perimeter';
%orderBy = 'Area';

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


%get the centroid, perimeter and area information of each object
stats = regionprops(lb, 'Centroid', 'Perimeter', 'Area', 'BoundingBox');
objectCount = size(stats,1);

%create table converting the stats struct to table and add a new column
%with the numbers and delete the Bounding Box column
T = struct2table(stats);
T.ObjectNumber = zeros(objectCount, 1);
T.ObjectNumber(:) = 1:objectCount;

%transform table in figure
colnames= {'Area', 'Centroid x','Centroid y', 'BoundingBox x', 'BoundingBox y', 'BoundingBox width', 'BoundingBox height', 'Perimeter', 'Object Number'};
t = uitable('Data', T{:,:}, 'ColumnName', colnames,'RowName', T.Properties.RowNames, 'Units', 'Normalized','Position', [0, 0, 1, 1]);
saveas(t,'table.png');
close all;
ff = imread('table.png');
%fff = imresize(ff, 0.75);
figure;imshowpair(label2rgb(lb), ff, 'montage');  title('Colored Objects with centroid                            Table with values');

%for each object draw the centroid and put the number on it too
hold on;
for k=1:num
    plot(stats(k).Centroid(1), stats(k).Centroid(2), 'k.', 'markersize',25);
    txt = int2str(k);
    text(stats(k).Centroid(1)-5,stats(k).Centroid(2)-25, txt);
    area = stats(k).Area;
    money = money + whichCoin(area);
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
imshow(BW);title('Green Boundaries');
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
if(strcmp(orderBy,'Area'))
    
    TO = sortrows(T, 'Area');
    strr = ['Money = ' num2str(money)];
    figure('Name', strr);
    for k = 1 : objectCount
        cenas = TO.ObjectNumber(k);
        area = stats(cenas).Area;
        bbox = stats(cenas).BoundingBox;
        subImage = imcrop(orig, bbox);
        subplot(3,4,k);
        imshow(subImage);title(['Area = ' int2str(stats(cenas).Area)]);
        text(stats(cenas).BoundingBox(3)/2-25, stats(cenas).BoundingBox(4)+15, ['Coin ' num2str(cenas)]);
    end
end


if(strcmp(orderBy,'Perimeter'))
    
    TO = sortrows(T, 'Perimeter');
    strr = ['Money = ' num2str(money)];
    figure('Name', strr);
    for k = 1 : objectCount
        cenas = TO.ObjectNumber(k);
        bbox = stats(cenas).BoundingBox;
        subImage = imcrop(orig, bbox);
        subplot(3,4,k);
        imshow(subImage);title(['Perimeter = ' int2str(stats(cenas).Perimeter)]);
        text(stats(cenas).BoundingBox(3)/2-25, stats(cenas).BoundingBox(4)+15, ['Coin ' num2str(cenas)]);
    end
    
end


%-------------------------------------------
%func to know which coin is it
function y = whichCoin(x)
    y = 0; 
    if (9500 <= x) && (x < 12000)
        y = 0.01;
    end
    if (12000 <= x) && (x < 17000)
        y = 0.02;
    end

    if (17000 <= x) && (x < 18000)
        y = 0.1;
    end
    if (18000 <= x) && (x < 20000)
        y = 0.05;
    end
    if (20000 <= x) && (x < 22500)
        y = 0.2;
    end
    if (22500 <= x) && (x < 24500)
        y = 1;
    end
    if (24500 <= x) && (x < 27000)
        y = 0.5;
    end
    if (27000 <= x)
        y = 2;
    end
end
%-------------------------------------------





