import config_loader
import oss2

from oss2 import Bucket


def get_bucket() -> Bucket:
    auth = oss2.Auth(config_loader.oss_access_key_id, config_loader.oss_access_key_secret)
    return oss2.Bucket(auth, config_loader.oss_endpoint, config_loader.oss_bucket_name)
