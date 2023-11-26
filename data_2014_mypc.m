%% data 2014
%% Read loads
M12_2014=xlsread('01_load_data\load_values_2014_12.xls');
M11_2014=xlsread('01_load_data\load_values_2014_11.xls');
M10_2014=xlsread('01_load_data\load_values_2014_10.xls');
M9_2014=xlsread('01_load_data\load_values_2014_9.xls');
M8_2014=xlsread('01_load_data\load_values_2014_8.xls');
M7_2014=xlsread('01_load_data\load_values_2014_7.xls');
M6_2014=xlsread('01_load_data\load_values_2014_6.xls');
M5_2014=xlsread('01_load_data\load_values_2014_5.xls');
M4_2014=xlsread('01_load_data\load_values_2014_4.xls');
M3_2014=xlsread('01_load_data\load_values_2014_3.xls');
M2_2014=xlsread('01_load_data\load_values_2014_2.xls');
M1_2014=xlsread('01_load_data\load_values_2014_1.xls');

%% Convert to struct
%26.10 - 2am repeats itself
%30.3 - 2am doesnt exist
% setting up the struct
    SM(14).M01=M1_2014(:,6);  SM(14).M07=M7_2014(:,6);
     SM(14).M02=M2_2014(:,6);  SM(14).M08=M8_2014(:,6);
    SM(14).M03=[M3_2014(1:2792,6);50;50;50;50;M3_2014(2793:2972,6)];  SM(14).M09=M9_2014(:,6);
    SM(14).M04=M4_2014(:,6);  SM(14).M010=[M10_2014(1:2409,5); M10_2014(2414:2980,6)];
    SM(14).M05=M5_2014(:,6);  SM(14).M011=M11_2014(:,6);
     SM(14).M06=M6_2014(:,6);  SM(14).M012=M12_2014(:,6);
%% mins and maxs
% fixing M09
SM(14).M09(1671,1) = 92 ;

% getting for entire year
    for idx=1:12
        min_max_2014(idx,1)=idx;
        min_max_2014(idx,2)=min(SM(14).(['M0',num2str(idx)]));
        min_max_2014(idx,3)=max(SM(14).(['M0',num2str(idx)]));
    end
    min_max_2014;
    DEM_2014 = 669.2499;
