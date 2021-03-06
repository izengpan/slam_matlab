function [img, frm, des, p, ld_err] = load_camera_frame(fid)
%
% David Z, March 3th, 2015
% load camera data: 
% img, 2D pixels
% frm, 
% p [x y z]; (width, height, 3) 
% ld_err = 1, if not exist 
global g_data_dir g_data_prefix g_data_suffix g_camera_type 
global g_filter_type

ld_err = 0; % TODO: take the load data error into consideration
% now only support SwissRanger 
cut_off_boarder = 0; % weather to cut off the boarder pixels
dm = 1; % directory of data? 
scale = 1; % scale the intensity image to the range [0~255]
value_type = 'int'; % convert to int, after scaling the image

%% feature has been stored 
if file_exist(fid) ~= 0
    [img, frm, des, p] = load_feature(fid); 
    return ;
else
    if strcmp(g_camera_type, 'creative')      
        [img, x, y, z, c] = LoadCreative_dat(g_camera_type, fid);
    else
        if strcmp(g_data_suffix, 'dat')
            [img, x, y, z, c] = LoadSR_no_bpc(g_camera_type, g_filter_type, ...
                cut_off_boarder, dm, fid, scale, value_type);
        elseif strcmp(g_data_suffix, 'bdat')
            [img, x, y, z, c] = LoadSR_no_bpc_time_single_binary(g_camera_type, ...
                g_filter_type, cut_off_boarder, dm, fid, scale, value_type);
        end
    end
    if isempty(img)
        frm = []; des = []; p =[]; 
        ld_err = 1; 
        return;
    end
end
%% sift feature 
global g_sift_threshold 
if g_sift_threshold == 0
    [frm, des] = sift(img); 
else
    [frm, des] = sift(img, 'threshold', g_sift_threshold);
end

%% plot the point cloud 
% plot_pc(x, y, z, 'b');
% dump2ply('tmp.ply', x, y, z, img);

%% confindence filtering 
if c ~=0
    [frm, des] = confidence_filtering(frm, des, c);
end
%% construct return value 
[m, n] = size(x); 
p = zeros(m, n, 3); 
p(:,:,1) = x; 
p(:,:,2) = y; 
p(:,:,3) = z;

%% save it into file 
global g_save_vro_middle_result
if g_save_vro_middle_result
    save_feature(fid, img, frm, des, p);
end

end

function plot_pc(x, y, z, c)
    plot3(x, y, z, c); 
end

%% check weather this visul feature exist 
function [exist_flag] = file_exist(id)
%% get file name  
global g_data_dir g_data_prefix g_feature_dir
file_name = sprintf('%s/%s/%s_%04d.mat', g_data_dir, g_feature_dir, g_data_prefix, id); 
exist_flag = exist(file_name, 'file'); 
end
