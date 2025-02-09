function [N, T, nbrdeparted, servers_over_time] = Qx(lambda, mu, endtime, time_threshold)
    t = 0; % current time
    tstep = 1; % average time between consecutive measurement events
    currcustomers = 0; % current number of customers in the system
    current_servers = 1; % start with one server
    event = zeros(1, 4); % event vector: arrival (1), departure (2), measurement (3), server adjustment (4)
    event(1) = exprnd(1/lambda); % time for next arrival
    event(2) = inf; % no next service completion (empty system)
    event(3) = exprnd(tstep); % time for next measurement event
    event(4) = 10; % time interval to check queue time and adjust servers

    nbrmeasurements = 0; % number of measurement events
    nbrdeparted = 0; % number of departed customers
    nbrarrived = 0; % number of arrived customers
    total_queue_time = 0; % total queue time for all customers
    servers_over_time = []; % track server changes over time
    queue_times = []; % store individual customer queue times

    while t < endtime
        [next_event_time, next_event_type] = min(event);
        t = next_event_time;

        if next_event_type == 1 % Arrival
            nbrarrived = nbrarrived + 1;
            currcustomers = currcustomers + 1;
            event(1) = exprnd(1/lambda) + t;

            if currcustomers <= current_servers
                event(2) = exprnd(1/(current_servers * mu)) + t;
            else
                queue_times = [queue_times; t]; % add customer to queue
            end

        elseif next_event_type == 2 % Departure
            currcustomers = currcustomers - 1;
            nbrdeparted = nbrdeparted + 1;

            if ~isempty(queue_times)
                queue_time = t - queue_times(1); % calculate queue time for first customer in line
                total_queue_time = total_queue_time + queue_time;
                queue_times(1) = []; % remove from queue
                event(2) = exprnd(1/(current_servers * mu)) + t;
            elseif currcustomers >= current_servers
                event(2) = exprnd(1/(current_servers * mu)) + t;
            else
                event(2) = inf;
            end

        elseif next_event_type == 3 % Measurement Event
            nbrmeasurements = nbrmeasurements + 1;
            N(nbrmeasurements) = currcustomers;
            T(nbrmeasurements) = t;
            event(3) = event(3) + exprnd(tstep);

        elseif next_event_type == 4 % Server Adjustment Event
            if ~isempty(queue_times)
                avg_queue_time = total_queue_time / max(nbrdeparted, 1); % avoid division by zero

                if avg_queue_time > time_threshold && current_servers < 10
                    current_servers = current_servers + 1; % add a server if threshold exceeded
                    disp(['Added a server at time ' num2str(t)]);
                elseif avg_queue_time < time_threshold / 2 && current_servers > 1
                    current_servers = current_servers - 1; % remove a server if load decreases significantly
                    disp(['Removed a server at time ' num2str(t)]);
                end

                servers_over_time = [servers_over_time; t, current_servers];
            end

            total_queue_time = 0; % reset total queue time for the next interval
            nbrdeparted = 0; % reset departed count for this interval
            event(4) = t + 10; % schedule next server adjustment check
        end
    end

end
