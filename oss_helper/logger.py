import config_loader
import kits
import os
import time


def log(*strs):
    file = kits.current_path() + '/' + config_loader.log_file
    file_path = file[:file.rindex('/')]
    if not os.path.exists(file_path):
        os.mkdir(file_path)
    s = time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime())
    for ss in strs:
        s = s + ' ' + ss
    with open(file, 'a+') as f:
        f.write('\n')
        f.write(s)
    f.close()
