# RGBE-Gaze:Journey Towards High Frequency Remote Gaze Tracking with Event Cameras
## Dataset Organization

The **RGBE_Gaze_dataset** folder consists of the data generated by FLIR BFS-U3-16S2C RGB camera (RGB Images), Prophesee EVK4 event camera (Event Streams), Gazepoint GP3 HD (Gaze References) and mouse click positions on the screen (Sparse PoG ground truth).

This directory contains 66 subdirectories corresponding to 66 participants i.e., user_1-user_66. For each participant, the six sessions' data is contained in six separate directory i.e., exp1-exp6. Within each session directory, you will find a `convert2eventspace` folder containing RGB Images, a `prophesee` folder containing the Event Stream, a `gazepoint` folder containing Gaze References, and a `click_gt_cpu.txt` text file recording Mouse Click Positions alongside corresponding windows CPU timestamps.

  ```
 ─ RGBE_Gaze_dataset
├─user_1
│ ├─eye
│ │ ├─exp1
│ │ │ │ ├─convert2eventspace
│ │ │ │ ├─prophesee
│ │ │ │ ├─gazepoint
│ │ │ │ ├─click_gt_cpu.txt
│ │ │ ├─exp2
│ │ │ │ ..........
│ │ │ └─exp6
├─user_2
..........
├─user_66
  ```
--------------------

#### 1. convert2eventspace
**convert2eventspace** folder offers the RGB Images converted from the raw RGB Images using the homography matrix T_{h} i.e., 'matlab_processed/align_frame_event_pixel/tform_total.mat', the homography matrix T_{h} is calculated using the code 'matlab_processed/align_frame_event_pixel/twoimage_homography.m', and the code transforms the 66 participant's raw RGB Images to align the event stream's space is presented in  'matlab_processed/align_frame_event_pixel/transfer_image_homography.m'. 

In addition, the **convert2eventspace** folder include three '.txt' file.
- **timestamp.txt** records the internal hardware timestamp provided by FLIR BFS-U3-16S2C.
- **timestamp_win.txt** records the Windows system time provided by function 'time.time()' in Python, the first two lines represent the moments before and after the FLIR camera acquisition interface is activated.
- **timestamp_cpu.txt** records the CPU timestamp provided by function 'cv2.getTickCount' of opencv, the first two lines also represent the moments before and after the FLIR camera acquisition interface is activated.


#### 2. prophesee
**prophesee** folder offers **event_merge.npz**, it provides a record of the event stream in the npz form.
In addition, the **prophesee** folder include two '.txt' file.
- **event_win.txt** records the Windows system time provided by function 'time.time()' in Python, the first two lines represent the moments before and after the prophesee camera acquisition interface is activated, and the last two line represent the moment when the first event and the last event are recorded.
- **event_cpu.txt** records the CPU timestamp provided by function 'cv2.getTickCount' of OpenCV, the first two lines also represent the moments before and after the prophesee camera acquisition interface is activated, and the last two line represent the moment when the first event and the last event are recorded.


#### 3. gazepoint
**gazepoint** folder offers **gazepoint.csv**, the introduction of different type of gaze reference data can be found in  (https://usabilityin.ru/wp-content/uploads/2017/12/Gazepoint-API.pdf).

In addition, the **gazepoint** folder include another two '.txt' file.
- **time_win.txt** records the Windows system time provided by function 'time.time()' in Python, the second line represents the moment when the computer received the first ACK message of gazepoint.
- **time_cpu.txt** records the CPU timestamp provided by function 'cv2.getTickCount' of OpenCV, the second line represents the moment when the computer received the first ACK message of gazepoint.


<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />
This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons
Attribution-NonCommercial 4.0 International License</a>.
