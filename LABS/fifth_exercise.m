img = imread('BrainMRI_Axial.jpg');
imshow(img); title('Original');

imgg = rgb2gray(img);
%figure, imhist(imgg);

BW = imgg>60;
figure;
subplot(2,3,1);
imshow(BW); title('Original BW');

se = strel('disk',3);

BW1 = imerode(BW, se);
subplot(2,3,2); imshow(BW1); title('Erosão');

BW2 = imdilate(BW,se);
subplot(2,3,3); imshow(BW2); title('Dilatação');

BW3 = imopen(BW, se);
subplot(2,3,4); imshow(BW3); title('Abertura');

BW4 = imclose(BW, se);
subplot(2,3,5); imshow(BW4); title('Fecho');

[lb num] = bwlabel(BW3); 
figure;
subplot(1,3,1); imshow(label2rgb(lb));title('Labels');

stats = regionprops(lb);
areas = [stats.Area];
[dummy indM] = max(areas);
imgBr = (lb == indM);
subplot(1,3,2);imshow(imgBr);title('Maior area');

%subplot(1,3,3);imshow(imgg.*uint8(imgBr));title('Cerebro');

subplot(1,2,3);imshow(BW3);
hold on
for k=1:num
    plot(stats(k).Centroid(1), stats(k).Centroid(2), 'r.', 'markersize',25);
    drawnow;
end
hold off

%centroids = cat(1, stats.Centroid);
%subplot(1,3,3);imshow(BW3);title('Centroides');
%hold on
%plot(centroids(:,1), centroids(:,2), 'g.')
%hold off


