# autoshaping

This repo details an experiment that translated a previously developed
computational model of automatic behavior
(https://academic.oup.com/tbm/article/8/2/183/4859457?login=true)
shaping into a real-world setting.

By comparing the results of this experiment to its computational analogue, 
we aimed to validate the computational tool, which will allow it to be used
for designing future interventions. Participants (n = 54) operated a computer
mouse and attempted to locate a hidden, randomly placed target circle on a blank
computer screen and clicks within some threshold distance of the target circle
were reinforced by a pleasant auditory tone. As the trial progressed, the
threshold distance narrowed according to a shaping function until eventually
only clicks within the target circle were reinforced. Area Under Trajectory Curves and Time Until
10 Consecutive Target Clicks were used to quantify the probability of the
target behavior and linear mixed effects models were used to assess differential
outcomes for concave up, concave down, and linear shaping functions.

The following files associated with this experiment are provided:

1. Lab Experiment Data: One file per participant where each row is a trial, 
response is the number of trials before the trial ended, and function is
the type of shaping function: 1 = Concave Down, 2 = Linear, 3 = Concave Up

2. AUC Summary.csv: calculated AUCs detailing the average trajectory. 
One AUC per shaping function per participant

3. Data Analysis.R: the R script used to analyze the data

4. Lab Experimental Protocol: The Matlab code used to run the experiment. 
