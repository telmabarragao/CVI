close all, clear all;

fileToRead= 'Moedas4.jpg';

orig = imread(fileToRead);

red = orig(:,:,1); % Red channel
green = orig(:,:,2); % Green channel
blue = orig(:,:,3); % Blue channel
a = zeros(size(orig, 1), size(orig, 2));
just_red = cat(3, red, a, a);
%just_green = cat(3, a, green, a);
%just_blue = cat(3, a, a, blue);
%back_to_original_img = cat(3, red, green, blue);
figure, imshow(just_red), title('Red channel')

money = 0.0;

%variable used to see if its a circle
%Area/Perimeter should be equals to R/2, so i'll use A/P = BBox.width/4
%(diameter/2)/2
arpe = 0.0;
bbw = 0.0;

orderBy = 'Area';
%orderBy = 'Perimeter';
%orderBy = 'Area';

%transform the image from rgb to grayscale
gray = rgb2gray(just_red);
[row,col] = size(gray);

BW = gray > (graythresh(gray)*255);
%moedas3 - BW = gray > 139;
se1 = strel('disk', 8); %moedas4 works well with size 8
se2 = strel('disk', 4); %moedas4 works well with size 4

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
%saveas(t,'table.png');
%close all;
ff = imread('table.png');
%figure; imshow(t);
fff = imresize(ff, 0.75);
figure;%imshowpair(label2rgb(lb), ff, 'montage');  title('Colored Objects with centroid                            Table with values');
imshow(label2rgb(lb));

%for each object draw the centroid and put the number on it too
Tdist = NaN(objectCount, objectCount);
hold on;
for k=1:num
    %draw the point
    plot(stats(k).Centroid(1), stats(k).Centroid(2), 'k.', 'markersize',25);
    txt = int2str(k);
    text(stats(k).Centroid(1)-5,stats(k).Centroid(2)-25, txt);
    
    %relative distance
    Tdist(1, k) = k;
    Tdist(k, k) = 0;
    for j=k+1:num
        %stats(k).Centroid(1) stats(k).Centroid(2)
        %plot([stats(k).Centroid(1) stats(j).Centroid(1)], [stats(k).Centroid(2) stats(j).Centroid(2)], '-');
        %plot([stats(k).Centroid(1) stats(k).Centroid(2)], [stats(j+1).Centroid(1) stats(j+1).Centroid(2)], '-');
        %plot([stats(k).Centroid(1) stats(k).Centroid(2)], [stats(j+2).Centroid(1) stats(j+2).Centroid(2)], '-');
        %txt = ['k' int2str(k) 'j' int2str(j)];
        %text(stats(j).Centroid(1)-5,stats(j).Centroid(2)-(25+k*10+j*10), txt);
        
        X = [stats(k).Centroid(1),stats(k).Centroid(2);stats(j).Centroid(1),stats(j).Centroid(2)];
        d = pdist(X,'euclidean');
        Tdist(j, k) = d;
    end
%     positionVector1 = [0.1, 0.2, 1, 1];    % position of first subplot
%     subplot('Position',positionVector1);
%     plot([0 0], [200 200], '-');
    
    %calculate money
    area = stats(k).Area;
    perimeter = stats(k).Perimeter;
    arpe = area/perimeter;
    bbw = (stats(k).BoundingBox(3))/4;
    if (arpe < bbw+10) && (arpe > bbw-10)
        money = money + whichCoin(area, fileToRead);
    end
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

figure; 
imshow(orig);title('Select a Coin');
hold on;
[x,y] = ginput(1);
for k=1:objectCount
    if (x > stats(k).BoundingBox(1)) && (x < (stats(k).BoundingBox(1) + stats(k).BoundingBox(3)))
        if (y > stats(k).BoundingBox(2)) && (y < (stats(k).BoundingBox(2) + stats(k).BoundingBox(4)))
           for j=1:objectCount
               if k < j
                    txt = ['dist = ' num2str(Tdist(j, k))];
                    text(stats(j).Centroid(1)-70,stats(j).Centroid(2)-(25), txt);
               end
               if k > j
                    txt = ['dist = ' num2str(Tdist(k, j))];
                    text(stats(j).Centroid(1)-70,stats(j).Centroid(2)-(25), txt);
               end
               plot([stats(k).Centroid(1) stats(j).Centroid(1)], [stats(k).Centroid(2) stats(j).Centroid(2)], '-');
            end
        end
    end
end
hold off;

%-------------------------------------------
%func to know which coin is it
function y = whichCoin(x, file)

    if(strcmp(file, 'Moedas4.jpg') == 1)
        
        y = 0; 
        if (9000 <= x) && (x < 14000)
            y = 0.01;
        end
        if (14000 <= x) && (x < 15000)
            y = 0.02;
        end

        if (15000 <= x) && (x < 16000)
            y = 0.1;
        end
        if (16000 <= x) && (x < 17000)
            y = 0.05;
        end
        if (17000 <= x) && (x < 18000)
            y = 0.2;
        end
        if (18000 <= x) && (x < 20000)
            y = 1;
        end
        if (20000 <= x) && (x < 21000)
            y = 0.5;
        end
        if (21000 <= x)
            y = 2;
        end
        
    end
   
    if(strcmp(file, 'Moedas4.jpg') == 0)
        
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
    
end
%-------------------------------------------

%-------------------------------------------
% function dummy = drawDists(nCoin, objectCount)
%     for j=1:objectCount
%         plot([stats(nCoin).Centroid(1) stats(j).Centroid(1)], [stats(nCoin).Centroid(2) stats(j).Centroid(2)], '-');
%     end
%     dummy = 0;
% end
