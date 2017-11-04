clc
clear all
src = 'C:\Users\Subham\Desktop\Offline _2_Online\Data\';
% Search for .jpg images in the given directory
D = dir([src,'*.jpg']);
flag = 0;
for i = 1:length(D)
    %% Read the image
    I = imread([src,D(i).name]);
    % Binarize the image
    I = im2bw(I,graythresh(I));
    % Invert Image to black background
    I = ~I;
    % Pad the Image with zeros
    I = padarray(I,[20, 20],0,'both');
    save('I');
    % Skeletonization using 3-D Medial Axis TransForm
    X = system('python skeletonize.py');
    load('I.mat');
    I = bwareaopen(I,40);
    % Search for EndPoints
    P_End = bwmorph(I,'endpoints');
    [Y, X] = find(P_End==1); P_End = [Y, X];
    % If there are no EndPoints 
    % For example for converting a handwritten Zero
    % create an endpoint at the left-most position
    if(length(P_End)==0)
        [Y, X] = find(I == 1);
        X_1 = X(find(Y == min(Y)));
        Y_1 = min(Y);
        I(X_1(1),Y_1(1))=0;
    end
    %% Remove Spur Pixels
    % Store the Junction Points
    P_Junc = bwmorph(I,'branchpoints');
    [Y, X] = find(P_Junc==1); P_Junc = [Y, X];
    % Remove all Junction Points to avoid un-reliable pixels
    for i = 1:length(Y)
        I(Y(i),X(i)) = 0;
    end
    I = bwareaopen(I, 20);
    for i = 1:length(Y)
        I(Y(i),X(i)) = 1;
    end
    %%
    % Store all EngPoints in a Queue and in a X-Wise sorted
    P_End = bwmorph(I,'endpoints');
    [Y_End, X_End] = find(P_End==1); P_End = [Y_End, X_End];
    % Remove all Junction Points to avoid un-reliable pixels
    for i = 1:length(Y)
        I(Y(i), X(i)-1) = 0;
        I(Y(i)-1,X(i)-1) = 0;
        I(Y(i)+1,X(i)-1) = 0;
        I(Y(i)-1,X(i)) = 0;
        I(Y(i),X(i)) = 0;
        I(Y(i)+1,X(i)) = 0;
        I(Y(i)-1,X(i)+1) = 0;
        I(Y(i),X(i)+1) = 0;
        I(Y(i)+1,X(i)+1) = 0;
    end
    % Now remove spurious pixels
    I = bwareaopen(I,10);
%     imshow(I,[])
%     pause;
    % Convert the image to uint8
    I = I * 255;
    I = I / 255;
    % Deque from P_End and start tracking
    current_Y = P_End(1,1);
    current_X = P_End(1,2);
    P_End(1,:) = [];
    REC = []; Memory = [];
    % Tracking is done until there is no pixel left to labelled in the image
    while(length(P_End)~=0)
        try
        % Pixel Value = 2 represents the pixel has been recorded
            REC = [REC;[current_Y, current_X]]; % REC stores all the tracked coordinates
            % Label Current Pixel
            I(current_Y, current_X) = 2;
            % Form a 3*3 neighborhood to track
            neighborhood = I(current_Y-1:current_Y+1,current_X-1:current_X+1);
            % Calculate the Sum of the surrounding pixels
            Sum = sum(neighborhood(:)) - 2;
            % If Sum is 1 or 3 the current pixel in on a straight-line
            if(Sum == 1 || Sum == 3)
                [A, B] = find(neighborhood==1);
                % Find the next connected pixel and assign to the current pixel
                % value
                current_Y = current_Y + A - 2;
                current_X = current_X + B - 2;
                % If Sum is 2 or 0 it is an EndPoint
            else if(Sum == 2 || Sum == 0)
                    %% Check the pixel is a genuine endpoint or a junction-point
                    % which has been removed i.e. if the pixel belongs to P_End
                    val = sum(ismember(P_End,[current_Y, current_X],'rows'));
                    % if it belongs to P_End val will not be zero
                    if(val > 0)
                    % Dequeue from P_End and assign it to the current pixel 
                        pos = find(ismember(P_End,[current_Y, current_X],'rows')==1);
                        % check Memory
                        P_End(pos,:) = [];
                        P_End = [Memory;P_End];
                        Memory = [];
                        P_End = sortrows(P_End,2);
    %                     pause;
                        current_Y = P_End(1,1);
                        current_X = P_End(1,2);
                        P_End(1,:) = [];
                        % If the pixel is a junction-point
                    else
                        %% take a neighbourhood
                        width = 20;
                        neighborhood = I(current_Y-width:current_Y+width,current_X-width:current_X+width);
