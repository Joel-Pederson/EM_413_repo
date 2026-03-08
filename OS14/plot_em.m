% EM.413 OS14 
% Allows manipulation and visualization of Contianment (Performance) PDFs for OS14 Q1 and Q2
close all; clear all; clc;

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

fprintf('\n--- D1 Statistics (For Table) ---\n');
fprintf('Containment (Area):\n');
fprintf('Option 1 (Drive-On):  Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d1_o1_area, sigma_d1_o1_area);
fprintf('Option 2 (Container): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d1_o2_area, sigma_d1_o2_area);
fprintf('Option 3 (Loader):    Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d1_o3_area, sigma_d1_o3_area);

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

% -- D2 Math Correction Printout 
fprintf('\n--- CORRECTED D2 Containment Statistics (Update your table!) ---\n');
mu_std1 = alpha1 / (alpha1 + beta1);
var_std1 = (alpha1 * beta1) / ((alpha1 + beta1)^2 * (alpha1 + beta1 + 1));
fprintf('Option 1 (Drone):    Mu = %.0f m^2 | Sigma = %.0f m^2\n', a1 + (mu_std1 * (b1 - a1)), sqrt(var_std1 * (b1 - a1)^2));
mu_std2 = alpha2 / (alpha2 + beta2);
var_std2 = (alpha2 * beta2) / ((alpha2 + beta2)^2 * (alpha2 + beta2 + 1));
fprintf('Option 2 (Parafoil): Mu = %.0f m^2 | Sigma = %.0f m^2\n', a2 + (mu_std2 * (b2 - a2)), sqrt(var_std2 * (b2 - a2)^2));
fprintf('Option 3 (Airbag):   Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu3, sigma3);

%% -- DECISION 3: LANDING ACTIVATION -- %%

% -- Option 1: Impact-Triggered Auto Activation
% Normal Dist: Lowest impact on max potential containment area; mid variability
sigma_d3_o1_area = CAslope * 2; % 1760
mu_d3_o1_area = 26000 - (3 * sigma_d3_o1_area); % 20720
y_d3_o1_area = normpdf(x, mu_d3_o1_area, sigma_d3_o1_area);

% -- Option 2: Remote Commanded Activation
% Normal Dist: Most impact on max potential containment area; low variability
sigma_d3_o2_area = CAslope * 1; % 880
mu_d3_o2_area = 26000 - (3 * sigma_d3_o2_area) - (CAslope * 2); % 21600
y_d3_o2_area = normpdf(x, mu_d3_o2_area, sigma_d3_o2_area);

% -- Option 3: Dual Key Auto & Remote Activation
% Normal Dist: Low impact on max potential containment area; most variability
sigma_d3_o3_area = CAslope * 3; % 2640
mu_d3_o3_area = 26000 - (3 * sigma_d3_o3_area); % 18080
y_d3_o3_area = normpdf(x, mu_d3_o3_area, sigma_d3_o3_area);

% -- Plotting D3 
figure(3);
plot(x, y_d3_o1_area, 'b', 'LineWidth', 2, 'DisplayName', 'Auto Acivate (Normal)'); hold on;
plot(x, y_d3_o2_area, 'r', 'LineWidth', 2, 'DisplayName', 'Remote Activate (Normal)');
plot(x, y_d3_o3_area, 'g', 'LineWidth', 2, 'DisplayName', 'Dual Key Activate (Normal)');
title('Containment Area PDFs (D3: Landing Activation)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

% -- D3 Math Printout for Table (Normal distributions)
fprintf('\n--- D3 Containment Statistics (For Table) ---\n');
fprintf('Option 1 (Auto Activate):   Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d3_o1_area, sigma_d3_o1_area);
fprintf('Option 2 (Remote Activate): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d3_o2_area, sigma_d3_o2_area);
fprintf('Option 3 (Dual Key):        Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu_d3_o3_area, sigma_d3_o3_area);

%% -- DECISION 4: FLEET COMPOSITION CONTAINMENT -- %%
% -- Option 1: Homogeneous (Reliable but slower)
mu_d4_o1_area = 23000; sigma_d4_o1_area = 1000;
y_d4_o1_area = normpdf(x, mu_d4_o1_area, sigma_d4_o1_area);

% -- Option 2: Two-tier (Good tactical synergy)
mu_d4_o2_area = 24500; sigma_d4_o2_area = 500;
y_d4_o2_area = normpdf(x, mu_d4_o2_area, sigma_d4_o2_area);

% -- Option 3: Three-role (Perfect specialization)
mu_d4_o3_area = 25100; sigma_d4_o3_area = 300;
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

% -- D4 Math Printout --
fprintf('\n--- D4 Statistics (For Table) ---\n');
fprintf('Containment:\n');
fprintf('Option 1 (Homogeneous):   Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d4_o1_area, sigma_d4_o1_area);
fprintf('Option 2 (2-Tier): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d4_o2_area, sigma_d4_o2_area);
fprintf('Option 3 (3-Role): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d4_o3_area, sigma_d4_o3_area);

%% -- DECISION 5: REPLACEMENT RATIO CONTAINMENT (Autonomy Proficiency) -- %%
% -- Option 1: 1:1 (High proficiency, high efficiency)
mu_d5_o1_area = 25000; sigma_d5_o1_area = 350;
y_d5_o1_area = normpdf(x, mu_d5_o1_area, sigma_d5_o1_area);

% -- Option 2: 3:1 (Moderate proficiency, some swarm friction)
mu_d5_o2_area = 18000; sigma_d5_o2_area = 2000;
y_d5_o2_area = normpdf(x, mu_d5_o2_area, sigma_d5_o2_area);

% -- Option 3: 6:1 (Low proficiency, high swarm friction)
mu_d5_o3_area = 10000; sigma_d5_o3_area = 3000;
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

fprintf('\n--- D5 Statistics (For Table) ---\n');
fprintf('Containment (Area):\n');
fprintf('Option 1 (1:1): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d5_o1_area, sigma_d5_o1_area);
fprintf('Option 2 (3:1): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d5_o2_area, sigma_d5_o2_area);
fprintf('Option 3 (6:1): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d5_o3_area, sigma_d5_o3_area);

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

% -- D6 Math Printout --
fprintf('\n--- D6 Statistics (For Table) ---\n');
fprintf('Containment:\n');
fprintf('Option 1 (A400M): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d6_o1_area, sigma_d6_o1_area);

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

% -- D7 Math Printout --
fprintf('--- D7 Containment Statistics (For Table) ---\n');
mu_std4 = alpha4 / (alpha4 + beta4);
var_std4 = (alpha4 * beta4) / ((alpha4 + beta4)^2 * (alpha4 + beta4 + 1));
fprintf('Option 1 (SATCOM):   Mu = %.0f m^2 | Sigma = %.0f m^2\n', a4 + (mu_std4 * (b4 - a4)), sqrt(var_std4 * (b4 - a4)^2));
fprintf('Option 2 (Ground):   Mu = %.0f m^2 | Sigma = %.0f m^2 (Note: Tri mean is (a+b+c)/3)\n', (a_tri+b_tri+c_tri)/3, sqrt((a_tri^2+b_tri^2+c_tri^2 - a_tri*b_tri - a_tri*c_tri - b_tri*c_tri)/18));
mu_std6 = alpha6 / (alpha6 + beta6);
var_std6 = (alpha6 * beta6) / ((alpha6 + beta6)^2 * (alpha6 + beta6 + 1));
fprintf('Option 3 (Airborne): Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', a6 + (mu_std6 * (b6 - a6)), sqrt(var_std6 * (b6 - a6)^2));

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

% -- D8 Math Printout --
fprintf('\n--- D8 Statistics (For Table) ---\n');
fprintf('Containment:\n');
fprintf('Option 1 (Teleop): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d8_o1_area, sigma_d8_o1_area);
fprintf('Option 2 (Super):  Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d8_o2_area, sigma_d8_o2_area);
mu_std8_3 = alpha8_3 / (alpha8_3 + beta8_3);
var_std8_3 = (alpha8_3 * beta8_3) / ((alpha8_3 + beta8_3)^2 * (alpha8_3 + beta8_3 + 1));
fprintf('Option 3 (Coord):  Mu = %.0f m^2 | Sigma = %.0f m^2\n', a8_3 + (mu_std8_3 * (b8_3 - a8_3)), sqrt(var_std8_3 * (b8_3 - a8_3)^2));

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

% -- D9 Math Printout for Table --
fprintf('\n--- D9 Containment Statistics (For Table) ---\n');
fprintf('Option 1 (Ground): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d9_o1_area, sigma_d9_o1_area);
fprintf('Option 2 (Expendable):     Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d9_o2_area, sigma_d9_o2_area);
fprintf('Option 3 (Auto):       Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu_d9_o3_area, sigma_d9_o3_area);

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

% -- D10 Math Printout --
fprintf('\n--- D10 Containment Statistics (For Table) ---\n');
mu_std10_1 = alpha10_1 / (alpha10_1 + beta10_1);
var_std10_1 = (alpha10_1 * beta10_1) / ((alpha10_1 + beta10_1)^2 * (alpha10_1 + beta10_1 + 1));
fprintf('Option 1 (Bare):   Mu = %.0f m^2 | Sigma = %.0f m^2\n', a10_1 + (mu_std10_1 * (b10_1 - a10_1)), sqrt(var_std10_1 * (b10_1 - a10_1)^2));

mu_std10_2 = alpha10_2 / (alpha10_2 + beta10_2);
var_std10_2 = (alpha10_2 * beta10_2) / ((alpha10_2 + beta10_2)^2 * (alpha10_2 + beta10_2 + 1));
fprintf('Option 2 (Indiv):  Mu = %.0f m^2 | Sigma = %.0f m^2\n', a10_2 + (mu_std10_2 * (b10_2 - a10_2)), sqrt(var_std10_2 * (b10_2 - a10_2)^2));

mu_std10_3 = alpha10_3 / (alpha10_3 + beta10_3);
var_std10_3 = (alpha10_3 * beta10_3) / ((alpha10_3 + beta10_3)^2 * (alpha10_3 + beta10_3 + 1));
fprintf('Option 3 (Module): Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', a10_3 + (mu_std10_3 * (b10_3 - a10_3)), sqrt(var_std10_3 * (b10_3 - a10_3)^2));

%% %%%% -- COST -- %%%% %%
% Legend entries are aligned to match Containment labels.
% Statistics are printed per section for the Command Window.

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

fprintf('\n--- D1 Cost Statistics ---\n');
fprintf('Option 1 (Drive-On):  Mu = $%.0f | Sigma = $%.0f\n', mu_d1_o1_cost, sigma_d1_o1_cost);
fprintf('Option 2 (Container): Mu = $%.0f | Sigma = $%.0f\n', mu_d1_o2_cost, sigma_d1_o2_cost);
fprintf('Option 3 (Loader):    Mu = $%.0f | Sigma = $%.0f\n', mu_d1_o3_cost, sigma_d1_o3_cost);

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

fprintf('\n--- D2 Cost Statistics ---\n');
fprintf('Option 1 (Drone):    Mean = $%.0f | Sigma = $%.0f (Tri)\n', (a_c2_1+b_c2_1+c_c2_1)/3, sqrt((a_c2_1^2+b_c2_1^2+c_c2_1^2 - a_c2_1*b_c2_1 - a_c2_1*c_c2_1 - b_c2_1*c_c2_1)/18));
fprintf('Option 2 (Parafoil): Mean = $%.0f | Sigma = $%.0f (Tri)\n', (a_c2_2+b_c2_2+c_c2_2)/3, sqrt((a_c2_2^2+b_c2_2^2+c_c2_2^2 - a_c2_2*b_c2_2 - a_c2_2*c_c2_2 - b_c2_2*c_c2_2)/18));
fprintf('Option 3 (Airbag):   Mu = $%.0f | Sigma = $%.0f\n', mu_d2_o3_cost, sigma_d2_o3_cost);

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

fprintf('\n--- D3 Cost Statistics ---\n');
fprintf('Option 1 (Auto):      Mu = $%.0f | Sigma = $%.0f\n', mu_d3_o1_cost, sigma_d3_o1_cost);
fprintf('Option 2 (Remote):    Mu = $%.0f | Sigma = $%.0f\n', mu_d3_o2_cost, sigma_d3_o2_cost);
fprintf('Option 3 (Dual Key):  Mu = $%.0f | Sigma = $%.0f\n', mu_d3_o3_cost, sigma_d3_o3_cost);

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

fprintf('\n--- D4 Cost Statistics ---\n');
fprintf('Option 1 (Homo):   Mu = $%.0f | Sigma = $%.0f\n', mu_d4_o1_cost, sigma_d4_o1_cost);
fprintf('Option 2 (2-Tier): Mu = $%.0f | Sigma = $%.0f\n', mu_d4_o2_cost, sigma_d4_o2_cost);
fprintf('Option 3 (3-Role): Mu = $%.0f | Sigma = $%.0f\n', mu_d4_o3_cost, sigma_d4_o3_cost);

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

fprintf('\n--- D5 Cost Multiplier Statistics ---\n');
fprintf('Option 1 (1:1): Mu = %.1fx | Sigma = %.2fx\n', mu_d5_o1_cost, sigma_d5_o1_cost);
fprintf('Option 2 (3:1): Mu = %.1fx | Sigma = %.2fx\n', mu_d5_o2_cost, sigma_d5_o2_cost);
fprintf('Option 3 (6:1): Mu = %.1fx | Sigma = %.2fx\n', mu_d5_o3_cost, sigma_d5_o3_cost);

%% -- DECISION 6: DEPLOYMENT AIRCRAFT COST -- %%
x_cost6 = linspace(20000, 45000, 1000);
mu_d6_o1_cost = 33532; sigma_d6_o1_cost = 2500; 
y_d6_o1_cost = normpdf(x_cost6, mu_d6_o1_cost, sigma_d6_o1_cost);

figure(106);
plot(x_cost6, y_d6_o1_cost, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2, 'DisplayName', 'A400M Baseline');
title('Cost PDFs (D6: Aircraft)'); xlabel('Cost ($)'); ylabel('Density');
legend('Location', 'NorthWest'); grid on; xlim([20000 45000]);

fprintf('\n--- D6 Cost Statistics ---\n');
fprintf('Option 1 (A400M): Mu = $%.0f | Sigma = $%.0f\n', mu_d6_o1_cost, sigma_d6_o1_cost);

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

fprintf('\n--- D7 Cost Statistics ---\n');
fprintf('Option 1 (SATCOM):   Mean = $%.0f | Sigma = $%.0f (Tri)\n', (a_c7_1+b_c7_1+c_c7_1)/3, sqrt((a_c7_1^2+b_c7_1^2+c_c7_1^2 - a_c7_1*b_c7_1 - a_c7_1*c_c7_1 - b_c7_1*c_c7_1)/18));
fprintf('Option 2 (Ground):   Mean = $%.0f | Sigma = $%.0f (Tri)\n', (a_c7_2+b_c7_2+c_c7_2)/3, sqrt((a_c7_2^2+b_c7_2^2+c_c7_2^2 - a_c7_2*b_c7_2 - a_c7_2*c_c7_2 - b_c7_2*c_c7_2)/18));
fprintf('Option 3 (Airborne): Mean = $%.0f | Sigma = $%.0f (Tri)\n', (a_c7_3+b_c7_3+c_c7_3)/3, sqrt((a_c7_3^2+b_c7_3^2+c_c7_3^2 - a_c7_3*b_c7_3 - a_c7_3*c_c7_3 - b_c7_3*c_c7_3)/18));

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

fprintf('\n--- D8 Cost Statistics ---\n');
fprintf('Option 1 (Teleop): Mu = $%.0f | Sigma = $%.0f\n', mu_d8_o1_cost, sigma_d8_o1_cost);
fprintf('Option 2 (Super):  Mu = $%.0f | Sigma = $%.0f\n', mu_d8_o2_cost, sigma_d8_o2_cost);
fprintf('Option 3 (Coord):  Mu = $%.0f | Sigma = $%.0f\n', mu_d8_o3_cost, sigma_d8_o3_cost);

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

fprintf('\n--- D9 Cost Statistics ---\n');
fprintf('Option 1 (Ground):  Mu = %.1fx | Sigma = %.2fx (Mult)\n', mu_d9_o1_cost, sigma_d9_o1_cost);
fprintf('Option 2 (Expend):  Mu = $%.0f | Sigma = $%.0f\n', mu_d9_o2_cost, sigma_d9_o2_cost);
fprintf('Option 3 (Air-Rec): Mu = $%.0f | Sigma = $%.0f\n', mu_d9_o3_cost, sigma_d9_o3_cost);

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

fprintf('\n--- D10 Cost Statistics ---\n');
fprintf('Option 1 (Bare):   Mu = $%.0f | Sigma = $%.0f\n', mu_d10_o1_cost, sigma_d10_o1_cost);
fprintf('Option 2 (Pods):   Mu = $%.0f | Sigma = $%.0f\n', mu_d10_o2_cost, sigma_d10_o2_cost);
fprintf('Option 3 (Module): Mu = $%.0f | Sigma = $%.0f\n', mu_d10_o3_cost, sigma_d10_o3_cost);

% Finish formatting all figures
figHandles = findobj('Type', 'figure');
for i = 1:length(figHandles)
    ax = get(figHandles(i), 'CurrentAxes');
    if ~isempty(ax)
        ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
        xtickformat(ax, '%,.0f');
    end
end

%% --  Q2 FIBONACCI LOOKUP TABLE (from OS13 matrix) -- %%
% Decision | Option1 score | Option2 score | Option3 score
fib_table.D1 = [2, 3, 1];   % Self-Propelled, Containerized, Ground Loader
fib_table.D2 = [5, 5, 1];   % Containerized Drone, Parafoil, Airbag
fib_table.D3 = [3, 1, 2];   % Auto, Remote, Dual
fib_table.D4 = [5, 3, 2];   % Homogenous, Two-Tier, Three Role
fib_table.D5 = [8, 8, 8];   % 1:1, 3:1, 6:1
fib_table.D6 = [5, NaN, NaN]; % A400M (fixed)
fib_table.D7 = [5, 2, 3];   % SATCOM, Ground Node, Airborne Relay
fib_table.D8 = [2, 5, 8];   % Teleop, Supervised, Coordinated
fib_table.D9 = [2, 3, 1];   % Expendable, Ground, Air-based
fib_table.D10= [1, 2, 5];   % Bare, Individual, Containerized

% Sum the maximum score from each decision row in fib_table (handles NaN)
fields = fieldnames(fib_table);
max_fib_sum = 0;
for k = 1:numel(fields)
    row = fib_table.(fields{k});
    if ~isempty(row)
        max_val = nanmax(row); % ignore NaNs when taking max
        if ~isnan(max_val)
            max_fib_sum = max_fib_sum + max_val;
        end
    end
end

%% Q2 MONTE CARLO TRADESPACE SIMULATION (Containment & Cost)

% Save the user's current RNG state so we don't mess up their future work
original_rng_state = rng; 
rng(1); % Lock the seed to 1 for perfectly repeatable Monte Carlo draws
nTrials = 10000;
fprintf('\n=== Q2 Monte Carlo Results (10,000 Iterations/Concept) ===\n');

% Helper function to draw a random number from a Triangular Distribution
tri_rnd = @(a, c, b) a + sqrt(rand() * (b - a) * (c - a)) * (rand() < (c - a)/(b - a)) + ...
                     (b - sqrt((1 - rand()) * (b - a) * (b - c)) - a) * (rand() >= (c - a)/(b - a));

% Helper function to prevent negative costs from high-variance options
pos = @(x) max(0, x); 

% Preallocate Data Arrays (Length 7 to match rubric requirements)
mean_contain = zeros(1,7); std_contain = zeros(1,7);
mean_cost = zeros(1,7); std_cost = zeros(1,7);

% ==================================================================
% CONCEPT 1: High Precision, High Performance, Max Autonomy
% Matrix Mapping: D1o1, D2o2, D3o1, D4o1, D5o1, D6o1, D7o1, D8o3, D9o3, D10o3
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o2_area, sigma_d1_o2_area)*(fib_table.D1(2)/max_fib_sum) + ...
                 (betarnd(alpha2,beta2)*(b2-a2)+a2)*(fib_table.D2(2)/max_fib_sum) + ...
                 normrnd(mu_d3_o1_area, sigma_d3_o1_area)*(fib_table.D3(1)/max_fib_sum) + ...
                 normrnd(mu_d4_o1_area, sigma_d4_o1_area)*(fib_table.D4(1)/max_fib_sum) + ...
                 normrnd(mu_d5_o1_area, sigma_d5_o1_area)*(fib_table.D5(1)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 (betarnd(alpha4,beta4)*(b4-a4)+a4)*(fib_table.D7(1)/max_fib_sum) + ...
                 (betarnd(alpha8_3,beta8_3)*(b8_3-a8_3)+a8_3)*(fib_table.D8(3)/max_fib_sum) + ...
                 normrnd(mu_d9_o1_area, sigma_d9_o1_area)*(fib_table.D9(1)/max_fib_sum) + ...
                 (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3)*(fib_table.D10(3)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o1_cost, sigma_d4_o1_cost)) * pos(normrnd(mu_d5_o1_cost, sigma_d5_o1_cost));
    attr = 0; % Air-based recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o2_cost, sigma_d1_o2_cost)) + pos(tri_rnd(a_c2_2, c_c2_2, b_c2_2)) + ...
          pos(normrnd(mu_d3_o1_cost, sigma_d3_o1_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_1, c_c7_1, b_c7_1)) + pos(normrnd(mu_d8_o3_cost, sigma_d8_o3_cost)) + ...
          pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost)) + pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost));
    c_samp(i) = hw + attr + ops;
end
mean_contain(1) = mean(ca_samp); std_contain(1) = std(ca_samp);
mean_cost(1) = mean(c_samp); std_cost(1) = std(c_samp);
fprintf('Concept 1 (Max Auto): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(1), std_contain(1), mean_cost(1), std_cost(1));

% ==================================================================
% CONCEPT 2: High Precision, Low Autonomy, Low Performance
% Matrix Mapping: D1o2, D2o2, D3o2, D4o3, D5o1, D6o1, D7o3, D8o1, D9o2, D10o3
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o2_area, sigma_d1_o2_area)*(fib_table.D1(2)/max_fib_sum) + ...
                 (betarnd(alpha2,beta2)*(b2-a2)+a2)*(fib_table.D2(2)/max_fib_sum) + ...
                 normrnd(mu_d3_o2_area, sigma_d3_o2_area)*(fib_table.D3(2)/max_fib_sum) + ...
                 normrnd(mu_d4_o3_area, sigma_d4_o3_area)*(fib_table.D4(3)/max_fib_sum) + ...
                 normrnd(mu_d5_o1_area, sigma_d5_o1_area)*(fib_table.D5(1)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 (betarnd(alpha6,beta6)*(b6-a6)+a6)*(fib_table.D7(3)/max_fib_sum) + ...
                 normrnd(mu_d8_o1_area, sigma_d8_o1_area)*(fib_table.D8(1)/max_fib_sum) + ...
                 normrnd(mu_d9_o1_area, sigma_d9_o1_area)*(fib_table.D9(1)/max_fib_sum) + ...
                 (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3)*(fib_table.D10(3)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o3_cost, sigma_d4_o3_cost)) * pos(normrnd(mu_d5_o1_cost, sigma_d5_o1_cost));
    attr = 0; % Ground Recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o2_cost, sigma_d1_o2_cost)) + pos(tri_rnd(a_c2_2, c_c2_2, b_c2_2)) + ...
          pos(normrnd(mu_d3_o2_cost, sigma_d3_o2_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_3, c_c7_3, b_c7_3)) + pos(normrnd(mu_d8_o1_cost, sigma_d8_o1_cost)) + ...
          pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost)) + pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost));
    c_samp(i) = hw + attr + ops;
end
mean_contain(2) = mean(ca_samp); std_contain(2) = std(ca_samp);
mean_cost(2) = mean(c_samp); std_cost(2) = std(c_samp);
fprintf('Concept 2 (Low Auto): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(2), std_contain(2), mean_cost(2), std_cost(2));

% ==================================================================
% CONCEPT 3: High Precision, Medium Autonomy, Medium Performance
% Matrix Mapping: D1o2, D2o2, D3o3, D4o2, D5o2, D6o1, D7o2, D8o2, D9o2, D10o3
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o2_area, sigma_d1_o2_area)*(fib_table.D1(2)/max_fib_sum) + ...
                 (betarnd(alpha2,beta2)*(b2-a2)+a2)*(fib_table.D2(2)/max_fib_sum) + ...
                 normrnd(mu_d3_o3_area, sigma_d3_o3_area)*(fib_table.D3(3)/max_fib_sum) + ...
                 normrnd(mu_d4_o2_area, sigma_d4_o2_area)*(fib_table.D4(2)/max_fib_sum) + ...
                 normrnd(mu_d5_o2_area, sigma_d5_o2_area)*(fib_table.D5(2)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 tri_rnd(a_tri, c_tri, b_tri)*(fib_table.D7(2)/max_fib_sum) + ...
                 normrnd(mu_d8_o2_area, sigma_d8_o2_area)*(fib_table.D8(2)/max_fib_sum) + ...
                 normrnd(mu_d9_o1_area, sigma_d9_o1_area)*(fib_table.D9(1)/max_fib_sum) + ...
                 (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3)*(fib_table.D10(3)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o2_cost, sigma_d4_o2_cost)) * pos(normrnd(mu_d5_o2_cost, sigma_d5_o2_cost));
    attr = 0; % Ground Recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o2_cost, sigma_d1_o2_cost)) + pos(tri_rnd(a_c2_2, c_c2_2, b_c2_2)) + ...
          pos(normrnd(mu_d3_o3_cost, sigma_d3_o3_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_2, c_c7_2, b_c7_2)) + pos(normrnd(mu_d8_o2_cost, sigma_d8_o2_cost)) + ...
          pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost)) + pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost));
    c_samp(i) = hw + attr + ops;
end
mean_contain(3) = mean(ca_samp); std_contain(3) = std(ca_samp);
mean_cost(3) = mean(c_samp); std_cost(3) = std(c_samp);
fprintf('Concept 3 (Med Auto): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(3), std_contain(3), mean_cost(3), std_cost(3));

% ==================================================================
% CONCEPT 4: Minimal Cost
% Matrix Mapping: D1o1, D2o3, D3o2, D4o3, D5o1, D6o1, D7o2, D8o1, D9o1, D10o1
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o1_area, sigma_d1_o1_area)*(fib_table.D1(1)/max_fib_sum) + ...
                 normrnd(mu3, sigma3)*(fib_table.D2(3)/max_fib_sum) + ...
                 normrnd(mu_d3_o2_area, sigma_d3_o2_area)*(fib_table.D3(2)/max_fib_sum) + ...
                 normrnd(mu_d4_o3_area, sigma_d4_o3_area)*(fib_table.D4(3)/max_fib_sum) + ...
                 normrnd(mu_d5_o1_area, sigma_d5_o1_area)*(fib_table.D5(1)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 tri_rnd(a_tri, c_tri, b_tri)*(fib_table.D7(2)/max_fib_sum) + ...
                 normrnd(mu_d8_o1_area, sigma_d8_o1_area)*(fib_table.D8(1)/max_fib_sum) + ...
                 normrnd(mu_d9_o1_area, sigma_d9_o1_area)*(fib_table.D9(1)/max_fib_sum) + ...
                 (betarnd(alpha10_1,beta10_1)*(b10_1-a10_1)+a10_1)*(fib_table.D10(1)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o3_cost, sigma_d4_o3_cost)) * pos(normrnd(mu_d5_o1_cost, sigma_d5_o1_cost));
    attr = 0; % Ground Recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o1_cost, sigma_d1_o1_cost)) + pos(normrnd(mu_d2_o3_cost, sigma_d2_o3_cost)) + ...
          pos(normrnd(mu_d3_o2_cost, sigma_d3_o2_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_2, c_c7_2, b_c7_2)) + pos(normrnd(mu_d8_o1_cost, sigma_d8_o1_cost)) + ...
          pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost)) + pos(normrnd(mu_d10_o1_cost, sigma_d10_o1_cost));
    c_samp(i) = hw + attr + ops;
