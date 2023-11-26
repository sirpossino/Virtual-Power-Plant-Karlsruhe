%% Optimization my pc system
% 
% % Scripts to run first
% clear all
% clc
% prices_mypc
% extra
% data_2014_mypc

%% Choosing day & month (2014)
  day =12;
  month = 7;

%% if we consider ev profile 2030 
ev = 0;
 
%%  
count_prices = 1; count_tp_tminus = 0;
count_imps = 1; imp_month_day = [];
count_exps = 1; exp_month_day = [];
count_pvs = 1; pv_month_day = [];

val_vec_year(:,1:3)=zeros(365,3);
Emix(:,1:5)=zeros(365,5);
TP_hour = []; PV_hour = []; IMP_hour = []; EXP_hour=[];
BAT_hour = []; DEM_hour=[]; CHR_hour=[]; CAP_hour=[];
prices_year = []; prices_day = [];
%% ATM variables
% x1 = usage of thermal 
% x2 = capacity of thermal    
% x3 = usage of PV 
% x4 = capacity of pv 
% x5 = usage of import 
% x6 = export
var = 6 ; % minimum vars
% x7 = battery capacity 
% x8 = battery charging 
% x9 = battery discarging 
% x10= battery status t+1 
% = Battery Status

%% Wind ON/OFF
wind = 0; % Wind on = 1 , off = 0;
if wind == 1
    var = var +2; % wind vars = 2
else 
end
%% Battery ON/OFF
bat = 1; % battery on = 1 , off = 0;
if bat == 1
    var = var + 4; % battery var = 3; 
    bs = 0; % battery starts discharged
    bstatus = zeros(25,1);
else
end
%% INSERT CYCLE FOR
count_val_vec_year = 1; % to get cost values
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
for month = 1:12 
for day = 1:MONTHS(month,1) 
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%% AFTER CYCLE FOR
Mix = zeros(24,var);

for hour=1:24
%% Constants

% EV load increase 1.25% = 8.365624 GWh/yr -> 22.9 MWh/day -> profile in
% extra
if ev == 1;
demand_day(hour,1) = SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,1) + y_vect(hour,1); %MWh
demand_day(hour,2) = SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,2); %MWh 
else
demand_day(hour,1) = SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,1); %MWh
demand_day(hour,2) = SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,2); %MWh
end
%% For Thermal:
  mc1 = 15; %[€/kW]
% cc1 = anualized specific first cost of thermal [€/kW]
  cc1 = 57.96; %[€/kW]
  n1  = 0.41; 
  p1 = 0.023; %[€/kWh]
% Carbon factor (tCO2/MWhth) = 0.202
  co2_fac = 0.202/n1; %[kgCO2 / kWh of TP]
% Auction Prices [€/tCO2]
  price_co2_euro_kg = (5.5*10^-3); % [€/kgCO2]  
  cftp = 1;

%% For PV: 
% mc2 = specific maintenance cost of PV [€/kW]
% cc2 = anualized specific first cost of PV [€/kW]

%80 % from smaller installations (roofs) & 20% ground
  cc2 = 0.8*108.7 + 0.2*94 ;%218.738 ; % [€/kW] already has mc2 in it
  mc2 = 0; %included in cc2
  n_inv = 1; % included in cf%
% cfpv
  cfpv = SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,3);
  %(hour,3) = avg cfpv
  %(hour,4) = 60W20S
  %(hour,5) = 60W30S
  cap_pv = 100*10^3; %MW
% Sg,t = Global horizontal radiation at time t [Wh/m2]
% FLH  = Annual full_load hours of PV

 %% For Wind
% %   Inv_cost_wind = 5832; % investment cost [€/kW] %
% % % Lifespan = 20 years 
% % % mc3 = specific maintenance cost of Wind [€/kW]
% %   mc3 = 0.02*Inv_cost_wind; % 2% of investment cost [€/kW]
% % % cc3 = anualized specific first cost of Wind [€/kW]
% %   cc3 = 685.00; % [€/kW]
% % % vw,t = velocity of wind at time t -> vw = jan_1_wv(hour,1);
% %   
% % % cf_wind
% % if wind == 1
% %   cf_wind =(1.6^jan_1_wv(hour,1))*0.00775 ;  
% % else
% % end

%% For Batteries - Lead-acid batteries


% % mc4 & mc5 = specific maintenance cost of BC & BD [€/kW]
%   mc45 =  0.01*Inv_cost_battery;
  cc4 = 262.62; %[€/kWh] with maintenance included