%                         imtool(neighborhood,[])
%                         pause;
                        % Get the C Points
                        ref_pixels = bwmorph((neighborhood==2),'endpoints');
                        [Y, X] = find(ref_pixels==1); ref_pixels = [Y , X];

                        N_End = bwmorph((neighborhood==1),'endpoints');
                        [Y, X] = find(N_End==1);N_End = [Y, X];
                        sample = neighborhood;
                        for k = 2:(2*width)
                            for n = 2:(2*width)
                                neighborhood(n, k) = 0;
                            end
                        end
                        [Y, X] = find(neighborhood==1);C_Points = [Y, X]
                        %%
                        %%%%%%%%%%%%%%%%%% In case the algorihm is stuck
                        %%%%%%%%%%%%%%%%%% lower the neighbour hood size
                        %%%%%%%%%%%%%%%%%% and try again%%%%%%%%%%%%%%%%%
                        % If the algorithm is stuck the catch block with
                        % catch an exception and set flag = 1 for
                        % rechecking
                        if( flag == 1)
                            if(~isempty(find(neighborhood == 1)))
                                width = 5; % reduced neighbourhood size
                                neighborhood = I(current_Y-width:current_Y+width,current_X-width:current_X+width);
%                                 imtool(neighborhood,[])
%                                 pause;
                                % Get the C Points
                                ref_pixels = bwmorph((neighborhood==2),'endpoints');
                                [Y, X] = find(ref_pixels==1); ref_pixels = [Y , X];

                                N_End = bwmorph((neighborhood==1),'endpoints');
                                [Y, X] = find(N_End==1);N_End = [Y, X];
                                sample = neighborhood;
                                for k = 2:(2*width)
                                    for n = 2:(2*width)
                                        neighborhood(n, k) = 0;
                                    end
                                end
                                [Y, X] = find(neighborhood==1);C_Points = [Y, X]
                                flag = 0;
                            else
                                display('No C Points')
                            end
                        end
                        %% Get the EndPoints in Neighbourhood
                        N_End = setdiff(N_End, C_Points,'rows');
                        N_End(:,1) = N_End(:,1) + current_Y - width - 1;
                        N_End(:,2) = N_End(:,2) + current_X - width - 1;
                        if(length(C_Points(:,1)) > 1)
                            %% calcuate intersection angles 
                            angles = abs(find_angles(ref_pixels, C_Points, (2 * width) + 1))
                            % choose the point with ngle of intersection
                            % closest to 180 degrees. If So angle tends to 0
                            pos = C_Points(angles == min(angles),:);
                            stored_Val = pos;
                            next_X = pos(2) + current_X - width - 1;
                            next_Y = pos(1) + current_Y - width - 1;
                            %                         display(stored_Val);
                            %% choose the end-point associated to the chosen pixel
                            % it is to be noted that we choose a neighbourhood
                            % of 40 pixels to avoid noise due to skeleton
                            % pixels. These pixels are the considered pixels are the C-Points

                            % end-point associated witht the chosen pixel will
                            % have least euclidean distance from that pixel
                            dist = [];
                            for k = 1:length(N_End)
                                dist = [dist;pdist2([next_Y,next_X],N_End(k,:),'euclidean')];
                            end
                            pos = N_End(find(dist == min(dist)),:)
                            % assign it to the current pixel
                            current_X = pos(2); current_Y = pos(1);
                            %% now the left out elements in the junction point are inserted into Memory
                            C_Points = setdiff(C_Points, stored_Val,'rows');
                            for m = 1:length(C_Points(:,1))
                                dist = [];
                                for k = 1:length(N_End)
                                    pt = C_Points(m,:);
                                    pt(1) = pt(1) + current_Y - width - 1;
                                    pt(2) = pt(2) + current_X - width - 1;
                                    % find end-points associated with the
                                    % C-Points
                                    dist = [dist;sum(pdist2(pt,N_End(k,:),'euclidean'))];
                                end
                                pos = N_End(find(dist == min(dist)),:);
                                Memory = [Memory;pos]
                            end
                            %                         imtool(I,[]);
                            %                        pause;

                        % if there is only one untracked element no need for
                        % calculations and is simply dequeue and tracked
                        else if(length(C_Points(:,1)) == 1)
                                current_X = N_End(2); current_Y = N_End(1);
                                % if all the elements in a junction point are
                                % already tracked deque and track the rest
                            else if(length(C_Points(:,1)) == 0)
                                    % Track the points in the memory
                                    P_End = [Memory;P_End];
                                    Memory = [];
                                    P_End = sortrows(P_End,2);
    %                                 pause;
                                    current_Y = P_End(1,1);
                                    current_X = P_End(1,2);
                                    P_End(1,:) = [];
                                end
                            end
                        end
                    end
                end
            end
            % catch exception and try to solve
        catch
            display('Caught an Exception, trying to solve');
            flag = 1;
        end
        imshow(I,[])
        pause(0.001)
    end
end
    