%% Insert days & other info in Struct
count_p=1 ; % keep track of price matrix
count_cf=1; % keep track of CF Solar matrix
SM(24).M1.D1(:,2) = zeros(24,1);
% SM(24).Mx.Dy = [Demand(MWh) price(€/MWh) cfpv(avg) cfpv(60W20S) cfpv(60W30S)]
%% JAN
count=1;
for day=1:31
    SM(14).M1.(['D',num2str(day)]) = SM(14).M01(count:count+95); %Insert the load in 15 mins intervals
    SM(14).M1.(['D',num2str(day)])(:,2) = P(14).M1.(['D',num2str(day)]); % insert the prices for the day
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_jan=1:24
        SM(24).M1.(['D',num2str(day)])(hour_jan,1) = mean(SM(14).M1.(['D',num2str(day)])(hour_jan*4-3:hour_jan*4,1));
        SM(24).M1.(['D',num2str(day)])(hour_jan,3) = cf_2014(count_cf,1); %cfpv(avg
        SM(24).M1.(['D',num2str(day)])(hour_jan,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M1.(['D',num2str(day)])(hour_jan,5) = cf_new_read(count_cf,10); %NEW CF IMKE
        count_cf = count_cf + 1;
    end
        SM(24).M1.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% FEB
count=1;
for day=1:28
    SM(14).M2.(['D',num2str(day)])=SM(14).M02(count:count+95);
    SM(14).M2.(['D',num2str(day)])(:,2) = P(14).M2.(['D',num2str(day)]);
    count=count+96;
   % transforming the day of 96 ints into 24 hours
    for hour_feb=1:24
        SM(24).M2.(['D',num2str(day)])(hour_feb,1) = mean(SM(14).M2.(['D',num2str(day)])(hour_feb*4-3:hour_feb*4,1));
        SM(24).M2.(['D',num2str(day)])(hour_feb,3) = cf_2014(count_cf,1);
        SM(24).M2.(['D',num2str(day)])(hour_feb,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M2.(['D',num2str(day)])(hour_feb,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M2.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% MAR
count=1;
for day=1:31
    SM(14).M3.(['D',num2str(day)])=SM(14).M03(count:count+95);
    SM(14).M3.(['D',num2str(day)])(:,2) = P(14).M3.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_mar=1:24
        SM(24).M3.(['D',num2str(day)])(hour_mar,1) = mean(SM(14).M3.(['D',num2str(day)])(hour_mar*4-3:hour_mar*4,1));
        SM(24).M3.(['D',num2str(day)])(hour_mar,3) = cf_2014(count_cf,1);
        SM(24).M3.(['D',num2str(day)])(hour_mar,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M3.(['D',num2str(day)])(hour_mar,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M3.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% APR
count=1;
for day=1:30
    SM(14).M4.(['D',num2str(day)])=SM(14).M04(count:count+95);
    SM(14).M4.(['D',num2str(day)])(:,2) = P(14).M4.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_apr=1:24
        SM(24).M4.(['D',num2str(day)])(hour_apr,1) = mean(SM(14).M4.(['D',num2str(day)])(hour_apr*4-3:hour_apr*4,1));
        SM(24).M4.(['D',num2str(day)])(hour_apr,3) = cf_2014(count_cf,1);
        SM(24).M4.(['D',num2str(day)])(hour_apr,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M4.(['D',num2str(day)])(hour_apr,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M4.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% MAY
count=1;
for day=1:31
    SM(14).M5.(['D',num2str(day)])=SM(14).M05(count:count+95);
    SM(14).M5.(['D',num2str(day)])(:,2) = P(14).M5.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_may=1:24
        SM(24).M5.(['D',num2str(day)])(hour_may,1) = mean(SM(14).M5.(['D',num2str(day)])(hour_may*4-3:hour_may*4,1));
        SM(24).M5.(['D',num2str(day)])(hour_may,3) = cf_2014(count_cf,1);
        SM(24).M5.(['D',num2str(day)])(hour_may,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M5.(['D',num2str(day)])(hour_may,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M5.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% JUN
count=1;
for day=1:30
    SM(14).M6.(['D',num2str(day)])=SM(14).M06(count:count+95);
    SM(14).M6.(['D',num2str(day)])(:,2) = P(14).M6.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_jun=1:24
        SM(24).M6.(['D',num2str(day)])(hour_jun,1) = mean(SM(14).M6.(['D',num2str(day)])(hour_jun*4-3:hour_jun*4,1));
        SM(24).M6.(['D',num2str(day)])(hour_jun,3) = cf_2014(count_cf,1);
        SM(24).M6.(['D',num2str(day)])(hour_jun,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M6.(['D',num2str(day)])(hour_jun,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M6.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% JUL
count=1;
for day=1:31
    SM(14).M7.(['D',num2str(day)])=SM(14).M07(count:count+95);
    SM(14).M7.(['D',num2str(day)])(:,2) = P(14).M7.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_jul=1:24
        SM(24).M7.(['D',num2str(day)])(hour_jul,1) = mean(SM(14).M7.(['D',num2str(day)])(hour_jul*4-3:hour_jul*4,1));
        SM(24).M7.(['D',num2str(day)])(hour_jul,3) = cf_2014(count_cf,1);
        SM(24).M7.(['D',num2str(day)])(hour_jul,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M7.(['D',num2str(day)])(hour_jul,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M7.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% AUG
count=1;
for day=1:31
    SM(14).M8.(['D',num2str(day)])=SM(14).M08(count:count+95);
    SM(14).M8.(['D',num2str(day)])(:,2) = P(14).M8.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_aug=1:24
        SM(24).M8.(['D',num2str(day)])(hour_aug,1) = mean(SM(14).M8.(['D',num2str(day)])(hour_aug*4-3:hour_aug*4,1));
        SM(24).M8.(['D',num2str(day)])(hour_aug,3) = cf_2014(count_cf,1);
        SM(24).M8.(['D',num2str(day)])(hour_aug,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M8.(['D',num2str(day)])(hour_aug,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M8.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% SEP
count=1;
for day=1:30
    SM(14).M9.(['D',num2str(day)])=SM(14).M09(count:count+95);
    SM(14).M9.(['D',num2str(day)])(:,2) = P(14).M9.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_sep=1:24
        SM(24).M9.(['D',num2str(day)])(hour_sep,1) = mean(SM(14).M9.(['D',num2str(day)])(hour_sep*4-3:hour_sep*4,1));
        SM(24).M9.(['D',num2str(day)])(hour_sep,3) = cf_2014(count_cf,1);
        SM(24).M9.(['D',num2str(day)])(hour_sep,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M9.(['D',num2str(day)])(hour_sep,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M9.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% OCT
count=1;
for day=1:31
    SM(14).M10.(['D',num2str(day)])=SM(14).M010(count:count+95);
    SM(14).M10.(['D',num2str(day)])(:,2) = P(14).M10.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_oct=1:24
        SM(24).M10.(['D',num2str(day)])(hour_oct,1) = mean(SM(14).M10.(['D',num2str(day)])(hour_oct*4-3:hour_oct*4,1));
        SM(24).M10.(['D',num2str(day)])(hour_oct,3) = cf_2014(count_cf,1);
        SM(24).M10.(['D',num2str(day)])(hour_oct,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M10.(['D',num2str(day)])(hour_oct,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M10.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% NOV
count=1;
for day=1:30
    SM(14).M11.(['D',num2str(day)])=SM(14).M011(count:count+95);
    SM(14).M11.(['D',num2str(day)])(:,2) = P(14).M11.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_nov=1:24
        SM(24).M11.(['D',num2str(day)])(hour_nov,1) = mean(SM(14).M11.(['D',num2str(day)])(hour_nov*4-3:hour_nov*4,1));
        SM(24).M11.(['D',num2str(day)])(hour_nov,3) = cf_2014(count_cf,1);
        SM(24).M11.(['D',num2str(day)])(hour_nov,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M11.(['D',num2str(day)])(hour_nov,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M11.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%% DEC
count=1;
for day=1:31
    SM(14).M12.(['D',num2str(day)])=SM(14).M012(count:count+95);
    SM(14).M12.(['D',num2str(day)])(:,2) = P(14).M12.(['D',num2str(day)]);
    count=count+96;
    % transforming the day of 96 ints into 24 hours
    for hour_dez=1:24
        SM(24).M12.(['D',num2str(day)])(hour_dez,1) = mean(SM(14).M12.(['D',num2str(day)])(hour_dez*4-3:hour_dez*4,1));
        SM(24).M12.(['D',num2str(day)])(hour_dez,3) = cf_2014(count_cf,1);
        SM(24).M12.(['D',num2str(day)])(hour_dez,4) = cf_new_read(count_cf,12); %cfpv(20S
        SM(24).M12.(['D',num2str(day)])(hour_dez,5) = cf_new_read(count_cf,10); %cfpv(30S
        count_cf = count_cf + 1;
    end
        SM(24).M12.(['D',num2str(day)])(:,2) = P(24).(['D',num2str(count_p)]);
        count_p = count_p +1 ;
end
%%










%% Putting 1 JAN in 24 hours




