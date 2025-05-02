function [ct,TS_results] = extract_code_timing_Final(fname)
%for Monkey U 
code_number=[15 25 30 40 50 60 70 80 90 100]; 
%15_center ON, 25 center off, 30 center capture, 40 center hold, 50target on, 60target off, 70 center leave, 80 target capture, 90 reward on, 100 reward off
%% for Monkey Q
%code_number=[9 20 50 18];
%bhv_code(20,'Sample',40,'Go',50,'Reward',100,'TrialEnd');  % behavioral

%modified on 090124 to take in account the offset 
% Data in TS are put in s

%This will extract the timing of the codes stored in code_number.
% Multiple codes can be stored in code number.  The output will be a table
% in which the first column is the trial number, the second the status of
% the trial (good trial = 0, bad trial = 3), the third column is the Block
% and the forth is the condition (1 is target to the right, 2 target at the 
% center and 3 target on the left).
% The remaining columns identify the timing of the codes. The second output 
% variable is the 'cond' structure.  This contains the timing data, 
% relative to the start of the behavioral file, describingon all conditions
% that were tested (= different directions tested), and within those 
% conditions good, bad, and all trials (cond(2).bad would, for example, 
% contain the data from condition the bad trials of condition 2.e_flag = 0
% does not save the data, e_flag = 1 will save the data.
%
% Example call:
% >> extract_code_timing_v2('221025_Quartz_Sing-touch_Quartz_TTL2.bhv2',)
% according to ag_6n.m file bhv_code(80,'Sample',40,'Go',50,'Reward')
% This call will use the file 221025_Quartz_Sing-touch_Quartz_TTL2.bhv2 and
% will extract the trial outcome, and the timing of the trials that
% correspond to codes 20 and 50.  The data will be saved to disk. 
%
% TW 12/12/2022, 1/27/2023
%% AD 04/12/24
%Condition Monkey Q
% 1-Target to right
% 2-Target at center
% 3-Target to left
% Condition Monkey U
% 1- Target Left
% 2- Target Right



f_gpio=([fname '_GPIO.csv']);
disp('Select Bhv2 file')
[file,path] = uigetfile;
e_flag=0;%1 to save the data
f_ttl=([path file]);
o=offset_GPIO_bhv2_v2(f_gpio,f_ttl,3,90,0);
O=o/1000 %to put the offset in s instead of ms


TD = mlread(f_ttl);
ct = NaN(length(TD),length(code_number)+5);
for i = 1:length(TD)
    ct(i,1) = i;
    ct(i,2) = TD(i).TrialError;
    ct(i,3) = TD(i).Block;
    ct(i,4) = TD(i).Condition;
    ct(i,5) = TD(i).AbsoluteTrialStartTime;
    for j = 1:10
        a = find(TD(i).BehavioralCodes.CodeNumbers == code_number(j));
        if ~isempty(a)
            ct(i,5+j) = TD(i).BehavioralCodes.CodeTimes(a(1));
        end
    end

    for jj = 1:10 
        ct(i,j+6)=ct(i,5)+ct(i,jj+5);
        j=j+1;
    end 

end

I = identify_conditions(ct(:,4));
All_TS_results_RT=[];
All_TS_results_CenterOn=[];
All_TS_results_CenterOff=[];
All_TS_results_CenterCapture=[];
All_TS_results_CenterHold=[];
All_TS_results_TargetOn=[];
All_TS_results_TargetOff=[];
All_TS_results_CenterLeave=[];
All_TS_results_TargetCapture=[];
All_TS_results_RewardOn=[];
All_TS_results_RewardOff=[];


for i = 1:length(I)
    TS_results(i).identified_conditions=i;
    g = find(ct(:,4) == I(i) & ct(:,2) == 0);           % identifies good trials in condition i
    g_offset = ct(g,5);
   TS_results(i).CenterOn =ct(g,16)/1000;
   TS_results(i).CenterOff =ct(g,17)/1000;
   TS_results(i).CenterCapture =ct(g,18)/1000; 
   TS_results(i).CenterHold =ct(g,19)/1000;
   TS_results(i).TargetOn =ct(g,20)/1000; 
   TS_results(i).TargetOff =ct(g,21)/1000;
   TS_results(i).CenterLeave =ct(g,22)/1000;
   TS_results(i).TargetCapture =ct(g,23)/1000;
   TS_results(i).RewardOn =ct(g,24)/1000;
   TS_results(i).RewardOff =ct(g,25)/1000;
   TS_results(i).RT =TS_results(i).TargetCapture -TS_results(i).TargetOn;
  
    TS_results(i).Mean_ResponseTime_ms=mean(TS_results(i).RT);
    TS_results(i).STD_ResponseTime=std(TS_results(i).RT);

     all = find(ct(:,4) == I(i));           % identifies all comdition in TS_results

    TS_results(i).SuccessRate=length ( TS_results(i).RT)*100/length (all);
    TS_results(i).identified_codes = code_number;  
    
    All_TS_results_RT=[All_TS_results_RT;TS_results(i).RT];
    All_TS_results_CenterOn=[All_TS_results_CenterOn;TS_results(i).CenterOn];
    All_TS_results_CenterOff=[All_TS_results_CenterOff;TS_results(i).CenterOff];
    All_TS_results_CenterCapture=[All_TS_results_CenterCapture;TS_results(i).CenterCapture];
    All_TS_results_CenterHold=[All_TS_results_CenterHold;TS_results(i).CenterHold];
    All_TS_results_TargetOn=[All_TS_results_TargetOn;TS_results(i).TargetOn];
    All_TS_results_TargetOff=[All_TS_results_TargetOff;TS_results(i).TargetOff];
    All_TS_results_CenterLeave=[All_TS_results_CenterLeave;TS_results(i).CenterLeave];
    All_TS_results_TargetCapture=[All_TS_results_TargetCapture;TS_results(i).TargetCapture];
    All_TS_results_RewardOn=[All_TS_results_RewardOn;TS_results(i).RewardOn];
    All_TS_results_RewardOff=[All_TS_results_RewardOff;TS_results(i).RewardOff];
       
    TS_results(i).CenterOn_withGPIOoffset= TS_results(i).CenterOn+O; %only for the trial that are succeful 
    TS_results(i).CenterOff_withGPIOoffset=TS_results(i).CenterOff+O;
    TS_results(i).CenterCapture_withGPIOoffset= TS_results(i).CenterCapture+O; 
    TS_results(i).CenterHold_withGPIOoffset=TS_results(i).CenterHold+O;
    TS_results(i).TargetOn_withGPIOoffset= TS_results(i).TargetOn+O; 
    TS_results(i).TargetOff_withGPIOoffset=TS_results(i).TargetOff+O;
    TS_results(i).CenterLeave_withGPIOoffset= TS_results(i).CenterLeave+O; 
    TS_results(i).TargetCapture_withGPIOoffset=TS_results(i).TargetCapture+O;
    TS_results(i).RewardOn_withGPIOoffset= TS_results(i).RewardOn+O; 
    TS_results(i).RewardOff_withGPIOoffset=TS_results(i).RewardOff+O;

end

%for all the TS_results
TS_results(4).identified_conditions='all condition';
TS_results(4).CenterOn_withGPIOoffset= All_TS_results_CenterOn+O;
TS_results(4).CenterOff_withGPIOoffset=All_TS_results_CenterOff+O;
TS_results(4).CenterCapture_withGPIOoffset= All_TS_results_CenterCapture+O;
TS_results(4).CenterHold_withGPIOoffset=All_TS_results_CenterHold+O;
TS_results(4).TargetOn_withGPIOoffset= All_TS_results_TargetOn+O;
TS_results(4).TargetOff_withGPIOoffset=All_TS_results_TargetOff+O;
TS_results(4).CenterLeave_withGPIOoffset= All_TS_results_CenterLeave+O;
TS_results(4).TargetCapture_withGPIOoffset=All_TS_results_TargetCapture+O;
TS_results(4).RewardOn_withGPIOoffset= All_TS_results_RewardOn+O;
TS_results(4).RewardOff_withGPIOoffset=All_TS_results_RewardOff+O;


TS_results(4).RT=All_TS_results_RT;
TS_results(4).Mean_ResponseTime_ms=mean(TS_results(4).RT);
TS_results(4).STD_ResponseTime=std(TS_results(4).RT);
TS_results(4).SuccessRate=length ( TS_results(4).RT)*100/length (ct(:,1));
TS_results(4).identified_codes = code_number;
save ([fname '.mat'],'TS_results','ct','-append')

clear TS* All_TS* ct* TD
end

function I = identify_conditions(c)
%

I = [];
for i = 1:1000
  if ~isempty(find(c == i))
      I = [I i];
  end
end
end