% n4  & n5   = effiency of charging & discharging [%]
  n4 = 0.9; n5 = 0.95;
% cc4 & cc5 = anualized specific first cost of BC & BD [€/kW]
% cf4 & cf5 = 0.8 ; 
  cf45 = 0.8;    
% capacity for the batteries
 max_cap_bat = 20*10^3 ; %[kWh] 

%% Imports
cost_kWh_imported = 2.04; 
fix_cost_connect = 13.22;
%% lower bounds
lb = zeros (var,1);
lb(4) = cap_pv; %[kWh] 
if count_tp_tminus >0 && (usage_TP_tminus-15*10^3)>30*10^3
    lb(1)=usage_TP_tminus-15*10^3; % minus 20 MWh
else
    lb(1)=30*10^3;
end
% Minimum battery installed capacity
 lb(var-3) = max_cap_bat ; %[kWh]
%% upper bounds
ub = inf (var,1);
ub(var) = 0.8*max_cap_bat;
if count_tp_tminus >0 && (usage_TP_tminus+20*10^3)<105*10^3;
    ub(1)=usage_TP_tminus+20*10^3; % plus 20 MWh
else
    ub(1)=105*10^3;
end
% Max usage of PV
ub(4) = cap_pv;
ub(var-3) = max_cap_bat;
if bs > 10*10^3 % 10 MWh
    ub(var-1) = 10*10^3; %can't discharge more than 10 MWh
end

%% linear inequalities
eq=0;
A = zeros (1,var); 
b = zeros(1,1);

% Usage of thermal <= capacity_tp * cf_tp
A(1,[1 2]) = [1 -cftp]; b(1) = 0;
eq = eq +1;
% Usage of solar <= capacity_pv * cf_pv
A(2,[3 4]) = [1 -cfpv]; b(2) = 0;
eq = eq +1;
if wind == 1
        % Usage of wind <= capacity_wind * cf_wind
        A(eq +1,[6 7]) = [1 -cf_wind]; b(eq +1) = 0;
        eq = eq +1;
else
end

if bat == 1
    
    % usage of battery charging:
    % 4) x4 <= (c4-bs,t)/n4 <=> B.charging - capacity <= - status
    A(eq +1,[var-2 var-3]) = [1 -(1/n4)]; b(eq +1)= (1/n4)*(-bs);
    eq = eq +1;
    % usage of battery discharging:
    A(eq +1,[var-1]) = [1]; b(eq +1)=bs; %
    eq = eq +1;          
else    
end

% Demand restriction:
if bat == 1
    A(eq +1,[1 3 5 var-1 var-2])=[-1 -1*n_inv -1 (-n5) 1]; 
    b(eq +1) = -SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,1)*10^3 ; % demand at time t
else
%     A(eq +1,[1 3 5])=[-1 -1*n_inv -1]; 
%     b(eq +1) = -SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,1)*10^3 ; % demand at time t
end
%% linear equalities
eq_2=0;
Aeq = zeros(1,var); 
beq = zeros(1,1);
% All pv goes into the system
Aeq(1,[3 4]) = [1 -cfpv]; 
beq(eq_2+1) = 0 ;
eq_2 = eq_2+1;
 
% % All wind goes into the system
% if wind == 1
%     Aeq(eq_2+1,[6 7]) = [1 -cf_wind];
%     beq(eq_2+1) = 0 ;
%     eq_2 = eq_2+1;
% else 
% end

if bat == 1  
        % for batteries:
        Aeq(eq_2+1,[var var-2 var-1])=[1 (-n4) 1]; beq(eq_2+1)=bs;
        eq_2 = eq_2+1;           
% !!! ALL ENERGY MUST BE A 0 SUM GAME !!!
%TP + PV + IMP - EXP -CHR + DIS -DEM = 0
% x1 + x3 + x5 -x6  -(var-2) +(var-1) -demand = 0;       
        Aeq(eq_2+1,[1 3 5 6 var-2 var-1])=[1 1*n_inv 1 -1 -1 (n5)]; 
        beq(eq_2+1)=demand_day(hour,1)*10^3; %kWh
        eq_2 = eq_2+1;       
% if PV>0  -> BD = 0;
    if cfpv > 0.1
        Aeq(eq_2+1,[var-1])=[1]; beq(eq_2+1)= 0;
        eq_2 = eq_2+1;
    else
    end    
else
end

