% K-means model classificator
classdef classificator_pursuits_class <  eye_tracker_raw_data_reader_class & ...             % Reader from eye tracker data
                                         eye_records_class & ...                             % Basic class for placing eye tracker data
                                         eye_tracker_raw_data_converter_ETU_degree & ...     % Convertor between ETU and degress in data
                                         eye_tracker_raw_data_filter_class & ...             % Eye tracker data filtering by range of degrees
                                         classificator_merge_class & ...                     % Creates sequences of eye movements
                                         classificator_saccade_amplitude_filter_class & ...  % Filtered saccades based theire amplitude
                                         classificator_datafile_output_class & ...           % Output sequences to the files
                                         classificator_get_percentage_class & ...            % Calculate percentage of movements of every type
                                         classificator_enumerations_class & ...              % Basic enumerations definitions
                                         classificator_time_rate_class & ...                 % Time step and sample rate definitions
                                    handle
    % This is skeleton class for user classification
  
    properties (Hidden)
        k;
        outlier_window;
    end

    methods

        % Classification function
        function classify(obj)
            if( obj.debug_mode ~= 0)
                fprintf(strcat('Begin data classification with user classifier in :',datestr(now),'\n'));
                fprintf(strcat('Clustering with k = ', int2str(obj.k), '\n'));
            end
            obj.calculate_delta_t();
            
            
            %Create feature array
            vel_and_acc = zeros( length(obj.eye_records),4 );
            x_velocity_degree = zeros( length(obj.eye_records),1 );
            y_velocity_degree = zeros( length(obj.eye_records),1 );
            
            % Calculate absolute degree velocity of our records
            x_velocity_degree( 2:end ) =(   obj.eye_records( 2:end,obj.X_COORD ) - ...
                                            obj.eye_records( 1:end-1,obj.X_COORD ) ) / obj.delta_t_sec;
            y_velocity_degree( 2:end ) =(   obj.eye_records( 2:end,obj.Y_COORD ) - ...
                                            obj.eye_records( 1:end-1,obj.Y_COORD ) ) / obj.delta_t_sec;
            
            % First point is a special case
            x_velocity_degree(1) = 0;
            y_velocity_degree(1) = 0;
            %vel_and_acc(1,1) = 0;
            %vel_and_acc(1,2) = 0;
            %vel_and_acc(1,3) = 0;
            
            %Load velocity values
            %obj.eye_records(:,obj.VELOCITY) = sqrt( x_velocity_degree.^2 + y_velocity_degree.^2 );
            vel_and_acc(1:end, 1) = abs(x_velocity_degree(1:end));
            vel_and_acc(1:end, 2) = abs(y_velocity_degree(1:end));
            vel_and_acc(1:end, 3) = sqrt( x_velocity_degree.^2 + y_velocity_degree.^2 );
            
            % First point is a special case
            obj.eye_records(1,obj.MOV_TYPE ) = obj.NOISE_TYPE;
            %obj.eye_records(1,obj.VELOCITY) = 0;
            
            %Calculate acceleration values as difference of consecutive
            %velocities.
            vel_and_acc(:,4) = abs(vertcat([0], diff(vel_and_acc(:,3))));
            
            %Get the noise out
            baddies = isoutlier(vel_and_acc(:,3:4), 'movmedian', obj.outlier_window);
            %mean_x = mean(vel_and_acc(:,1));
            %mean_y = mean(vel_and_acc(:,2));
            %mean_vel = mean(vel_and_acc(:,3));
            %mean_acc = mean(vel_and_acc(:,4));
            
            for i = 1:length(vel_and_acc)
                if baddies(i) == 1
                    %fprintf(strcat('Removing ', int2str(i), '\n'));
                    obj.eye_records(i,obj.MOV_TYPE) = obj.NOISE_TYPE;
                    vel_and_acc(i,1) = 0;
                    vel_and_acc(i,2) = 0;
                    vel_and_acc(i,3) = 0;
                    vel_and_acc(i,4) = 0;
                    
                end
            end
            
            %figure(1);
            %plot(vel_and_acc(:,3));
            
            %figure(2);
            %scatter(vel_and_acc(:,3), vel_and_acc(:,4));
            
            
            
            %Cluster the velocity and acceleration values
            %k should be 3
            clusters = kmeans(vel_and_acc, obj.k);
            
            %Calculate average velocity of each cluster
            cluster1_vel = 0;
            cluster1_count = 0;
            cluster2_vel = 0;
            cluster2_count = 0;
            cluster3_vel = 0;
            cluster3_count = 0;
            
            for i = 1:length(clusters)
               if clusters(i) == 1
                   cluster1_vel = cluster1_vel + vel_and_acc(i,3);
                   cluster1_count = cluster1_count + 1;
               elseif clusters(i) == 2
                   cluster2_vel = cluster2_vel + vel_and_acc(i,3);
                   cluster2_count = cluster2_count + 1;
               else
                   cluster3_vel = cluster3_vel + vel_and_acc(i,3);
                   cluster3_count = cluster3_count + 1;
               end
            end
            
            if cluster1_count > 0
                cluster1_vel = cluster1_vel/cluster1_count;
            end
            
            if cluster2_count > 0
                cluster2_vel = cluster2_vel/cluster2_count;
            end
            
            if cluster3_count > 0
                cluster3_vel = cluster3_vel/cluster3_count;
            end
            
            if( obj.debug_mode ~= 0)
                fprintf(strcat('Cluster 1 number of points :',int2str(cluster1_count),'\n'));
                fprintf(strcat('Cluster 1 avg velocity :',int2str(cluster1_vel),'\n'));
                fprintf(strcat('Cluster 2 number of points :',int2str(cluster2_count),'\n'));
                fprintf(strcat('Cluster 2 avg velocity :',int2str(cluster2_vel),'\n'));
                fprintf(strcat('Cluster 3 number of points :',int2str(cluster3_count),'\n'));
                fprintf(strcat('Cluster 3 avg velocity :',int2str(cluster3_vel),'\n'));
            end
            
            %Classify points based on cluster
            %Using 1 = Fixation
            %       2 = Saccade
            %       3 = Pursuit
            %       4 = Noise
            movements = zeros(length(clusters));
            if (cluster1_vel < cluster2_vel) && (cluster2_vel < cluster3_vel)
                cluster_values = [1, 3, 2];
            elseif (cluster1_vel < cluster3_vel) && (cluster3_vel < cluster2_vel)
                cluster_values = [1, 2, 3];
            elseif (cluster2_vel < cluster1_vel) && (cluster1_vel < cluster3_vel)
                cluster_values = [2, 3, 1];
            elseif (cluster2_vel < cluster3_vel) && (cluster3_vel < cluster1_vel)
                cluster_values = [2, 1, 3];
            elseif (cluster3_vel < cluster1_vel) && (cluster1_vel < cluster2_vel)
                cluster_values = [3, 2, 1];
            elseif (cluster3_vel < cluster2_vel) && (cluster2_vel < cluster1_vel)
                cluster_values = [3, 1, 2];
            else
            end
            
            for i = 1:length(movements)
                movements(i) = cluster_values(clusters(i));
            end
                
            
            movement_counts = zeros(4);
            %Assign movements based on clustered values
            for i = 1:length(obj.eye_records)
                if movements(i) == 1 && obj.eye_records(i,obj.MOV_TYPE) ~= obj.NOISE_TYPE
                    obj.eye_records(i,obj.MOV_TYPE) = obj.FIXATION_TYPE;
                    movement_counts(1) = movement_counts(1) + 1;
                elseif movements(i) == 2 && obj.eye_records(i,obj.MOV_TYPE) ~= obj.NOISE_TYPE
                    obj.eye_records(i,obj.MOV_TYPE) = obj.SACCADE_TYPE;
                    movement_counts(2) = movement_counts(2) + 1;
                elseif movements(i) == 3 && obj.eye_records(i,obj.MOV_TYPE) ~= obj.NOISE_TYPE
                    obj.eye_records(i,obj.MOV_TYPE) = obj.PURSUIT_TYPE;
                    movement_counts(3) = movement_counts(3) + 1;
                else 
                    obj.eye_records(i,obj.MOV_TYPE) = obj.NOISE_TYPE;
                    movement_counts(4) = movement_counts(4) + 1;
                    
                end
            end
            
            if( obj.debug_mode ~= 0)
                fprintf(strcat('Number of Fixation points :',int2str(movement_counts(1)),'\n'));
                fprintf(strcat('Number of Saccade points :',int2str(movement_counts(2)),'\n'));
                fprintf(strcat('Number of Pursuit points :',int2str(movement_counts(3)),'\n'));
                fprintf(strcat('Number of Noise points :',int2str(movement_counts(4)),'\n'));
            end
                

            if( obj.debug_mode ~= 0)
                fprintf(strcat('Complete data classification with user classifier in :',datestr(now),'\n'));
            end
        end
        
        function set.k(obj,value), obj.k = value; end
    end

end
