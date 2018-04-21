orig = imread('Moedas1.jpg');

%transform the image from rgb to grayscale
gray = rgb2gray(orig);

BW = gray > (graythresh(gray)*255);

se1 = strel('disk', 1); %moedas4 works well with size 7
se2 = strel('disk', 6);

%perform erosion with a disk mask on image BW
BW = imerode(BW, se1);
%perform dilation with a disk mask on image BW
BW = imdilate(BW, se2);

[lb num] = bwlabel(BW);

figure; imshow(label2rgb(lb));  title('Colored Objects with centroid');

stats = regionprops(lb, 'Centroid', 'Perimeter', 'Area');

hold on;
for k=1:num
    plot(stats(k).Centroid(1), stats(k).Centroid(2), 'k.', 'markersize',25);
    drawnow;
end
hold off;

BWedges = edges(BW);
figure; imshow(BWedges); title('Derivative');