# DC State Estimation in Power Systems

This MATLAB code is developed for performing DC state estimation in power systems. The purpose of this code is to estimate the state of a power system network based on input parameters such as bus and line data, slack bus, and power base values.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Inputs](#inputs)
- [Output](#output)
- [Notes](#notes)
- [Authors](#authors)
- [License](#license)

## Overview

DC State Estimation is a technique used to calculate the electrical states (e.g., voltages and angles) of buses in a power network under direct current (DC) assumptions. This script takes various input parameters including bus and line data, performs state estimation, and provides estimated values that can be used for system analysis.

## Features

- Calculates state estimation based on line and bus data.
- Handles slack bus identification and base power adjustments.
- Allows configuration of measurement accuracy and error.

## Installation

1. Ensure you have MATLAB installed.
2. Clone or download this repository.
3. Place `main.m` in your MATLAB working directory.

## Usage

1. Open MATLAB.
2. Set the appropriate input values in `main.m` (see **Inputs** section).
3. Run the script:
   ```matlab
   main
## Inputs
-	**line_data** : A matrix containing line parameters:

	*	**Column 1**: From bus
	*	**Column 2**: To bus
	*	**Column 3**: Resistance (R) in per unit (PU)
	*	**Column 4**: Reactance (X) in per unit (PU)
-	**slack_bus**: Specifies the bus number that acts as the slack bus for reference.

-	**s_base_mw**: Base power value in megawatts (MW).

-	**accuracy_mw**: Measurement accuracy in MW for the estimation process.

-	**sigma**: Constant value for adjusting accuracy.
```matlab
line_data = [1, 2, 0, 0.1;
             1, 3, 0, 0.071;
             2, 3, 0, 0.25;];
slack_bus = 3;
s_base_mw = 100;
accuracy_mw = 3;
sigma = 3;
```
## Output
The script outputs the estimated states of the power network, displaying voltage angles and other relevant parameters after performing the state estimation.
## Notes
-	**Input Format**: Ensure that input data for line and bus parameters are provided exactly as shown in the example. The order of data and direction (e.g., P12 vs. P21) should match the expected input format.
-	**Accuracy Configuration**: Adjust the accuracy_mw and sigma values as needed for different precision requirements.
## Authors
-	[Ali Bahrami Fard](https://github.com/AliBahramiFard81)
## License
This project is licensed under the [MIT] License
