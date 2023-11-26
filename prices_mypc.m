%% Read prices 2014
prices_2014=xlsread('prices.xlsx','2014');
prices_2014(:,1)=[];
%% Extending prices to 96 intervals
prices_jan_2014=ones(96,1);
count=1;
 % P(14).(['D',num2str(day)]);
for day=1:365
for hour=1:24
    P(14).(['D',num2str(day)])(hour*4-3,1)=prices_2014(day,hour);
    P(14).(['D',num2str(day)])(hour*4-2,1)=prices_2014(day,hour);
    P(14).(['D',num2str(day)])(hour*4-1,1)=prices_2014(day,hour);
    P(14).(['D',num2str(day)])(hour*4,1)=prices_2014(day,hour);
    
    P(24).(['D',num2str(day)])(hour,1) = prices_2014(day,hour);
end
end
%% compiling months
month=1; day =1;
for days=1:365
P(14).(['M',num2str(month)]).(['D',num2str(day)])=P(14).(['D',num2str(days)]);
day=day+1;
if days==31 || days == 59 || days == 90 || days == 120 || days == 151 || days == 181 || days == 212 || days == 243 || days == 273 || days == 304 || days == 334;
        days == 243 || days == 273 || days == 304 || days == 334;
    month=month+1; day =1;
end

end


























