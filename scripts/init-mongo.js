// MongoDB init script — runs inside mongosh on first container start
db = db.getSiblingDB('brandhub');

// Collections with validators
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'email', 'password', 'role', 'isActive'],
      properties: {
        email: { bsonType: 'string' },
        role: { enum: ['ADMIN', 'AGENCY_OWNER', 'ACCOUNT_MANAGER', 'CONTENT_CREATOR', 'BRAND_CLIENT'] },
        isActive: { bsonType: 'bool' },
      },
    },
  },
});

db.createCollection('workspaces');
db.createCollection('clients');
db.createCollection('social_accounts');
db.createCollection('content_requests');
db.createCollection('posts');
db.createCollection('campaigns');
db.createCollection('knowledge_documents');
db.createCollection('notifications');

// Indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ workspaceId: 1 });
db.users.createIndex({ role: 1 });

db.workspaces.createIndex({ ownerId: 1 });

db.clients.createIndex({ workspaceId: 1 });
db.clients.createIndex({ accountManagerId: 1 });

db.social_accounts.createIndex({ workspaceId: 1, clientId: 1 });
db.social_accounts.createIndex({ tokenExpiresAt: 1 });

db.content_requests.createIndex({ workspaceId: 1, status: 1 });
db.content_requests.createIndex({ clientId: 1 });
db.content_requests.createIndex({ assignedTo: 1 });

db.posts.createIndex({ workspaceId: 1, status: 1 });
db.posts.createIndex({ clientId: 1 });
db.posts.createIndex({ scheduledAt: 1, status: 1 });

db.knowledge_documents.createIndex({ workspaceId: 1, clientId: 1 });

db.notifications.createIndex({ userId: 1, isRead: 1 });
db.notifications.createIndex({ createdAt: -1 });

print('BrandHub MongoDB initialized.');
