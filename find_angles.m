function angles = find_angles(ref, Points)
%% get the reference pixels 
% one pixel has to be at the boundary of the image so it x or y coordinate
% has to be equal to 1 or 41
% rest are calculated accordingly
if(~isempty(find(ref(:,2)==1)))
    pos = find(ref(:,2)==1);
    ref_1 = ref(pos,:);
    ref_2 = ref(find(ref(:,2)==setdiff(ref(:,2),1)),:);
    ref_X = ref_2(2) - ref_1(2);
    ref_Y = ref_2(1) - ref_1(1);
    
else if(~isempty(find(ref(:,1)==1)))
        pos = find(ref(:,1)==1);
        ref_1 = ref(pos,:);
        ref_2 = ref(find(ref(:,1)==setdiff(ref(:,1),1)),:);
        ref_X = ref_2(2) - ref_1(2);
        ref_Y = ref_2(1) - ref_1(1);
        
    else if(~isempty(find(ref(:,2)==41)))
            pos = find(ref(:,2)==41);
            ref_1 = ref(pos,:);
            ref_2 = ref(find(ref(:,2)==setdiff(ref(:,2),41)),:);
            ref_X = ref_2(2) - ref_1(2);
            ref_Y = ref_2(1) - ref_1(1);
        else if(~isempty(find(ref(:,1)==41)))
                pos = find(ref(:,1)==41);
                ref_1 = ref(pos,:);
                ref_2 = ref(find(ref(:,1)==setdiff(ref(:,1),41)),:);
                ref_X = ref_2(2) - ref_1(2);
                ref_Y = ref_2(1) - ref_1(1);
            end
        end
    end
end
%% Calculate angles
angles = [];
for i = 1:length(Points)
    cood = Points(i,:);
    vec_X = atan(ref_Y/ref_X);
    vec_Y = atan((cood(1) - ref_1(1))/ ((cood(2) - ref_1(2))));
    angles = [angles;(vec_X - vec_Y)*180/pi];
end
