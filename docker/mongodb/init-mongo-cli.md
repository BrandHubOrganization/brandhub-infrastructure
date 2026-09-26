# MongoDB Atlas CLI

## 1. Connect

```powershell
docker run --rm -it `
  --mount "type=bind,source=D:\capstone\brandhub\brandhub-infrastructure\docs\database,target=/scripts,readonly" `
  mongo:7 mongosh `
  "mongodb+srv://brandhub.dupoa3v.mongodb.net/?appName=brandhub" `
  --username brandhub-mongo `
  --authenticationDatabase admin
```

# Điền password <!-- 3TfyH74Nz.gxmZH -->

## 2. Initialize

```javascript
load("/scripts/init-mongo.js");
```

## 3. List collections

```javascript
db.getSiblingDB("brandhub").getCollectionNames();
```
