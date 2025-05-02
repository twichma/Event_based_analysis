function ReorganizedData_Final (filename,TS)
% modified on 08/31/2023 to include the offset between GPIO file and iox
% video.
% For Ulrik
% ·         GPIO1 start time = when central target appears
% ·         GPIO1 end time = when the side target disappears
% ·         GPIO2 start time = when side target appears
% ·         GPIO2 end time = when the animal releases the center of the screen to reach the side target
% ·         GPIO3 = when the animal touches the side target (and then get the reward) 
% Example :ReorganizedData_Final ('Time_Series_Ulrik_R_2023_03_23',1)
% If there is no beahvioral task TS=0 else TS=1

fid2= fopen(filename,'r');
fnamee=[fname(145:end)] % needs to be adjusted if the path is added

%% this will load all the data exported from Inscopix
[num, txt, raw] = xlsread([fname '_Spikes.csv']);
[raw_num,raw_txt,raw_raw]=xlsread([fname '_Raw.csv']);
[Denoised_num,Denoised_txt,Denoised_raw]=xlsread([fname '_Denoised.csv']);
[numCC, txtCC, rawCC] = xlsread([fname '_Raw-props.csv']);
Cc=txt(2:end,2);

for i=1:length (Cc)
Ccc=Cc{i};
Clls{i}=Ccc(3:end);
end
CellsList=str2double(Clls);
N_Cells=CellsList(end);

j=1; %need this to extract the amplitude and timing 
for i=0:N_Cells
    N_events=length (find (CellsList==i));
    Cells(i+1, 1).Status=txtCC(i+2,2);
    Cells(i+1, 1).N_events=length (find (CellsList==i));
     T=raw_num(:,1);
    Cells(i+1, 1).Rate=length (find (CellsList==i))/T(end);
    Cells(i+1, 1).Time_events=num(j:(j+N_events-1),1);
    Cells(i+1, 1).Amp_events=num(j:(j+N_events-1),3);
    Cells(i+1, 1).Raw_data=raw_num(:,i+2);
    Cells(i+1, 1).Raw_timing=raw_num(:,1);
    Cells(i+1, 1).CentroideX=rawCC(i+2,6);
    Cells(i+1, 1).CentroideY=rawCC(i+2,7);
    j=j+length (find (CellsList==i));
end
j=1;
%Only select accepted Cells
for i=1:length (Cells)
    if Cells(i).Status=="accepted";
            Accepted_Cells(j)=Cells(i);
            j=j+1;
    end
end

% Add denoised data
for i=1:length (Accepted_Cells)
    Accepted_Cells(i).Denoised=Denoised_num(:,i+1);
end

if TS==1
%Spontaneous data vs Touch screen Data
TS_start=find (diff (Accepted_Cells(i).Raw_timing)>0.1)+1; %switch between S and TS
TS_start=TS_start(1);
for i=1:length (Accepted_Cells)
    Num_S_event=length (find (Accepted_Cells(i).Time_events<(TS_start/10)));
    Spontaneous.Accepted_Cells(i).Denoised=Accepted_Cells(i).Denoised(1:TS_start-1);
    TouchScreen.Accepted_Cells(i).Denoised=Accepted_Cells(i).Denoised(TS_start:end);
    Spontaneous.Accepted_Cells(i).Raw_timing=Accepted_Cells(i).Raw_timing(1:TS_start-1);
    TouchScreen.Accepted_Cells(i).Raw_timing=Accepted_Cells(i).Raw_timing(TS_start:end);
    TouchScreen.Accepted_Cells(i).Raw_timing2=TouchScreen.Accepted_Cells(i).Raw_timing-TouchScreen.Accepted_Cells(i).Raw_timing(1);
    TouchScreen.Accepted_Cells(i).Raw_data=Accepted_Cells(i).Raw_data(TS_start:end);
    Spontaneous.Accepted_Cells(i).Raw_data=Accepted_Cells(i).Raw_data(1:TS_start-1);
    Spontaneous.Accepted_Cells(i).CentroideX=Accepted_Cells(i).CentroideX;
    TouchScreen.Accepted_Cells(i).CentroideX=Accepted_Cells(i).CentroideX;
    Spontaneous.Accepted_Cells(i).CentroideY=Accepted_Cells(i).CentroideY;
    TouchScreen.Accepted_Cells(i).CentroideY=Accepted_Cells(i).CentroideY;
    Spontaneous.Accepted_Cells(i).Time_events=Accepted_Cells(i).Time_events(1:Num_S_event);
    TouchScreen.Accepted_Cells(i).Time_events=Accepted_Cells(i).Time_events(Num_S_event+1:end);
    Spontaneous.Accepted_Cells(i).Amp_events=Accepted_Cells(i).Amp_events(1:Num_S_event);
    TouchScreen.Accepted_Cells(i).Amp_events=Accepted_Cells(i).Amp_events(Num_S_event+1:end);
    Spontaneous.Accepted_Cells(i).N_events=length (Spontaneous.Accepted_Cells(i).Time_events);
    TouchScreen.Accepted_Cells(i).N_events=length (TouchScreen.Accepted_Cells(i).Time_events);
    Spontaneous.Accepted_Cells(i).Rate=Spontaneous.Accepted_Cells(i).N_events/Spontaneous.Accepted_Cells(i).Raw_timing(end);
    TouchScreen.Accepted_Cells(i).Rate=TouchScreen.Accepted_Cells(i).N_events/TouchScreen.Accepted_Cells(i).Raw_timing2(end);
    Spontaneous.Accepted_Cells(i).MeanAmp=mean (Spontaneous.Accepted_Cells(i).Amp_events);
    TouchScreen.Accepted_Cells(i).MeanAmp=mean (TouchScreen.Accepted_Cells(i).Amp_events);    
