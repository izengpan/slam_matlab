%% 
% Jan. 28 2018, He Zhang, hxzhang1@ualr.edu
% explore the T pattern 
% 
 
function getTPattern(fname)
global g_TN;
g_TN = 5;
if nargin == 0
    fname = './motion_capture_data/Dense_Slow_640x480_30_b.csv';
end

%% read data from .csv file
pts = get_data(fname); 

%% compute sum distance 
sum_dis = compute_distance(pts); 

mu = mean(sum_dis);
sigma = std(sum_dis);

end

function pts = get_data(fname)
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
    line_data = textscan(line_i,'%s %d %f %f %f %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s %f %f %f %d %s','delimiter',',');
    if strcmp(line_data{1}, 'frame')
        if  ~isempty(line_data{6})
                % time_stamp = line_data{3};
                marker=[];
                if line_data{5} == 5  % original
                    for m=1:line_data{5}
                        marker=[marker; [line_data{(m-1)*5+6},line_data{(m-1)*5+7},line_data{(m-1)*5+8}]];
                    end
                    cnt_b5 = cnt_b5 + 1;
                    pts =[pts; reshape(marker', 1, 15)];
                end
        end
    end
end
fclose(fid);
fprintf('scan_data.m: cnt 5-points %d, \n', cnt_b5);

end

