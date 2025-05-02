function [O,M] = offset_GPIO_bhv2_v2(gpio_fname,bhv2_fname,gpio_num,bhv2_num,updown)
% This function defines the offset between a specific event (bhv_num) in a 
% bhv2 file (bhv2_name), and specific TTL shifts (updown = 1 would identify
% a 0 -> 5V shift, updown = 0 would identify a 5V -> 0V shift) in a gpio
% channel (gpio_num) in a GPIO file (gpio_fname).  The result O is in
% milliseconds.  Positive numbers indicate that the BHV2 file started AFTER
% the start of the GPIO file, while negative numbers indicate that the BHV2
% file started BEFORE the GPIO file.
%
% Example:
% >> O = offset_GPIO_bhv2('Time_Series_Quartz_L_2022_09_15_GPIO.csv','220915_Quartz_Sing-touch_Quartz_TTL2.bhv2',1,50,0)
% 
% This call will work on the two input files to extract TTL steps from 1 to
% 0 from the GPIO file, and occurrences of the reward event (event 50) from
% the BHV2 file.  The two values are cross-correlated, and the maximum of
% the match is selected.  The output O is 389351, meaning that the GPIO 
% file started 389.351s before the BHV2 file. 

% load data
BHV2 = mlread(bhv2_fname);
GPIO = read_gpio_csv(gpio_fname);

% extract timing from GPIO data
gpio_var_name = ['GPIO.GPIO_' num2str(gpio_num)];
gpio_chan = eval(gpio_var_name);
if updown == 1
    to_gpio = find(gpio_chan(2:end) > gpio_chan(1:end-1));  % this will find the START of the TTL pulses to be matched with bhv2 files
else
    to_gpio = find(gpio_chan(2:end) < gpio_chan(1:end-1));  % this will find the END of the TTL pulses to be matched with bhv2 files
end

% extract timing from BHV2 data
to_bhv2 = NaN(length(BHV2),1);
for i = 1:length(BHV2)
    f = BHV2(i).BehavioralCodes.CodeTimes(BHV2(i).BehavioralCodes.CodeNumbers == bhv2_num);
    if ~isempty(f)
        to_bhv2(i) = BHV2(i).AbsoluteTrialStartTime + f(1);
    end
end
to_bhv2 = to_bhv2(~isnan(to_bhv2));
to_bhv2 = round(to_bhv2);
if to_bhv2(1) == 0
    to_bhv2(1) = 1;
end

% generate time series
ts_gpio = zeros(max(to_gpio(end),to_bhv2(end)),1);
ts_gpio(to_gpio) = 1;
ts_bhv2 = zeros(max(to_gpio(end),to_bhv2(end)),1);
ts_bhv2(to_bhv2) = 1;

% calculate offset, based on cross-correlation
[M,max_x] = max(xcorr(ts_gpio,ts_bhv2));
O = max_x-length(ts_gpio);

% generate plots
subplot 221;
plot(ts_gpio);
title('GPIO');

subplot 222;
plot(ts_bhv2);
title('Bhv2 record');

subplot 223;
plot(xcorr(ts_gpio,ts_bhv2));
title('Cross-correlation');

subplot 224
if O > 0
    plot(ts_gpio(O:end));
    hold on;
    plot(ts_bhv2);
    hold off;
else
    plot(ts_gpio);
    hold on;
    plot(ts_bhv2(-O:end));
    hold off;
end
title('GPIO & Bhv2 records');

