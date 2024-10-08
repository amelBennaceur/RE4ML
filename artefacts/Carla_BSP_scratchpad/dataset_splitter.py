#%%
import os
import shutil
from sklearn.model_selection import train_test_split
#%%
# Paths to your datasets
image_dir = '/home/adeptus/Pictures/RE4ML/mixed_annot/mixed_annot/images'
annotation_dir = '/home/adeptus/Pictures/RE4ML/mixed_annot/mixed_annot/annotations'
output_base_dir = '/home/adeptus/Pictures/RE4ML/mixed_annot/mixed_annot/split_set'

# Create output directories if they don't exist
for split in ['train', 'val', 'test']:
    for folder in ['images', 'annotations']:
        os.makedirs(os.path.join(output_base_dir, folder, split), exist_ok=True)

# # Get a list of filenames without file extensions
# filenames = [os.path.splitext(file)[0] for file in os.listdir(image_dir) if not file.startswith('.')]

allowed_extensions = {'.jpg', '.jpeg', '.png'}
filenames = []

for file in os.listdir(image_dir):
    if not file.startswith('.'):  # Skip hidden or system files
        base_name, extension = os.path.splitext(file)
        if extension.lower() in allowed_extensions:  # Check if the file extension is allowed
            # Place for additional processing on base_name if needed
            filenames.append(base_name)

# Ensure the list is sorted so the split is reproducible
filenames.sort()
#%%
def copy_files(files, src_folder, dst_folder, file_type):
    """
    Copies files of a specific type (extension) from a source folder to a destination folder.
    
    Parameters:
    - files: A list of filenames (without extension) to be copied.
    - src_folder: The source directory where the original files are located.
    - dst_folder: The destination directory where the files should be copied.
    - file_type: The file extension/type to copy (e.g., '.png' for images or '.txt' for annotations).
    """
    for filename in files:
        src_path = os.path.join(src_folder, filename + file_type)  # Use file_type to determine the file extension
        dst_path = os.path.join(dst_folder, filename + file_type)
        shutil.copy(src_path, dst_path)
#%%
# Split filenames into train/val/test with a 90/5/5 split
train_files, test_files = train_test_split(filenames, test_size=0.1, random_state=42)
val_files, test_files = train_test_split(test_files, test_size=0.5, random_state=42)
#%%
# Copy files to their respective directories

# Copy image files
copy_files(train_files, image_dir, os.path.join(output_base_dir, 'images/train'), '.png')
copy_files(val_files, image_dir, os.path.join(output_base_dir, 'images/val'), '.png')
copy_files(test_files, image_dir, os.path.join(output_base_dir, 'images/test'), '.png')

# Copy annotation files
copy_files(train_files, annotation_dir, os.path.join(output_base_dir, 'annotations/train'), '.txt')
copy_files(val_files, annotation_dir, os.path.join(output_base_dir, 'annotations/val'), '.txt')
copy_files(test_files, annotation_dir, os.path.join(output_base_dir, 'annotations/test'), '.txt')


print("Dataset successfully split and copied.")

# %%
