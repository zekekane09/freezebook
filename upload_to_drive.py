import sys
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

# Path to your service account key file
SERVICE_ACCOUNT_FILE = '/Users/jmrealubit/AndroidStudioProjects/freezebook/lib/freezebook-ab0ba-6993f0ff4072.json'  # Update this path

# Scopes for Google Drive API
SCOPES = ['https://www.googleapis.com/auth/drive.file']

# Folder ID where the file will be uploaded
FOLDER_ID = '1Urt4wAl5MXKX6-xi6CtGgLlEa3LUeig5'  # Update this with your folder ID

def upload_file(file_path):
    try:
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES)

        service = build('drive', 'v3', credentials=credentials)

        file_metadata = {
            'name': os.path.basename(file_path),
            'mimeType': 'application/vnd.android.package-archive',  # Change if needed
            'parents': [FOLDER_ID]  # Specify the folder ID here
        }

        media = MediaFileUpload(file_path, mimetype='application/vnd.android.package-archive')

        file = service.files().create(body=file_metadata, media_body=media, fields='id').execute()
        print(f'Uploaded file ID: {file.get("id")}')
    except HttpError as error:
        print(f'An error occurred: {error}')
    except Exception as e:
        print(f'An unexpected error occurred: {e}')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python upload_to_drive.py <file_path>")
        sys.exit(1)

    upload_file(sys.argv[1])