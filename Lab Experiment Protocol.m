clear all
close all
clc

global InitialThreshold DotSize Num_Reinforce Slope i A b W0 Wc tf Click DotLoc Yes No Threshold Click_Count Target_click

%% Initialization
black = [0 0 0];
white = [255 255 255];
grey = [128 128 128];
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];

%%%%%%%%%%Initial Parameters%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_pass_final       = 8;            % Number of accumulated good clicks in final target to end block
num_pass_consecutive = 15;           % Numbcer of consecutive good clicks in all targets  to end block
num_max_click        = 50;           % Number of maximum number of clicks allowed in one trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% question1 = 'What reinforcement function would you like to choose?  ';
% disp('1: Linear   2: Convex   3: Concave')
% choice = input(question1);

question1 = 'Please enter your student ID:  ';
ID = input(question1);

question6 = 'Please enter the 5-digit code: ';
subject = input(question6,'s');

question2 = 'Please enter the number of trials:  ';
num_trial = input(question2);

if num_trial <= 2
   error('Invalid choice. Please restart the program.')
else   
end

num_linear = round(num_trial/3);
num_convex = round(num_trial/3);
num_concave = num_trial - num_linear - num_convex;
order = [ones(1,num_linear) ones(1,num_convex)*2 ones(1,num_concave)*3];
order = order(randperm(size(order,2))); % Shuffle order
order = num2cell(order);


question3 = 'Initial Threshold W0 =   ';
InitialThreshold = input(question3);

question4 = 'End Threshold Wc =   ';
DotSize = input(question4);

