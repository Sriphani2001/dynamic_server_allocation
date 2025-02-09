% Main script to run the modified Qx function

close all;
clear all;
clc;

% Set parameters
lambda = 11;          % Arrival rate
mu = 10;              % Service rate per server
endtime = 10000;      % Simulation length (seconds)
time_threshold = 0.5; % Queue time threshold for adding/removing servers

% Run simulation
[N, T, nbrdeparted, servers_over_time] = Qx(lambda, mu, endtime, time_threshold);
[N1, T1, nbrdeparted1] = Qx1(lambda, mu, endtime);


% Plot number of customers over time
figure,plot(N);

title('Number of Customers Over Time adaptive ');
xlabel('Time');
ylabel('Number of Customers');
figure,histogram(N)

figure,plot(N1);
title('Number of Customers Over Time mm1');
xlabel('Time');
ylabel('Number of Servers');
figure,histogram(N1)


% Plot number of servers over time

figure,stairs(servers_over_time(:,1), servers_over_time(:,2));
title('Number of Servers Over Time');
xlabel('Time');
ylabel('Number of Servers');

%%%%%%%%simualtion different values of the lamda and repetaion for accurate results

lambda_range = 5:1:15;
mu = 10;
endtime = 1000;
time_threshold = 0.5;
num_repetitions = 100;

avg_servers = zeros(1, length(lambda_range));
avg_queue_time = zeros(1, length(lambda_range));
avg_customers = zeros(1, length(lambda_range));

avg_queue_time_mm1 = zeros(1, length(lambda_range));
avg_customers_mm1 = zeros(1, length(lambda_range));

for i = 1:length(lambda_range)
    lambda = lambda_range(i);
    servers_sum = 0;
    queue_time_sum = 0;
    customers_sum = 0;
    queue_time_sum_mm1 = 0;
    customers_sum_mm1 = 0;
    
    for j = 1:num_repetitions
        [N, T, nbrdeparted, servers_over_time] = Qx(lambda, mu, endtime, time_threshold);
        servers_sum = servers_sum + mean(servers_over_time(:,2));
        queue_time_sum = queue_time_sum + mean(diff(T));
        customers_sum = customers_sum + mean(N);
        
        [N_mm1, T_mm1, nbrdeparted_mm1] = Qx1(lambda, mu, endtime);
        queue_time_sum_mm1 = queue_time_sum_mm1 + mean(diff(T_mm1));
        customers_sum_mm1 = customers_sum_mm1 + mean(N_mm1);
    end
    
    avg_servers(i) = servers_sum / num_repetitions;
    avg_queue_time(i) = queue_time_sum / num_repetitions;
    avg_customers(i) = customers_sum / num_repetitions;
    
    avg_queue_time_mm1(i) = queue_time_sum_mm1 / num_repetitions;
    avg_customers_mm1(i) = customers_sum_mm1 / num_repetitions;
end

% Plot results
figure;

%subplot(3,1,1);
plot(lambda_range, avg_servers, 'b-o');
title('Average Number of Servers (Adaptive System)');
xlabel('Lambda');
ylabel('Avg Servers');

%subplot(,1,2);
figure,plot(lambda_range, avg_customers, 'b-o', lambda_range, avg_customers_mm1, 'r-s');
title('Average Number of Customers Comparison');
xlabel('Lambda');
ylabel('Avg Customers');
legend('Adaptive System', 'M/M/1 System');

