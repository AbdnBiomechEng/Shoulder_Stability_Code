# Shoulder Stability Code
This repository contains the code we used to create c3d files from the Vicon system, and convert these data into plain text.

- c3d_from_vicon: the protocol for collecting and post-processing the data, the Vicon labeling skeleton templates and the BodyBuilder model
- c3d_to_plaintext: Matlab code to create:
  - trc files with marker locations (for input into Opensim)
  - csv files with the raw EMG, and processed EMG (normalised envelopes)
  - csv files and mot files (for input into Opensim) with external forces applied to the hand

To read c3d files, we use the [BTK toolkit](https://github.com/Biomechanical-ToolKit), which needs to be included in the Matlab path. 
