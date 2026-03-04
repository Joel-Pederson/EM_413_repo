%EM.413 OS14 Question 1 Decision Aid
% Allows manipulation and visualization of probability density functions to
% support EM.413 OS14 Q1

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);

%% -- Decision 2:
% -- Option 1: Containerized Guided Drone --
% Beta Dist: Alpha = 8, Beta = 2. Bounds: 20k to 26k
alpha1 = 8; beta1 = 2;
a1 = 24000; b1 = 26000;
x_norm1 = (x - a1) / (b1 - a1); % Normalize x to [0,1]
x_norm1(x_norm1 < 0 | x_norm1 > 1) = NaN; % Ignore values outside bounds
y1 = betapdf(x_norm1, alpha1, beta1) / (b1 - a1); % Calculate PDF and scale height

% -- Option 2: Precision Guided Parafoil ---
% Beta Dist: Alpha = 5, Beta = 2. Bounds: 10k to 26k
alpha2 = 5; beta2 = 2;
a2 = 22000; b2 = 26000;
x_norm2 = (x - a2) / (b2 - a2);
x_norm2(x_norm2 < 0 | x_norm2 > 1) = NaN; 
y2 = betapdf(x_norm2, alpha2, beta2) / (b2 - a2);

% -- Option 3: Ramp Extraction / Airbag --
% Normal Dist: Mu = 14,000, Sigma = 4,000
mu3 = 14000; sigma3 = 4000;
y3 = normpdf(x, mu3, sigma3);

% -- Plotting the Distributions --
figure;
plot(x, y1, 'b', 'LineWidth', 2, 'DisplayName', 'Guided Drone (Beta)');
hold on;
plot(x, y2, 'r', 'LineWidth', 2, 'DisplayName', 'Parafoil (Beta)');
plot(x, y3, 'g', 'LineWidth', 2, 'DisplayName', 'Airbag (Normal)');
title('Containment Area PDFs (D2: Insertion Method)');
xlabel('Containment Area (m^2)');
ylabel('Probability Density');
legend('Location', 'NorthWest');
grid on;
xlim([0 30000]);

% -- Remove Scientific Notation & Format Axes --
ax = gca; % Get the current axes
ax.XAxis.Exponent = 0; % Turn off scientific notation on X
ax.YAxis.Exponent = 0; % Turn off scientific notation on Y
% Add commas to the X-axis numbers for readability (e.g., 30,000)
xtickformat('%,.0f'); 
ytickformat('%.5f'); % Forces Y-axis to show standard decimals

fprintf('\n--- D2 Containment Statistics (For Q1c Table) ---\n');

% Calculate Option 1 (Guided Drone)
mu_std1 = alpha1 / (alpha1 + beta1);
var_std1 = (alpha1 * beta1) / ((alpha1 + beta1)^2 * (alpha1 + beta1 + 1));
mu_scaled1 = a1 + (mu_std1 * (b1 - a1));
sigma_scaled1 = sqrt(var_std1 * (b1 - a1)^2);
fprintf('Option 1 (Drone):    Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_scaled1, sigma_scaled1);

% Calculate Option 2 (Parafoil)
mu_std2 = alpha2 / (alpha2 + beta2);
var_std2 = (alpha2 * beta2) / ((alpha2 + beta2)^2 * (alpha2 + beta2 + 1));
mu_scaled2 = a2 + (mu_std2 * (b2 - a2));
sigma_scaled2 = sqrt(var_std2 * (b2 - a2)^2);
fprintf('Option 2 (Parafoil): Mu = %.0f m^2 | Sigma = %.0f m^2\n', mu_scaled2, sigma_scaled2);

% Print Option 3 (Airbag - already known, just formatting for consistency)
fprintf('Option 3 (Airbag):   Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu3, sigma3);

%% Decision X