end
mean_contain(4) = mean(ca_samp); std_contain(4) = std(ca_samp);
mean_cost(4) = mean(c_samp); std_cost(4) = std(c_samp);
fprintf('Concept 4 (Min Cost): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(4), std_contain(4), mean_cost(4), std_cost(4));

% ==================================================================
% CONCEPT 5: Strategic Lift Optimized
% Matrix Mapping: D1o3, D2o2, D3o1, D4o1, D5o2, D6o1, D7o2, D8o2, D9o2, D10o3
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o3_area, sigma_d1_o3_area)*(fib_table.D1(3)/max_fib_sum) + ...
                 (betarnd(alpha2,beta2)*(b2-a2)+a2)*(fib_table.D2(2)/max_fib_sum) + ...
                 normrnd(mu_d3_o1_area, sigma_d3_o1_area)*(fib_table.D3(1)/max_fib_sum) + ...
                 normrnd(mu_d4_o2_area, sigma_d4_o2_area)*(fib_table.D4(2)/max_fib_sum) + ...
                 normrnd(mu_d5_o2_area, sigma_d5_o2_area)*(fib_table.D5(2)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 tri_rnd(a_tri, c_tri, b_tri)*(fib_table.D7(2)/max_fib_sum) + ...
                 normrnd(mu_d8_o2_area, sigma_d8_o2_area)*(fib_table.D8(2)/max_fib_sum) + ...
                 normrnd(mu_d9_o1_area, sigma_d9_o1_area)*(fib_table.D9(1)/max_fib_sum) + ...
                 (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3)*(fib_table.D10(3)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o2_cost, sigma_d4_o2_cost)) * pos(normrnd(mu_d5_o2_cost, sigma_d5_o2_cost));
    attr = 0; % Ground Recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o3_cost, sigma_d1_o3_cost)) + pos(tri_rnd(a_c2_2, c_c2_2, b_c2_2)) + ...
          pos(normrnd(mu_d3_o1_cost, sigma_d3_o1_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_2, c_c7_2, b_c7_2)) + pos(normrnd(mu_d8_o2_cost, sigma_d8_o2_cost)) + ...
          pos(normrnd(mu_d9_o1_cost, sigma_d9_o1_cost)) + pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost)); 
    c_samp(i) = hw + attr + ops;
