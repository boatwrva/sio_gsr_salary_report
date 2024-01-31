% Scrpit to create two-panel figure showing inflation-adjusted and
% rent-adjusted normalized GSR salary at SIO from September 2016 to May
% 2025. Takes "salaries.txt" as input, which is a timeseires of salary data
% generated using the script "generate_salary_timeseries.m". Also takes CPI
% data downloaded from the Bureau of Labor Statistics, and housing rental
% data downloaded from Zillow.

% load salary data
salary_array = readmatrix('salaries.txt');
t = datetime(salary_array(:,1),'convertfrom','datenum');
gsr_salary_old_student_prequal = salary_array(:,2);
gsr_salary_old_student_postqual = salary_array(:,3);
gsr_salary_new_student_prequal = salary_array(:,4);
gsr_salary_new_student_postqual = salary_array(:,5);

% specify times of contract implementation
contract_start_time = datetime(2023,04,01);
settlement_time = datetime(2024,04,01);
bar_offset = caldays(-15); % to make the plots look nice

% extract cpi values
% CPI data downloaded from Bureau of Labor Statistics website
% path from https://www.bls.gov/ is:
% subjects > consumer price index > cpi data > regional resources > west
% https://data.bls.gov/pdq/SurveyOutputServlet?data_tool=dropmap&series_id=CUUR0400SA0,CUUS0400SA0
cpi = zeros(size(t));
cpi_table = readtable('cpi_western_urban_dec2023.xlsx');
cpi_array = table2array(cpi_table(:,2:13));
for i = 1:length(t)
    for j = 1:length(cpi_table.Year)
        if year(t(i)) == cpi_table.Year(j)
            for k = 1:12
                if month(t(i)) == k
                    cpi(i) = cpi_array(j,k);
                    break
                end
            end
            break
        end
    end
end

cpi(cpi==0) = NaN;

% create projected_cpi_array
current_time_index = find(~isnan(cpi), 1, 'last' );
cpi_projected = cpi(current_time_index)*1.02.^years(t-t(current_time_index));
cpi_projected(1:current_time_index-1) = NaN;

% compute cpi-normalized salaries
cpi_normalized_salary_old_student_prequal_historical = (gsr_salary_old_student_prequal./gsr_salary_old_student_prequal(1))./(cpi/cpi(1));
cpi_normalized_salary_old_student_postqual_historical = (gsr_salary_old_student_postqual./gsr_salary_old_student_postqual(1))./(cpi/cpi(1));
cpi_normalized_salary_old_student_prequal_projected = (gsr_salary_old_student_prequal./gsr_salary_old_student_prequal(1))./(cpi_projected/cpi(1));
cpi_normalized_salary_old_student_postqual_projected = (gsr_salary_old_student_postqual./gsr_salary_old_student_postqual(1))./(cpi_projected/cpi(1));

cpi_normalized_salary_new_student_prequal_historical = (gsr_salary_new_student_prequal./gsr_salary_old_student_prequal(1))./(cpi/cpi(1));
cpi_normalized_salary_new_student_postqual_historical = (gsr_salary_new_student_postqual./gsr_salary_old_student_postqual(1))./(cpi/cpi(1));
cpi_normalized_salary_new_student_prequal_projected = (gsr_salary_new_student_prequal./gsr_salary_old_student_prequal(1))./(cpi_projected/cpi(1));
cpi_normalized_salary_new_student_postqual_projected = (gsr_salary_new_student_postqual./gsr_salary_old_student_postqual(1))./(cpi_projected/cpi(1));

% specify colors for plotting
color_set = cbrewer2('set1',8);
old_student_prequal_col = color_set(2,:);
old_student_postqual_col = color_set(1,:);
new_student_prequal_col = color_set(3,:);
new_student_postqual_col = color_set(4,:);
vertical_bar_col = 0.7*[1 1 1];

% plot cpi-normalized gsr salary
figure(1);
subplot(2,1,1);
ylimits = [0.85 1.28];
plot([contract_start_time contract_start_time]+bar_offset,ylimits,'color',vertical_bar_col,'linewidth',2);
hold on;
plot([settlement_time settlement_time]+bar_offset,ylimits,'color',vertical_bar_col,'linewidth',2);

h4 = plot(t,cpi_normalized_salary_new_student_postqual_historical,'color',new_student_postqual_col,'linewidth',2);
h3 = plot(t,cpi_normalized_salary_new_student_prequal_historical,'color',new_student_prequal_col,'linewidth',2);
plot(t,cpi_normalized_salary_new_student_prequal_projected,'color',new_student_prequal_col,'linewidth',2,'linestyle','--');
plot(t,cpi_normalized_salary_new_student_postqual_projected,'color',new_student_postqual_col,'linewidth',2,'linestyle','--');

h2 = plot(t,cpi_normalized_salary_old_student_postqual_historical,'color',old_student_postqual_col,'linewidth',2);
h1 = plot(t,cpi_normalized_salary_old_student_prequal_historical,'color',old_student_prequal_col,'linewidth',2);
plot(t,cpi_normalized_salary_old_student_postqual_projected,'color',old_student_postqual_col,'linewidth',2,'linestyle','--');
plot(t,cpi_normalized_salary_old_student_prequal_projected,'color',old_student_prequal_col,'linewidth',2,'linestyle','--');

