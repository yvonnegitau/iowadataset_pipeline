import json
import requests
import pandas as pd


from google.cloud import storage

def get_api_data(month,year):
    print(month,year)
    response = requests.get(f"https://data.iowa.gov/resource/m3tr-qhgy.json?$where=date_extract_m(date)='{month}' and date_extract_y(date)='{year}'")
    print("the response is ", response.status_code)
    if response.status_code == 200:
        print('here.........')
        data = response.json()
        transformed_data = []
        
        
        if data:
            for entries in data:
                if 'store_location' in entries:

                    entries['store_location'] = str(entries['store_location']['coordinates'][0])+","+str(entries['store_location']['coordinates'][0])
                else:
                    entries['store_location'] = None
                transformed_data.append(entries)
            df = pd.DataFrame(transformed_data)
            print(df.head())
            df.to_parquet(f"/opt/iowa/data/data_{year}-{month}.parquet",index=False)

            print("Data saved..........")

def upload_to_gcs(bucket, object_name, local_file):
    """ Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    param bucket: GCS bucket name
    param object_name: target path and file name
    param local_file: source path and file name
    
    return"""
    # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # (Ref: https://github.com/googleapis/python-storage/issues/74)
    storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024* 1024  # 5 MB
    storage.blob._MAX_MULTIPART_SIZE = 5 * 1024* 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)

    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)