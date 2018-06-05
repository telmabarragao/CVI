close all, clear all;

video = VideoReader('movie\2015-04-22-18-22-35_tase.avi');
frame_start = 9680;
frame_end = 10940;
total_frames = frame_end - frame_start;

frame = frame_start;
step = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These thresholds are "created" by us manually thru experimentation
% current best values are [90 20]

% minimum value for a pixel to be active (we assume the boat is white, so this value shouldn't be low)
Tm = 90; 
% difference between MAX and MIN: we assume the boat is white so this value should be "small"
Td = 20; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dilate_strel = strel('disk', 5);
blob_max_area = 900;
isolation_threshold = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PLEASE NOTE THAT ALL RGB VALUES ARE IN [0, 255] RANGE!

figure;

% FOR EACH FRAME
while(frame < frame_end)
    % GET THE FRAME
    img = read(video, frame);
    [height, width, nChannels] = size(img);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%-------------- VESSEL DETECTION --------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ACTIVE PIXEL BINARIZATION

    % GET EACH CHANNEL
    img_R = img(:,:,1);
    img_G = img(:,:,2);
    img_B = img(:,:,3);
    
    % INITIALIZE BW IMAGE
    BW = zeros(height, width);
    
    % FOR EACH PIXEL
    for x=1:height
        for y=1:width
            % GET THE HIGHEST AND LOWEST VALUE OF ALL COMPONENTS
            R = img_R(x,y); G = img_G(x,y); B = img_B(x,y);
            max_c = max([R,G,B]);
            min_c = min([R,G,B]);
            
            % IF CONDITION IS SATISFIED PIXEL IS ACTIVE ( = 1)
            if( max_c > Tm && (max_c - min_c) < Td)
                BW(x,y) = 1;
            end
            
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%--------------- SPATIAL VALIDATION ---------------%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % REMOVE BIG BLOBS

    BW = imdilate(BW, dilate_strel); 
    
    [lb num] = bwlabel(BW);
    
    blobs_props = regionprops(lb,'Centroid', 'Area', 'FilledImage');
    blobs_count = size(blobs_props, 1);
    
    
    
    blob_indices = find([blobs_props.Area] < blob_max_area);
    
    BW_culled = zeros(size(BW));
    BW_aux = zeros(size(BW));
  
    for n = 1:size(blob_indices,2)
        BW_aux = zeros(size(BW));
        BW_aux = BW_aux + (lb == blob_indices(n));
        BW_culled = BW_culled + BW_aux;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % REMOVE BLOBS THAT TOUCH BOUNDARIES
    
    BW_cleared = imclearborder(BW_culled);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % SHOW ONLY ISOLATED BLOBS
    
    [lb num] = bwlabel(BW_cleared);
    blobs_props = regionprops(lb, 'Centroid');
    blobs_count = size(blobs_props, 1);
    
    isolated_blobs = []; % contains indices
    
    % for each blob...
    for n=1:blobs_count
        dist = realmax; % start with distance = infinity
        for i=1:blobs_count
            if(n ~= i)
                points = [blobs_props(n).Centroid(1), blobs_props(n).Centroid(2); blobs_props(i).Centroid(1), blobs_props(i).Centroid(2)];
                dist_aux = pdist(points, 'euclidean');
                
                % replace dist if it's smaller than the current one
                if(dist_aux < dist)
                    dist = dist_aux;
                end
            end
        end
        
        if(dist > isolation_threshold)
            isolated_blobs = [isolated_blobs ; n];
        end
        
    end
    
    isolated_blobs = transpose(isolated_blobs);
    
    BW_spatial = zeros(size(BW_cleared));
    BW_aux = zeros(size(BW_cleared));
  
    for n = 1:size(isolated_blobs,2)
        BW_aux = zeros(size(BW_cleared));
        BW_aux = BW_aux + (lb == isolated_blobs(n));
        BW_spatial = BW_spatial + BW_aux;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%--------------- TEMPORAL VALIDATION ---------------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % SHOW BW
    imshow(BW_spatial);
    drawnow;
    
    
    frame = frame + step;
end