end

%% ISI_gammafunction will calculate the rate, CV, mean amplitude ...
[Spontaneous,TouchScreen]=ISI_Final (Spontaneous,TouchScreen,fname);   
save ([fname '.mat'],'Spontaneous','TouchScreen')

%% for bhv file analysis calling extract code script to analyse beh data  
    [BehData.ct,BehData.TS_results] = extract_code_timing_Final(([path file]),[],[15 50 60],'g',4.76,0)  % for GPIO data, with a known offset of 4.76s
    %code_timing_data_to_Excel(BehData.ct,'test.xlsx')

%% for GPIO analysis 
if isfile([fname '_GPIO.csv'])
    [numTS, txtTS, rawTS] = xlsread([fname '_GPIO.csv']);
    CcTS=txtTS(:,2);
    prompt="GPIO_offset = ";
    GPIO_offset = input(prompt);
    
    k=1;%for GPIO-1
    kk=1;%for GPIO-2
    kkk=1;%for GPIO-3
    BehData.GPIO2.Start=[];
    BehData.GPIO2.End=[];
    BehData.GPIO1.Start=[];
    BehData.GPIO1.End=[];
    BehData.GPIO2.Outcome=[];
    BehData.GPIO3.Start=[];
    BehData.GPIO3.End=[];

for i=1:length (CcTS)

    if strcmp(CcTS{i},' GPIO-1')==1
        gPIO1{k}=i;
        k=k+1;
    end
    if strcmp(CcTS{i},' GPIO-2')==1
        gPIO2{kk}=i;
        kk=kk+1;
    end

    if strcmp(CcTS{i},' GPIO-3')==1
        gPIO3{kkk}=i;
        kkk=kkk+1;
    end

end

GPIO1v=cell2mat(rawTS(cell2mat(gPIO1),3)); %for value
GPIO2v=cell2mat(rawTS(cell2mat(gPIO2),3));%for value
GPIO3v=cell2mat(rawTS(cell2mat(gPIO3),3));%for value

GPIO1t=cell2mat(rawTS(cell2mat(gPIO1),1)); %for timing
GPIO2t=cell2mat(rawTS(cell2mat(gPIO2),1));%for timing
GPIO3t=cell2mat(rawTS(cell2mat(gPIO3),1));%for timing

ii=1;
g=1;
while ii<length (GPIO1v)
    ii;
    if GPIO1v(ii)>1000
        GPIO1start(g)=ii;
        ii=ii+1;
        while GPIO1v(ii)>1000 & ii<(length (GPIO1v)-1)
            ii=ii+1;
        end
        GPIO1end(g)=ii;
        g=g+1;
    else
        ii=ii+1;
    end
end

ii=1;
gg=1;
while ii<length (GPIO2v)
    if GPIO2v(ii)>1000
        GPIO2start(gg)=ii;
        ii=ii+1;
        while GPIO2v(ii)>1000 & ii<(length (GPIO2v)-1)
            ii=ii+1;
        end
        GPIO2end(gg)=ii;
        gg=gg+1;
    else
        ii=ii+1;
    end
