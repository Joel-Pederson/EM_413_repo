% EM.413 OS14 
% Allows manipulation and visualization of Containment (Performance) PDFs for OS14 Q1 and Q2
close all; clear all; clc;

% Initialize cell arrays for Excel export
decisions_data = {'Decision', 'Metric', 'Opt1_Name', 'Opt1_Mean', 'Opt1_Std', 'Opt2_Name', 'Opt2_Mean', 'Opt2_Std', 'Opt3_Name', 'Opt3_Mean', 'Opt3_Std'};
concepts_data = {'Concept_Name', 'Mean_Area_m2', 'Std_Area_m2', 'Mean_Cost_USD', 'Std_Cost_USD'};

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);

% Define a square meters per Fibonacci score value that can be used in containment area PDFs
CAslope = 880;

%% -- Question 1 Decision Aid -- %%

%% %%%% -- CONTAINMENT AREA -- %%%% %%

%% -- DECISION 1: LOADING METHOD CONTAINMENT -- %%
% Modeled based on CAslope = 880 logic. 
% Shifted using 3-sigma rule to respect the 26,000 m^2 absolute ceiling.

% -- Option 1: Self-Propelled Drive-On
% Moderate variance, slight delay penalty (CAslope * 1)
sigma_d1_o1_area = CAslope * 2;
mu_d1_o1_area = 26000 - (3 * sigma_d1_o1_area) - (CAslope * 1);
y_d1_o1_area = normpdf(x, mu_d1_o1_area, sigma_d1_o1_area);

% -- Option 2: Containerized Module
% Lowest variance, zero delay penalty (touches max ceiling)
sigma_d1_o2_area = CAslope * 1;
mu_d1_o2_area = 26000 - (3 * sigma_d1_o2_area) - (CAslope * 0);
y_d1_o2_area = normpdf(x, mu_d1_o2_area, sigma_d1_o2_area);

% -- Option 3: Dedicated Ground Loader
% Highest variance, highest delay penalty (CAslope * 2)
sigma_d1_o3_area = CAslope * 3;
mu_d1_o3_area = 26000 - (3 * sigma_d1_o3_area) - (CAslope * 2);
y_d1_o3_area = normpdf(x, mu_d1_o3_area, sigma_d1_o3_area);