question5 = 'Number of reinforcements tf=   ';
Num_Reinforce = input(question5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%Optional GUI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if choice == 1
%     
%    gui2(1)
%    uiwait;
%    
% elseif choice == 2
%     gui2(2)
%     uiwait;
%     
% elseif choice == 3
%     gui2(3)
%     uiwait;
% 
% 
% else
%     error('Invalid choice. Please restart the program.')
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if QuitProgram == 0

Yes = [];
No = [];
DotLoc = [];
Dist = {};
Click = {}; 
StartTime = {};
ResponseTime = {};


%%
Screen('Preference', 'VisualDebugLevel', 1);
% InitializePsychSound(reallyneedlowlatency=0)
InitializePsychSound(1);
KbName('UnifyKeyNames'); 

commandwindow;

% Screen setup
[w,winRect]=Screen('OpenWindow',0,[0 0 0]);


ShowCursor('Arrow');


Screen('TextSize', w, 20);
Screen('TextFont',w,'Times');
Screen('TextStyle',w,1); 

% Read voice file
[voice1,Fs1] = audioread('Correct.wav');
[voice2,Fs2] = audioread('Wrong.wav');
pahandle1 = PsychPortAudio('Open', 4, [], 2, Fs1, 1, 0);
PsychPortAudio('FillBuffer', pahandle1, voice1');
pahandle2 = PsychPortAudio('Open', 4, [], 2, Fs2, 1, 0);
PsychPortAudio('FillBuffer', pahandle2, voice2');

% Load picture
thumb = imread('thumb up.png');
thumb(thumb == 255) = 1;

%% Instructions
message_begin=[ '\n'...
    'Welcome!\n'...
    '\n'...
    '\n'...
    'In this experiment, you will perform a series of reinforcement-based trials.\n '...
    '\n'...
    'For each trial, a black full screen is presented with a hidden circular target randomly placed somewhere on the screen.\n'...
    '\n'...
    'The size of the hidden target will shrink throught the trial.\n'...
    '\n'...
    'Your goal is to determine the location of this target.\n'...
    '\n'...
    'Otherwise, another voice will indicate that your click is outside the range of the target.\n'...
    '\n'...
    '\n'...
    'Left click the mouse on a location to determine whether it is within the target.\n'...
    '\n'...
    'Sounds will be provided to inform you whether the location you have clicked on is within the target or not.\n'...
    '\n'...
    'The trial will end after 15 consecutive clicks within the target or after 50 total clicks.\n'...
    '\n'...
    'Once a trial ends, a second trial with a new randomly-placed target will automatically begin.\n'...
    '\n'...
    '\n'...
    '\n'...
    'Please press the space bar to go the the next page and hear the voice demo, then the experiment will start.\n'...
    '\n'];

DrawFormattedText(w, message_begin, 'center', 'center', white) ;
Screen('Flip', w) ;


press = true;

while press
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press = false;
    end
    
end


% Show message
message1=[ '\n'... 
           'If you hear this sound, \n '...
           '\n'... 
           '\n'...
           'your click is within the target.\n'...
           '\n'... 
           '\n'...
           'Click to hear demo.\n'];
DrawFormattedText(w, message1, 'center', 'center', white) ;
Screen('Flip', w) ;  


[~,~,~,whichButton] = GetClicks(w,0.001); % Get mouse click info 

MousePress = any(whichButton); %sets to 1 if a button was pressed

if MousePress %if key was pressed do the following
   sound(voice1,Fs1);
end

WaitSecs(1);


% Show message
message2=[ '\n'... 
           'If you hear this sound, \n '...
           '\n'... 
           '\n'...
           'your click is outside the target.\n'...
           '\n'... 
           '\n'...
           'Click to hear demo.\n'];
DrawFormattedText(w, message2, 'center', 'center', white) ;
Screen('Flip', w) ;  

% Get mouse click info 
[~,~,~,whichButton] = GetClicks(w,0.001);

MousePress = any(whichButton); %sets to 1 if a button was pressed

if MousePress %if key was pressed do the following
   sound(voice2,Fs2)
end

WaitSecs(1);



    message_start=[ '\n'...
    'Please press the space bar to start the experiment.\n'...
    '\n'];

    DrawFormattedText(w, message_start, 'center', 'center' , white) ;
    Screen('Flip', w) ;
    
    press_start = true;

while press_start
    [~, keyCode, ~] = KbWait;
    
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press_start = false;
    end
    
end



Threshold = [];
Target_Rect = [];
W0 = InitialThreshold;
Wc = DotSize;
tf = Num_Reinforce;



%% Trial loop
for i = 1:num_trial   % Number of trials
    
    Target_click{i,1}(1,1)=0; %Initialize
    
    if order{1,i} == 1
        order{2,i} = 'Linear';
        Slope = linspace(InitialThreshold, DotSize, Num_Reinforce);
        
    elseif order{1,i} == 2
        order{2,i} = 'Convex';

        b = 0.3;  % Define b value for convex
        A = (Wc-W0)/(1-exp(b*tf));
        
        for x = 0:tf
            y(x+1)=A*(1-exp(b*x))+W0;
            Slope(1,x+1) = y(x+1);
        end
        
    elseif order{1,i} == 3
        order{2,i} = 'Concave';

        b = -0.3;  % Define b value for convex
        A = (Wc-W0)/(1-exp(b*tf));
        
        for x = 0:tf
            y(x+1)=A*(1-exp(b*x))+W0;
            Slope(1,x+1) = y(x+1);
        end
        
    end

    
Count = 0;  % Initial correct click
 
% Random dot location within range
DotLoc(i,1) = (winRect(3) - InitialThreshold - InitialThreshold).*rand([1 1]) + InitialThreshold;       % X coordinate
DotLoc(i,2) = (winRect(4) - InitialThreshold - InitialThreshold).*rand([1 1]) + InitialThreshold;       % Y coordinate



% % Display circle
% Screen('DrawDots', w, [DotLoc(i,1);DotLoc(i,2)], DotSize, black, [0 0], 1);
% Screen('Flip', w);
% WaitSecs(0.5);

% Show message
message3=['Trial  ' num2str(i) ];
DrawFormattedText(w, message3, 'center', 'center', white) ;
Screen('Flip', w) ;  
WaitSecs(1); 

% Black screen
Screen('FillRect', w,[0 0 0],[winRect]); 
Screen('Flip', w) ;  


input = [];
a = 1;
temp = InitialThreshold;

for j = 1:num_max_click    % Number of clicks until reaching threshold 15 times overall
  
StartTime{i,1}(j,1) = GetSecs;
    
% Get mouse click info 
[clicks,x(j),y(j),whichButton] = GetClicks(w,0.01);

MousePress = any(whichButton); %sets to 1 if a button was pressed

if MousePress %if key was pressed do the following
   ResponseTime{i,1}(j,1) = GetSecs-StartTime{i,1}(j,1);
end

WaitSecs(0.005);

% Distance from first click point to center 1
Dist{i,1}(j,1) = sqrt((x(j) - DotLoc(i,1))^2 + (y(j) - DotLoc(i,2))^2);

Click{i,1}(j,1) = x(j);
Click{i,1}(j,2) = y(j);



% Decrease threshold - only when clicks are within threshold
if Dist{i,1}(j,1) <= temp
    a = a + 1;
    if a < size(Slope,2)
        temp = Slope(1,a);
    else
        a = size(Slope,2);
        temp = Slope(1,a);
    end
else
    temp = Slope(1,a);
end

Threshold(i,j) = temp;

if j == 1
if Dist{i,1}(j,1) <= Threshold(i,j)    % Determine if click is within threshold
 
    starttime = GetSecs + 0.001;
    PsychPortAudio('Start', pahandle1, 1,starttime);

   Yes{i,1}(j,1) = 1;
   No{i,1}(j,1) = 0;
   
   Click_Count = [ '' num2str(j) ''];
   DrawFormattedText(w, Click_Count, 0.9*winRect(3), 0.1*winRect(4), white);

   
   Screen('Flip', w) ;  
%    WaitSecs(0.1);

if Dist{i,1}(j,1) <= Wc   % Only when click is within target
    Target_click{i,1}(j,1) = 1;
    Count = Count +1;
else
    Target_click{i,1}(j,1) = 0;
end
   
   
   
else
   starttime = GetSecs + 0.001;
   PsychPortAudio('Start', pahandle2, 1,starttime);

   No{i,1}(j,1) = 1;
   Yes{i,1}(j,1) = 0;
   
   Click_Count = [ '' num2str(j) ''];
   DrawFormattedText(w, Click_Count, 0.9*winRect(3), 0.1*winRect(4), white);

   
   Screen('Flip', w) ;  
%    WaitSecs(0.1); 
  
end


elseif j > 1
    
    if Dist{i,1}(j,1) <= Threshold(i,j-1)    % Determine if click is within threshold

       starttime = GetSecs + 0.001;
       PsychPortAudio('Start', pahandle1, 1,starttime);

   Yes{i,1}(j,1) = 1;
   No{i,1}(j,1) = 0;
   
   Click_Count = [ '' num2str(j) ''];
   DrawFormattedText(w, Click_Count, 0.9*winRect(3), 0.1*winRect(4), white);

   
   Screen('Flip', w) ;  
%    WaitSecs(0.1);

if Dist{i,1}(j,1) <= Wc   % Only when click is within final target
    Target_click{i,1}(j,1) = 1;
    Count = Count +1;
else
    Target_click{i,1}(j,1) = 0;
end
   
   
   
    else
    
    starttime = GetSecs + 0.001;
    PsychPortAudio('Start', pahandle2, 1,starttime);

   No{i,1}(j,1) = 1;
   Yes{i,1}(j,1) = 0;
   
   Click_Count = [ '' num2str(j) ''];
   DrawFormattedText(w, Click_Count, 0.9*winRect(3), 0.1*winRect(4), white);

   
   Screen('Flip', w) ;  
%    WaitSecs(0.1); 

   end

end
    
         
   % Accumulated clicks within final target for "num_pass" times or Consecutive clicks within target for 15 times   
%    if (Count >= num_pass_final)|| (max(diff([0 (find(~(Target_click{i,1} > 0))') numel(Target_click{i,1})' + 1]) - 1) >= num_pass_consecutive)
   if (Count >= num_pass_final)

      WaitSecs(0.5);
      
DrawFormattedText(w, Click_Count, 0.9*winRect(3), 0.1*winRect(4), white);
Screen('PutImage', w, thumb, [0.49*winRect(3) 0.48*winRect(4) 0.49*winRect(3)+100 0.48*winRect(4)+100]);    % Show thumb up to encourage

Screen('Flip', w);
WaitSecs(1.5);
   
      
       break
       
   else
       continue
       
   end   % Count >=
end    % j

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Review%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
message_force = [ '\n'...
    'Press the space bar to review this trial.\n'...
    '\n'];


if (i < 4) ||(i == round(num_trial/3))||i == (round(num_trial/3))*2  % Review only after first 3 trials and before breaks

DrawFormattedText(w, message_force, 'center', 'center', white) ;
Screen('Flip', w) ; 

press = true;

while press
    [~, keyCode, ~] = KbWait;
  
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press = false;
    end
    
end
review(i);
end  %  if i < 4 force review
% else  % if i > 4
% 
% message_review = [ '\n'...
%     'Review? \n '...
%     '\n'...
%     '\n'...
%     'Press y for YES, press any other button for NO\n'...
%     '\n'];
% 
% DrawFormattedText(w, message_review, 'center', 'center', white) ;
% Screen('Flip', w) ; 
% 
% 
% %%%%%% Decide to review or not
%  press1 = true;
%     
%     while press1
%         [~, keyCode, ~] = KbPressWait;       
%         pressedKey = KbName(keyCode) ;
%               
%         YN = true;
%         while YN
%             
%             if strcmpi(pressedKey, 'y') == 1
%                 input = 'y';
%                 YN = false;
%                 
%             elseif strcmpi(pressedKey, 'n') == 1
%                 input = 'n';
%                 YN = false;
%             else
%                 YN = false;
%                 input = [];
%             end
%             
%         end    % while YN
%         
%         
%         if strcmpi('y',input) == 1
%            review(i);
%            press1 = false;
%            
%         else
%         press1 = false;
%         end
%     
%     end        % while press1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Review Ends%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if i == round(num_trial/3)
    
    message_rest=[ '\n'...
    'Please take a break.\n '...
    '\n'...
    'Press the space bar to continue when ready.\n'...
    '\n'];

    DrawFormattedText(w, message_rest, 'center', 'center' , white) ;
    Screen('Flip', w) ;
    
    press_rest = true;

while press_rest
    [~, keyCode, ~] = KbWait;
    
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press_rest = false;
    end
    
end
        

elseif i == round(num_trial/3)*2
    DrawFormattedText(w, message_rest, 'center', 'center' , white) ;
    Screen('Flip', w) ;
    
    press_rest = true;

while press_rest
    [~, keyCode, ~] = KbWait;
    
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press_rest = false;
    end
    
end
        
 
end
end    % i


message_end = [ '\n'...
    'Complete!\n'...
    '\n'...
    '\n'...
    'Thank you for your participation.\n'...
    '\n'...
    '\n'...
    'Press the space bar to exit.\n'];

DrawFormattedText(w, message_end, 'center', 'center', [255 255 255] ) ;
Screen('Flip', w) ; 
WaitSecs(0.1);

press_end = true;

while press_end
    [~, keyCode, ~] = KbWait;
  
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press_end = false;
    end
    
end

% ListenChar(0); %makes it so characters typed do show up in the command window
Screen('CloseAll'); %closes the window

% Save Results
Results.ClickLocation = Click;
Results.ClickDistance = Dist;
Results.StimuliLocation = DotLoc;
Results.ResponseTime = ResponseTime;
Results.Yes = Yes;
Results.No = No;
Results.Order = order;
Results.TargetClick = Target_click;


close all

formatOut = 'yymmdd';
date = datestr(now,formatOut);
filename = [num2str(date) '_' num2str(subject) '_' num2str(ID)];
save(filename)
