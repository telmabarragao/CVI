clear all, close all;

%Parameters
SZ = 80; % size of downsampled images
DF = [2 2]; % decimationfactor for plot(OF)

[I,map] = imread('fish.gif', 'frames', 'all');

I = squeeze(I(:,:,:,1:end-1));

[s1,s2,s3] = size(I);
img = zeros(size(I));
for t = 1:s3
    rgb = map(double(reshape(I(:,:,t), [], 1))+1,:);
    aux = cat(3,...
        reshape(rgb(:,1),s1,s2),...
        reshape(rgb(:,2),s1,s2),...
        reshape(rgb(:,3),s1,s2));
       img(:,:,t) = rgb2gray(aux); %convert rgb to gray
end

%save img img
%load img

figure; hold on
for k = 1 : size(img,3)
    imagesc(img(:,:,k)); colormap gray;
end

%downsample image
aux = imresize(img,SZ*[1 1]);

%compute optical flow for first frame
%there are some libraries that are needed!!!! a toolbox or something
% Image Processing Toolbox
obj = opticalFlowLK;
flow = estimateFlow(obj, aux(:,:,1));
% % Optical flow in original image size
% flow2 = opticalFlow(imresize(flow.Vx, [s1,s2]), imresize(flow.Vy, [s1
% s2]));

%Cycle through all frames

for t = 2:s3
    %compute optical flow of frame t
    flow = estimateFlow(obj, aux(:,:,t));
    
    %show optical flow
    figure(1), colormap gray
    hold off, imagesc(aux(:,:,t)), hold on
    plot(flow, 'DecimationFactor', DF);
    drawnow
    pause
end