%% Calcules
  OM1 = (mc1+cc1)/8760; %thermal
  OM2 = (mc2+cc2)/8760; % PV
  
%   if wind == 1
%     OM3 = (mc3+cc3)/8760; % Wind
%   else
%   end
%   
  if bat == 1
     OM4 = cc4/8760; % battery   
  else
  end
%% Objective -> minimize total costs 
% Tc = OM1*c1 + OM2*c2 + OM3*c3 + OM4*c4 + OM5*c5 + ...
%...(p1/n1)*SOM [x1],t=1...8760 hrs
f = zeros(var,1) ;
f(2) = OM1 ; % capacity for thermal
f(4) = OM2 ; % capacity for solar
f(1) = ((p1/n1) + price_co2_euro_kg*co2_fac); 

% import cost = kWh_imported *( market_price_kWh + grid_cost_kWh )
f(5) = (cost_kWh_imported + SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,2)*10^-3); % [€/kWh]
f(6) = (fix_cost_connect - SM(24).(['M',num2str(month)]).(['D',num2str(day)])(hour,2)*10^-3); %[€/kWh]
% 
% if wind ==1
%     f(7) = OM3 ; % capacity for wind 
% else
% end
if bat == 1
    f(var-3) = OM4; % cost per capacity installed
    %f(var-2)= lcoe_bat; %!!!!!!!!!!!!!!!!!!!!!!!! capacity battery it's wrong
else
end
%% call solver
[x val] = linprog(f,A,b,Aeq,beq,lb,ub);
%%
Mix(hour,:)=x'*10^-3; % MWh
% changes
val_vector(hour,1)=(val)*10^-2; %  hundred € = val * 100 €

%% 
% 
% if Mix(hour,5) > 1*10^-6
%     imp_month_day(count_imps,1) = month;
%     imp_month_day(count_imps,2) = day;
%     imp_month_day(count_imps,3) = hour;
%     imp_month_day(count_imps,4) = Mix(hour,5); % amount imported in MWh
%     imp_month_day(count_imps,5) = Mix(hour,5)*demand_day(hour,2); % Amount[MWh]*Price[€/MWh]
%     count_imps = count_imps +1;
% end
% if Mix(hour,6) > 1*10^-6 %if there are exports
%     exp_month_day(count_exps,1) = month;
%     exp_month_day(count_exps,2) = day;
%     exp_month_day(count_exps,3) = hour;
%     exp_month_day(count_exps,4) = Mix(hour,6); % amount exported in MWh
%     exp_month_day(count_exps,5) = Mix(hour,6)*demand_day(hour,2); % Amount[MWh]*Price[€/MWh]
%     count_exps = count_exps +1;
% end
% if Mix(hour,3) > 40
%             pv_month_day(count_pvs,1) = Mix(hour,3);
%             pv_month_day(count_pvs,2) = demand_day(hour,1);
%             pv_month_day(count_pvs,3) = Mix(hour,3)-(demand_day(hour,1)+Mix(hour,7)); %demand & charging
%             pv_month_day(count_pvs,4) = Mix(hour,1);
%             
%             pv_month_day(count_pvs,5) = hour;
%             pv_month_day(count_pvs,6) = day;
%             pv_month_day(count_pvs,7) = month;
%             count_pvs = count_pvs +1;
% end
       
% putting prices market in a vector
prices_year(count_prices,1) = demand_day(hour,2);       
count_prices = count_prices +1;
%% !! puting nest bs = bs,t+1
    if bat == 1
        bs=x(var,1); %kWh
        bstatus(hour+1,1) = x(var,1)*10^-3; % MWh
    else
    end
%getting the value for TP usage
    usage_TP_tminus = Mix(hour,1)*10^3; %kWh
    count_tp_tminus = 1;
    
    
