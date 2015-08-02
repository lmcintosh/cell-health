classdef spiketestPaq
    
   properties
      
       - spiking analysis
- for now just change analysis to keep track of spiketests for the cell in question and plot them with a time stamp
- later
	- create spike test subclass
	- look for current steps (median +/- step thresh) 
	- plot all steps	
	- store all step stats in a cell array
	isi = cell
		- get isi to classify adaptation or stuttering or bursting
	spikecount = cell
		- count spikes 
	firingrate
		- instatanious firing rate given a dt
	APhights
		- get spike amps
	Reobase
		- get min I needed to spike
	AHP
		- min after AP and median between APs or end of step
	Hcurrent
    - get hyperpolarizing current deflection min Vm after hyp step vs median

    %only for pulses with APs
    isi = cell(0)
    spikecount = [] 
    firingrate = cell(0) 
    APhights = cell(0) 
    AHP = cell(0) 
    currentSteps = []
    StepTimes = [] %set of start and stop times
    Reobase %current at first spike but not he real reobase
    Hcurrent = [] %only for hyperolarizing pulses
        
   end
   
   methods
       
   end
   
   %get set methods
   methods 
       
   end
    
end