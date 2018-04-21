clear all, close all;

frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame = 1048;
step = 1;

str1 = sprintf(str,'',1,'jpg');

I = imread(str1);
[L,C,Z] = size(I);

vid4D = zeros([240 320 3 nFrame/step]);
%figure; hold on;


%for k = 1 : step : nFrame
 %   str1 = sprintf(str, '', k, 'jpg');
  %  img = imread(str1);
   % vid4D(:,:,:,k)=img;
    %imshow(img); drawnow;
    %disp('');
%end

bkg = median(vid4D,4);
figure; imshow(uint8(bkg));


%METHOD 2
bkg = zeros(size(I));
alfa = 1;

bkg2 = zeros(size(I));

for k = 1 : step : nFrame
    str1 = sprintf(str,'',k,'jpg');
   % str2= sprintf(str,'', nFrame - k, 'jpg');
    img = imread(str1);
   % img2 = imread(str2);
    Y = img;
    %Z = img2;
    bkg = alfa * double(Y) + (1-alfa) * double(bkg);
    %bkg2 = alfa* double(Z) + (1-alfa) * double(bkg2);
    
   % mix = 0.9*bkg + 0.1*bkg2;
    
   % imshow(uint8(mix)); drawnow;
   imshow(uint8(bkg)); drawnow;
end

% equalizaçao de histograma
% I = imread('tire.tif');
% J = histeq(I,64);
% figure; imshow(J);
%
%

