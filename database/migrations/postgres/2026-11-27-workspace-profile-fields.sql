-- Add TikTok & Threads profile links and widen description/logo_url on workspaces
ALTER TABLE workspaces ADD COLUMN IF NOT EXISTS tiktok_url VARCHAR(255);
ALTER TABLE workspaces ADD COLUMN IF NOT EXISTS threads_url VARCHAR(255);
ALTER TABLE workspaces ALTER COLUMN logo_url TYPE VARCHAR(512);
ALTER TABLE workspaces ALTER COLUMN banner_url TYPE VARCHAR;
ALTER TABLE workspaces ALTER COLUMN description TYPE VARCHAR(4000);
