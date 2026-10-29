# -*- coding: utf-8 -*-
"""
Restore MongoDB full bundle (collections, $jsonSchema validators, indexes, and BSON documents)
from brandhub_mongodb_full_20261029.ejson.

Usage:
  python restore_mongodb.py [MONGODB_URI] [DATABASE_NAME]
"""
import os
import sys
import pymongo
from bson import json_util

DEFAULT_URI = "mongodb+srv://brandhub-mongo:REDACTED_EXPOSED_CREDENTIAL@brandhub.dupoa3v.mongodb.net/?appName=brandhub"
DEFAULT_DB = "brandhub"

def main():
    uri = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("MONGODB_URI", DEFAULT_URI)
    db_name = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("MONGODB_DATABASE", DEFAULT_DB)
    bundle_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "brandhub_mongodb_full_20261029.ejson")

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