h5 = plot(NaN,NaN,'color','black','linewidth',2);
h6 = plot(NaN,NaN,'color','black','linewidth',2,'linestyle','--');
hold off;
text(datetime(2023,5,15),0.98,'Initial contract implementation','rotation',90,'fontsize',11);
text(datetime(2024,5,15),1.03,'Settlement','rotation',90,'fontsize',11);
ylim(ylimits);
yticks(0.9:0.05:1.25);
ylabel('Inflation-adjusted normalized salary, S_I');
legend([h1 h2 h3 h4 h5 h6],{'Old Students, pre-qualification','Old Students, post-qualification','New Students, pre-qualification','New Students, post-qualification','Historical','Projected'},'location','northwest');
grid on;
set(gca,'fontsize',12);
set(gca,'position',[0.1 0.55 0.84 0.4]);

% extract zillow rent data
% ZORI (smoothed): All homes plus multifamily time series, by city
% downloaded from https://www.zillow.com/research/data/
% need to look manually in the file to see start and stop times
zori_table = readtable('zori_unadjusted_all_homes_plus_multifamily_by_city_dec2023.csv');
zori_san_diego_raw = table2array(zori_table(10,9:end))';
zori_time = (datetime(2015,01,01):calmonths(1):datetime(2023,12,1))'; 

% put zori onto same time stamp
zori = NaN(size(t));
for i = 1:length(t)
    for j = 1:length(zori_time)
        if t(i) == zori_time(j)
            zori(i) = zori_san_diego_raw(j);
        end
    end
end

% create projected zori (flat to end of contract)
zori_projected = NaN(size(zori));
zori_projected(current_time_index:end) = zori(current_time_index);

% compute rent-normalized salaries
rent_normalized_salary_old_student_prequal_historical = (gsr_salary_old_student_prequal./gsr_salary_old_student_prequal(1))./(zori./zori(1));
rent_normalized_salary_old_student_postqual_historical = (gsr_salary_old_student_postqual./gsr_salary_old_student_postqual(1))./(zori./zori(1));
rent_normalized_salary_old_student_prequal_projected = (gsr_salary_old_student_prequal./gsr_salary_old_student_prequal(1))./(zori_projected./zori(1));
rent_normalized_salary_old_student_postqual_projected = (gsr_salary_old_student_postqual./gsr_salary_old_student_postqual(1))./(zori_projected./zori(1));

rent_normalized_salary_new_student_prequal_historical = (gsr_salary_new_student_prequal./gsr_salary_old_student_prequal(1))./(zori./zori(1));
rent_normalized_salary_new_student_postqual_historical = (gsr_salary_new_student_postqual./gsr_salary_old_student_postqual(1))./(zori./zori(1));
rent_normalized_salary_new_student_prequal_projected = (gsr_salary_new_student_prequal./gsr_salary_old_student_prequal(1))./(zori_projected./zori(1));
rent_normalized_salary_new_student_postqual_projected = (gsr_salary_new_student_postqual./gsr_salary_old_student_postqual(1))./(zori_projected./zori(1));

% plot rent-normalized gsr salary
subplot(2,1,2);
ylimits = [0.7 1.08];
plot([contract_start_time contract_start_time]+bar_offset,ylimits,'color',vertical_bar_col,'linewidth',2);
hold on;
plot([settlement_time settlement_time]+bar_offset,ylimits,'color',vertical_bar_col,'linewidth',2);

h3 = plot(t,rent_normalized_salary_new_student_prequal_historical,'color',new_student_prequal_col,'linewidth',2);
h4 = plot(t,rent_normalized_salary_new_student_postqual_historical,'color',new_student_postqual_col,'linewidth',2);
plot(t,rent_normalized_salary_new_student_postqual_projected,'color',new_student_postqual_col,'linewidth',2,'linestyle','--');
plot(t,rent_normalized_salary_new_student_prequal_projected,'color',new_student_prequal_col,'linewidth',2,'linestyle','--');

h2 = plot(t,rent_normalized_salary_old_student_postqual_historical,'color',old_student_postqual_col,'linewidth',2);
h1 = plot(t,rent_normalized_salary_old_student_prequal_historical,'color',old_student_prequal_col,'linewidth',2);
plot(t,rent_normalized_salary_old_student_postqual_projected,'color',old_student_postqual_col,'linewidth',2,'linestyle','--');
plot(t,rent_normalized_salary_old_student_prequal_projected,'color',old_student_prequal_col,'linewidth',2,'linestyle','--');

hold off;
ylim(ylimits);
grid on;
ylabel('Rent-adjusted normalized salary, S_R');
set(gca,'fontsize',12);
set(gca,'position',[0.1 0.06 0.84 0.4]);

annotation('textbox',[0.05 0.89 0.1 0.1],'string','(a)','fontsize',14,'edgecolor','none','fontweight','bold');
annotation('textbox',[0.05 0.4 0.1 0.1],'string','(b)','fontsize',14,'edgecolor','none','fontweight','bold');
set(gcf,'position',[360 42 760 740]);
saveas(1,'combined_normalized_gsr_salary.png');