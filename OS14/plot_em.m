% EM.413 OS14 Question 1 Decision Aid
% Allows manipulation and visualization of Contianment (Performance) PDFs for OS14 Q1
close all; clear all; clc;

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);

% Define a square meters per Fibonacci score value that can be used in containment area PDFs
CAslope = 880;

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
mu_d3_o1_area = 26000 - CAslope * 0; sigma_d3_o1_area = CAslope * 2;
y_d3_o1_area = normpdf(x, mu_d3_o1_area, sigma_d3_o1_area);

% -- Option 2: Remote Commanded Activation
% Normal Dist: Most impact on max potential containment area; low variability
mu_d3_o2_area = 26000 - CAslope * 2; sigma_d3_o2_area = CAslope * 1;
y_d3_o2_area = normpdf(x, mu_d3_o2_area, sigma_d3_o2_area);

% -- Option 3: Dual Key Auto & Remote Activation
% Normal Dist: Low impact on max potential containment area; most variability
mu_d3_o3_area = 26000 - CAslope * 1; sigma_d3_o3_area = CAslope * 3;
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
fprintf('Option 1 (Auto Activate): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d3_o1_area, sigma_d3_o1_area);
fprintf('Option 2 (Remote Activate): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d3_o2_area, sigma_d3_o2_area);
fprintf('Option 3 (Dual Key Activate): Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu_d3_o3_area, sigma_d3_o3_area);

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

% -- Option 1: Expendable (No Recovery)
% 100% battery to the mission. 3-sigma tail hits 26,000.
mu_d9_o1_area = 24800; sigma_d9_o1_area = 400;
y_d9_o1_area = normpdf(x, mu_d9_o1_area, sigma_d9_o1_area);

% -- Option 2: Manual Ground Retrieval
% Minor battery reserve required. 
mu_d9_o2_area = 22000; sigma_d9_o2_area = 1000;
y_d9_o2_area = normpdf(x, mu_d9_o2_area, sigma_d9_o2_area);

% -- Option 3: Air-based Recovery
% Minor battery reserve required.
mu_d9_o3_area = 22000; sigma_d9_o3_area = 1000;
y_d9_o3_area = normpdf(x, mu_d9_o3_area, sigma_d9_o3_area);

% -- Plotting D9 
figure(5);
plot(x, y_d9_o1_area, 'b', 'LineWidth', 2.5, 'DisplayName', 'Expendable'); hold on;
plot(x, y_d9_o2_area, 'r', 'LineWidth', 2.5, 'DisplayName', 'Ground Retrieval');
plot(x, y_d9_o3_area, 'g', 'LineWidth', 2.5, 'DisplayName', 'Air-based Recovery');

title('Containment Area PDFs (D9: Recovery Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

% -- D9 Math Printout for Table --
fprintf('\n--- D9 Containment Statistics (For Table) ---\n');
fprintf('Option 1 (Expendable): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d9_o1_area, sigma_d9_o1_area);
fprintf('Option 2 (Ground):     Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d9_o2_area, sigma_d9_o2_area);
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