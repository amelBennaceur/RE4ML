#%%
import imageio.v3 as iio
import os
import cv2
import threading
import numpy as np
import logging
import matplotlib.pyplot as plt
import multiprocessing
import pandas as pd

# Create a logger
logger = logging.getLogger(__name__)

# Set the level of the logger to DEBUG
logger.setLevel(logging.DEBUG)

# Define a log file directory and log file name
log_dir = '/home/adeptus/dataset/BinarySinglePedestrian/logs'
log_file = 'processing_errors.log'

# Create a file handler to log messages to a file in the specified directory
if not os.path.exists(log_dir):
    os.makedirs(log_dir)
file_handler = logging.FileHandler(os.path.join(log_dir, log_file))

# Create a formatter and set it for the file handler
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# Add the file handler to the logger
logger.addHandler(file_handler)

def error_display(idx, rgb_buffer, mask_buffer):
    cv2.imshow('rgb box', rgb_buffer[idx][0])
    cv2.imshow('seg box', mask_buffer[idx][0])
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def process_file(root_dir, output_dir, file_identifier, yolo_annotations_dir, idx_list):

    video_file_path = os.path.join(root_dir, f"{file_identifier}-0-0.mp4")
    apng_file_path = os.path.join(root_dir, f"{file_identifier}-0-1.apng")

    mask_buffer = []
    rgb_buffer = []

    with iio.imopen(video_file_path, "r", plugin="pyav") as img_file:
        for i in idx_list:
            rgb_frame = img_file.read(index=i)
            rgb_buffer.append((rgb_frame, i))
    # print(f'finished processing: {file_identifier} --- mp4')

    with iio.imopen(apng_file_path, "r", plugin="pyav") as mask_file:
        for idx, i in enumerate(idx_list):
            mask_frame = mask_file.read(index=i)
            mask_buffer.append((mask_frame, i))
    # print(f'finished processing: {file_identifier} --- apng')
    extract_save_bbox(mask_buffer, rgb_buffer, file_identifier, yolo_annotations_dir, output_dir)

