% EM.413 OS14 Question 1 Decision Aid
% Allows manipulation and visualization of Contianment (Performance) PDFs for OS14 Q1
close all; clear all; clc;

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);

% Define a square meters per Fibonacci score value that can be used in containment area PDFs
CAslope = 880;

%% -- DECISION 1: LOADING METHOD -- %%

% -- Option 1: Self-Propelled Drive-On
% Normal Dist: Low impact on max potential containment area; some variability
mu_d1_o1_area = 26000 - CAslope * 1; sigma_d1_o1_area = CAslope * 2;
y_d1_o1_area = normpdf(x, mu_d1_o1_area, sigma_d1_o1_area);

% -- Option 2: Containerized Module
% Normal Dist: Low impact on max potential containment area; low variability
mu_d1_o2_area = 26000 - CAslope * 0; sigma_d1_o2_area = CAslope * 1;
y_d1_o2_area = normpdf(x, mu_d1_o2_area, sigma_d1_o2_area);

% -- Option 3: Dedicated Ground Loader
% Normal Dist: Low impact on max potential containment area; high variability
mu_d1_o3_area = 26000 - CAslope * 2; sigma_d1_o3_area = CAslope * 3;
y_d1_o3_area = normpdf(x, mu_d1_o3_area, sigma_d1_o3_area);