end
mean_contain(5) = mean(ca_samp); std_contain(5) = std(ca_samp);
mean_cost(5) = mean(c_samp); std_cost(5) = std(c_samp);
fprintf('Concept 5 (Strat Lift): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(5), std_contain(5), mean_cost(5), std_cost(5));

% ==================================================================
% CONCEPT 10: Smallest Containment Area
% Matrix Mapping: D1o3, D2o3, D3o2, D4o3, D5o3, D6o1, D7o3, D8o1, D9o3, D10o1
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o3_area, sigma_d1_o3_area)*(fib_table.D1(3)/max_fib_sum) + ...
                 normrnd(mu3, sigma3)*(fib_table.D2(3)/max_fib_sum) + ...
                 normrnd(mu_d3_o2_area, sigma_d3_o2_area)*(fib_table.D3(2)/max_fib_sum) + ...
                 normrnd(mu_d4_o3_area, sigma_d4_o3_area)*(fib_table.D4(3)/max_fib_sum) + ...
                 normrnd(mu_d5_o3_area, sigma_d5_o3_area)*(fib_table.D5(3)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 (betarnd(alpha6,beta6)*(b6-a6)+a6)*(fib_table.D7(3)/max_fib_sum) + ...
                 normrnd(mu_d8_o1_area, sigma_d8_o1_area)*(fib_table.D8(1)/max_fib_sum) + ...
                 normrnd(mu_d9_o3_area, sigma_d9_o3_area)*(fib_table.D9(3)/max_fib_sum) + ...
                 (betarnd(alpha10_1,beta10_1)*(b10_1-a10_1)+a10_1)*(fib_table.D10(1)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o3_cost, sigma_d4_o3_cost)) * pos(normrnd(mu_d5_o3_cost, sigma_d5_o3_cost));
    attr = 0; % Air-based recovery (no hardware penalty)
    ops = pos(normrnd(mu_d1_o3_cost, sigma_d1_o3_cost)) + pos(normrnd(mu_d2_o3_cost, sigma_d2_o3_cost)) + ...
          pos(normrnd(mu_d3_o2_cost, sigma_d3_o2_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_3, c_c7_3, b_c7_3)) + pos(normrnd(mu_d8_o1_cost, sigma_d8_o1_cost)) + ...
          pos(normrnd(mu_d9_o3_cost, sigma_d9_o3_cost)) + pos(normrnd(mu_d10_o1_cost, sigma_d10_o1_cost));
    c_samp(i) = hw + attr + ops;