% -- Plotting D1 Containment --
figure(1);
plot(x, y_d1_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Self Drive-On'); hold on;
plot(x, y_d1_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Containerized');
plot(x, y_d1_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Ground Loader');
title('Containment Area PDFs (D1: Loading Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D1: Loading Method', 'Containment Area (m^2)', ...
    'Self Drive-On', mu_d1_o1_area, sigma_d1_o1_area, ...
    'Containerized', mu_d1_o2_area, sigma_d1_o2_area, ...
    'Ground Loader', mu_d1_o3_area, sigma_d1_o3_area};

%% -- DECISION 2: INSERTION METHOD CONTAINMENT -- %%
% -- Option 1: Containerized Guided Drone 
% Beta Dist: Highly accurate (sub-500m) with active propulsion to fight wind, but expensive. Bounds: 24k to 26k
% Parameters for Beta(α,β) scaled to [a1,b1]
alpha1 = 8; beta1 = 2;
a1 = 24000; b1 = 26000;
% Normalize x into [0,1] for the beta PDF
x_norm1 = (x - a1) / (b1 - a1); 
% Treat values outside the interval as missing for the scaled density
x_norm1(x_norm1 < 0 | x_norm1 > 1) = NaN; 
% Compute scaled beta PDF on original x units (divide by scaling width)
y1 = betapdf(x_norm1, alpha1, beta1) / (b1 - a1); 

% -- Option 2: Precision Guided Parafoil
% Beta Dist: Good GPS steering and lower cost, but passive gliding increases wind drift risk. Bounds: 22k to 26k
alpha2 = 5; beta2 = 2;
a2 = 22000; b2 = 26000;
x_norm2 = (x - a2) / (b2 - a2);
x_norm2(x_norm2 < 0 | x_norm2 > 1) = NaN; 
y2 = betapdf(x_norm2, alpha2, beta2) / (b2 - a2);

% -- Option 3: Ramp Extraction / Airbag 
% Normal Dist: Very cheap and simple, but unguided drop creates massive footprint uncertainty. Mu=14k, Sig=4k
mu3 = 14000; sigma3 = 4000;
y3 = normpdf(x, mu3, sigma3);

% -- Plotting D2 
figure(2);
plot(x, y1, 'b', 'LineWidth', 2, 'DisplayName', 'Guided Drone (Beta)'); hold on;
plot(x, y2, 'r', 'LineWidth', 2, 'DisplayName', 'Parafoil (Beta)');
plot(x, y3, 'g', 'LineWidth', 2, 'DisplayName', 'Airbag (Normal)');
title('Containment Area PDFs (D2: Insertion Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

mu_std1 = alpha1 / (alpha1 + beta1);
var_std1 = (alpha1 * beta1) / ((alpha1 + beta1)^2 * (alpha1 + beta1 + 1));
mu_d2_o1_area = a1 + (mu_std1 * (b1 - a1));
sig_d2_o1_area = sqrt(var_std1 * (b1 - a1)^2);

mu_std2 = alpha2 / (alpha2 + beta2);
var_std2 = (alpha2 * beta2) / ((alpha2 + beta2)^2 * (alpha2 + beta2 + 1));
mu_d2_o2_area = a2 + (mu_std2 * (b2 - a2));
sig_d2_o2_area = sqrt(var_std2 * (b2 - a2)^2);

decisions_data(end+1,:) = {'D2: Insertion Method', 'Containment Area (m^2)', ...
    'Guided Drone', mu_d2_o1_area, sig_d2_o1_area, ...
    'Parafoil', mu_d2_o2_area, sig_d2_o2_area, ...
    'Airbag', mu3, sigma3};

%% -- DECISION 3: LANDING ACTIVATION -- %%
% Scaled Beta distribution (bounded [0, 26000]) — sharp right cutoff, correct ranking
% Parameters tuned to your preference (Fib scores 3/2/1 respected, no over-penalty)
a3 = 0; 
b3 = 26000;

% -- Option 1: Impact-Triggered Auto Activation (BEST — highest mean, sharp drop near 26k)
alpha_d3_o1 = 50; beta_d3_o1 = 3;               % mean ≈ 24,528 m²
y_d3_o1_area = betapdf((x - a3)/(b3 - a3), alpha_d3_o1, beta_d3_o1) / (b3 - a3);

% -- Option 2: Remote Commanded Activation (WORST)
alpha_d3_o2 = 40; beta_d3_o2 = 7;               % mean ≈ 22,128 m²
y_d3_o2_area = betapdf((x - a3)/(b3 - a3), alpha_d3_o2, beta_d3_o2) / (b3 - a3);

% -- Option 3: Dual Key Auto & Remote Activation (middle)
alpha_d3_o3 = 80; beta_d3_o3 = 10;              % mean ≈ 23,111 m²
y_d3_o3_area = betapdf((x - a3)/(b3 - a3), alpha_d3_o3, beta_d3_o3) / (b3 - a3);

% -- D3 Statistics for Table (exact means + actual Beta std devs)
mu_d3_o1_area = a3 + (alpha_d3_o1 / (alpha_d3_o1 + beta_d3_o1)) * (b3 - a3);
mu_d3_o2_area = a3 + (alpha_d3_o2 / (alpha_d3_o2 + beta_d3_o2)) * (b3 - a3);
mu_d3_o3_area = a3 + (alpha_d3_o3 / (alpha_d3_o3 + beta_d3_o3)) * (b3 - a3);

var_d3_o1 = (alpha_d3_o1*beta_d3_o1)/((alpha_d3_o1+beta_d3_o1)^2*(alpha_d3_o1+beta_d3_o1+1)) * (b3-a3)^2;
var_d3_o2 = (alpha_d3_o2*beta_d3_o2)/((alpha_d3_o2+beta_d3_o2)^2*(alpha_d3_o2+beta_d3_o2+1)) * (b3-a3)^2;
var_d3_o3 = (alpha_d3_o3*beta_d3_o3)/((alpha_d3_o3+beta_d3_o3)^2*(alpha_d3_o3+beta_d3_o3+1)) * (b3-a3)^2;

sigma_d3_o1_area = sqrt(var_d3_o1);
sigma_d3_o2_area = sqrt(var_d3_o2);
sigma_d3_o3_area = sqrt(var_d3_o3);

% -- Plotting D3
figure(3);
plot(x, y_d3_o1_area, 'b', 'LineWidth', 2, 'DisplayName', 'Auto Activate (Beta)'); hold on;
plot(x, y_d3_o2_area, 'r', 'LineWidth', 2, 'DisplayName', 'Remote Activate (Beta)');
plot(x, y_d3_o3_area, 'g', 'LineWidth', 2, 'DisplayName', 'Dual Key Activate (Beta)');
title('Containment Area PDFs (D3: Landing Activation)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthEast'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D3: Landing Activation', 'Containment Area (m^2)', ...
    'Auto Activate', mu_d3_o1_area, sigma_d3_o1_area, ...
    'Remote Activate', mu_d3_o2_area, sigma_d3_o2_area, ...
    'Dual Key', mu_d3_o3_area, sigma_d3_o3_area};

%% -- DECISION 4: FLEET COMPOSITION CONTAINMENT -- %%
% -- Option 1: Homogeneous (Reliable but slower)
mu_d4_o1_area = 25100; sigma_d4_o1_area = 300;
y_d4_o1_area = normpdf(x, mu_d4_o1_area, sigma_d4_o1_area);

% -- Option 2: Two-tier (Good tactical synergy)
mu_d4_o2_area = 24500; sigma_d4_o2_area = 500;
y_d4_o2_area = normpdf(x, mu_d4_o2_area, sigma_d4_o2_area);

% -- Option 3: Three-role (Perfect specialization)
mu_d4_o3_area = 23000; sigma_d4_o3_area = 1000;
y_d4_o3_area = normpdf(x, mu_d4_o3_area, sigma_d4_o3_area);

% -- Plotting D4 Containment --
figure(17);
plot(x, y_d4_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Homogeneous'); hold on;
plot(x, y_d4_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Two-Tier');
plot(x, y_d4_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Three-Role');
title('Containment Area PDFs (D4: Fleet Composition)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D4: Fleet Composition', 'Containment Area (m^2)', ...
    'Homogeneous', mu_d4_o1_area, sigma_d4_o1_area, ...
    '2-Tier', mu_d4_o2_area, sigma_d4_o2_area, ...
    '3-Role', mu_d4_o3_area, sigma_d4_o3_area};

%% -- DECISION 5: REPLACEMENT RATIO CONTAINMENT (Autonomy Proficiency) -- %%
% -- Option 1: 1:1 (High proficiency, high efficiency)
mu_d5_o1_area = 25000; sigma_d5_o1_area = 350;
y_d5_o1_area = normpdf(x, mu_d5_o1_area, sigma_d5_o1_area);

% -- Option 2: 3:1 (Moderate proficiency, some swarm friction)
mu_d5_o2_area = 23000; sigma_d5_o2_area = 1000;
y_d5_o2_area = normpdf(x, mu_d5_o2_area, sigma_d5_o2_area);

% -- Option 3: 6:1 (Low proficiency, high swarm friction)
mu_d5_o3_area = 20000; sigma_d5_o3_area = 2000;
y_d5_o3_area = normpdf(x, mu_d5_o3_area, sigma_d5_o3_area);

% -- Plotting D5 Containment --
figure(13);
plot(x, y_d5_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', '1:1 (High Proficiency)'); hold on;
plot(x, y_d5_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', '3:1 (Mod Proficiency)');
plot(x, y_d5_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', '6:1 (Low Proficiency)');
title('Containment Area PDFs (D5: Autonomy Proficiency Ratio)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D5: Autonomy Ratio', 'Containment Area (m^2)', ...
    '1:1', mu_d5_o1_area, sigma_d5_o1_area, ...
    '3:1', mu_d5_o2_area, sigma_d5_o2_area, ...
    '6:1', mu_d5_o3_area, sigma_d5_o3_area};

%% -- DECISION 6: DEPLOYMENT AIRCRAFT TYPE -- %%
% Note: Down-selected to A400M due to Airbus stakeholder constraint.
% Acts as a system baseline for all Monte Carlo architectures.

% -- Containment (Highly reliable baseline delivery) --
mu_d6_o1_area = 25500; sigma_d6_o1_area = 150;
y_d6_o1_area = normpdf(x, mu_d6_o1_area, sigma_d6_o1_area);

figure(11);
plot(x, y_d6_o1_area, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2.5, 'DisplayName', 'A400M Baseline');
title('Containment Area PDFs (D6: Deployment Aircraft)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D6: Aircraft', 'Containment Area (m^2)', ...
    'A400M', mu_d6_o1_area, sigma_d6_o1_area, ...
    'N/A', NaN, NaN, ...
    'N/A', NaN, NaN};

%% -- DECISION 7: COMMUNICATIONS CONTAINMENT -- %%
% -- Option 1: Per-Robot SATCOM
% Beta Dist: Highly reliable, minor canopy masking risk. Bounds: 22k to 26k
alpha4 = 8; beta4 = 2;
a4 = 22000; b4 = 26000;
x_norm4 = (x - a4) / (b4 - a4);
x_norm4(x_norm4 < 0 | x_norm4 > 1) = NaN;
y4 = betapdf(x_norm4, alpha4, beta4) / (b4 - a4);

% -- Option 2: Ground C2 Node (Localized RF) 
% Triangular Dist: Susceptible to terrain masking. 
% Min (a) = 12k, Mode (c) = 24k, Max (b) = 26k
% Define triangular membership breakpoints (left, peak, right)
a_tri = 12000; c_tri = 24000; b_tri = 26000;
% Preallocate output vector matching input x
y5 = zeros(size(x));
% Compute increasing side where x between left and peak
idx1 = (x >= a_tri & x <= c_tri);
y5(idx1) = 2 * (x(idx1) - a_tri) / ((b_tri - a_tri) * (c_tri - a_tri)); % Upward slope
% Compute decreasing side where x between peak and right
idx2 = (x > c_tri & x <= b_tri);
y5(idx2) = 2 * (b_tri - x(idx2)) / ((b_tri - a_tri) * (b_tri - c_tri)); % Downward slope

% -- Option 3: Airborne Relay Node 
% Beta Dist: Excellent LOS, but UAS refuel/loiter gaps. Bounds: 18k to 26k
alpha6 = 5; beta6 = 2;
a6 = 18000; b6 = 26000;
x_norm6 = (x - a6) / (b6 - a6);
x_norm6(x_norm6 < 0 | x_norm6 > 1) = NaN;
y6 = betapdf(x_norm6, alpha6, beta6) / (b6 - a6);

% -- Plotting D7 
figure(4);
plot(x, y4, 'Color', [0.00, 0.25, 0.45], 'LineWidth', 2.5, 'DisplayName', 'Per-Robot SATCOM (Beta)'); hold on;
plot(x, y5, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 2.5, 'DisplayName', 'Ground Node RF (Triangular)');
plot(x, y6, 'Color', [0.00, 0.60, 0.65], 'LineWidth', 2.5, 'DisplayName', 'Airborne Relay (Beta)');
title('Containment Area PDFs (D7: Communications)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax2 = gca; ax2.XAxis.Exponent = 0; ax2.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

mu_std4 = alpha4 / (alpha4 + beta4);
var_std4 = (alpha4 * beta4) / ((alpha4 + beta4)^2 * (alpha4 + beta4 + 1));
mu_d7_o1_area = a4 + (mu_std4 * (b4 - a4));
sig_d7_o1_area = sqrt(var_std4 * (b4 - a4)^2);

mu_d7_o2_area = (a_tri+b_tri+c_tri)/3;
sig_d7_o2_area = sqrt((a_tri^2+b_tri^2+c_tri^2 - a_tri*b_tri - a_tri*c_tri - b_tri*c_tri)/18);

mu_std6 = alpha6 / (alpha6 + beta6);
var_std6 = (alpha6 * beta6) / ((alpha6 + beta6)^2 * (alpha6 + beta6 + 1));
mu_d7_o3_area = a6 + (mu_std6 * (b6 - a6));
sig_d7_o3_area = sqrt(var_std6 * (b6 - a6)^2);

decisions_data(end+1,:) = {'D7: Communications', 'Containment Area (m^2)', ...
    'SATCOM', mu_d7_o1_area, sig_d7_o1_area, ...
    'Ground Node', mu_d7_o2_area, sig_d7_o2_area, ...
    'Airborne Relay', mu_d7_o3_area, sig_d7_o3_area};

%% -- DECISION 8: AUTONOMY MODE CONTAINMENT -- %%
% -- Option 1: Teleoperation (Normal: Human bottleneck)
mu_d8_o1_area = 16000; sigma_d8_o1_area = 3000;
y_d8_o1_area = normpdf(x, mu_d8_o1_area, sigma_d8_o1_area);

% -- Option 2: Supervised Autonomy (Normal: Better, but still human-limited)
mu_d8_o2_area = 21000; sigma_d8_o2_area = 1500;
y_d8_o2_area = normpdf(x, mu_d8_o2_area, sigma_d8_o2_area);

% -- Option 3: Coordinated Autonomy (Beta: High peak, vulnerable to edge cases)
alpha8_3 = 6; beta8_3 = 2; a8_3 = 12000; b8_3 = 26000;
x_norm8_3 = (x - a8_3) / (b8_3 - a8_3);
x_norm8_3(x_norm8_3 < 0 | x_norm8_3 > 1) = NaN;
y_d8_o3_area = betapdf(x_norm8_3, alpha8_3, beta8_3) / (b8_3 - a8_3);

% -- Plotting D8 Containment --
figure(9);
plot(x, y_d8_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Teleoperation (Normal)'); hold on;
plot(x, y_d8_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Supervised (Normal)');
plot(x, y_d8_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Coordinated (Beta)');
title('Containment Area PDFs (D8: Autonomy Mode)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f');

mu_std8_3 = alpha8_3 / (alpha8_3 + beta8_3);
var_std8_3 = (alpha8_3 * beta8_3) / ((alpha8_3 + beta8_3)^2 * (alpha8_3 + beta8_3 + 1));
mu_d8_o3_area = a8_3 + (mu_std8_3 * (b8_3 - a8_3));
sig_d8_o3_area = sqrt(var_std8_3 * (b8_3 - a8_3)^2);

decisions_data(end+1,:) = {'D8: Autonomy Mode', 'Containment Area (m^2)', ...
    'Teleop', mu_d8_o1_area, sigma_d8_o1_area, ...
    'Supervised', mu_d8_o2_area, sigma_d8_o2_area, ...
    'Coordinated', mu_d8_o3_area, sig_d8_o3_area};

%% -- DECISION 9: RECOVERY METHOD CONTAINMENT -- %%
% Modeled based on "Bingo Fuel" / Battery Reserve constraints.
% Normal distributions are shifted to respect the 26,000 m^2 absolute ceiling.

% -- Option 1: Manual Ground Retrieval
% Minor battery reserve required. 
mu_d9_o1_area = 23000; sigma_d9_o1_area = 1000;
y_d9_o1_area = normpdf(x, mu_d9_o1_area, sigma_d9_o1_area);

% -- Option 2: Expendable (No Recovery)
% 100% battery to the mission. 3-sigma tail hits 26,000.
mu_d9_o2_area = 24800; sigma_d9_o2_area = 400;
y_d9_o2_area = normpdf(x, mu_d9_o2_area, sigma_d9_o2_area);

% -- Option 3: Air-based Recovery
% Minor battery reserve required.
mu_d9_o3_area = 22000; sigma_d9_o3_area = 1500;
y_d9_o3_area = normpdf(x, mu_d9_o3_area, sigma_d9_o3_area);

% -- Plotting D9 
figure(5);
plot(x, y_d9_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Ground Retrieval'); hold on;
plot(x, y_d9_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Expendable');
plot(x, y_d9_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Air-based Recovery');
title('Containment Area PDFs (D9: Recovery Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

decisions_data(end+1,:) = {'D9: Recovery Method', 'Containment Area (m^2)', ...
    'Ground Retrieval', mu_d9_o1_area, sigma_d9_o1_area, ...
    'Expendable', mu_d9_o2_area, sigma_d9_o2_area, ...
    'Air-based Recovery', mu_d9_o3_area, sigma_d9_o3_area};

%% -- DECISION 10: ENCAPSULATION METHOD CONTAINMENT (BETA UPDATE) -- %%
% Modeled to allow all options to hit the 26,000 m^2 absolute ceiling, 
% but with varying probabilities and worst-case bounds.

% -- Option 1: Bare Robot (Wide spread, lower probability of max)
alpha10_1 = 3; beta10_1 = 2; a10_1 = 15000; b10_1 = 26000;
x_norm10_1 = (x - a10_1) / (b10_1 - a10_1); 
x_norm10_1(x_norm10_1 < 0 | x_norm10_1 > 1) = NaN; 
y_d10_o1_area = betapdf(x_norm10_1, alpha10_1, beta10_1) / (b10_1 - a10_1);

% -- Option 2: Individual Pods (Tighter spread, better probability)
alpha10_2 = 5; beta10_2 = 2; a10_2 = 20000; b10_2 = 26000;
x_norm10_2 = (x - a10_2) / (b10_2 - a10_2); 
x_norm10_2(x_norm10_2 < 0 | x_norm10_2 > 1) = NaN; 
y_d10_o2_area = betapdf(x_norm10_2, alpha10_2, beta10_2) / (b10_2 - a10_2);

% -- Option 3: Containerized Module (Highest probability of max)
alpha10_3 = 8; beta10_3 = 2; a10_3 = 24000; b10_3 = 26000;
x_norm10_3 = (x - a10_3) / (b10_3 - a10_3); 
x_norm10_3(x_norm10_3 < 0 | x_norm10_3 > 1) = NaN; 
y_d10_o3_area = betapdf(x_norm10_3, alpha10_3, beta10_3) / (b10_3 - a10_3);

% -- Plotting D10 Containment --
figure(7);
plot(x, y_d10_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Bare Robot (Beta)'); hold on;
plot(x, y_d10_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Individual Pods (Beta)');
plot(x, y_d10_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Containerized Module (Beta)');
title('Containment Area PDFs (D10: Encapsulation Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

mu_std10_1 = alpha10_1 / (alpha10_1 + beta10_1);
var_std10_1 = (alpha10_1 * beta10_1) / ((alpha10_1 + beta10_1)^2 * (alpha10_1 + beta10_1 + 1));
mu_d10_o1_area = a10_1 + (mu_std10_1 * (b10_1 - a10_1));
sig_d10_o1_area = sqrt(var_std10_1 * (b10_1 - a10_1)^2);

mu_std10_2 = alpha10_2 / (alpha10_2 + beta10_2);
var_std10_2 = (alpha10_2 * beta10_2) / ((alpha10_2 + beta10_2)^2 * (alpha10_2 + beta10_2 + 1));
mu_d10_o2_area = a10_2 + (mu_std10_2 * (b10_2 - a10_2));
sig_d10_o2_area = sqrt(var_std10_2 * (b10_2 - a10_2)^2);

mu_std10_3 = alpha10_3 / (alpha10_3 + beta10_3);
var_std10_3 = (alpha10_3 * beta10_3) / ((alpha10_3 + beta10_3)^2 * (alpha10_3 + beta10_3 + 1));
mu_d10_o3_area = a10_3 + (mu_std10_3 * (b10_3 - a10_3));
sig_d10_o3_area = sqrt(var_std10_3 * (b10_3 - a10_3)^2);

decisions_data(end+1,:) = {'D10: Encapsulation', 'Containment Area (m^2)', ...
    'Bare', mu_d10_o1_area, sig_d10_o1_area, ...
    'Indiv Pods', mu_d10_o2_area, sig_d10_o2_area, ...
    'Module', mu_d10_o3_area, sig_d10_o3_area};

%% %%%% -- COST -- %%%% %%

%% -- DECISION 1: LOADING METHOD COST -- %%
x_cost1 = linspace(-5000, 100000, 1000); 
mu_d1_o1_cost = 0; sigma_d1_o1_cost = 100; 
y_d1_o1_cost = normpdf(x_cost1, mu_d1_o1_cost, sigma_d1_o1_cost);

mu_d1_o2_cost = 50000; sigma_d1_o2_cost = 5000; 
y_d1_o2_cost = normpdf(x_cost1, mu_d1_o2_cost, sigma_d1_o2_cost);

mu_d1_o3_cost = 70000; sigma_d1_o3_cost = 7000; 
y_d1_o3_cost = normpdf(x_cost1, mu_d1_o3_cost, sigma_d1_o3_cost);

figure(101);
plot(x_cost1, y_d1_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Self Drive-On'); hold on;
plot(x_cost1, y_d1_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Containerized');
plot(x_cost1, y_d1_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Ground Loader');
title('Cost PDFs (D1: Loading Method)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([-5000 100000]);

decisions_data(end+1,:) = {'D1: Loading Method', 'Cost ($)', ...
    'Self Drive-On', mu_d1_o1_cost, sigma_d1_o1_cost, ...
    'Containerized', mu_d1_o2_cost, sigma_d1_o2_cost, ...
    'Ground Loader', mu_d1_o3_cost, sigma_d1_o3_cost};

%% -- DECISION 2: INSERTION METHOD COST -- %%
x_cost2 = linspace(-50000, 750000, 1000); 

% -- Option 1: Drone (Tri)
a_c2_1 = 180000; c_c2_1 = 200000; b_c2_1 = 220000;
y_d2_o1_cost = zeros(size(x_cost2));
idx_up = (x_cost2 >= a_c2_1 & x_cost2 <= c_c2_1);
y_d2_o1_cost(idx_up) = 2 * (x_cost2(idx_up) - a_c2_1) / ((b_c2_1 - a_c2_1) * (c_c2_1 - a_c2_1));
idx_down = (x_cost2 > c_c2_1 & x_cost2 <= b_c2_1);
y_d2_o1_cost(idx_down) = 2 * (b_c2_1 - x_cost2(idx_down)) / ((b_c2_1 - a_c2_1) * (b_c2_1 - c_c2_1));

% -- Option 2: Parafoil (Tri)
a_c2_2 = 534600; c_c2_2 = 594000; b_c2_2 = 653400;
y_d2_o2_cost = zeros(size(x_cost2));
idx_up = (x_cost2 >= a_c2_2 & x_cost2 <= c_c2_2);
y_d2_o2_cost(idx_up) = 2 * (x_cost2(idx_up) - a_c2_2) / ((b_c2_2 - a_c2_2) * (c_c2_2 - a_c2_2));
idx_down = (x_cost2 > c_c2_2 & x_cost2 <= b_c2_2);
y_d2_o2_cost(idx_down) = 2 * (b_c2_2 - x_cost2(idx_down)) / ((b_c2_2 - a_c2_2) * (b_c2_2 - c_c2_2));

% -- Option 3: Airbag (Norm)
mu_d2_o3_cost = 40000; sigma_d2_o3_cost = 44000;
y_d2_o3_cost = normpdf(x_cost2, mu_d2_o3_cost, sigma_d2_o3_cost);

figure(102);
plot(x_cost2, y_d2_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Guided Drone'); hold on;
plot(x_cost2, y_d2_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Parafoil');
plot(x_cost2, y_d2_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Airbag');
title('Cost PDFs (D2: Insertion Method)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthWest'); grid on; xlim([-50000 750000]);

mu_d2_o1_cost_val = (a_c2_1+b_c2_1+c_c2_1)/3;
sig_d2_o1_cost_val = sqrt((a_c2_1^2+b_c2_1^2+c_c2_1^2 - a_c2_1*b_c2_1 - a_c2_1*c_c2_1 - b_c2_1*c_c2_1)/18);

mu_d2_o2_cost_val = (a_c2_2+b_c2_2+c_c2_2)/3;
sig_d2_o2_cost_val = sqrt((a_c2_2^2+b_c2_2^2+c_c2_2^2 - a_c2_2*b_c2_2 - a_c2_2*c_c2_2 - b_c2_2*c_c2_2)/18);

decisions_data(end+1,:) = {'D2: Insertion Method', 'Cost ($)', ...
    'Guided Drone', mu_d2_o1_cost_val, sig_d2_o1_cost_val, ...
    'Parafoil', mu_d2_o2_cost_val, sig_d2_o2_cost_val, ...
    'Airbag', mu_d2_o3_cost, sigma_d2_o3_cost};

%% -- DECISION 3: LANDING ACTIVATION COST -- %%
x_cost3 = linspace(-2000, 10000, 1000);
mu_d3_o1_cost = 5000; sigma_d3_o1_cost = 500;
y_d3_o1_cost = normpdf(x_cost3, mu_d3_o1_cost, sigma_d3_o1_cost);

mu_d3_o2_cost = 0; sigma_d3_o2_cost = 50; 
y_d3_o2_cost = normpdf(x_cost3, mu_d3_o2_cost, sigma_d3_o2_cost);

mu_d3_o3_cost = 5000; sigma_d3_o3_cost = 1000; 
y_d3_o3_cost = normpdf(x_cost3, mu_d3_o3_cost, sigma_d3_o3_cost);

figure(103);
plot(x_cost3, y_d3_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Auto Activate'); hold on;
plot(x_cost3, y_d3_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Remote Activate');
plot(x_cost3, y_d3_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Dual Key Activate');
title('Cost PDFs (D3: Landing Activation)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([-2000 10000]);

decisions_data(end+1,:) = {'D3: Landing Activation', 'Cost ($)', ...
    'Auto Activate', mu_d3_o1_cost, sigma_d3_o1_cost, ...
    'Remote Activate', mu_d3_o2_cost, sigma_d3_o2_cost, ...
    'Dual Key Activate', mu_d3_o3_cost, sigma_d3_o3_cost};

%% -- DECISION 4: FLEET COMPOSITION COST -- %%
x_cost4 = linspace(1000000, 4500000, 1000);
mu_d4_o1_cost = 3750000; sigma_d4_o1_cost = 150000; 
y_d4_o1_cost = normpdf(x_cost4, mu_d4_o1_cost, sigma_d4_o1_cost);

mu_d4_o2_cost = 3600000; sigma_d4_o2_cost = 180000; 
y_d4_o2_cost = normpdf(x_cost4, mu_d4_o2_cost, sigma_d4_o2_cost);

mu_d4_o3_cost = 1650000; sigma_d4_o3_cost = 100000; 
y_d4_o3_cost = normpdf(x_cost4, mu_d4_o3_cost, sigma_d4_o3_cost);

figure(104);
plot(x_cost4, y_d4_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Homogeneous'); hold on;
plot(x_cost4, y_d4_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Two-Tier');
plot(x_cost4, y_d4_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Three-Role');
title('Cost PDFs (D4: Fleet Composition)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthWest'); grid on; xlim([1000000 4500000]);

decisions_data(end+1,:) = {'D4: Fleet Composition', 'Cost ($)', ...
    'Homogeneous', mu_d4_o1_cost, sigma_d4_o1_cost, ...
    '2-Tier', mu_d4_o2_cost, sigma_d4_o2_cost, ...
    '3-Role', mu_d4_o3_cost, sigma_d4_o3_cost};

%% -- DECISION 5: REPLACEMENT RATIO COST (MULTIPLIER) -- %%
x_mult5 = linspace(0, 8, 1000);
mu_d5_o1_cost = 1.0; sigma_d5_o1_cost = 0.05; 
y_d5_o1_cost = normpdf(x_mult5, mu_d5_o1_cost, sigma_d5_o1_cost);

mu_d5_o2_cost = 3.0; sigma_d5_o2_cost = 0.15; 
y_d5_o2_cost = normpdf(x_mult5, mu_d5_o2_cost, sigma_d5_o2_cost);

mu_d5_o3_cost = 6.0; sigma_d5_o3_cost = 0.3; 
y_d5_o3_cost = normpdf(x_mult5, mu_d5_o3_cost, sigma_d5_o3_cost);

figure(105);
plot(x_mult5, y_d5_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', '1:1 (High Proficiency)'); hold on;
plot(x_mult5, y_d5_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', '3:1 (Mod Proficiency)');
plot(x_mult5, y_d5_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', '6:1 (Low Proficiency)');
title('Cost Multiplier PDFs (D5: Fleet Size)'); xlabel('D4 Multiplier'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([0 8]);

decisions_data(end+1,:) = {'D5: Autonomy Ratio', 'Cost Multiplier', ...
    '1:1', mu_d5_o1_cost, sigma_d5_o1_cost, ...
    '3:1', mu_d5_o2_cost, sigma_d5_o2_cost, ...
    '6:1', mu_d5_o3_cost, sigma_d5_o3_cost};

%% -- DECISION 6: DEPLOYMENT AIRCRAFT COST -- %%
x_cost6 = linspace(20000, 45000, 1000);
mu_d6_o1_cost = 33532; sigma_d6_o1_cost = 2500; 
y_d6_o1_cost = normpdf(x_cost6, mu_d6_o1_cost, sigma_d6_o1_cost);

figure(106);
plot(x_cost6, y_d6_o1_cost, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2, 'DisplayName', 'A400M Baseline');
title('Cost PDFs (D6: Aircraft)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthWest'); grid on; xlim([20000 45000]);

decisions_data(end+1,:) = {'D6: Aircraft', 'Cost ($)', ...
    'A400M', mu_d6_o1_cost, sigma_d6_o1_cost, ...
    'N/A', NaN, NaN, ...
    'N/A', NaN, NaN};

%% -- DECISION 7: COMMUNICATIONS COST -- %%
x_cost7 = linspace(0, 25000, 1000); 

% -- Option 1: SATCOM (Tri)
a_c7_1 = 4630; c_c7_1 = 5145; b_c7_1 = 5659;
y_d7_o1_cost = zeros(size(x_cost7));
idx_up = (x_cost7 >= a_c7_1 & x_cost7 <= c_c7_1);
y_d7_o1_cost(idx_up) = 2 * (x_cost7(idx_up) - a_c7_1) / ((b_c7_1 - a_c7_1) * (c_c7_1 - a_c7_1));
idx_down = (x_cost7 > c_c7_1 & x_cost7 <= b_c7_1);
y_d7_o1_cost(idx_down) = 2 * (b_c7_1 - x_cost7(idx_down)) / ((b_c7_1 - a_c7_1) * (b_c7_1 - c_c7_1));

% -- Option 2: Ground (Tri)
a_c7_2 = 4782; c_c7_2 = 5314; b_c7_2 = 5845;
y_d7_o2_cost = zeros(size(x_cost7));
idx_up = (x_cost7 >= a_c7_2 & x_cost7 <= c_c7_2);
y_d7_o2_cost(idx_up) = 2 * (x_cost7(idx_up) - a_c7_2) / ((b_c7_2 - a_c7_2) * (c_c7_2 - a_c7_2));
idx_down = (x_cost7 > c_c7_2 & x_cost7 <= b_c7_2);
y_d7_o2_cost(idx_down) = 2 * (b_c7_2 - x_cost7(idx_down)) / ((b_c7_2 - a_c7_2) * (b_c7_2 - c_c7_2));

% -- Option 3: Airborne (Tri)
a_c7_3 = 18000; c_c7_3 = 20000; b_c7_3 = 22000;
y_d7_o3_cost = zeros(size(x_cost7));
idx_up = (x_cost7 >= a_c7_3 & x_cost7 <= c_c7_3);
y_d7_o3_cost(idx_up) = 2 * (x_cost7(idx_up) - a_c7_3) / ((b_c7_3 - a_c7_3) * (c_c7_3 - a_c7_3));
idx_down = (x_cost7 > c_c7_3 & x_cost7 <= b_c7_3);
y_d7_o3_cost(idx_down) = 2 * (b_c7_3 - x_cost7(idx_down)) / ((b_c7_3 - a_c7_3) * (b_c7_3 - c_c7_3));

figure(107);
plot(x_cost7, y_d7_o1_cost, 'Color', [0.00, 0.25, 0.45], 'LineWidth', 2, 'DisplayName', 'Per-Robot SATCOM'); hold on;
plot(x_cost7, y_d7_o2_cost, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 2, 'DisplayName', 'Ground Node RF');
plot(x_cost7, y_d7_o3_cost, 'Color', [0.00, 0.60, 0.65], 'LineWidth', 2, 'DisplayName', 'Airborne Relay');
title('Cost PDFs (D7: Communications)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([0 25000]);

mu_d7_o1_cost_val = (a_c7_1+b_c7_1+c_c7_1)/3;
sig_d7_o1_cost_val = sqrt((a_c7_1^2+b_c7_1^2+c_c7_1^2 - a_c7_1*b_c7_1 - a_c7_1*c_c7_1 - b_c7_1*c_c7_1)/18);
mu_d7_o2_cost_val = (a_c7_2+b_c7_2+c_c7_2)/3;
sig_d7_o2_cost_val = sqrt((a_c7_2^2+b_c7_2^2+c_c7_2^2 - a_c7_2*b_c7_2 - a_c7_2*c_c7_2 - b_c7_2*c_c7_2)/18);
mu_d7_o3_cost_val = (a_c7_3+b_c7_3+c_c7_3)/3;
sig_d7_o3_cost_val = sqrt((a_c7_3^2+b_c7_3^2+c_c7_3^2 - a_c7_3*b_c7_3 - a_c7_3*c_c7_3 - b_c7_3*c_c7_3)/18);

decisions_data(end+1,:) = {'D7: Communications', 'Cost ($)', ...
    'SATCOM', mu_d7_o1_cost_val, sig_d7_o1_cost_val, ...
    'Ground Node', mu_d7_o2_cost_val, sig_d7_o2_cost_val, ...
    'Airborne Relay', mu_d7_o3_cost_val, sig_d7_o3_cost_val};

%% -- DECISION 8: AUTONOMY MODE COST -- %%
x_cost8 = linspace(0, 15000, 1000);
mu_d8_o1_cost = 10000; sigma_d8_o1_cost = 1500; 
y_d8_o1_cost = normpdf(x_cost8, mu_d8_o1_cost, sigma_d8_o1_cost);

mu_d8_o2_cost = 4000; sigma_d8_o2_cost = 500; 
y_d8_o2_cost = normpdf(x_cost8, mu_d8_o2_cost, sigma_d8_o2_cost);

mu_d8_o3_cost = 1000; sigma_d8_o3_cost = 100; 
y_d8_o3_cost = normpdf(x_cost8, mu_d8_o3_cost, sigma_d8_o3_cost);

figure(108);
plot(x_cost8, y_d8_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Teleoperation'); hold on;
plot(x_cost8, y_d8_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Supervised');
plot(x_cost8, y_d8_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Coordinated');
title('Cost PDFs (D8: Autonomy)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([0 15000]);

decisions_data(end+1,:) = {'D8: Autonomy Mode', 'Cost ($)', ...
    'Teleoperation', mu_d8_o1_cost, sigma_d8_o1_cost, ...
    'Supervised', mu_d8_o2_cost, sigma_d8_o2_cost, ...
    'Coordinated', mu_d8_o3_cost, sigma_d8_o3_cost};

%% -- DECISION 9: RECOVERY METHOD COST -- %%
% ALIGNED: O1=Expendable, O2=Ground, O3=Air-based
x_cost9_flat = linspace(0, 50000, 1000); 
x_cost9_mult = linspace(0, 2, 1000); 

% -- Option 1: Ground Crew Physical Recovery (Flat)
mu_d9_o1_cost = 1000; sigma_d9_o1_cost = 300;
y_d9_o1_cost = normpdf(x_cost9_flat, mu_d9_o1_cost, sigma_d9_o1_cost);

% -- Option 2: Expendable / Attritable (Multiplier) 
mu_d9_o2_cost = 1.0; sigma_d9_o2_cost = 0.05; 
y_d9_o2_mult = normpdf(x_cost9_mult, mu_d9_o2_cost, sigma_d9_o2_cost);

% -- Option 3: Air-Based Recovery (Flat) 
mu_d9_o3_cost = 35034; sigma_d9_o3_cost = 5225;
y_d9_o3_cost = normpdf(x_cost9_flat, mu_d9_o3_cost, sigma_d9_o3_cost);

figure(109);
plot(x_cost9_flat, y_d9_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Ground Retrieval'); hold on;
plot(x_cost9_flat, y_d9_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Air-based Recovery');
title('Flat Cost PDFs (D9: Recovery Method)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([0 50000]);

figure(110);
plot(x_cost9_mult, y_d9_o2_mult, 'r', 'LineWidth', 2, 'DisplayName', 'Expendable');
title('Cost Multiplier PDF (D9: Recovery Method)'); xlabel('Hardware Multiplier'); ylabel('Density');
legend('Location', 'NorthEast'); grid on; xlim([0.0 2.0]);

decisions_data(end+1,:) = {'D9: Recovery Method', 'Cost ($)', ...
    'Ground Retrieval', mu_d9_o1_cost, sigma_d9_o1_cost, ...
    'Expendable', mu_d9_o2_cost, sigma_d9_o2_cost, ...
    'Air-based Recovery', mu_d9_o3_cost, sigma_d9_o3_cost};

%% -- DECISION 10: ENCAPSULATION METHOD COST -- %%
x_cost10 = linspace(0, 30000, 1000);
mu_d10_o1_cost = 2000; sigma_d10_o1_cost = 750; 
y_d10_o1_cost = normpdf(x_cost10, mu_d10_o1_cost, sigma_d10_o1_cost);

mu_d10_o2_cost = 15000; sigma_d10_o2_cost = 1200; 
y_d10_o2_cost = normpdf(x_cost10, mu_d10_o2_cost, sigma_d10_o2_cost);

mu_d10_o3_cost = 24000; sigma_d10_o3_cost = 1500; 
y_d10_o3_cost = normpdf(x_cost10, mu_d10_o3_cost, sigma_d10_o3_cost);

figure(111);
plot(x_cost10, y_d10_o1_cost, 'b', 'LineWidth', 2, 'DisplayName', 'Bare Robot'); hold on;
plot(x_cost10, y_d10_o2_cost, 'r', 'LineWidth', 2, 'DisplayName', 'Individual Pods');
plot(x_cost10, y_d10_o3_cost, 'g', 'LineWidth', 2, 'DisplayName', 'Containerized Module');
title('Cost PDFs (D10: Encapsulation)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);

decisions_data(end+1,:) = {'D10: Encapsulation', 'Cost ($)', ...
    'Bare Robot', mu_d10_o1_cost, sigma_d10_o1_cost, ...
    'Individual Pods', mu_d10_o2_cost, sigma_d10_o2_cost, ...
    'Containerized Module', mu_d10_o3_cost, sigma_d10_o3_cost};

% Finish formatting all figures
figHandles = findobj('Type', 'figure');
for i = 1:length(figHandles)
    ax = get(figHandles(i), 'CurrentAxes');
    if ~isempty(ax)
        ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
        xtickformat(ax, '%,.0f');
    end
end

% EM.413 OS14 
% Allows manipulation and visualization of Containment (Performance) PDFs for OS14 Q1 and Q2
close all; clear all; clc;

% Initialize cell arrays for Excel export (Tab 1)
decisions_data = {'Decision', 'Metric', 'Opt1_Name', 'Opt1_Mean', 'Opt1_Std', 'Opt2_Name', 'Opt2_Mean', 'Opt2_Std', 'Opt3_Name', 'Opt3_Mean', 'Opt3_Std'};

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);
CAslope = 880;

%% %%%% -- CONTAINMENT AREA DEFINITIONS -- %%%% %%

% D1: LOADING
sigma_d1_o1_area = CAslope * 2; mu_d1_o1_area = 26000 - (3 * sigma_d1_o1_area) - (CAslope * 1);
sigma_d1_o2_area = CAslope * 1; mu_d1_o2_area = 26000 - (3 * sigma_d1_o2_area) - (CAslope * 0);
sigma_d1_o3_area = CAslope * 3; mu_d1_o3_area = 26000 - (3 * sigma_d1_o3_area) - (CAslope * 2);
decisions_data(end+1,:) = {'D1: Loading Method', 'Containment Area (m^2)', 'Self Drive-On', mu_d1_o1_area, sigma_d1_o1_area, 'Containerized', mu_d1_o2_area, sigma_d1_o2_area, 'Ground Loader', mu_d1_o3_area, sigma_d1_o3_area};

% D2: INSERTION
alpha1 = 8; beta1 = 2; a1 = 24000; b1 = 26000;
alpha2 = 5; beta2 = 2; a2 = 22000; b2 = 26000;
mu3 = 14000; sigma3 = 4000;
mu_std1 = alpha1 / (alpha1 + beta1); var_std1 = (alpha1 * beta1) / ((alpha1 + beta1)^2 * (alpha1 + beta1 + 1));
mu_d2_o1_area = a1 + (mu_std1 * (b1 - a1)); sig_d2_o1_area = sqrt(var_std1 * (b1 - a1)^2);
mu_std2 = alpha2 / (alpha2 + beta2); var_std2 = (alpha2 * beta2) / ((alpha2 + beta2)^2 * (alpha2 + beta2 + 1));
mu_d2_o2_area = a2 + (mu_std2 * (b2 - a2)); sig_d2_o2_area = sqrt(var_std2 * (b2 - a2)^2);
decisions_data(end+1,:) = {'D2: Insertion Method', 'Containment Area (m^2)', 'Guided Drone', mu_d2_o1_area, sig_d2_o1_area, 'Parafoil', mu_d2_o2_area, sig_d2_o2_area, 'Airbag', mu3, sigma3};

% D3: ACTIVATION
a3 = 0; b3 = 26000;
alpha_d3_o1 = 50; beta_d3_o1 = 3; 
alpha_d3_o2 = 40; beta_d3_o2 = 7; 
alpha_d3_o3 = 80; beta_d3_o3 = 10;
mu_d3_o1_area = a3 + (alpha_d3_o1 / (alpha_d3_o1 + beta_d3_o1)) * (b3 - a3);
mu_d3_o2_area = a3 + (alpha_d3_o2 / (alpha_d3_o2 + beta_d3_o2)) * (b3 - a3);
mu_d3_o3_area = a3 + (alpha_d3_o3 / (alpha_d3_o3 + beta_d3_o3)) * (b3 - a3);
var_d3_o1 = (alpha_d3_o1*beta_d3_o1)/((alpha_d3_o1+beta_d3_o1)^2*(alpha_d3_o1+beta_d3_o1+1)) * (b3-a3)^2;
var_d3_o2 = (alpha_d3_o2*beta_d3_o2)/((alpha_d3_o2+beta_d3_o2)^2*(alpha_d3_o2+beta_d3_o2+1)) * (b3-a3)^2;
var_d3_o3 = (alpha_d3_o3*beta_d3_o3)/((alpha_d3_o3+beta_d3_o3)^2*(alpha_d3_o3+beta_d3_o3+1)) * (b3-a3)^2;
sigma_d3_o1_area = sqrt(var_d3_o1); sigma_d3_o2_area = sqrt(var_d3_o2); sigma_d3_o3_area = sqrt(var_d3_o3);
decisions_data(end+1,:) = {'D3: Landing Activation', 'Containment Area (m^2)', 'Auto Activate', mu_d3_o1_area, sigma_d3_o1_area, 'Remote Activate', mu_d3_o2_area, sigma_d3_o2_area, 'Dual Key', mu_d3_o3_area, sigma_d3_o3_area};

% D4: FLEET
mu_d4_o1_area = 25100; sigma_d4_o1_area = 300;
mu_d4_o2_area = 24500; sigma_d4_o2_area = 500;
mu_d4_o3_area = 23000; sigma_d4_o3_area = 1000;
decisions_data(end+1,:) = {'D4: Fleet Composition', 'Containment Area (m^2)', 'Homogeneous', mu_d4_o1_area, sigma_d4_o1_area, '2-Tier', mu_d4_o2_area, sigma_d4_o2_area, '3-Role', mu_d4_o3_area, sigma_d4_o3_area};

% D5: RATIO
mu_d5_o1_area = 25000; sigma_d5_o1_area = 350;
mu_d5_o2_area = 23000; sigma_d5_o2_area = 1000;
mu_d5_o3_area = 20000; sigma_d5_o3_area = 2000;
decisions_data(end+1,:) = {'D5: Autonomy Ratio', 'Containment Area (m^2)', '1:1', mu_d5_o1_area, sigma_d5_o1_area, '3:1', mu_d5_o2_area, sigma_d5_o2_area, '6:1', mu_d5_o3_area, sigma_d5_o3_area};

% D6: AIRCRAFT
mu_d6_o1_area = 25500; sigma_d6_o1_area = 150;
decisions_data(end+1,:) = {'D6: Aircraft', 'Containment Area (m^2)', 'A400M', mu_d6_o1_area, sigma_d6_o1_area, 'N/A', NaN, NaN, 'N/A', NaN, NaN};

% D7: COMMS
alpha4 = 8; beta4 = 2; a4 = 22000; b4 = 26000;
a_tri = 12000; c_tri = 24000; b_tri = 26000;
alpha6 = 5; beta6 = 2; a6 = 18000; b6 = 26000;
mu_std4 = alpha4 / (alpha4 + beta4); var_std4 = (alpha4 * beta4) / ((alpha4 + beta4)^2 * (alpha4 + beta4 + 1));
mu_d7_o1_area = a4 + (mu_std4 * (b4 - a4)); sig_d7_o1_area = sqrt(var_std4 * (b4 - a4)^2);
mu_d7_o2_area = (a_tri+b_tri+c_tri)/3; sig_d7_o2_area = sqrt((a_tri^2+b_tri^2+c_tri^2 - a_tri*b_tri - a_tri*c_tri - b_tri*c_tri)/18);
mu_std6 = alpha6 / (alpha6 + beta6); var_std6 = (alpha6 * beta6) / ((alpha6 + beta6)^2 * (alpha6 + beta6 + 1));
mu_d7_o3_area = a6 + (mu_std6 * (b6 - a6)); sig_d7_o3_area = sqrt(var_std6 * (b6 - a6)^2);
decisions_data(end+1,:) = {'D7: Communications', 'Containment Area (m^2)', 'SATCOM', mu_d7_o1_area, sig_d7_o1_area, 'Ground Node', mu_d7_o2_area, sig_d7_o2_area, 'Airborne Relay', mu_d7_o3_area, sig_d7_o3_area};

% D8: AUTONOMY
mu_d8_o1_area = 16000; sigma_d8_o1_area = 3000;
mu_d8_o2_area = 21000; sigma_d8_o2_area = 1500;
alpha8_3 = 6; beta8_3 = 2; a8_3 = 12000; b8_3 = 26000;
mu_std8_3 = alpha8_3 / (alpha8_3 + beta8_3); var_std8_3 = (alpha8_3 * beta8_3) / ((alpha8_3 + beta8_3)^2 * (alpha8_3 + beta8_3 + 1));
mu_d8_o3_area = a8_3 + (mu_std8_3 * (b8_3 - a8_3)); sig_d8_o3_area = sqrt(var_std8_3 * (b8_3 - a8_3)^2);
decisions_data(end+1,:) = {'D8: Autonomy Mode', 'Containment Area (m^2)', 'Teleop', mu_d8_o1_area, sigma_d8_o1_area, 'Supervised', mu_d8_o2_area, sigma_d8_o2_area, 'Coordinated', mu_d8_o3_area, sig_d8_o3_area};

% D9: RECOVERY
mu_d9_o1_area = 23000; sigma_d9_o1_area = 1000;
mu_d9_o2_area = 24800; sigma_d9_o2_area = 400;
mu_d9_o3_area = 22000; sigma_d9_o3_area = 1500;
decisions_data(end+1,:) = {'D9: Recovery Method', 'Containment Area (m^2)', 'Ground Retrieval', mu_d9_o1_area, sigma_d9_o1_area, 'Expendable', mu_d9_o2_area, sigma_d9_o2_area, 'Air-based Recovery', mu_d9_o3_area, sigma_d9_o3_area};

% D10: ENCAPSULATION
alpha10_1 = 3; beta10_1 = 2; a10_1 = 15000; b10_1 = 26000;
alpha10_2 = 5; beta10_2 = 2; a10_2 = 20000; b10_2 = 26000;
alpha10_3 = 8; beta10_3 = 2; a10_3 = 24000; b10_3 = 26000;
mu_std10_1 = alpha10_1 / (alpha10_1 + beta10_1); var_std10_1 = (alpha10_1 * beta10_1) / ((alpha10_1 + beta10_1)^2 * (alpha10_1 + beta10_1 + 1));
mu_d10_o1_area = a10_1 + (mu_std10_1 * (b10_1 - a10_1)); sig_d10_o1_area = sqrt(var_std10_1 * (b10_1 - a10_1)^2);
mu_std10_2 = alpha10_2 / (alpha10_2 + beta10_2); var_std10_2 = (alpha10_2 * beta10_2) / ((alpha10_2 + beta10_2)^2 * (alpha10_2 + beta10_2 + 1));
mu_d10_o2_area = a10_2 + (mu_std10_2 * (b10_2 - a10_2)); sig_d10_o2_area = sqrt(var_std10_2 * (b10_2 - a10_2)^2);
mu_std10_3 = alpha10_3 / (alpha10_3 + beta10_3); var_std10_3 = (alpha10_3 * beta10_3) / ((alpha10_3 + beta10_3)^2 * (alpha10_3 + beta10_3 + 1));
mu_d10_o3_area = a10_3 + (mu_std10_3 * (b10_3 - a10_3)); sig_d10_o3_area = sqrt(var_std10_3 * (b10_3 - a10_3)^2);
decisions_data(end+1,:) = {'D10: Encapsulation', 'Containment Area (m^2)', 'Bare', mu_d10_o1_area, sig_d10_o1_area, 'Indiv Pods', mu_d10_o2_area, sig_d10_o2_area, 'Module', mu_d10_o3_area, sig_d10_o3_area};

%% %%%% -- COST DEFINITIONS -- %%%% %%

% D1 COST
mu_d1_o1_cost = 0; sigma_d1_o1_cost = 100; 
mu_d1_o2_cost = 50000; sigma_d1_o2_cost = 5000; 
mu_d1_o3_cost = 70000; sigma_d1_o3_cost = 7000; 
decisions_data(end+1,:) = {'D1: Loading Method', 'Cost ($)', 'Self Drive-On', mu_d1_o1_cost, sigma_d1_o1_cost, 'Containerized', mu_d1_o2_cost, sigma_d1_o2_cost, 'Ground Loader', mu_d1_o3_cost, sigma_d1_o3_cost};

% D2 COST
a_c2_1 = 180000; c_c2_1 = 200000; b_c2_1 = 220000;
a_c2_2 = 534600; c_c2_2 = 594000; b_c2_2 = 653400;
mu_d2_o3_cost = 40000; sigma_d2_o3_cost = 44000;
mu_d2_o1_cost_val = (a_c2_1+b_c2_1+c_c2_1)/3; sig_d2_o1_cost_val = sqrt((a_c2_1^2+b_c2_1^2+c_c2_1^2 - a_c2_1*b_c2_1 - a_c2_1*c_c2_1 - b_c2_1*c_c2_1)/18);
mu_d2_o2_cost_val = (a_c2_2+b_c2_2+c_c2_2)/3; sig_d2_o2_cost_val = sqrt((a_c2_2^2+b_c2_2^2+c_c2_2^2 - a_c2_2*b_c2_2 - a_c2_2*c_c2_2 - b_c2_2*c_c2_2)/18);
decisions_data(end+1,:) = {'D2: Insertion Method', 'Cost ($)', 'Guided Drone', mu_d2_o1_cost_val, sig_d2_o1_cost_val, 'Parafoil', mu_d2_o2_cost_val, sig_d2_o2_cost_val, 'Airbag', mu_d2_o3_cost, sigma_d2_o3_cost};

% D3 COST
mu_d3_o1_cost = 5000; sigma_d3_o1_cost = 500;
mu_d3_o2_cost = 0; sigma_d3_o2_cost = 50; 
mu_d3_o3_cost = 5000; sigma_d3_o3_cost = 1000; 
decisions_data(end+1,:) = {'D3: Landing Activation', 'Cost ($)', 'Auto Activate', mu_d3_o1_cost, sigma_d3_o1_cost, 'Remote Activate', mu_d3_o2_cost, sigma_d3_o2_cost, 'Dual Key Activate', mu_d3_o3_cost, sigma_d3_o3_cost};

% D4 COST
mu_d4_o1_cost = 3750000; sigma_d4_o1_cost = 150000; 
mu_d4_o2_cost = 3600000; sigma_d4_o2_cost = 180000; 
mu_d4_o3_cost = 1650000; sigma_d4_o3_cost = 100000; 
decisions_data(end+1,:) = {'D4: Fleet Composition', 'Cost ($)', 'Homogeneous', mu_d4_o1_cost, sigma_d4_o1_cost, '2-Tier', mu_d4_o2_cost, sigma_d4_o2_cost, '3-Role', mu_d4_o3_cost, sigma_d4_o3_cost};

% D5 MULTIPLIER COST
mu_d5_o1_cost = 1.0; sigma_d5_o1_cost = 0.05; 
mu_d5_o2_cost = 3.0; sigma_d5_o2_cost = 0.15; 
mu_d5_o3_cost = 6.0; sigma_d5_o3_cost = 0.3; 
decisions_data(end+1,:) = {'D5: Autonomy Ratio', 'Cost Multiplier', '1:1', mu_d5_o1_cost, sigma_d5_o1_cost, '3:1', mu_d5_o2_cost, sigma_d5_o2_cost, '6:1', mu_d5_o3_cost, sigma_d5_o3_cost};

% D6 COST
mu_d6_o1_cost = 33532; sigma_d6_o1_cost = 2500; 
decisions_data(end+1,:) = {'D6: Aircraft', 'Cost ($)', 'A400M', mu_d6_o1_cost, sigma_d6_o1_cost, 'N/A', NaN, NaN, 'N/A', NaN, NaN};

% D7 COST
a_c7_1 = 4630; c_c7_1 = 5145; b_c7_1 = 5659;
a_c7_2 = 4782; c_c7_2 = 5314; b_c7_2 = 5845;
a_c7_3 = 18000; c_c7_3 = 20000; b_c7_3 = 22000;
mu_d7_o1_cost_val = (a_c7_1+b_c7_1+c_c7_1)/3; sig_d7_o1_cost_val = sqrt((a_c7_1^2+b_c7_1^2+c_c7_1^2 - a_c7_1*b_c7_1 - a_c7_1*c_c7_1 - b_c7_1*c_c7_1)/18);
mu_d7_o2_cost_val = (a_c7_2+b_c7_2+c_c7_2)/3; sig_d7_o2_cost_val = sqrt((a_c7_2^2+b_c7_2^2+c_c7_2^2 - a_c7_2*b_c7_2 - a_c7_2*c_c7_2 - b_c7_2*c_c7_2)/18);
mu_d7_o3_cost_val = (a_c7_3+b_c7_3+c_c7_3)/3; sig_d7_o3_cost_val = sqrt((a_c7_3^2+b_c7_3^2+c_c7_3^2 - a_c7_3*b_c7_3 - a_c7_3*c_c7_3 - b_c7_3*c_c7_3)/18);
decisions_data(end+1,:) = {'D7: Communications', 'Cost ($)', 'SATCOM', mu_d7_o1_cost_val, sig_d7_o1_cost_val, 'Ground Node', mu_d7_o2_cost_val, sig_d7_o2_cost_val, 'Airborne Relay', mu_d7_o3_cost_val, sig_d7_o3_cost_val};

% D8 COST
mu_d8_o1_cost = 10000; sigma_d8_o1_cost = 1500; 
mu_d8_o2_cost = 4000; sigma_d8_o2_cost = 500; 
mu_d8_o3_cost = 1000; sigma_d8_o3_cost = 100; 
decisions_data(end+1,:) = {'D8: Autonomy Mode', 'Cost ($)', 'Teleoperation', mu_d8_o1_cost, sigma_d8_o1_cost, 'Supervised', mu_d8_o2_cost, sigma_d8_o2_cost, 'Coordinated', mu_d8_o3_cost, sigma_d8_o3_cost};

% D9 COST
mu_d9_o1_cost = 1000; sigma_d9_o1_cost = 300;
mu_d9_o2_cost = 1.0; sigma_d9_o2_cost = 0.05; 
mu_d9_o3_cost = 35034; sigma_d9_o3_cost = 5225;
decisions_data(end+1,:) = {'D9: Recovery Method', 'Cost ($)', 'Ground Retrieval', mu_d9_o1_cost, sigma_d9_o1_cost, 'Expendable', mu_d9_o2_cost, sigma_d9_o2_cost, 'Air-based Recovery', mu_d9_o3_cost, sigma_d9_o3_cost};

% D10 COST
mu_d10_o1_cost = 2000; sigma_d10_o1_cost = 750; 
mu_d10_o2_cost = 15000; sigma_d10_o2_cost = 1200; 
mu_d10_o3_cost = 24000; sigma_d10_o3_cost = 1500; 
decisions_data(end+1,:) = {'D10: Encapsulation', 'Cost ($)', 'Bare Robot', mu_d10_o1_cost, sigma_d10_o1_cost, 'Individual Pods', mu_d10_o2_cost, sigma_d10_o2_cost, 'Containerized Module', mu_d10_o3_cost, sigma_d10_o3_cost};

%% ==================================================================
%% Q2 FULL FACTORIAL TRADESPACE EXPLORATION (Parfor Nest)
original_rng_state = rng; 
rng(1); % Lock the seed to 1
nTrials = 10000; % Draw 10,000 times per concept

fprintf('\n=== Generating Full Factorial Tradespace ===\n');
fprintf('Building pre-draw probability matrices...\n');

pos = @(x) max(0, x); 

% --- 1. BUILD THE FIBONACCI MATRIX ---
fib_mat = zeros(10, 3);
fib_mat(1,:) = [2, 3, 1];
fib_mat(2,:) = [5, 5, 1];
fib_mat(3,:) = [3, 1, 2];
fib_mat(4,:) = [5, 3, 2];
fib_mat(5,:) = [8, 8, 8];
fib_mat(6,:) = [5, 0, 0]; % A400M fixed
fib_mat(7,:) = [5, 2, 3];
fib_mat(8,:) = [2, 5, 8];
fib_mat(9,:) = [3, 2, 1]; % Ground, Expendable, Air
fib_mat(10,:) = [1, 2, 5];

max_fib_sum = sum(max(fib_mat, [], 2)); 

% --- 2. PRE-DRAW ALL DISTRIBUTIONS (VECTORIZED FOR SPEED) ---
Area_Draws = zeros(10, 3, nTrials);
Cost_Draws = zeros(10, 3, nTrials); 
Mult_Draws = zeros(10, 3, nTrials); 

% Decision 1
Area_Draws(1,1,:) = normrnd(mu_d1_o1_area, sigma_d1_o1_area, [1,1,nTrials]);
Area_Draws(1,2,:) = normrnd(mu_d1_o2_area, sigma_d1_o2_area, [1,1,nTrials]);
Area_Draws(1,3,:) = normrnd(mu_d1_o3_area, sigma_d1_o3_area, [1,1,nTrials]);
Cost_Draws(1,1,:) = pos(normrnd(mu_d1_o1_cost, sigma_d1_o1_cost, [1,1,nTrials]));
Cost_Draws(1,2,:) = pos(normrnd(mu_d1_o2_cost, sigma_d1_o2_cost, [1,1,nTrials]));
Cost_Draws(1,3,:) = pos(normrnd(mu_d1_o3_cost, sigma_d1_o3_cost, [1,1,nTrials]));

% Decision 2
Area_Draws(2,1,:) = betarnd(alpha1, beta1, [1,1,nTrials])*(b1-a1)+a1;
Area_Draws(2,2,:) = betarnd(alpha2, beta2, [1,1,nTrials])*(b2-a2)+a2;
Area_Draws(2,3,:) = normrnd(mu3, sigma3, [1,1,nTrials]);
Cost_Draws(2,1,:) = pos(tri_draw(a_c2_1, c_c2_1, b_c2_1, nTrials));
Cost_Draws(2,2,:) = pos(tri_draw(a_c2_2, c_c2_2, b_c2_2, nTrials));
Cost_Draws(2,3,:) = pos(normrnd(mu_d2_o3_cost, sigma_d2_o3_cost, [1,1,nTrials]));

% Decision 3
Area_Draws(3,1,:) = betarnd(alpha_d3_o1, beta_d3_o1, [1,1,nTrials])*(b3-a3)+a3;
Area_Draws(3,2,:) = betarnd(alpha_d3_o2, beta_d3_o2, [1,1,nTrials])*(b3-a3)+a3;
Area_Draws(3,3,:) = betarnd(alpha_d3_o3, beta_d3_o3, [1,1,nTrials])*(b3-a3)+a3;
Cost_Draws(3,1,:) = pos(normrnd(mu_d3_o1_cost, sigma_d3_o1_cost, [1,1,nTrials]));
Cost_Draws(3,2,:) = pos(normrnd(mu_d3_o2_cost, sigma_d3_o2_cost, [1,1,nTrials]));
Cost_Draws(3,3,:) = pos(normrnd(mu_d3_o3_cost, sigma_d3_o3_cost, [1,1,nTrials]));

% Decision 4
Area_Draws(4,1,:) = normrnd(mu_d4_o1_area, sigma_d4_o1_area, [1,1,nTrials]);
Area_Draws(4,2,:) = normrnd(mu_d4_o2_area, sigma_d4_o2_area, [1,1,nTrials]);
Area_Draws(4,3,:) = normrnd(mu_d4_o3_area, sigma_d4_o3_area, [1,1,nTrials]);
Cost_Draws(4,1,:) = pos(normrnd(mu_d4_o1_cost, sigma_d4_o1_cost, [1,1,nTrials]));
Cost_Draws(4,2,:) = pos(normrnd(mu_d4_o2_cost, sigma_d4_o2_cost, [1,1,nTrials]));
Cost_Draws(4,3,:) = pos(normrnd(mu_d4_o3_cost, sigma_d4_o3_cost, [1,1,nTrials]));

% Decision 5 
Area_Draws(5,1,:) = normrnd(mu_d5_o1_area, sigma_d5_o1_area, [1,1,nTrials]);
Area_Draws(5,2,:) = normrnd(mu_d5_o2_area, sigma_d5_o2_area, [1,1,nTrials]);
Area_Draws(5,3,:) = normrnd(mu_d5_o3_area, sigma_d5_o3_area, [1,1,nTrials]);
Mult_Draws(5,1,:) = pos(normrnd(mu_d5_o1_cost, sigma_d5_o1_cost, [1,1,nTrials]));
Mult_Draws(5,2,:) = pos(normrnd(mu_d5_o2_cost, sigma_d5_o2_cost, [1,1,nTrials]));
Mult_Draws(5,3,:) = pos(normrnd(mu_d5_o3_cost, sigma_d5_o3_cost, [1,1,nTrials]));

% Decision 6
Area_Draws(6,1,:) = normrnd(mu_d6_o1_area, sigma_d6_o1_area, [1,1,nTrials]);
Cost_Draws(6,1,:) = pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost, [1,1,nTrials]));

% Decision 7
Area_Draws(7,1,:) = betarnd(alpha4, beta4, [1,1,nTrials])*(b4-a4)+a4;
Area_Draws(7,2,:) = tri_draw(a_tri, c_tri, b_tri, nTrials);
Area_Draws(7,3,:) = betarnd(alpha6, beta6, [1,1,nTrials])*(b6-a6)+a6;
Cost_Draws(7,1,:) = pos(tri_draw(a_c7_1, c_c7_1, b_c7_1, nTrials));
Cost_Draws(7,2,:) = pos(tri_draw(a_c7_2, c_c7_2, b_c7_2, nTrials));
Cost_Draws(7,3,:) = pos(tri_draw(a_c7_3, c_c7_3, b_c7_3, nTrials));

% Decision 8
Area_Draws(8,1,:) = normrnd(mu_d8_o1_area, sigma_d8_o1_area, [1,1,nTrials]);
Area_Draws(8,2,:) = normrnd(mu_d8_o2_area, sigma_d8_o2_area, [1,1,nTrials]);
Area_Draws(8,3,:) = betarnd(alpha8_3, beta8_3, [1,1,nTrials])*(b8_3-a8_3)+a8_3;
Cost_Draws(8,1,:) = pos(normrnd(mu_d8_o1_cost, sigma_d8_o1_cost, [1,1,nTrials]));
Cost_Draws(8,2,:) = pos(normrnd(mu_d8_o2_cost, sigma_d8_o2_cost, [1,1,nTrials]));
Cost_Draws(8,3,:) = pos(normrnd(mu_d8_o3_cost, sigma_d8_o3_cost, [1,1,nTrials]));

% Decision 9
Area_Draws(9,1,:) = normrnd(mu_d9_o1_area, sigma_d9_o1_area, [1,1,nTrials]);
Area_Draws(9,2,:) = normrnd(mu_d9_o2_area, sigma_d9_o2_area, [1,1,nTrials]);
Area_Draws(9,3,:) = normrnd(mu_d9_o3_area, sigma_d9_o3_area, [1,1,nTrials]);
Cost_Draws(9,1,:) = pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost, [1,1,nTrials]));
Cost_Draws(9,2,:) = 0; % Expendable multiplier only
Cost_Draws(9,3,:) = pos(normrnd(mu_d9_o3_cost, sigma_d9_o3_cost, [1,1,nTrials]));
Mult_Draws(9,1,:) = 0;
Mult_Draws(9,2,:) = pos(normrnd(mu_d9_o2_cost, sigma_d9_o2_cost, [1,1,nTrials]));
Mult_Draws(9,3,:) = 0;

% Decision 10
Area_Draws(10,1,:) = betarnd(alpha10_1, beta10_1, [1,1,nTrials])*(b10_1-a10_1)+a10_1;
Area_Draws(10,2,:) = betarnd(alpha10_2, beta10_2, [1,1,nTrials])*(b10_2-a10_2)+a10_2;
Area_Draws(10,3,:) = betarnd(alpha10_3, beta10_3, [1,1,nTrials])*(b10_3-a10_3)+a10_3;
Cost_Draws(10,1,:) = pos(normrnd(mu_d10_o1_cost, sigma_d10_o1_cost, [1,1,nTrials]));
Cost_Draws(10,2,:) = pos(normrnd(mu_d10_o2_cost, sigma_d10_o2_cost, [1,1,nTrials]));
Cost_Draws(10,3,:) = pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost, [1,1,nTrials]));

% --- Pre-multiply the Fibonacci Weights into the Area Matrix ---
for d = 1:10
    for o = 1:3
        Area_Draws(d,o,:) = Area_Draws(d,o,:) * (fib_mat(d,o) / max_fib_sum);
    end
end

% --- 3. GENERATE THE COMBO MATRIX ---
fprintf('Generating 19,683 concept combinations...\n');
[o1, o2, o3, o4, o5, o6, o7, o8, o9, o10] = ndgrid(1:3, 1:3, 1:3, 1:3, 1:3, 1, 1:3, 1:3, 1:3, 1:3);
combos = [o1(:), o2(:), o3(:), o4(:), o5(:), o6(:), o7(:), o8(:), o9(:), o10(:)];
num_combos = size(combos, 1);

mean_area_all = zeros(num_combos, 1);
std_area_all = zeros(num_combos, 1);
mean_cost_all = zeros(num_combos, 1);
std_cost_all = zeros(num_combos, 1);

fprintf('Executing Parfor Loop across %d concepts (%d total missions)...\n', num_combos, num_combos * nTrials);

% --- 4. THE PARFOR NEST ---
parfor i = 1:num_combos
    c = combos(i, :); 
    
    area_runs = zeros(1, nTrials);
    ops_runs = zeros(1, nTrials);
    
    for d = 1:10
        area_runs = area_runs + squeeze(Area_Draws(d, c(d), :))';
        if d ~= 4 && d ~= 5 
            ops_runs = ops_runs + squeeze(Cost_Draws(d, c(d), :))';
        end
    end
    
    hw_runs = squeeze(Cost_Draws(4, c(4), :))' .* squeeze(Mult_Draws(5, c(5), :))';
    attr_runs = hw_runs .* squeeze(Mult_Draws(9, c(9), :))';
    
    cost_runs = hw_runs + attr_runs + ops_runs;
    
    mean_area_all(i) = mean(area_runs);
    std_area_all(i) = std(area_runs);
    mean_cost_all(i) = mean(cost_runs);
    std_cost_all(i) = std(cost_runs);
end

fprintf('Simulation Complete. Generating Plots and Excel Output...\n');

%% --- 5. PARETO FRONT ALGORITHM & INDEX TRACKING ---
all_costs_full = mean_cost_all / 1e6; 
all_areas_full = mean_area_all;       
[sorted_costs_f, sort_idx_f] = sort(all_costs_full);
sorted_areas_f = all_areas_full(sort_idx_f);

pareto_indices = [];
pareto_x_f = []; 
pareto_y_f = [];
max_area_so_far = -Inf;

for i = 1:length(sorted_costs_f)
    if sorted_areas_f(i) > max_area_so_far
        pareto_indices(end+1) = sort_idx_f(i);
        pareto_x_f(end+1) = sorted_costs_f(i);
        pareto_y_f(end+1) = sorted_areas_f(i);
        max_area_so_far = sorted_areas_f(i);
    end
end

%% --- 6. PLOTTING THE TRADESPACE ---

% FIGURE 40: Full Tradespace (No Variance)
figure(40); clf;
scatter(all_costs_full, all_areas_full, 5, 'b', 'filled', 'MarkerFaceAlpha', 0.2, 'DisplayName', 'Concepts');
hold on;
plot(pareto_x_f, pareto_y_f, '-o', 'Color', [1 0.65 0], 'LineWidth', 2.5, 'MarkerSize', 6, 'MarkerFaceColor', [1 0.65 0], 'DisplayName', 'Pareto Front');
plot(0, 26000, 'p', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1 0.84 0], 'DisplayName', 'Utopia Point');
title('Full Factorial Tradespace: 19,683 Concepts');
xlabel('System Cost ($ millions)'); ylabel('Mean Wildfire Containment Area (m²)');
grid on; legend('Location','southeast');
set(gca, 'FontSize', 12); ax = gca; ax.YAxis.Exponent = 0; ytickformat('%,.0f');

% FIGURE 41: Sampled Tradespace (With 2 Pareto designs explicitly included)
figure(41); clf;
num_pareto_samples = min(2, length(pareto_indices));
num_random_samples = 10 - num_pareto_samples;

shuffled_pareto = pareto_indices(randperm(length(pareto_indices)));
pareto_samples = shuffled_pareto(1:num_pareto_samples);

non_pareto_indices = setdiff(1:num_combos, pareto_indices);
shuffled_non_pareto = non_pareto_indices(randperm(length(non_pareto_indices)));
random_samples = shuffled_non_pareto(1:num_random_samples);

sample_idx = [pareto_samples, random_samples];

errorbar(mean_cost_all(sample_idx)/1e6, mean_area_all(sample_idx), ...
         2*std_area_all(sample_idx), 2*std_area_all(sample_idx), ...   
         2*std_cost_all(sample_idx)/1e6, 2*std_cost_all(sample_idx)/1e6, ... 
         'o', 'LineStyle','none', 'Color','k', 'LineWidth',2.0, ...
         'MarkerSize',8, 'MarkerFaceColor',[0 0.45 0.74], 'DisplayName', '10 Sampled Concepts (\pm2\sigma)');
hold on;

% Label the 10 sampled concepts
for i = 1:length(sample_idx)
    idx = sample_idx(i);
    label_str = sprintf(' Concept %d', idx);
    text(mean_cost_all(idx)/1e6 + 0.1, mean_area_all(idx) + 150, label_str, 'FontSize', 9, 'FontWeight', 'bold', 'Color', 'k');
end

plot(pareto_x_f, pareto_y_f, '-o', 'Color', [1 0.65 0], 'LineWidth', 2.5, 'MarkerSize', 6, 'MarkerFaceColor', [1 0.65 0], 'DisplayName', 'Global Pareto Front');
plot(0, 26000, 'p', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1 0.84 0], 'DisplayName', 'Utopia Point');
title('Tradespace Sample: 10 Concepts with Monte Carlo Uncertainty');
xlabel('System Cost ($ millions)'); ylabel('Wildfire Containment Area (m²)');
grid on; legend('Location','southeast');
set(gca, 'FontSize', 12); ax = gca; ax.YAxis.Exponent = 0; ytickformat('%,.0f');

% FIGURE 42: Pareto Front Only (Labeled with Concept ID)
figure(42); clf;
scatter(all_costs_full, all_areas_full, 5, 'b', 'filled', 'MarkerFaceAlpha', 0.1, 'DisplayName', 'Concepts');
hold on;
plot(pareto_x_f, pareto_y_f, '-o', 'Color', [1 0.65 0], 'LineWidth', 2.5, 'MarkerSize', 6, 'MarkerFaceColor', [1 0.65 0], 'DisplayName', 'Pareto Front');

for i = 1:length(pareto_indices)
    idx = pareto_indices(i);
    label_str = sprintf(' Concept %d', idx);
    text(mean_cost_all(idx)/1e6 + 0.1, mean_area_all(idx) + 150, label_str, 'FontSize', 9, 'FontWeight', 'bold', 'Color', 'k');
end
plot(0, 26000, 'p', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1 0.84 0], 'DisplayName', 'Utopia Point');
title('Optimal Concepts: Pareto Front ID Mapping');
xlabel('System Cost ($ millions)'); ylabel('Wildfire Containment Area (m²)');
grid on; legend('Location','southeast');
set(gca, 'FontSize', 12); ax = gca; ax.YAxis.Exponent = 0; ytickformat('%,.0f');

%% --- 7. EXCEL EXPORT ---
filename = 'OS14_FullFactorial_Results.xlsx';

% Delete old file to guarantee exact tab ordering
if isfile(filename)
    delete(filename);
end

% Sheet 1: Decisions
writecell(decisions_data, filename, 'Sheet', 'Decisions');

% Calculate Distance to Utopia for all designs
% Note: Using plotted units (Cost in $M, Area in m^2). 
Dist_to_Utopia_All = sqrt((all_costs_full - 0).^2 + (all_areas_full - 26000).^2);

% Sheet 2: Pareto Front Concepts
Pareto_Combos = combos(pareto_indices, :);
Concept_ID = pareto_indices';
D1 = Pareto_Combos(:,1); D2 = Pareto_Combos(:,2); D3 = Pareto_Combos(:,3);
D4 = Pareto_Combos(:,4); D5 = Pareto_Combos(:,5); D6 = Pareto_Combos(:,6);
D7 = Pareto_Combos(:,7); D8 = Pareto_Combos(:,8); D9 = Pareto_Combos(:,9);
D10 = Pareto_Combos(:,10);
Mean_Cost_M = mean_cost_all(pareto_indices) / 1e6;
Std_Cost_M = std_cost_all(pareto_indices) / 1e6;
Mean_Area = mean_area_all(pareto_indices);
Std_Area = std_area_all(pareto_indices);
Dist_to_Utopia = Dist_to_Utopia_All(pareto_indices);

pareto_table = table(Concept_ID, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, ...
    Mean_Cost_M, Std_Cost_M, Mean_Area, Std_Area, Dist_to_Utopia);
writetable(pareto_table, filename, 'Sheet', 'Pareto_Front');

% Sheet 3: All Concepts
All_Concept_ID = (1:num_combos)';
D1_All = combos(:,1); D2_All = combos(:,2); D3_All = combos(:,3);
D4_All = combos(:,4); D5_All = combos(:,5); D6_All = combos(:,6);
D7_All = combos(:,7); D8_All = combos(:,8); D9_All = combos(:,9);
D10_All = combos(:,10);
All_Mean_Cost_M = mean_cost_all / 1e6;
All_Std_Cost_M = std_cost_all / 1e6;
All_Mean_Area = mean_area_all;
All_Std_Area = std_area_all;

all_concepts_table = table(All_Concept_ID, D1_All, D2_All, D3_All, D4_All, D5_All, D6_All, D7_All, D8_All, D9_All, D10_All, ...
    All_Mean_Cost_M, All_Std_Cost_M, All_Mean_Area, All_Std_Area, Dist_to_Utopia_All);
all_concepts_table.Properties.VariableNames{'Dist_to_Utopia_All'} = 'Dist_to_Utopia';
writetable(all_concepts_table, filename, 'Sheet', 'All_Concepts');

% Formatting helper for the terminal output
fmt = @(x) regexprep(num2str(x), '(?<=\d)(?=(\d{3})+(?!\d))', ',');

disp('=======================================================');
disp(['Tradespace generation complete. Processed ', fmt(num_combos * nTrials), ' total missions.']);
disp(['Results saved to: ', fullfile(pwd, filename)]);
disp('=======================================================');

rng(original_rng_state);