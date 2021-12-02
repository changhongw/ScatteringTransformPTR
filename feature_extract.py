

from scipy.io import savemat
import numpy as np
import soundfile
import librosa
from tqdm import tqdm

# F0 trajectory extraction
frame_length = 2048; hop_length = 128
f0 = {'file'+str(k):[] for k in range(len(wav_files))}

t0 = time.time()
for k in tqdm(range(len(wav_files))):
    y, sr = soundfile.read(wav_files[k])
    y = np.mean(y, 1)
    f0_file, voiced_flag, voiced_probs = librosa.pyin(y, fmin=librosa.note_to_hz('C2'), fmax=librosa.note_to_hz('C8'), sr=sr,
                                                     frame_length = frame_length, hop_length = hop_length)
    f0['file'+str(k)] = f0_file

savemat("F0_trajectory_default_C2C8_hop128.mat", f0)
print('F0 extraction time:%.2f hours.' % ((time.time() - t0)/3600))


# extract AdaTS+AdaTRS feature in matlab
t0 = time.time()
!octave -W feature_extract/AdaTS_AdaTRS_PMT_extraction.m
print('Feature extraction time:%.2f hours.' % ((time.time() - t0)/3600))

# extract dJTFS-avg feature in matlab
t0 = time.time()
!octave -W feature_extract/dJTFS_avg_PET_extraction.m
print('Feature extraction time:%.2f hours.' % ((time.time() - t0)/3600))