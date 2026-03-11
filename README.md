Full Factorial Tradespace Exploration:

This MATLAB script performs a computationally rigorous, full factorial tradespace exploration for a proposed system. Rather than evaluating a handful of point designs, this code mathematically models every possible architectural combination of the system (19,683 unique concepts).

Using a Monte Carlo simulation engine, it runs 10,000 simulated deployments for each concept (totaling roughly 196.8 million simulated missions) to account for environmental and hardware uncertainties.

The script evaluates two primary competing objectives:

System Cost (Minimize): Hardware procurement, expendability penalties, and flat operational costs.

Wildfire Containment Area (Maximize): The physical square meter coverage the robot swarm can successfully manage, capped at a theoretical maximum of 26,000 m.

The final output is a two-dimensional tradespace that identifies the global Pareto front—the absolute best system concepts that yield the highest containment area per dollar spent—and computes their normalized distance to an ideal 'Utopia' point.
