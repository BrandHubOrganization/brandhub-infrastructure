"""Add repository indexes without resetting data or replacing newer Trash validators. Dry-run by default."""
import argparse
from pathlib import Path
from pymongo import MongoClient

parser = argparse.ArgumentParser()
parser.add_argument('--apply', action='store_true')
parser.add_argument('--env-file', type=Path,
                    default=Path(__file__).resolve().parents[4] / 'brandhub-business-service' / '.env')
args = parser.parse_args()
settings = {}
for line in args.env_file.read_text(encoding='utf-8-sig').splitlines():
    if '=' in line and not line.lstrip().startswith('#'):
        key, value = line.split('=', 1)
        settings[key.strip()] = value.strip().strip('"').strip("'")

specs = [
    ('materials', 'idx_repository_scope_ready', [('workspace_id', 1), ('status', 1),
        ('deleted_at', 1), ('created_at', -1), ('_id', -1)], {}),
    ('materials', 'uq_repository_provider_key', [('storage_provider', 1), ('s3_key', 1)],
        {'unique': True, 'partialFilterExpression': {'storage_provider': {'$type': 'string'}, 's3_key': {'$type': 'string'}}}),
    ('material_upload_sessions', 'uq_repository_session_key', [('workspace_id', 1), ('staging_key', 1)], {'unique': True}),
    ('material_upload_sessions', 'idx_repository_session_recovery', [('state', 1), ('expires_at', 1)], {}),
    ('material_references', 'uq_repository_reference', [('workspace_id', 1), ('material_id', 1), ('source_id', 1)], {'unique': True}),
]

try:
    with MongoClient(settings['MONGODB_URI'], serverSelectionTimeoutMS=10000) as client:
        db = client[settings.get('MONGODB_DATABASE', 'brandhub')]
        hello = client.admin.command('hello')
        if not (hello.get('setName') or hello.get('msg') == 'isdbgrid'):
            raise RuntimeError('Mongo transactions are unavailable')
        names = db.list_collection_names()
        # Complete preflight before creating any indexes. Reject incompatible definitions or duplicate keys.
        for collection, name, keys, options in specs:
            existing = list(db[collection].list_indexes()) if collection in names else []
            current = next((item for item in existing if item['name'] == name), None)
            if current and (list(current['key'].items()) != keys or bool(current.get('unique')) != bool(options.get('unique'))
                            or current.get('partialFilterExpression') != options.get('partialFilterExpression')):
                raise RuntimeError('Conflicting index: ' + name)
            if options.get('unique'):
                stages = []
                if options.get('partialFilterExpression'):
                    stages.append({'$match': options['partialFilterExpression']})
                stages.extend([{'$group': {'_id': {key: '$' + key for key, _ in keys}, 'count': {'$sum': 1}}},
                               {'$match': {'count': {'$gt': 1}}}, {'$limit': 1}])
                if list(db[collection].aggregate(stages)):
                    raise RuntimeError('Duplicate keys must be reconciled before creating ' + name)
        for collection, name, keys, options in specs:
            if args.apply:
                db[collection].create_index(keys, name=name, **options)
            print(('VERIFIED ' if args.apply else 'DRY_RUN ') + name)
except Exception as error:
    # Driver exceptions may contain the connection URI or user data. Keep logs sanitized.
    if isinstance(error, RuntimeError):
        print(str(error))
    else:
        print('Migration failed: ' + type(error).__name__)
    raise SystemExit(1)
