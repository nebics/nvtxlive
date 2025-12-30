-- Seed data for NovintiX admin panel
-- Run: npx wrangler d1 execute novintix-db --remote --file=db/seed.sql

-- Create initial admin user
-- Password: admin123 (hashed with salt)
-- To generate a new password hash: node db/hash-password.cjs <password>

-- Note: In production, change this password immediately after first login
-- Format: salt:sha256hash

INSERT OR IGNORE INTO admin_users (email, password_hash, name, role)
VALUES (
  'admin@novintix.com',
  '069cf3800e280cd70303ffb5de80c15c:8cb8dffd929c15c524d93b75d9e9798f48061041c3d401474fb502492fa74834',
  'Admin',
  'super_admin'
);

-- Add a test contact message for development
INSERT OR IGNORE INTO contact_messages (first_name, last_name, email, phone, company, inquiry_type, message, metadata, status)
VALUES (
  'John',
  'Doe',
  'john.doe@example.com',
  '+1-555-123-4567',
  'Acme Corp',
  'General Inquiry',
  'This is a test message to verify the admin panel is working correctly. Please delete after testing.',
  '{"ip": "127.0.0.1", "user_agent": "Test Agent", "location": {"country": "US", "city": "San Francisco"}}',
  'unread'
);
