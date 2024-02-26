% Script to generate a text file containing monthly salay data for old and
% new SIO GSRs pre- and post-qualification. The output file,
% "salaries.txt", serves as the input for the scrpit
% "generate_normalized_salary_figure.m"

% create datetime array
t_start = datetime(2015,01,01);
t_end = datetime(2025,05,01);
t = (t_start:calmonths(1):t_end)';

t_dnum = datenum(t);

% specify times of raises
t_2019_raise = datetime(2019,07,01);
t_2021_raise = datetime(2021,07,01);
t_2022_raise = datetime(2022,07,01);
t_apr23_raise = datetime(2023,04,01);
t_oct23_raise = datetime(2023,10,01);
t_oct24_raise = datetime(2024,10,01);
t_new_students_start = datetime(2023,09,01);
t_settlement_start = datetime(2024,04,01);
t_settlement_end = datetime(2024,07,01);

% initialize arrays
gsr_salary_old_student_prequal = zeros(size(t));
gsr_salary_old_student_postqual = zeros(size(t));
gsr_salary_new_student_prequal = zeros(size(t));
gsr_salary_new_student_postqual = zeros(size(t));
step3_fte = NaN(size(t));
step4_fte = NaN(size(t));
step6_fte = NaN(size(t));

% specify step 3 FTE salary
step3_fte(t_apr23_raise<=t & t<t_oct23_raise) = 70915;
step3_fte(t_oct23_raise<=t & t<t_oct24_raise) = 75454;
step3_fte(t_oct24_raise<=t) = 80260;

% specify step 4 FTE salary
step4_fte(t_apr23_raise<=t & t<t_oct23_raise) = 76411;
step4_fte(t_oct23_raise<=t & t<t_oct24_raise) = 81302;
step4_fte(t_oct24_raise<=t) = 86481;

% specify step 6 FTE salary
step6_fte(t_apr23_raise<=t & t<t_oct23_raise) = 88714;
step6_fte(t_oct23_raise<=t & t<t_oct24_raise) = 94392;
step6_fte(t_oct24_raise<=t) = 100406;

% specify old student pre-qualification salary
gsr_salary_old_student_prequal(t<t_2019_raise) = 30000;
gsr_salary_old_student_prequal(t_2019_raise<=t & t<t_2021_raise) = 32000;
gsr_salary_old_student_prequal(t_2021_raise<=t & t<t_2022_raise) = 33000;
gsr_salary_old_student_prequal(t_2022_raise<=t & t<t_apr23_raise) = 34000;
gsr_salary_old_student_prequal(t_apr23_raise<=t & t<t_settlement_start) = 0.4*step6_fte(t_apr23_raise<=t & t<t_settlement_start);
gsr_salary_old_student_prequal(t_settlement_start<=t & t<t_settlement_end) = 0.5*step6_fte(t_settlement_start<=t & t<t_settlement_end);
gsr_salary_old_student_prequal(t_settlement_end<=t) = 0.4*step6_fte(t_settlement_end<=t);

% specify old student post-qualification salary
gsr_salary_old_student_postqual(t<t_2019_raise) = 31000;
gsr_salary_old_student_postqual(t_2019_raise<=t & t<t_2021_raise) = 33000;
gsr_salary_old_student_postqual(t_2021_raise<=t & t<t_2022_raise) = 34000;
gsr_salary_old_student_postqual(t_2022_raise<=t & t<t_apr23_raise) = 35000;
gsr_salary_old_student_postqual(t_apr23_raise<=t & t<t_settlement_start) = 0.43*step6_fte(t_apr23_raise<=t&t<t_settlement_start);
gsr_salary_old_student_postqual(t_settlement_start<=t & t<t_settlement_end) = 0.5*step6_fte(t_settlement_start<=t & t<t_settlement_end);
gsr_salary_old_student_postqual(t_settlement_end<=t) = 0.43*step6_fte(t_settlement_end<=t);

% specify new student pre-qualification salary
gsr_salary_new_student_prequal(t<t_new_students_start) = NaN;
gsr_salary_new_student_prequal(t>=t_new_students_start) = 0.5*step3_fte(t>=t_new_students_start);

% specify new student post-qualification salay
gsr_salary_new_student_postqual(t<t_new_students_start) = NaN;
gsr_salary_new_student_postqual(t>=t_new_students_start) = 0.5*step4_fte(t>=t_new_students_start);

% print salaries to file
salary_array = [t_dnum, gsr_salary_old_student_prequal, gsr_salary_old_student_postqual, gsr_salary_new_student_prequal, gsr_salary_new_student_postqual];
fid = fopen('salaries.txt','w');
fprintf(fid,'%7s %15s %15s %15s %15s\r\n','datenum','old-prequal','old-postqual','new-prequal','new-postqual');
fprintf(fid,'%7d %15.2f %15.2f %15.2f %15.2f\r\n',salary_array');
fclose(fid);

% plot salaires
figure(1);
plot(t,gsr_salary_old_student_prequal);
hold on;
plot(t,gsr_salary_old_student_postqual);
plot(t,gsr_salary_new_student_prequal);
plot(t,gsr_salary_new_student_postqual);
hold off;