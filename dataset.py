""" 
	download CBFdataset from https://zenodo.org/record/5744336
"""

import os
import requests
import fmatch
from zipfile import ZipFile
import soundfile

# download as .zip
ACCESS_TOKEN = "replace this with your access token"
record_id = "replace this with your record"

r = requests.get(f"https://zenodo.org/api/records/5744336", params={'access_token': ACCESS_TOKEN})
download_urls = [f['links']['self'] for f in r.json()['files']]
filenames = [f['key'] for f in r.json()['files']]

print(download_urls)

for filename, url in zip(filenames, download_urls):
    print("Downloading:", filename)
    r = requests.get(url, params={'access_token': ACCESS_TOKEN})
    with open(filename, 'wb') as f:
        f.write(r.content)

# unzip files into a foler, remove .zip file
!mkdir CBFdataset
with ZipFile('CBFdataset.zip', 'r') as zipObj:  # Create a ZipFile Object and load sample.zip in it
    zipObj.extractall('CBFdataset/')   # Extract all the contents of zip file in current directory
!rm CBFdataset.zip

# check the wav files of the dataset
base_dir = 'CBFdataset/'
target = "*.wav"
wav_files = []  
for path, subdirs, files in os.walk(base_dir):
    for name in files:
        if fnmatch(name, target):
            wav_files.append(os.path.join(path, name))   
print('Number of audio files:', format(len(wav_files)))

# check duration of the dataset
total_len = 0
for k in range(len(wav_files)):
    x, sr = soundfile.read(base_dir + wav_files[k])
    total_len = total_len + x.shape[0]/sr
print("Total duration of the dataset: %.2f h." % (total_len/3600))

# save file names for convenient feature extraction using matlab later
with open('file_names.txt', 'w') as f:
    for item in wav_files:
        f.write("%s\n" % item)