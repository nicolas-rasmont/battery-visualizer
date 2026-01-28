# Battery Visualizer

MATLAB tools for visualizing and comparing battery electrochemical impedance spectroscopy (EIS) data and charge/discharge curves.

## Project Structure

```
battery_visualizer/
├── shared_utils/               # Shared utility functions
│   ├── ceilsig.m              # Ceiling to N significant digits
│   ├── floorsig.m             # Floor to N significant digits
│   └── nice_axis_limits.m     # Create nicely rounded axis limits
│
├── single_viz_lib/            # Single battery visualization library
│   ├── batteryEISSummaryReader.m   # Read battery EIS summary files
│   ├── EISSOCScanReader.m          # Read EIS scans at various SOC levels
│   ├── chargeDataReader.m          # Read charge/discharge data
│   ├── EISVisualizer.m             # Basic EIS visualizer GUI
│   ├── EISVisualizerWithCharge.m   # EIS visualizer with charge data overlay
│   └── [other plotting/UI utilities]
│
├── comparator_lib_v3/         # Multi-battery comparison library (current version)
│   ├── BatteryEISandChargeComparator.m  # Main comparator GUI
│   ├── addBattery.m                # Add battery to comparison
│   ├── batchImport.m               # Batch import multiple datasets
│   ├── plotEISOverlay.m            # Overlay EIS plots
│   ├── plotEISSideBySide.m         # Side-by-side EIS comparison
│   └── [other UI/plotting functions]
│
├── baseline_comparator_lib_v2/  # Baseline test comparison library
│   ├── compareBaselineGUI.m     # Multi-window baseline comparison GUI
│   ├── readBaseline.m           # Recursive baseline data reader
│   └── [other utilities]
│
├── Thermal_Runaway_Ramp/      # Thermal analysis tools
│   ├── Thermal_RampGUI.m          # Thermal ramp comparison GUI
│   └── compareThermalRampRunawayGUI.m
│
├── battery data/              # Test data directory
│
├── battery_comparator_main.m      # Entry point: multi-battery comparator
├── baseline_comparator_main.m     # Entry point: baseline test comparator
├── battery_visualizer_main.m      # Entry point: single battery visualizer
├── example_usage.m                # Example: MPT file parsing
├── parse_mpt_file.m               # EC-Lab .mpt file parser
└── readmpt.m                      # Data analysis using MPT parser
```

## Quick Start

### Single Battery Visualization
```matlab
% View EIS and charge data for a single battery
battery_visualizer_main
```

### Multi-Battery Comparison (Recommended)
```matlab
% Launch the interactive multi-battery comparator
battery_comparator_main
```
This opens a GUI where you can:
- Add multiple battery datasets
- Compare EIS plots (overlay or side-by-side)
- Navigate through SOC levels with a slider
- Export views for reports

### Baseline Test Comparison
```matlab
% Edit baseline_comparator_main.m to specify your data paths, then run:
baseline_comparator_main
```

## Data Formats

### EIS Data Structure
The comparator expects directories containing:
- `summary.txt` or `summary.ini` - Experiment metadata
- Phase subdirectories (`phase_1/`, `phase_2/`, etc.)
- EIS measurements in `eis_measurements/` with `details_XX.txt` files
- Charge/discharge CSV files

### MPT Files
The `parse_mpt_file.m` function reads EC-Lab .mpt ASCII files exported from BioLogic instruments.

## Library Details

### shared_utils/
Utility functions used across all libraries:
- **ceilsig(x, n)** - Ceiling to N significant digits
- **floorsig(x, n)** - Floor to N significant digits
- **nice_axis_limits(xlimits, ylimits, options)** - Calculate clean axis limits for plots

### single_viz_lib/
For visualizing data from a single battery test:
- Nyquist plots at various SOC levels
- Bode plots (magnitude and phase)
- Charge/discharge curves with SOC markers
- Interactive navigation between SOC points

### comparator_lib_v3/
For comparing multiple batteries:
- Overlay mode: all batteries on same axes
- Side-by-side mode: separate plots per battery
- SOC slider for synchronized navigation
- Batch import from multiple directories
- Export functionality

### baseline_comparator_lib_v2/
For comparing baseline test series:
- Multi-window display (5 simultaneous views)
- Curve family visualizations
- Thermal analysis integration

### Thermal_Runaway_Ramp/
Specialized tools for thermal runaway analysis and temperature ramp comparisons.

## Dependencies

- MATLAB R2019b or later (for uifigure components)
- No external toolboxes required

## Usage Notes

1. All main entry points (`*_main.m`) automatically set up the required paths
2. Data paths in `baseline_comparator_main.m` need to be updated for your environment
3. The comparator GUI supports drag-and-drop style workflow via "Add Battery" button

## Architecture

The codebase follows a modular MVC-like pattern:
- **Readers** (Model): Parse data files into MATLAB structures
- **GUI creators** (View): Build figure windows with UI components
- **Callbacks** (Controller): Handle user interactions and update displays

State management uses `setappdata`/`getappdata` to store data associated with each figure window.
