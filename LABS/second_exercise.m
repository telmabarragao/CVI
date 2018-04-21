src_img = imread('veiculoGray.jpg');

iterations = 100;

[L C] = size(src_img);

while true
    for i=1:iterations
    image(:,:,i) = imnoise(src_img, 'salt & pepper', 0.002*i);
    figure(1); imshow(image(:,:,i));
    end
    
    i=1;
end

denoised = median(image, 3);
figure, imagesc(denoised); colormap gray