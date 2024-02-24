import kits
import yaml


def __load_config():
    current_path = kits.current_path()
    f = open(current_path + '/config.yaml')
    y = yaml.load(f, Loader=yaml.FullLoader)
    f.close()
    return y


def is_oss_valid(oss_config: dict) -> bool:
    access_key_id = oss_config['access_key_id']
    access_key_secret = oss_config['access_key_secret']
    endpoint = oss_config['endpoint']
    bucket_name = oss_config['bucket_name']
    return access_key_id is not None and len(access_key_id) > 0 and access_key_secret is not None and len(
        access_key_secret) > 0 and endpoint is not None and len(endpoint) > 0 and bucket_name is not None and len(
        bucket_name) > 0


configurations = __load_config()
oss_configurations = configurations['oss']
oss_access_key_id = oss_configurations['access_key_id']
oss_access_key_secret = oss_configurations['access_key_secret']
oss_endpoint = oss_configurations['endpoint']
oss_bucket_name = oss_configurations['bucket_name']

log_file = configurations['log']['file']
