clc
clear all
close all


for i = 1:66
    i
    for j =5:6
        j
        load eyetracker2world_parameters   %加载眼动仪坐标系到世界坐标系的坐标转换关系
        %求解转换矩阵
        load  D:\remote_dataset\calibration\CheckerboardPoints\tform_total.mat
        %         L_pitch_yaw_angle_list = [];
        %         R_pitch_yaw_angle_list = [];
        %         face_normalized_user_list = [];
        %         left_eye_normalized_list = [];
        %         right_eye_normalized_list = [];
        path_folder = ['D:\remote_dataset\user_',num2str(i),'\exp',num2str(j)];
        %         [left_gazenorm(:,1),left_gazenorm(:,2),left_gazenorm(:,3)] = textread(fullfile(path_folder, 'convert_frame_normalized\left_eye\rv_gazenorm.txt'), '%f%f%f');
        %         [right_gazenorm(:,1),right_gazenorm(:,2),right_gazenorm(:,3)] = textread(fullfile(path_folder, 'convert_frame_normalized\right_eye\rv_gazenorm.txt'), '%f%f%f');
        
       left_gazenorm = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j), '\convert_frame_normalized\left_eye\left_rv_gazenorm_list.mat'])).left_rv_gazenorm_list;
       right_gazenorm = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j)', '\convert_frame_normalized\right_eye\right_rv_gazenorm_list.mat'])).right_rv_gazenorm_list;
       left_scale_vector = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j), '\convert_frame_normalized\left_eye\left_scale_vector_list.mat'])).left_scale_vector_list;
       right_scale_vector = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j), '\convert_frame_normalized\right_eye\right_scale_vector_list.mat'])).right_scale_vector_list;
       left_hr_vector = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j), '\convert_frame_normalized\left_eye\left_hr_norm_list.mat'])).left_hr_norm_list;
       right_hr_vector = load (fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j), '\convert_frame_normalized\right_eye\right_hr_norm_list.mat'])).right_hr_norm_list;
    
   [flir_began] = textread(fullfile(path_folder, '\convert2eventspace\','timestamp_win.txt'), '%f');   % event 的第一个时间戳
        flir_began = flir_began(2);
        %
        [gazepoint_began ] = textread(fullfile(path_folder, '\gazepoint\','time_win.txt'), '%f');   % event 的第一个时间戳
        gazepoint_began = gazepoint_began(2);
        
        timedifference = (flir_began - gazepoint_began);
        
        % gazepoint_began = 1684479331.8651273;  % 时间戳对齐
        % flir_began = 1684479331.8661282;
        %
        % timedifference = (flir_began - gazepoint_began);
        
        totaldata  = csvread(fullfile(path_folder,'\gazepoint\gazepoint.csv'));
        %计算世界坐标系下的3d gaze，从眼动仪坐标系转换到世界坐标系，世界坐标系的原点在屏幕左上角
        
        
        %         gazepoint_began =  totaldata(1,3);
        %         timedifference = (flir_began - gazepoint_began)/10000000;
        %
        
           
        [Gazetimestamp, LGAZE, RGAZE] = wcs_3d_gaze(totaldata,R,t);
       
        
        % 转到棋盘格的世界坐标系 x 33.7cm   y9.25cm    60.55cm 全体反向就行
        LGAZE = - LGAZE;
        RGAZE = - RGAZE;
        
        
        
        
        
        % 转到棋盘格的世界坐标系 x 33.7cm   y9.25cm    60.55cm 全体反向就行
        %         LGAZE = - LGAZE;
        %         RGAZE = - RGAZE;
        
        %再从棋盘格世界坐标系转换到相机坐标系
        % Rw2c =  [   -0.9992   -0.0404    0.0002
        %     0.0346   -0.8541    0.5190
        %    -0.0208    0.5186    0.8548];
        %
        % Tw2c = [89.4829197763734,65.7482175778518,616.783865632952]; %平移没什么太大用，因为是归一化gaze
        
        % LGAZE = -Rw2c*LGAZE ;
        % RGAZE = -Rw2c*RGAZE ;
        
        
        Gazetimestamp = Gazetimestamp - timedifference; % 可能最好是减
        
        %         Gazetimestamp = Gazetimestamp + timedifference;
        %
        
        %         % 3D GAZE TO 2D
        %         R_pitch_yaw = vector_to_pitchyaw(RGAZE');
        %
        %         R_pitch_yaw_angle  = 180* R_pitch_yaw/pi;
        %
        %         L_pitch_yaw = vector_to_pitchyaw(LGAZE');
        %
        %         L_pitch_yaw_angle  = 180* L_pitch_yaw/pi;
        %
        % figure
        % plot(R_pitch_yaw_angle(:,1),R_pitch_yaw_angle(:,2))
        % figure
        % plot(L_pitch_yaw_angle(:,1),L_pitch_yaw_angle(:,2))
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%% read frame&event %%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%
        flir_folder = dir(fullfile(path_folder,'\convert2eventspace\','*.jpg*'));
        names_file = sort_nat({flir_folder.name}); %每一个aps 图片的名字
        [time_frame] = textread(fullfile(path_folder, '\convert2eventspace\','timestamp.txt'), '%f');   % event 的第一个时间戳
        time_frame = time_frame/(1e+9);
        time_frame = time_frame - time_frame(1) ;
        sort_label_value_list = [];
        
        %         ['D:\remote_dataset\user_',num2str(i),'\exp',num2str(j)]
        [no_detected_faces_index] = textread(fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j),'\convert_frame_normalized\','no_detected_faces_index.txt']), '%f');
        no_detected_faces_index = no_detected_faces_index+1; % python 相对matlab查找到的索引要加1，图片从0开始
        
        
    
        
        
        
        names_file(no_detected_faces_index) = [];
        %%%%%%%%%%%%%%%%%%%%%%%%% 这里要删除没有detect 到人脸的索引
        time_frame(no_detected_faces_index) = []; % 对应的时间戳也要删除
               
        if j<5
           originalArray_length = 10000; 
        else 
           originalArray_length = 4000;  
        end
        % 定义抽取间隔和每次抽取的元素数量
        interval = 100;
        elementsToExtract = 10;
        % 初始化一个空的索引数组
        indexArray = [];
        % 使用循环来记录抽取元素的索引
        for iq = 1:interval:(originalArray_length-elementsToExtract+1) % z这里引入随机抽取
            % 记录10个元素的索引
            extractedIndices = iq:(iq+elementsToExtract-1);
            indexArray = [indexArray, extractedIndices];
        end
        
   
        
        
        parfor sk =1:length(indexArray )
% parfor k = indexArray 
           k =  indexArray (sk);
%             length(names_file)k
% k
            left_eye_normalized = (imread(cell2mat(fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j),'\convert_frame_normalized\left_eye\', names_file(k)]))));
            right_eye_normalized = (imread(cell2mat(fullfile(['D:\remote_dataset\processed_data_total\user_',num2str(i),'\exp',num2str(j),'\convert_frame_normalized\right_eye\', names_file(k)]))));
%             face_normalized = (imread(cell2mat(fullfile(path_folder,'\convert2eventspace\', names_file(k)))));
%             face_normalized = (imread(cell2mat(fullfile(path_folder,'\convert_frame_normalized\face\', names_file(k)))));
            left_eye_normalized  = imresize(left_eye_normalized , [64,96]); 
            right_eye_normalized  = imresize(right_eye_normalized , [64,96]);
            left_eye_normalized  =  rgb2gray(left_eye_normalized);  % 转为灰度图
            right_eye_normalized =  rgb2gray(right_eye_normalized);
%             face_normalized =  rgb2gray(face_normalized);
%             right_eye_normalized = histeq(right_eye_normalized);
%             left_eye_normalized = histeq(left_eye_normalized);
            
            [sort_label_value, sort_label_ind] = min((abs(Gazetimestamp(:) - (time_frame(k))) * 1000)); %查找距离当前帧最近的tobii gt
            sort_label_value_list (sk) = sort_label_value;
            %筛选3ms以下 的gaze ground 因为有很多眨眼的

           
            
            T_left_gazenorm = squeeze(left_gazenorm(k,:,:));
            T_right_gazenorm = squeeze(right_gazenorm(k,:,:));
            
           
            
%             %%%%%%%%%%%%%%%%%%%%%%
%             tess =  hr_gazenorm (k,:);
%             headmatrix = rotation_vector2matrix(tess);
%             vec =  headmatrix(:, 3);  
%             twodhead_list (k,:) = HeadTo2d(vec);
               %%%%%%%%%%%%%%%%%%%%%%%
            
            T_headpose_r_left =   rotation_vector2matrix(left_hr_vector(k,:));  % 计算归一化头部姿态;  % Rn = MRr,
            T_headpose_r_right =  rotation_vector2matrix(right_hr_vector(k,:));
            
            T_headpose_r_left_vec =  T_headpose_r_left(:, 3);
            T_headpose_r_right_vec  = T_headpose_r_right(:, 3);
            
            T_headpose_r_left_pitch_yaw = HeadTo2d( T_headpose_r_left_vec); %  hn can be represented as a two-dimensiona rotation vector (horizontal and vertical orientations)
            T_headpose_r_right_pitch_yaw = HeadTo2d( T_headpose_r_right_vec); 
            
            
            headpose_left_pitch_yaw_list(sk, :) = T_headpose_r_left_pitch_yaw;
            headpose_right_pitch_yaw_list(sk, :)  = T_headpose_r_right_pitch_yaw;
            

            
            
            left_gazenorm_sample = T_left_gazenorm* LGAZE(:,sort_label_ind); %进行gazenorm，使用w2e先将gaze 从世界坐标系转到相机坐标系
            right_gazenorm_sample = T_right_gazenorm*  RGAZE(:,sort_label_ind);

             
               

%               right_gazenorm_sample = T_right_gazenorm* ( RGAZE(:,sort_label_ind)/ norm(RGAZE(:,sort_label_ind)));
%               left_gazenorm_sample = T_left_gazenorm* ( LGAZE(:,sort_label_ind)/ norm(LGAZE(:,sort_label_ind)));
              
              
%             right_gazenorm_sample = T_right_gazenorm* (RGAZE(:,sort_label_ind));            
%             left_gazenorm_sample = LGAZE(:,sort_label_ind);  %不进行gazenorm
%             right_gazenorm_sample = RGAZE(:,sort_label_ind);
            

            R_pitch_yaw = vector_to_pitchyaw(right_gazenorm_sample');
            R_pitch_yaw_angle  =  R_pitch_yaw;  %R_pitch_yaw_angle  = 180* R_pitch_yaw/pi;
            L_pitch_yaw = vector_to_pitchyaw(left_gazenorm_sample');
            L_pitch_yaw_angle  =  L_pitch_yaw;
            
            
            L_pitch_yaw_angle_list(sk, :) = L_pitch_yaw_angle;
            R_pitch_yaw_angle_list(sk, :) = R_pitch_yaw_angle;
            
            left_eye_normalized_list(sk, :, :) = left_eye_normalized ;
            right_eye_normalized_list(sk, :, :) = right_eye_normalized ;
%           face_normalized_list(k, :, :) = face_normalized;
            
           
%            L_pitch_yaw_angle =  T_headpose_r_left_pitch_yaw;
%            R_pitch_yaw_angle =  T_headpose_r_right_pitch_yaw;
            %%%%%%%%%%%%%%%%%%%%%%%%%plot gaze%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            lengths = 200;
%                                             %             ldx = lengths * sin(pi*L_pitch_yaw_angle(sort_label_ind,2)/180) * cos(pi*L_pitch_yaw_angle(sort_label_ind,1)/180);
%                                             %             ldy = -lengths * sin(pi*L_pitch_yaw_angle(sort_label_ind,1)/180);
%                                             %
%                                             %             rdx = lengths * sin(pi*R_pitch_yaw_angle(sort_label_ind,2)/180) * cos(pi*R_pitch_yaw_angle(sort_label_ind,1)/180);
%                                             %             rdy = -lengths * sin(pi*R_pitch_yaw_angle(sort_label_ind,1)/180);
%                                             ldx = lengths * sin(L_pitch_yaw_angle(:,2)) * cos(L_pitch_yaw_angle(:,1));
%                                             ldy = -lengths * sin(L_pitch_yaw_angle(:,1));
% 
%                                             rdx = lengths * sin(R_pitch_yaw_angle(:,2)) * cos(R_pitch_yaw_angle(:,1));
%                                             rdy = -lengths * sin(R_pitch_yaw_angle(:,1));
% %                                             lpos = [581 365];
%                                                     lpos = [26 70];
%                                             lpos = round(lpos);
%                                             lendpoint = round([lpos(1) + ldx, lpos(2) + ldy]);
% 
%                                                     rpos = [186 74];
% %                                             rpos = [732 371];
%                                             rpos = round(rpos);
%                                             rendpoint = round([rpos(1) + rdx, rpos(2) + ldy]);
% 
%                                             color = [0, 0, 255] ;
%                                             image_out = insertShape( face_normalized, 'Line', [lpos, lendpoint], 'Color', 'red', 'LineWidth', 10);
% 
%                                             image_outs = insertShape(image_out, 'Line', [rpos, rendpoint], 'Color', 'red', 'LineWidth', 10);
% 
% 
%                                             figure(4)
%                                             imshow(image_outs);
%                                             hold on 
%                                             plot(lpos(1), lpos(2), 'go', 'MarkerSize', 10);
%                                             plot(rpos(1), rpos(2), 'go', 'MarkerSize', 10);
%                                             hold off
%                                             pause(0.1)
%                                             figure(5)
%                                             imshow(left_eye_normalized );
%                                             pause(0.1)
%                                             figure(6)
%                                             imshow(right_eye_normalized );
%                                             pause(0.1)
%             
         

        end
        del_index = find( sort_label_value_list  >=4);
        L_pitch_yaw_angle_list(del_index , :) = [];
        R_pitch_yaw_angle_list(del_index , :) = [];
        
        left_eye_normalized_list(del_index , :, :) = [];
        right_eye_normalized_list(del_index , :, :) = [];
%         face_normalized_list(del_index , :, :) = [];
        
        headpose_left_pitch_yaw_list(del_index , :, :) = [];
        headpose_right_pitch_yaw_list(del_index , :, :) = [];
        %hdf5write (['D:\remote_dataset\data_for_gaze_network\','face_normalized_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', face_normalized_list);
        
        hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','histeq_64_96_L_eye_normalized_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', left_eye_normalized_list);
        hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','histeq_64_96_R_eye_normalized_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', right_eye_normalized_list);
%         hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','L_headpose_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', headpose_left_pitch_yaw_list);
%         hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','R_headpose_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', headpose_right_pitch_yaw_list);
%         hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','L_pitch_yaw_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', L_pitch_yaw_angle_list);
%         hdf5write (['C:\Users\Aiot_Server\Desktop\remote_dataset\data_for_gaze_network\','R_pitch_yaw_user_',num2str(i),'_exp',num2str(j),'.h5'],'/data', R_pitch_yaw_angle_list);
        
        clearvars -except i j
    end
    
end