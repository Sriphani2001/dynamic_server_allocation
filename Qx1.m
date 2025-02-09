function [N,T,nbrdeparted]=Qx1(lambda,mu,endtime)

% lambda=7; %arrival rate
% mu=10; %service rate
% endtime=1000; %simulation length (seconds)

t=0; %current time
tstep=1; %average time between consecutive measurement events
currcustomers=0; %current number of customers in system
event=zeros(1,3); %constructs vector to keep time for next arrival %(pos 1),next service completion (pos 2) and next% measurement event (pos 3)
event(1)=exprnd(1/lambda); %time for next arrival1
event(2)=inf; %no next service completion (empty system)
event(3)=exprnd(tstep); %time for next measurement event
nbrmeasurements=0; %number of measurement events so far
nbrdeparted=0; %number of departed customers
nbrarrived=0; %number of customers that have arrived throughout the simulations
while t<endtime
    [t,nextevent]=min(event);
    if nextevent==1
        event(1)=exprnd(1/lambda)+t;
        currcustomers=currcustomers+1;
        nbrarrived=nbrarrived+1; %one more customer has arrived to the system through the simulations
        arrivedtime(nbrarrived)=t; %the new customer arrived at time t
        if currcustomers==1
            event(2)=exprnd(1/mu)+t;
        end
    elseif nextevent==2
        currcustomers=currcustomers-1;
        timeinsystem=t-arrivedtime(nbrarrived-currcustomers);
        nbrdeparted=nbrdeparted+1; %one more customer has departed%from the system through the%simulations
        T(nbrdeparted)=timeinsystem;
        if currcustomers>0
            event(2)=exprnd(1/mu)+t;
        else
            event(2)=inf;
        end
    else
        nbrmeasurements=nbrmeasurements+1; %one more measurement event
        N(nbrmeasurements)=currcustomers;
        event(3)=event(3)+exprnd(tstep);
    end
end