% -- Plotting D1 
figure(1);
plot(x, y_d1_o1_area, 'b', 'LineWidth', 2, 'DisplayName', 'Self Drive-On (Normal)'); hold on;
plot(x, y_d1_o2_area, 'r', 'LineWidth', 2, 'DisplayName', 'Containerized (Normal)');
plot(x, y_d1_o3_area, 'g', 'LineWidth', 2, 'DisplayName', 'Ground Loader (Normal)');
title('Containment Area PDFs (D1: Loading Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

% -- D1 Math Printout for Table (Normal distributions)
fprintf('\n--- D1 Containment Statistics (For Table) ---\n');
fprintf('Option 1 (Self Drive-On): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d1_o1_area, sigma_d1_o1_area);
fprintf('Option 2 (Containerized): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_d1_o2_area, sigma_d1_o2_area);
fprintf('Option 3 (Ground Loader): Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu_d1_o3_area, sigma_d1_o3_area);

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

%% -- DECISION 4: FLEET COMPOSITION (D4) -- %%
% Normal distributions (symmetric uncertainty around expected synergy)

mu_d4_o1_area = 26000; sigma_d4_o1_area = 800;   % Homogenous (best)
y_d4_o1_area = normpdf(x, mu_d4_o1_area, sigma_d4_o1_area);

mu_d4_o2_area = 24000; sigma_d4_o2_area = 1200;  % Two-Tier
y_d4_o2_area = normpdf(x, mu_d4_o2_area, sigma_d4_o2_area);

mu_d4_o3_area = 22000; sigma_d4_o3_area = 1500;  % Three Role
y_d4_o3_area = normpdf(x, mu_d4_o3_area, sigma_d4_o3_area);

%% -- DECISION 5: REPLACEMENT RATIO (D5) -- %%
% Normal distributions (biggest impact on total containment)

mu_d5_o1_area = 26000; sigma_d5_o1_area = 600;   % 1:1 (best)
y_d5_o1_area = normpdf(x, mu_d5_o1_area, sigma_d5_o1_area);

mu_d5_o2_area = 24000; sigma_d5_o2_area = 900;   % 3:1
y_d5_o2_area = normpdf(x, mu_d5_o2_area, sigma_d5_o2_area);

mu_d5_o3_area = 22000; sigma_d5_o3_area = 1300;  % 6:1
y_d5_o3_area = normpdf(x, mu_d5_o3_area, sigma_d5_o3_area);

%% -- DECISION 6: DEPLOYMENT AIRCRAFT TYPE (D6) -- %%
% Fixed to A400M — very tight Normal (minimal uncertainty)

mu_d6_o1_area = 26000; sigma_d6_o1_area = 300;
y_d6_o1_area = normpdf(x, mu_d6_o1_area, sigma_d6_o1_area);

% -- Plotting D4, D5, D6 (combined figure for clarity)
figure(8);
subplot(3,1,1); plot(x, y_d4_o1_area, 'b', 'LineWidth', 2); hold on;
plot(x, y_d4_o2_area, 'r', 'LineWidth', 2); plot(x, y_d4_o3_area, 'g', 'LineWidth', 2);
title('D4: Fleet Composition'); legend('Homogenous','Two-Tier','Three Role'); grid on;

subplot(3,1,2); plot(x, y_d5_o1_area, 'b', 'LineWidth', 2); hold on;
plot(x, y_d5_o2_area, 'r', 'LineWidth', 2); plot(x, y_d5_o3_area, 'g', 'LineWidth', 2);
title('D5: Replacement Ratio'); legend('1:1','3:1','6:1'); grid on;

subplot(3,1,3); plot(x, y_d6_o1_area, 'b', 'LineWidth', 2);
title('D6: Aircraft Type (A400M)'); grid on;

% -- Math Printout for Table
fprintf('\n--- D4/D5/D6 Containment Statistics (For Table) ---\n');
fprintf('D4 O1 Homogenous:     Mu = %.0f m² | Sigma = %.0f m²\n', mu_d4_o1_area, sigma_d4_o1_area);
fprintf('D4 O2 Two-Tier:       Mu = %.0f m² | Sigma = %.0f m²\n', mu_d4_o2_area, sigma_d4_o2_area);
fprintf('D4 O3 Three Role:     Mu = %.0f m² | Sigma = %.0f m²\n', mu_d4_o3_area, sigma_d4_o3_area);
fprintf('D5 O1 1:1:            Mu = %.0f m² | Sigma = %.0f m²\n', mu_d5_o1_area, sigma_d5_o1_area);
fprintf('D5 O2 3:1:            Mu = %.0f m² | Sigma = %.0f m²\n', mu_d5_o2_area, sigma_d5_o2_area);
fprintf('D5 O3 6:1:            Mu = %.0f m² | Sigma = %.0f m²\n', mu_d5_o3_area, sigma_d5_o3_area);
fprintf('D6 O1 A400M:          Mu = %.0f m² | Sigma = %.0f m²\n\n', mu_d6_o1_area, sigma_d6_o1_area);

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

%% Q2 FIBONACCI LOOKUP TABLE (from OS13 matrix)
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

%% Q2 C3 MONTE CARLO - Containment Area Only (Weighted by Fibonacci)
nTrials = 10000;

% Concept 3 (High Precision, Medium Autonomy, Medium Performance)
% D1=O2 (score 3), D2=O2 (5), D3=O3 (2), D7=O2 (2), D8=O2 (5), D9=O2 (2), D10=O3 (5)
concept_total_fib = fib_table.D1(2) + fib_table.D2(2) + fib_table.D3(3) + ...
                    fib_table.D7(2) + fib_table.D8(2) + fib_table.D9(2) + fib_table.D10(3);

contain_samples = zeros(nTrials,1);

for i = 1:nTrials
    % D1: Loading (O2 - Containerized)
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o2_area, sigma_d1_o2_area) * (fib_table.D1(2) / concept_total_fib);
    
    % D2: Insertion (O2 - Parafoil)
    contain_samples(i) = contain_samples(i) + (betarnd(alpha2, beta2) * (b2 - a2) + a2) * (fib_table.D2(2) / concept_total_fib);
    
    % D3: Landing Activation (O3 - Dual Key)
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o3_area, sigma_d3_o3_area) * (fib_table.D3(3) / concept_total_fib);
    
    % D7: Communications (O2 - Ground Node RF)
    contain_samples(i) = contain_samples(i) + ((a_tri + b_tri + c_tri)/3) * (fib_table.D7(2) / concept_total_fib);
    
    % D8: Autonomy (O2 - Supervised)
    contain_samples(i) = contain_samples(i) + normrnd(mu_d8_o2_area, sigma_d8_o2_area) * (fib_table.D8(2) / concept_total_fib);
    
    % D9: Recovery (O2 - Ground Retrieval)
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o2_area, sigma_d9_o2_area) * (fib_table.D9(2) / concept_total_fib);
    
    % D10: Encapsulation (O3 - Containerized Module)
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_3, beta10_3) * (b10_3 - a10_3) + a10_3) * (fib_table.D10(3) / concept_total_fib);
end

mean_contain = mean(contain_samples);
std_contain  = std(contain_samples);

fprintf('\n=== Concept 3 Monte Carlo (Weighted Containment Area) ===\n');
fprintf('Mean = %.0f m² | Std Dev = %.0f m²\n', mean_contain, std_contain);
fprintf('95%% confidence interval ≈ %.0f to %.0f m²\n', mean_contain-2*std_contain, mean_contain+2*std_contain);

%% Q2 PLOT: Monte Carlo Distribution Curve (PDF)
[pdf_values, x_pdf] = ksdensity(contain_samples);   % Smooth kernel density

figure(10);
plot(x_pdf, pdf_values, 'b', 'LineWidth', 2.5);
hold on;

