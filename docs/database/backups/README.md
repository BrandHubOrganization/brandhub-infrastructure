# Local database backups

Database snapshots contain account records, password hashes, messages and authentication material. Keep them in private storage and never add them to Git. Local snapshots are ignored; removing them from the Git index preserves the local files.

`restore_mongodb.py` reads a locally supplied `brandhub_mongodb_full_20261029.ejson` bundle and requires MONGODB_URI in the environment. Obtain backups through an authorized private channel. Restoration drops existing collections; review the script and target database before running it.
