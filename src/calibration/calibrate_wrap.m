%clc
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(03281978)

% Load in the moments generated by the jupyter notebook, 
% calibration_targets_results.ipynb

growth_r_moments = load('./data/growth_and_r_moments.csv', '-ascii');
firm_moments = load('./data/firm_moments.csv', '-ascii');
bejk_moments = load('./data/bejk_moments.csv', '-ascii');
trade_moments = load('./data/trade_moments.csv', '-ascii');
entry_moments = load('./data/entry_moment.csv', '-ascii');
disp('')
disp('')
disp(today('datetime'))
disp('')
disp('')
disp('Calibration Targets...')
disp('')
disp('Real Rate and Productivity Growth')
disp(growth_r_moments')
disp('')
disp('BEJK Exporter Moments: Fraction of Exporters, Relative Size')
disp(bejk_moments')
disp('')
disp('Home Trade Share')
disp(trade_moments)
disp('')
disp('Entry Moment')
disp(entry_moments)
disp('Firm Moments (LHS Table 3)')
disp(rot90(firm_moments,2))
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.delta = entry_moments(1,1);
params.zeta = 1.00;
params.gtarget = growth_r_moments(2);
params.rho = growth_r_moments(1) - params.gtarget;

M = 500;
z_bar = 7.0;

addpath('./eq_functions');
addpath('./markov_chain');

% Generating grids and stationary distribution
z = linspace(0, z_bar, M);
%The following are invariant as long as M and z are fixed
[L_1_minus, L_2] = generate_stencils(z);

params.zgridL1 = L_1_minus;
params.zgridL2 = L_2;
params.zgridz = z;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.gamma = 1.0001;
params.n = 10; % number of countries
params.eta = 0; % denomination of adaption costs
params.Theta = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% moments...

quantile_moments = [firm_moments(1,:); firm_moments(2,:)];
%quantile_moments = [0.233, 0.287, 0.312, 0.168; 0.0659, 0.112, 0.246, 0.576];

quantile_moments = repmat(1-sum(quantile_moments,2),1,4)/4 + quantile_moments;
% This just ensures they add up to one since, the moments are averaged
% accros years, they don't exactly sum up

moments.quantile_moments = quantile_moments;

moments.other_moments = [params.gtarget,trade_moments(1,1),bejk_moments(1,1),bejk_moments(2,1)];
% productivity growth, home share, frac exporters, relative size

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% approach to get close
%upper_bound = [8, 7.5, 0.5, 15.5,  0.00, 0.20, 8]; 
%lower_bound = [2, 2.5, 0.0001, 1.5,  -0.08, 0.001, 1.5];
%initial_val = [3.0220    4.9898    0.1042    7.8833   -0.0311    0.0483    3.1673]; 

% ObjectiveFunction = @(xxx) calibrate_growth((xxx),params,moments,1);
% 
% options = gaoptimset('Display','iter','Generations',20,'Initialpopulation', initial_val, 'UseParallel', true);
% 
% guess = ga(ObjectiveFunction, length(upper_bound),[],[],[],[],(lower_bound),(upper_bound),[],options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimset('Display','final','MaxFunEvals',5e4,'MaxIter',1e5);
initial_val = [3.0220    4.9898    0.1042    7.8833   -0.0311    0.0483    3.1673];

tic
[new_cal, fval] =fminsearch(@(xxx) calibrate_growth(xxx,params,moments,1),initial_val,options);
toc

disp(fval)
disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Calibration Results')
disp('Parameter Values')
disp('d, theta, kappa, 1/chi, mu, upsilon, sigma, delta, rho')
disp([new_cal,params.delta,params.rho])

all_stuff = calibrate_growth(new_cal,params,moments,0);


model_firm_moments = all_stuff(5:end,2)';
model_firm_moments = [model_firm_moments(1:4);model_firm_moments(5:end)];
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Moments: Model')
disp('')
disp('Real Rate and Productivity Growth')
disp([params.rho + all_stuff(1,2), all_stuff(1,2)])
disp('')
disp('BEJK Exporter Moments: Fraction of Exporters, Relative Size')
disp([all_stuff(3,2), all_stuff(4,2)])
disp('')
disp('Home Trade Share')
disp([all_stuff(2,2)])
disp('')
disp('Entry Moment')
disp(params.delta)
disp('Firm Moments (RHS Table 3)')
disp(rot90(model_firm_moments,2))
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Correlation Model and Data Firm Moments')
disp(corr(firm_moments(:),model_firm_moments(:)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% steady state welfare gain % use julia for this stuff
% params.d = new_cal(1);
% params.theta = new_cal(2);
% params.kappa = new_cal(3);
% params.chi = 1/new_cal(4);
% params.mu = new_cal(5);
% params.upsilon = new_cal(6);
% params.sigma = new_cal(7);
% 
% [baseline, b_welfare] = compute_growth_fun_cal(params);
%     

% 
% [counterfact, c_welfare] = compute_growth_fun_cal(params);
%     
% lambda_gain = exp((params.rho).*(c_welfare - b_welfare)) - 1;
% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp('')
% disp('10% change in d, S to S welfare gain')
% disp(100*lambda_gain)
% disp('Growth Rate: baseline, then 10% change in d')
% disp([baseline(1), counterfact(1)])
% disp('Trade: baseline, then 10% change in d')
% disp([baseline(2), counterfact(2)])
% disp('ACR Calculation, Percent Gain')
% disp(100*(1/new_cal(2))*log(baseline(2)/counterfact(2)))
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% params.d = new_cal(1);
% [baseline, b_welfare] = compute_growth_fun_cal(params);
%     
% high_tau = (new_cal(1)-1).*2.90 + 1;
% params.d = high_tau;
% 
% [counterfact, c_welfare] = compute_growth_fun_cal(params);
%     
% lambda_gain = exp((params.rho).*(c_welfare - b_welfare)) - 1;
% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp('')
% disp('Move to Autarky, S to S welfare gain')
% disp(100*lambda_gain)
% disp('Growth Rate: baseline, then Autarky')
% disp([baseline(1), counterfact(1)])
% disp('Trade: baseline, then Autarky')
% disp([baseline(2), counterfact(2)])
% disp('ACR Calculation, Percent Gain')
% disp(100*(1/new_cal(2))*log(baseline(2)/counterfact(2)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rmpath('./eq_functions');
rmpath('./markov_chain');

T = today('datetime');

save cal_params new_cal T

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% how the julia set up looks

%parameter_defaults_tests = @with_kw (? = 0.0215,
%                                ? = 3.1725,
%                                N = 10,
%                                ? = 5.0018,
%                                ? = 1.00,
%                                ? = 0.0732,
%                                ? = 1.0,
%                                ? = 0.,
%                                Theta = 1,
%                                ? = 1/5.9577,
%                                ? = 0.0484 ,
%                                ? = -0.0189,
%                                ? = 0.02,
%                                d_0 = 3.0426,
%                                d_T = 2.83834)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the order (15?)
% 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
% d_0, ?, ?, ?, ?, ?, ?, ?, ?, ?, N  ,?, Theta, ?, d_T
params.d = new_cal(1);
params.theta = new_cal(2);
params.kappa = new_cal(3);
params.chi = 1/new_cal(4);
params.mu = new_cal(5);
params.upsilon = new_cal(6);
params.sigma = new_cal(7);
params.gamma = 1.0;
params.dT = (new_cal(1)-1).*0.90 + 1;


header = {'theta', 'kappa', 'chi', 'mu', 'upsilon', 'zeta', 'delta', 'N', 'gamma', 'eta', 'Theta', 'd_0', 'd_T'};

final_cal = [params.theta, params.kappa, params.chi, params.mu, params.upsilon, params.zeta, params.delta...
    params.n, params.gamma, params.eta, params.Theta,params.d, params.dT];
    

%save calibration final_cal

writecell([header; num2cell(final_cal)],'../../parameters/calibration_params.csv')

growth_trade = all_stuff(1:4,[1,2]);
firm_dynamics = all_stuff(5:end,[1,2]);    

%save moments_model_data growth_trade firm_dynamics













