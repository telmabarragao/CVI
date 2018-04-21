clear all, close all

src_img = imread('veiculoGray.jpg');

imshow(src_img); hold on;

N=0; but=1;

while(but==1 | but==32)
    [ci,li,but]=ginput(1);
    if but == 1 %add point
        N = N+1;
        cp(N) = ci;
        lp(N) = li;
        plot(ci,li,'r.', 'MarkerSize',18); drawnow;
        if N > 1
            plot(cp(:),lp(:), 'r.-', 'MarkerSize', 8); drawnow;
        end
    end
end

cp = cp'; lp=lp';

BW = roipoly(src_img,cp, lp);
im_crop = src_img.*uint8(BW);
imagesc(im_crop); colormap gray

%-----------------------------%

I = imread('eight.tif');
figure, imshow(I); hold on;

c = [222 272 300 270 221 194];
r = [21 21 75 121 121 75];

c = [c c(1)];
r = [r r(1)];

plot(c,r,'*b-');
BW = roipoly(I,c,r);
figure, imshow(BW);

ImCrp = I.*uint8(BW);

imshow(ImCrp);

imgFinal = BW.*(double(I));
imshow(imgFinal);

%%%%%%%%%%%%%%%

A = zeros(9);
A(1:6, 1:6) = 1;
B = zeros(9);
B(5:9, 5:9) = 1;
% line 5 to 9, column 5 to 9

figure; imagesc(A); colormap gray
figure; imagesc(B); colormap gray

subplot(1,2,1);imagesc(A); colormap gray;
subplot(1,2,2);imagesc(B); colormap gray;

% NOT = ~A
% AND = A .* B (. means element wise operation, * is multiplication)
% OR = A|B
% XOR = xor(A,B)
% AND and NOT = A & (~B)