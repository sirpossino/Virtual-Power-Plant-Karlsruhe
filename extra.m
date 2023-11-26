%% Extra stuff for optimizer
%% ev load profile per day
ev_load_day = 22.9; %MWh for ev
for x = 1:24
    y_vect(x,1) = (ev_load_day/16)*sin(0.5*x)+0.95;
end
cf_new_read=xlsread('different-azimuth');
cf_new_read(1:4,:)=[];
%%
cfSSWW_read=xlsread('CFSolarSummerWinter');
%%
MONTHS = [31 28 31 30 31 30 31 31 30 31 30 31]';
%%
cfpv_read=xlsread('solarCF');
%% sorting in years
cf_2013_int(:,1) = cfpv_read(1:35040,1);
cf_2014_int(:,1) = cfpv_read(35041:35040*2,1);
cf_2015_int(:,1) = cfpv_read(70081:35040*3,1);

% Getting values by hour
cf_2013=zeros(8760,1); cf_2014=zeros(8760,1); cf_2015=zeros(8760,1);
count=1;
for idx=1:8760
    cf_2013(idx) = mean(cf_2013_int(count:count+3,1));
    cf_2014(idx) = mean(cf_2014_int(count:count+3,1));
    cf_2015(idx) = mean(cf_2015_int(count:count+3,1));
    count=count+4;
end

%% using 2014 as the best year   sum(cf_2014(:,1)) = 999.3833;



%%
% % PLOTS
%  x1 = 1:720:8760;
%  figure;
%  hf = plot(cf_2013(:,1),'b');  hold on
%  plot(cf_2014(:,1),'r');
%  plot(cf_2015(:,1),'k');
%  set(gca,'XTick',x1);
%  grid on; box on;
%  xlabel('ints')
%  ylabel('%CF');
%  legend('CF 2013','CF 2014','CF 2015')
%% Solar
%% getting cfpv for JAN 1 2013
cfpv_read=xlsread('CF1January2013.xlsx');
%%
cfpv_15ints(:,1)=cfpv_read(3:end,6);
cfpv_15ints(:,2)=cfpv_read(3:end,5);
cfpv_jan1_hours = zeros(24,1);
for hour=1:24
    cfpv_jan1_hours(hour,1) = mean(cfpv_15ints(hour*4-3:hour*4,1));
    cfpv_jan1_hours(hour,2) = mean(cfpv_15ints(hour*4-3:hour*4,2));
end

%% creating a Sg [Wh/m2] fluctuation

% 1st
solar=ones(12,4); %kWh/m2
%rows = meses do ano; cols=years; 1 row= jan; 1 col=2013
for i=1:12
    solar(i,1)=i;
end
solar(:,4)=[23;43;93;148;168;173;188;158;103;58;28;23];  %2015
solar(:,3)=[28;53;108;138;173;198;153;138;98;63;28;13]; %2014
solar(:,2)=[23;33;78;103;123;173;198;155;98;58;23;23]; %2013

%2nd 
mean_solar=ones(12,2);
for i=1:12
    mean_solar(i,1)=i;
end
for i2=1:12
    mean_solar(i2,2)=mean([solar(i2,2);solar(i2,3);solar(i2,4);]);
end

%3rd
Sg_avg_hour = sum(mean_solar(:,2))/12/30/9; % during 9 hours of sun

for idx=1:8760
    Sg(idx,1) = (Sg_avg_hour+0.1)*sin(idx*0.3+4.2);
    if Sg(idx,1) < 0
        Sg(idx,1) = 0;
    else
    end
end
Sg_8760 = sum(Sg(:,1));
FHL = 1200; 

cf = zeros(8760,1);
for idx_2=1:8760
cf(idx_2,1) = (Sg(idx_2,1)*FHL)/(Sg_8760);
end
% 
% x1 = 1:1:24;
%  figure;
%  hf = plot(cf(1:24,1)); % hold on
%  set(gca,'XTick',x1);
%  grid on; box on;
%  xlabel('hours')
%  ylabel('Wh/m2');
%  legend('Sg')
%  
 
%%
%% creating a load fluctuation
for hour_y=1:8760
load_fluct(hour_y,1)= 70 + 20*sin(hour_y*0.3+4); 
end
% 
%  x1 = 1:24:24*7;
%  figure;
%  hf = plot(load_fluct(1:24*7,1)); % hold on
%  set(gca,'XTick',x1);
%  grid on; box on;
%  xlabel('hours')
%  ylabel('MWh');
%  legend('load')
%  
 %%