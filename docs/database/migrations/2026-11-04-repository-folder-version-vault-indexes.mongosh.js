// Run against the intended database only after backup. No live migration is executed by this change.
// Existing databases also need this prerequisite from init-mongo.js.
db.material_upload_sessions.createIndex({workspace_id:1,staging_key:1},{name:'uq_repository_session_key',unique:true});
db.material_folders.createIndex({scope_type:1,workspace_id:1,parent_folder_id:1,normalized_name:1},{name:'uq_workspace_folder_name',unique:true,partialFilterExpression:{scope_type:'WORKSPACE',deleted_at:null}});
db.material_folders.createIndex({scope_type:1,owner_user_id:1,parent_folder_id:1,normalized_name:1},{name:'uq_vault_folder_name',unique:true,partialFilterExpression:{scope_type:'CLIENT_VAULT',deleted_at:null}});
db.material_folders.createIndex({ancestor_ids:1});
db.materials.createIndex({workspace_id:1,folder_id:1,deleted_at:1,sort_key:1,normalized_name:1,created_at:-1});
db.materials.createIndex({scope_type:1,owner_user_id:1,folder_id:1,deleted_at:1});
db.materials.createIndex({ancestor_folder_ids:1});
db.materials.createIndex({workspace_id:1,content_hash:1});
db.material_versions.createIndex({material_id:1,version_number:1},{unique:true});
db.client_vault_shares.createIndex({workspace_id:1,owner_user_id:1,resource_type:1,resource_id:1},{unique:true});
// sort_key uses the Java vi-VN Collator and needs the matching application backfill; raw Unicode is not equivalent.
