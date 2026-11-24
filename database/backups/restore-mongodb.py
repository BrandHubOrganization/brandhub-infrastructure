# -*- coding: utf-8 -*-
"""
Restore MongoDB full bundle (collections, $jsonSchema validators, indexes, and BSON documents)
from the newest brandhub_mongodb_full_*.ejson in this directory.

Usage:
  Set MONGODB_URI in the environment, then run:
  python restore-mongodb.py [DATABASE_NAME]
"""
import glob
import os
import sys
import pymongo
from bson import json_util

DEFAULT_DB = "brandhub"

def main():
    uri = os.environ.get("MONGODB_URI", "").strip()
    if not uri:
        raise SystemExit("Set MONGODB_URI before running the restore script.")
    uri = uri.strip("'\"")
    db_name = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("MONGODB_DATABASE", DEFAULT_DB)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    bundles = sorted(glob.glob(os.path.join(script_dir, "brandhub_mongodb_full_*.ejson")))
    if not bundles:
        raise SystemExit(f"No brandhub_mongodb_full_*.ejson found in {script_dir}")
    bundle_path = bundles[-1]
    print(f"Restoring {os.path.basename(bundle_path)} into database '{db_name}'")

    with open(bundle_path, "r", encoding="utf-8") as f:
        bundle = json_util.loads(f.read())

    client = pymongo.MongoClient(uri, serverSelectionTimeoutMS=10000)
    db = client[db_name]

    for cname, cdata in bundle["collections"].items():
        if cname in db.list_collection_names():
            db.drop_collection(cname)
        options = cdata.get("options", {})
        create_kwargs = {}
        if "validator" in options:
            create_kwargs["validator"] = options["validator"]
        if "validationLevel" in options:
            create_kwargs["validationLevel"] = options["validationLevel"]
        if "validationAction" in options:
            create_kwargs["validationAction"] = options["validationAction"]
        db.create_collection(cname, **create_kwargs)
        col = db[cname]

        docs = cdata.get("documents", [])
        if docs:
            col.insert_many(docs)

        for idx in cdata.get("indexes", []):
            if idx.get("name") == "_id_":
                continue
            keys = list(idx["key"].items())
            idx_kwargs = {"name": idx["name"]}
            for opt in ("unique", "sparse", "expireAfterSeconds", "partialFilterExpression"):
                if opt in idx:
                    idx_kwargs[opt] = idx[opt]
            col.create_index(keys, **idx_kwargs)

        print(f"[OK] Restored {cname}: {len(docs)} documents, {len(cdata.get('indexes', []))} indexes")

if __name__ == "__main__":
    main()
