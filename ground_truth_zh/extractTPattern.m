%% 
% Jan. 30 2018, He Zhang, hxzhang1@ualr.edu
% extract T Pattern from motion capture data, and store it into TPattern.log  
% the T Pattern is described in compute_initial_Tnew.m
 
function extractTPattern(fname, ouf)
clear all
clc
clf
close all
global g_TN;
g_TN = 5;
global g_6;
g_6 = 0;
if nargin == 0
    fname = './motion_capture_data/Dense_Slow_640x480_30_b.csv';
    ouf = './motion_capture_data/Dense_Slow_640x480_30_b_TPattern.log';
end

%% read data from .csv file
pts = extract_TPoints(fname); 
fprintf('pattern extracted given 6 points %d\n', g_6);

%% compute sum distance 
sum_dis = compute_distance(pts(:, 2:end)); 

mu = mean(sum_dis);
sigma = std(sum_dis);

%% save it 
dlmwrite(ouf,pts,' '); % [time_stamp pt1 pt2 pt3 pt4 pt5]

end

function pts = extract_TPoints(fname)
%% scan all lines into a cell array
global g_TN;
fid = fopen(fname);
columns=textscan(fid,'%s','delimiter','\n');
lines=columns{1};
N=size(lines,1);
pts=[];
cnt_b5 = 0; 
for i=1:N
    line_i=lines{i};
    % line_data = textscan(line_i,'%s %d %f %f %f %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s','delimiter',',');
    l = textscan(line_i, '%s %d %f %f %f\n', 'delimiter', ',');
    
    %% valid data
    if strcmp(l{1}, 'frame')
        if l{5} >= 5
            %% read data
            line_data = [];
            if l{5} == 5
                line_data = textscan(line_i,'%s %d %f %f %f %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s\n','delimiter',',');
            elseif l{5} == 6
                line_data = textscan(line_i,'%s %d %f %f %f %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s\n','delimiter',',');
            else
                fprintf('extractTPattern: not handle %d points\n', l{5});
                continue;
            end
            time_stamp = line_data{3};
            %% extract marker point
            marker=[];

            for m=1:line_data{5}
                marker=[marker; [line_data{(m-1)*5+6},line_data{(m-1)*5+7},line_data{(m-1)*5+8}]];
            end
            %% extract TPattern
            TP = get_T_pattern(marker);
            if size(TP, 1) == g_TN
                cnt_b5 = cnt_b5 + 1;
                pts =[pts; time_stamp reshape(TP', 1, 15)];
            end
        end
    end
end
fclose(fid);
fprintf('scan_data.m: cnt 5-points %d, \n', cnt_b5);

end

function TP = get_T_pattern(markers)
    global g_TN
    global g_6
    TP  = [];
    if size(markers, 1) == g_TN
        TP = TPattern(markers);
    elseif size(markers, 1) == g_TN + 1
        TP = TPatternPlus(markers);
        if size(TP, 1) == g_TN
            g_6 = g_6 + 1;
        end
    end
end

%% only work when size(markers,1) = g_TN + 1
function TP = TPatternPlus(markers)
    global g_TN
    TP = [];
    for i=1:size(markers, 1)
        pts = [];
        for j = 1:size(markers,1)
            if j == i
                continue; % exclude point i
            end
            pts = [pts; markers(j,:)];
        end
        TP = TPattern(pts);
        if size(TP, 1) == g_TN
            break;
        end
    end
end

function TP = TPattern(markers)
    global g_TN;
    %% T pattern, details in compute_initial_Tnew.m
    T_dis = [0.51, 0.48, 0.68, 0.75, 0.76];
    pdis = compute_distance_pattern(markers);
    TP = zeros(size(markers));
    % first find point 1, 2, 3, then distinguish point 4, 5
    seq = [0 0 0 0 0]; 
    flag = [0 0 0 0 0];
    thre = 0.01; % 1cm
    cnt_45 = 0;
    pre_j = 0;
    pre_dj = 0;
    
    sorted_dis = sort(pdis);
    for i =1:g_TN
        fprintf('%f ', sorted_dis(i));
    end
    fprintf('\n');
    
    for i=1:g_TN
        d = pdis(i);
        for j = 1:g_TN
            if abs(d - T_dis(j)) < thre
                seq(i) = j;
                flag(j) = 1;
            end
        end
         %% distinguish 4 and 5. the TPattern design is so bad
        if d > 0.75 && d < 0.79
            if cnt_45 == 0
                pre_j = i;
                pre_dj = d;
            else
                if d < pre_dj
                    seq(i) = 4;
                    seq(pre_j) = 5;
                else
                    seq(i) = 5;
                    seq(pre_j) = 4; 
                end
                flag(4) = 1;
                flag(5) = 1;
            end
            cnt_45 = cnt_45 + 1;
        end
    end
    
    if sum(flag) ~= g_TN
        TP = [];
    else
       for i=1:g_TN
           if seq(i) == 0
               TP = [];
               break;
           end
            TP(seq(i),:) = markers(i, :);
       end
    end
   
end

function [sum_dis] = compute_distance_pattern(pts)
    global g_TN;
    sum_dis = zeros(g_TN, 1); 
    for i=1:g_TN 
        pti = pts(i, :);
        dis_m = 0; % sum of point i to all other points
        for m=1:g_TN
            ptj = pts(m, :);
            d_pt = ptj - pti;
            dis_m = dis_m + sqrt(sum(d_pt.*d_pt));
        end
        sum_dis(i) = dis_m;
    end
end