end %hour =1:24
size_Mix = size(Mix);
% usage per hour
TP_hour = [TP_hour; Mix(:,1)]; %TP usage
PV_hour = [PV_hour; Mix(:,3)]; %PV usage
IMP_hour =[IMP_hour; Mix(:,5)]; %IMP usage
EXP_hour =[EXP_hour; Mix(:,var-4)];% export
BAT_hour =[BAT_hour; Mix(:,var-1)]; %BAT discharging
CHR_hour =[CHR_hour; Mix(:,var-2)]; %BAT charging
CAP_hour = [CAP_hour; Mix(:,var-3)]; % necessary bat installed capacity
DEM_hour =[DEM_hour; demand_day]; %Demand usage (:,1) , prices (:,2)
% usage per day
Emix(count_val_vec_year,1) = sum(Mix(:,1)); %TP usage
Emix(count_val_vec_year,2) = sum(Mix(:,3)); %PV usage
Emix(count_val_vec_year,3) = sum(Mix(:,5)); %IMP usage
Emix(count_val_vec_year,4) = sum(Mix(:,var-2)); %BAT charging
Emix(count_val_vec_year,5) = sum(Mix(:,var-1)); %BAT discharging
% costs
val_vec_year(count_val_vec_year,1)=sum(val_vector/10); % total cost of day [k€]
val_vec_year(count_val_vec_year,2)=sum(val_vector/10)/24; %avg hour
val_vec_year(count_val_vec_year,3)=sum(Mix(:,5)); % MWh imported
count_val_vec_year = count_val_vec_year + 1;
% Costs at second to last col
Mix(:,size_Mix(1,2)+1)=val_vector; % cost of ruuning VPP [*100€]

%% plotting with bars
% % 
% %Create a stacked bar chart using the bar function
% f = figure;
% if bat==1
% bar(1:24, [Mix(:,var-2) Mix(:,1)-Mix(:,var-2) Mix(:,3)-Mix(:,6)-Mix(:,var-2) Mix(:,5) Mix(:,var-1) Mix(:,6)], 1, 'stack'); hold on
% elseif bat == 0
% bar(1:24, [ Mix(:,1) Mix(:,3) Mix(:,5)], 1, 'stack'); hold on
% elseif bat == 0
% else
% end
% %plot(Mix(:,var+1),'r'); % cost per hour [€]
% avg_cost_hour = mean(Mix(:,var+1))*10^-1 ;
% plot(SM(24).(['M',num2str(month)]).(['D',num2str(day)])(:,1) ,'k'); % demad [MWh]
% %bar(1:12, [measles' mumps' chickenPox'], 1)
% % Adjust the axis limits
% axis([0 25 0 150])
% set(gca, 'XTick', 1:12)
% set(gca, 'YTick', 0:10:150)
% 
% % Add title and axis labels
% title('Eletricity Generation')
% 
% 
%  set(gca,'layer','top');
%  x1 = 1:1:24;
%  set(gca,'XTick',x1);
%  grid on; box on;
%  xlabel('hours')
%  ylabel('MWh');
% 
% % Add a legend
% if bat == 1
%     legend('charging(Solar)','thermal', 'solar', 'import','discharge','export(Solar)','demand','Location','northeastoutside','Orientation','vertical')
% elseif bat == 0
%     legend('thermal', 'solar', 'import','avg cost','demand')
% else
% end

% % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% running the entire year with images
% saveas(f, ['VPP_14_',num2str(month),'_',num2str(day)], 'png'); % so para vizualizaçao
% close(f)
end % day=1:31
end % month = 1:12
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

total_demand(idx,1) = sum(Emix(:,5))*10^3; %[kWh]
total_cost_year(idx,1) = sum(val_vec_year(:,1))*10^3; %[€]

%euro_kWh(idx,1) = total_cost_year/total_demand

%% getting total vals in kWh
m=10^6;
TP_kWh_produced = sum(TP_hour(:,1))*10^3 ; 
PV_kWh_produced = sum(PV_hour(:,1))*10^3 ; 
IMP_kWh_imported = sum(IMP_hour(:,1))*10^3 ;
CHR_kWh = sum(CHR_hour(:,1))*10^3;
DIS_kWh = sum(BAT_hour(:,1))*10^3;
EXP_kWh = sum(EXP_hour(:,1))*10^3;
DEM_kWh = sum(DEM_hour(:,1))*10^3;

% MWh connectiong to the grid
 kW_grid_connection = max(EXP_hour)*10^3; %[10 MW]

E_in_sys = TP_kWh_produced + (PV_kWh_produced-CHR_kWh) + IMP_kWh_imported + DIS_kWh; %[kWh]
E_req = sum(DEM_hour(:,1))*10^3; %[kWh]
%% Pie chart
% kWh_PV = PV_kWh_produced-CHR_kWh; % bateries are charged from pv
% 
% x = [TP_kWh_produced,IMP_kWh_imported,kWh_PV,DIS_kWh];
% labels = {'TP','IMP','PV','BAT'};
% figure
% h = pie(x,labels);
% 
% x = [TP_kWh_produced,IMP_kWh_imported,kWh_PV,DIS_kWh];
% figure
% h = pie(x);
 %%