end
mean_contain(6) = mean(ca_samp); std_contain(6) = std(ca_samp);
mean_cost(6) = mean(c_samp); std_cost(6) = std(c_samp);
fprintf('Concept 10 (Min Area): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(6), std_contain(6), mean_cost(6), std_cost(6));

% ==================================================================
% CONCEPT 11: Largest Containment Area
% Matrix Mapping: D1o2, D2o2, D3o1, D4o1, D5o1, D6o1, D7o1, D8o3, D9o1, D10o3
ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
for i = 1:nTrials
    ca_samp(i) = normrnd(mu_d1_o2_area, sigma_d1_o2_area)*(fib_table.D1(2)/max_fib_sum) + ...
                 (betarnd(alpha2,beta2)*(b2-a2)+a2)*(fib_table.D2(2)/max_fib_sum) + ...
                 normrnd(mu_d3_o1_area, sigma_d3_o1_area)*(fib_table.D3(1)/max_fib_sum) + ...
                 normrnd(mu_d4_o1_area, sigma_d4_o1_area)*(fib_table.D4(1)/max_fib_sum) + ...
                 normrnd(mu_d5_o1_area, sigma_d5_o1_area)*(fib_table.D5(1)/max_fib_sum) + ...
                 normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
                 (betarnd(alpha4,beta4)*(b4-a4)+a4)*(fib_table.D7(1)/max_fib_sum) + ...
                 (betarnd(alpha8_3,beta8_3)*(b8_3-a8_3)+a8_3)*(fib_table.D8(3)/max_fib_sum) + ...
                 normrnd(mu_d9_o2_area, sigma_d9_o2_area)*(fib_table.D9(2)/max_fib_sum) + ...
                 (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3)*(fib_table.D10(3)/max_fib_sum);
                 
    hw = pos(normrnd(mu_d4_o1_cost, sigma_d4_o1_cost)) * pos(normrnd(mu_d5_o1_cost, sigma_d5_o1_cost));
    attr = hw * pos(normrnd(mu_d9_o2_cost, sigma_d9_o2_cost)); % EXPENDABLE/NO-RECOVERY (Multiplier applied)
    ops = pos(normrnd(mu_d1_o2_cost, sigma_d1_o2_cost)) + pos(tri_rnd(a_c2_2, c_c2_2, b_c2_2)) + ...
          pos(normrnd(mu_d3_o1_cost, sigma_d3_o1_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
          pos(tri_rnd(a_c7_1, c_c7_1, b_c7_1)) + pos(normrnd(mu_d8_o3_cost, sigma_d8_o3_cost)) + ...
          pos(normrnd(mu_d10_o3_cost, sigma_d10_o3_cost)); % No flat D9 ops cost
    c_samp(i) = hw + attr + ops;
end
mean_contain(7) = mean(ca_samp); std_contain(7) = std(ca_samp);
mean_cost(7) = mean(c_samp); std_cost(7) = std(c_samp);
fprintf('Concept 11 (Max Area): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(7), std_contain(7), mean_cost(7), std_cost(7));

% % ==================================================================
% % CONCEPT 12: Max Area Uncertainty
% % Matrix Mapping: D1o3, D2o3, D3o3, D4o31 D5o3, D6o1, D7o3, D8o1, D9o3, D10o1
% ca_samp = zeros(nTrials,1); c_samp = zeros(nTrials,1);
% for i = 1:nTrials
%     ca_samp(i) = normrnd(mu_d1_o3_area, sigma_d1_o3_area)*(fib_table.D1(3)/max_fib_sum) + ...
%                  normrnd(mu3, sigma3)*(fib_table.D2(3)/max_fib_sum) + ...
%                  normrnd(mu_d3_o3_area, sigma_d3_o3_area)*(fib_table.D3(3)/max_fib_sum) + ...
%                  normrnd(mu_d4_o1_area, sigma_d4_o1_area)*(fib_table.D4(1)/max_fib_sum) + ...
%                  normrnd(mu_d5_o3_area, sigma_d5_o3_area)*(fib_table.D5(3)/max_fib_sum) + ...
%                  normrnd(mu_d6_o1_area, sigma_d6_o1_area)*(fib_table.D6(1)/max_fib_sum) + ...
%                  (betarnd(alpha6,beta6)*(b6-a6)+a6)*(fib_table.D7(3)/max_fib_sum) + ...
%                  normrnd(mu_d8_o1_area, sigma_d8_o1_area)*(fib_table.D8(1)/max_fib_sum) + ...
%                  normrnd(mu_d9_o3_area, sigma_d9_o3_area)*(fib_table.D9(3)/max_fib_sum) + ...
%                  (betarnd(alpha10_1,beta10_1)*(b10_1-a10_1)+a10_1)*(fib_table.D10(1)/max_fib_sum);
% 
%     hw = pos(normrnd(mu_d4_o1_cost, sigma_d4_o1_cost)) * pos(normrnd(mu_d5_o3_cost, sigma_d5_o3_cost));
%     attr = 0; % Air-based recovery (no hardware penalty)
%     ops = pos(normrnd(mu_d1_o3_cost, sigma_d1_o3_cost)) + pos(normrnd(mu_d2_o3_cost, sigma_d2_o3_cost)) + ...
%           pos(normrnd(mu_d3_o3_cost, sigma_d3_o3_cost)) + pos(normrnd(mu_d6_o1_cost, sigma_d6_o1_cost)) + ...
%           pos(tri_rnd(a_c7_3, c_c7_3, b_c7_3)) + pos(normrnd(mu_d8_o1_cost, sigma_d8_o1_cost)) + ...
%           pos(normrnd(mu_d9_o3_cost, sigma_d9_o3_cost)) + pos(normrnd(mu_d10_o1_cost, sigma_d10_o1_cost));
%     c_samp(i) = hw + attr + ops;
% end
% mean_contain(8) = mean(ca_samp); std_contain(8) = std(ca_samp);
% mean_cost(8) = mean(c_samp); std_cost(8) = std(c_samp);
% fprintf('Concept 12 (Max Area +/-): Area = %.0f m² | Std = %.0f m² | Cost = $%.0f | Std = $%.0f\n', mean_contain(8), std_contain(8), mean_cost(8), std_cost(8));

%% ==================================================================
% Q2 Tradespace Plot - BOTH Cost & Containment Uncertainty (±2σ)

figure(25); clf;
% Plot 2D Error Bars (Vertical for area, Horizontal for cost)
errorbar(mean_cost/1e6, mean_contain, ...
         2*std_contain, 2*std_contain, ...   % vertical uncertainty
         2*std_cost/1e6, 2*std_cost/1e6, ... % horizontal uncertainty
         'o', 'LineStyle','none', 'Color','k', 'LineWidth',2.5, ...
         'MarkerSize',11, 'MarkerFaceColor',[0 0.45 0.74], 'DisplayName', 'Concepts with \pm2\sigma');
hold on;

% Historical Design of Reference (Smokejumpers)
hist_cost = 1.5;
hist_contain = 8094;

% --- DYNAMIC PARETO FRONT ALGORITHM ---
% Pool all data points including the historical baseline
all_costs = [hist_cost, mean_cost/1e6];
all_areas = [hist_contain, mean_contain];

% Sort by cost (minimize x)
[sorted_costs, sort_idx] = sort(all_costs);
sorted_areas = all_areas(sort_idx);

% Extract non-dominated points (maximize y)
pareto_x = [];
pareto_y = [];
max_area_so_far = -Inf;

for i = 1:length(sorted_costs)
    if sorted_areas(i) > max_area_so_far
        pareto_x(end+1) = sorted_costs(i);
        pareto_y(end+1) = sorted_areas(i);
        max_area_so_far = sorted_areas(i);
    end
end

% Connect the dominant designs with straight lines
plot(pareto_x, pareto_y, '-o', 'Color', [1 0.65 0], 'LineWidth', 3.5, 'MarkerSize', 8, 'MarkerFaceColor', [1 0.65 0], 'DisplayName', 'Pareto Front');
% ----------------------------------------

% Concept Labels (Updated to match OS13 Matrix)
labels = {'C1 Max Auto', 'C2 Low Auto', 'C3 Med Auto', 'C4 Min Cost', 'C5 Strat Lift', 'C10 Min Area', 'C11 Max Area'};
for i = 1:7
    text(mean_cost(i)/1e6 + 0.2, mean_contain(i) + 350, labels{i}, 'FontSize',11, 'FontWeight','bold');
end

% Utopia Point
plot(0, 26000, 'p', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1 0.84 0], 'DisplayName', 'Utopia Point');
text(0.3, 26000, 'Utopia', 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Plot Formatting
title('Tradespace: Wildfire Containment Area vs. System Cost (Monte Carlo Uncertainty)');
xlabel('System Cost [Purchase + Cost of Operation] ($ millions)');
ylabel('Wildfire Containment Area (m²)');
grid on;
xlim([-0.5 max(mean_cost/1e6) + 2.5]); 
ylim([8000 28000]);

% Plot Historical Design of Reference (Smokejumpers)
plot(hist_cost, hist_contain, 's', 'MarkerSize', 15, 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'k', 'DisplayName', 'Historical Ref');
text(hist_cost + 0.1, hist_contain, 'Historical Baseline (Smokejumpers)', 'FontSize', 11, 'FontAngle', 'italic');

% Call the legend (it will automatically grab all 'DisplayName' tags)
legend('Location','northeast');
set(gca, 'FontSize',12);

ax = gca;
ax.XAxis.Exponent = 0; % Forces X-axis to standard notation
ax.YAxis.Exponent = 0; % Forces Y-axis to standard notation
ytickformat('%,.0f');  % Adds commas to the Y-axis numbers

% CLEANUP: Restore the original RNG state
rng(original_rng_state);