% Vertical lines for mean and ±2σ
xline(mean_contain, 'r--', 'LineWidth', 1.5, 'Label', sprintf('Mean = %.0f m²', mean_contain));
xline(mean_contain - 2*std_contain, 'k--', 'LineWidth', 1.2, 'Label', '±2σ');
xline(mean_contain + 2*std_contain, 'k--', 'LineWidth', 1.2);

title('Monte Carlo Distribution - Concept 3 Containment Area');
xlabel('Containment Area (m²)');
ylabel('Probability Density');
grid on;
% xlim([mean_contain-4*std_contain mean_contain+4*std_contain]);

%% Q2 MONTE CARLO - Containment Area Only (Weighted by max_fib_sum)
nTrials = 10000;

fprintf('\n=== Q2 Monte Carlo Results (Weighted Containment Area) ===\n');

% ==================================================================
% Concept 1 (High Precision, High Performance, Max Autonomy)
contain_samples = zeros(nTrials,1);
for i = 1:nTrials
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o1_area, sigma_d1_o1_area) * (fib_table.D1(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha2,beta2)*(b2-a2)+a2) * (fib_table.D2(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o1_area, sigma_d3_o1_area) * (fib_table.D3(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d4_o1_area, sigma_d4_o1_area) * (fib_table.D4(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d5_o1_area, sigma_d5_o1_area) * (fib_table.D5(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d6_o1_area, sigma_d6_o1_area) * (fib_table.D6(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + ((a_tri+b_tri+c_tri)/3) * (fib_table.D7(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha8_3,beta8_3)*(b8_3-a8_3)+a8_3) * (fib_table.D8(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o3_area, sigma_d9_o3_area) * (fib_table.D9(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3) * (fib_table.D10(3) / max_fib_sum);
end
mean_C1 = mean(contain_samples);
std_C1  = std(contain_samples);
fprintf('Concept 1: Mean = %.0f m² | Std = %.0f m²\n', mean_C1, std_C1);

% ==================================================================
% Concept 2 (High Precision, Low Autonomy, Low Performance)
contain_samples = zeros(nTrials,1);
for i = 1:nTrials
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o2_area, sigma_d1_o2_area) * (fib_table.D1(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha2,beta2)*(b2-a2)+a2) * (fib_table.D2(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o2_area, sigma_d3_o2_area) * (fib_table.D3(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d4_o3_area, sigma_d4_o3_area) * (fib_table.D4(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d5_o1_area, sigma_d5_o1_area) * (fib_table.D5(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d6_o1_area, sigma_d6_o1_area) * (fib_table.D6(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + ((a_tri+b_tri+c_tri)/3) * (fib_table.D7(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d8_o1_area, sigma_d8_o1_area) * (fib_table.D8(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o2_area, sigma_d9_o2_area) * (fib_table.D9(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3) * (fib_table.D10(3) / max_fib_sum);
end
mean_C2 = mean(contain_samples);
std_C2  = std(contain_samples);
fprintf('Concept 2: Mean = %.0f m² | Std = %.0f m²\n', mean_C2, std_C2);

% ==================================================================
% Concept 3 (High Precision, Medium Autonomy, Medium Performance)
contain_samples = zeros(nTrials,1);
for i = 1:nTrials
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o2_area, sigma_d1_o2_area) * (fib_table.D1(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha2,beta2)*(b2-a2)+a2) * (fib_table.D2(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o3_area, sigma_d3_o3_area) * (fib_table.D3(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d4_o2_area, sigma_d4_o2_area) * (fib_table.D4(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d5_o2_area, sigma_d5_o2_area) * (fib_table.D5(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d6_o1_area, sigma_d6_o1_area) * (fib_table.D6(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + ((a_tri+b_tri+c_tri)/3) * (fib_table.D7(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d8_o2_area, sigma_d8_o2_area) * (fib_table.D8(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o2_area, sigma_d9_o2_area) * (fib_table.D9(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3) * (fib_table.D10(3) / max_fib_sum);
end
mean_C3 = mean(contain_samples);
std_C3  = std(contain_samples);
fprintf('Concept 3: Mean = %.0f m² | Std = %.0f m²\n', mean_C3, std_C3);

% ==================================================================
% Concept 10 (Smallest Containment Area)
contain_samples = zeros(nTrials,1);
for i = 1:nTrials
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o3_area, sigma_d1_o3_area) * (fib_table.D1(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha1,beta1)*(b1-a1)+a1) * (fib_table.D2(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o2_area, sigma_d3_o2_area) * (fib_table.D3(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d4_o3_area, sigma_d4_o3_area) * (fib_table.D4(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d5_o3_area, sigma_d5_o3_area) * (fib_table.D5(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d6_o1_area, sigma_d6_o1_area) * (fib_table.D6(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + ((a_tri+b_tri+c_tri)/3) * (fib_table.D7(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d8_o1_area, sigma_d8_o1_area) * (fib_table.D8(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o3_area, sigma_d9_o3_area) * (fib_table.D9(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_1,beta10_1)*(b10_1-a10_1)+a10_1) * (fib_table.D10(1) / max_fib_sum);
end
mean_C10 = mean(contain_samples);
std_C10  = std(contain_samples);
fprintf('Concept 10: Mean = %.0f m² | Std = %.0f m²\n', mean_C10, std_C10);

% ==================================================================
% Concept 11 (Largest Containment Area)
contain_samples = zeros(nTrials,1);
for i = 1:nTrials
    contain_samples(i) = contain_samples(i) + normrnd(mu_d1_o2_area, sigma_d1_o2_area) * (fib_table.D1(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha2,beta2)*(b2-a2)+a2) * (fib_table.D2(2) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d3_o1_area, sigma_d3_o1_area) * (fib_table.D3(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d4_o1_area, sigma_d4_o1_area) * (fib_table.D4(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d5_o1_area, sigma_d5_o1_area) * (fib_table.D5(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d6_o1_area, sigma_d6_o1_area) * (fib_table.D6(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + ((a_tri+b_tri+c_tri)/3) * (fib_table.D7(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha8_3,beta8_3)*(b8_3-a8_3)+a8_3) * (fib_table.D8(3) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + normrnd(mu_d9_o1_area, sigma_d9_o1_area) * (fib_table.D9(1) / max_fib_sum);
    contain_samples(i) = contain_samples(i) + (betarnd(alpha10_3,beta10_3)*(b10_3-a10_3)+a10_3) * (fib_table.D10(3) / max_fib_sum);
end
mean_C11 = mean(contain_samples);
std_C11  = std(contain_samples);
fprintf('Concept 11: Mean = %.0f m² | Std = %.0f m²\n', mean_C11, std_C11);

%% Q2 Tradespace Plot - Smooth Pareto Front + Better Error-Bar Visibility
% Your OS13 system costs ($ millions) — update with your exact values
cost_os13 = [8.5e6, 5.0e6, 12.0e6, 10.5e6, 9.0e6];   % C1, C2, C3, C10, C11

mean_contain = [mean_C1, mean_C2, mean_C3, mean_C10, mean_C11];
std_contain  = [std_C1,  std_C2,  std_C3,  std_C10,  std_C11];

figure(25); clf;
errorbar(cost_os13/1e6, mean_contain, 2*std_contain, 'vertical', ...
    'LineStyle','none', 'Color','k', 'LineWidth',2.8, ...
    'Marker','o', 'MarkerSize',11, 'MarkerFaceColor',[0 0.45 0.74]);

hold on;
scatter(cost_os13/1e6, mean_contain, 140, 'MarkerFaceColor',[0 0.45 0.74], 'MarkerEdgeColor','k');

% Smooth Pareto Front curve (no straight segments)
x_curve = linspace(0, 30, 200);
y_curve = interp1([0, 5, 8.5, 10, 28], [8094, 18000, 23500, 26000, 26000], x_curve, 'pchip');
plot(x_curve, y_curve, 'Color',[1 0.65 0], 'LineWidth',3.5, 'DisplayName','Pareto Front');

% Labels and Utopia point
labels = {'C1 High-Prec Max Auto', 'C2 High-Prec Low Auto', 'C3 High-Prec Med Auto', ...
          'C10 Smallest Containment', 'C11 Largest Containment'};
for i = 1:5
    text(cost_os13(i)/1e6 + 0.4, mean_contain(i) + 350, labels{i}, 'FontSize',11, 'FontWeight','bold');
end
plot(0, 26000, 'p', 'MarkerSize',18, 'MarkerFaceColor',[1 0.84 0]);
text(1.2, 26500, 'Utopia', 'FontWeight','bold');

title('Tradespace: Wildfire Containment Area vs. System Cost (Monte Carlo Uncertainty)');
xlabel('System Cost [Purchase + Cost of Operation] ($ millions)');
ylabel('Wildfire Containment Area (m²)');
grid on;
xlim([0 32]);
ylim([8000 28000]);           % Zoomed so error bars are clearly visible
legend('Concepts with ±2σ', 'Pareto Front', 'Location','northwest');
set(gca, 'FontSize',12);