def extract_save_bbox(mask_buffer, rgb_buffer, file_identifier, yolo_annotations_dir, output_dir):
    # Define the lower and upper bounds for the red color in RGB
    lower_red_rgb = np.array([200, 0, 50])  # Lower bound for red (with some tolerance)
    upper_red_rgb = np.array([255, 40, 70])  # Upper bound for red (with some tolerance)

    img_height, img_width = 640, 640

    for i in range(len(mask_buffer)):
        mask_idx, mask = mask_buffer[i][1], mask_buffer[i][0]

        # Resize the mask to the desired dimensions
        mask = cv2.resize(mask, (img_width, img_height), interpolation=cv2.INTER_LINEAR)

        # Create a mask for red color
        red_mask = cv2.inRange(mask, lower_red_rgb, upper_red_rgb)

        # Find contours from the red color mask
        contours, _ = cv2.findContours(red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if contours:
            # Assuming the largest contour in the red color mask image is the human
            human_contour = max(contours, key=cv2.contourArea)
            x, y, w, h = cv2.boundingRect(human_contour)

            # Display rectangle bounding box on RGB image
            rgb_image = rgb_buffer[i][0]  # Assuming this is already a numpy array
            rgb_image = cv2.resize(rgb_image, (img_width, img_height), interpolation=cv2.INTER_LINEAR)
            rgb_image = cv2.cvtColor(rgb_image, cv2.COLOR_BGR2RGB)
            # rgb_image_with_bbox = cv2.rectangle(rgb_image.copy(), (x, y), (x + w, y + h), (0, 255, 0), 2)
            
            # Display the image with bounding box using matplotlib
            # plt.figure(figsize=(10, 6))
            # plt.imshow(cv2.cvtColor(rgb_image_with_bbox, cv2.COLOR_BGR2RGB))
            # plt.title(f"RGB Image with Bounding Box - {file_identifier}")
            # plt.axis('off')
            # plt.show()

            # Convert bounding box to YOLO format and save annotation
            x_center, y_center, width_norm, height_norm = convert_to_yolo_format(x, y, w, h, img_width, img_height)
            class_index = 0
            yolo_annotation = f"{class_index} {x_center:.6f} {y_center:.6f} {width_norm:.6f} {height_norm:.6f}"
            frame_filename = f"{file_identifier}_{mask_idx}_frame.txt"
            annotation_path = os.path.join(yolo_annotations_dir, frame_filename)
            with open(annotation_path, 'w+') as file:
                file.write(yolo_annotation + '\n')

            # Assuming iio.imwrite is intended to save the RGB image, let's correct it to use cv2.imwrite
            frame_filename = f"{file_identifier}_{mask_idx}_frame.png"
            frame_path = os.path.join(output_dir, frame_filename)
            cv2.imwrite(frame_path, rgb_image)  # Save the original RGB image, adjust as necessary
        else:
            logger.exception(f"Error processing {mask_idx}_{file_identifier}")

    print(f'finished processing annotations --- {file_identifier}')


def convert_to_yolo_format(x, y, w, h, img_width, img_height):
    # YOLO format values
    x_center = (x + w / 2) / img_width
    y_center = (y + h / 2) / img_height
    width_norm = w / img_width
    height_norm = h / img_height
    return (x_center, y_center, width_norm, height_norm)


def process_images_concurrently(input_dir, output_dir, yolo_annotations_dir, idx_list, filtered_files = None):
    """
    Orchestrates the processing of all video and APNG files within the specified directory,
    extracting and saving frames at specified intervals.
    
    Parameters:
    - input_dir: str. Directory containing the input files.
    - output_dir: str. Directory where processed frames will be saved.
    """
    if filtered_files is None:
        all_files = os.listdir(input_dir)
        file_identifiers = {f.rsplit('-', 2)[0] for f in all_files if f.endswith('.mp4') or f.endswith('.apng')}
    # print(type(file_identifiers))
    else:
        file_identifiers = set(filtered_files)
    threads = []
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    if not os.path.exists(yolo_annotations_dir):
        os.makedirs(yolo_annotations_dir)

    # Setup a multiprocessing pool
    pool = multiprocessing.Pool(processes=(multiprocessing.cpu_count()-8))
    
    # Map process_file tasks to the pool
    pool.starmap(process_file, [(input_dir, output_dir, file_id, yolo_annotations_dir, idx_list) for file_id in file_identifiers])
    
    # Close the pool and wait for all processes to complete
    pool.close()
    pool.join()

    print("Done processing all images.")
#%%
def filter_dataset(dataset_dir = None):
    if dataset_dir is None:
        dataset_dir = '.'


    dataset = pd.read_csv(
        os.path.join(dataset_dir, 'data.csv'),
        index_col=['id', 'camera.idx', 'frame.idx', 'pedestrian.idx'],
        header=0,
    )
    dataset.drop(columns=['frame.pedestrian.transform', 'frame.pedestrian.velocity',
        'frame.pedestrian.pose.world', 'frame.pedestrian.pose.component',
        'frame.pedestrian.pose.relative'], inplace=True)
    # Filter the DataFrame where pedestrian.age = 'child'
    df_filtered = dataset[dataset['pedestrian.age'] == 'child']

    # Only retain the 'id' index
    df_filtered = df_filtered.reset_index(level=['camera.idx', 'frame.idx', 'pedestrian.idx'], drop=True)

    # Reset the index to make 'id' a column
    df_filtered = df_filtered.reset_index()
    df_filtered['pedestrian.gender'].unique()
    id_series_processed = df_filtered.id.apply(lambda x: x.rsplit('-', 1)[0])
    return id_series_processed.to_list()

#%%
# Example usage
filtered_files = None
filtered_files = filter_dataset(None)
input_dir = '/home/adeptus/dataset/BinarySinglePedestrian/clips'
output_dir = '/home/adeptus/dataset/BinarySinglePedestrian/clips_op'  # All frames will be stored here
yolo_annotations_dir = '/home/adeptus/dataset/BinarySinglePedestrian/clips_op_annotations'  # All frames will be stored here
idx_list = [i for i in range(0, 900, 100)]
# process_images_concurrently(input_dir, output_dir, yolo_annotations_dir, idx_list, filtered_files)

import timeit
# Assuming your function definition is available in the script
# Timing the function
execution_time = timeit.timeit(lambda: process_images_concurrently(input_dir, output_dir, yolo_annotations_dir, idx_list, filtered_files), number=1)
print(f"Execution time: {execution_time:.5f} seconds")

# %%