end

ii=1;
ggg=1;
while ii<length (GPIO3v)
    if GPIO3v(ii)>1000
        GPIO3start(ggg)=ii;
        ii=ii+1;
        while GPIO3v(ii)>1000 & ii<(length (GPIO3v)-1)
            ii=ii+1;
        end
        GPIO3end(ggg)=ii;
        ggg=ggg+1;
    else
        ii=ii+1;
    end
end



if exist ('GPIO2start')==1
BehData.GPIO2.Start=GPIO2t(GPIO2start);
BehData.GPIO2.End=GPIO2t(GPIO2end);
end
if exist ('GPIO1start')==1
BehData.GPIO1.Start=GPIO1t(GPIO1start);
BehData.GPIO1.End=GPIO1t(GPIO1end);
end
if exist ('GPIO3start')==1
BehData.GPIO3.Start=GPIO3t(GPIO3start);
BehData.GPIO3.End=GPIO3t(GPIO3end);
end

%% create a binary ouctome if there is some success and better organize the Data because GPIO1 and 2 are sometime reversed
    BehData.Trial_Start=BehData.GPIO1.Start+GPIO_offset;
    BehData.Trial_End=BehData.GPIO1.End+GPIO_offset;
    BehData.Target_Start=BehData.GPIO2.Start+GPIO_offset;
    BehData.Target_End=BehData.GPIO2.End+GPIO_offset;
    BehData.Reward_Start=BehData.GPIO3.Start+GPIO_offset;
    BehData.Reward_End=BehData.GPIO3.End+GPIO_offset;


if length (BehData.Reward_Start)>0
y=1;
yy=1;
  for y=1:length (BehData.Trial_Start)
      if yy>length (BehData.Reward_Start)
          BehData.Outcome(y)=3;
      else
        if (BehData.Reward_Start(yy)> BehData.Trial_Start(y) & BehData.Reward_Start(yy)< BehData.Trial_End(y))
        BehData.Outcome(y)=0;
        yy=yy+1;
        else
        BehData.Outcome(y)=3;
        end
      end
  end
BehData.Outcome=BehData.Outcome';
end
  
extract_code_timing_Ulrik_v8(fname);
save ([fname '.mat'],'BehData','Spontaneous','TouchScreen','-append')
clear Spontaneous TouchScreen Cells Ccc Clls Accepted_Cells BehData* GPIO* gPIO3 gPIO1 gPIO2 TS_results ct
else

save ([fname '.mat'],'Spontaneous','TouchScreen','-append')
clear Spontaneous TouchScreen Cells Ccc Clls Accepted_Cells     
end
clear all
end

if TS==0;

for i=1:length (Accepted_Cells)
    Num_S_event=length (find (Accepted_Cells(i).Time_events));
    Spontaneous.Accepted_Cells(i).Denoised=Accepted_Cells(i).Denoised(1:end);
    Spontaneous.Accepted_Cells(i).Raw_timing=Accepted_Cells(i).Raw_timing(1:end);
    Spontaneous.Accepted_Cells(i).Raw_data=Accepted_Cells(i).Raw_data(1:end);
    Spontaneous.Accepted_Cells(i).CentroideX=Accepted_Cells(i).CentroideX;
    Spontaneous.Accepted_Cells(i).CentroideY=Accepted_Cells(i).CentroideY;
    Spontaneous.Accepted_Cells(i).Time_events=Accepted_Cells(i).Time_events(1:end);
    Spontaneous.Accepted_Cells(i).Amp_events=Accepted_Cells(i).Amp_events(1:end);
    Spontaneous.Accepted_Cells(i).N_events=length (Spontaneous.Accepted_Cells(i).Time_events);
    Spontaneous.Accepted_Cells(i).Rate=Spontaneous.Accepted_Cells(i).N_events/Spontaneous.Accepted_Cells(i).Raw_timing(end);
    Spontaneous.Accepted_Cells(i).MeanAmp=mean (Spontaneous.Accepted_Cells(i).Amp_events);   
end
[Spontaneous]=ISI_gammafunctionSpont (Spontaneous,fname)   
save ([fname '.mat'],'Spontaneous')
clear Spontaenous Cells Ccc Clls Accepted_Cells
end

end