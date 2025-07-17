-- Seed Data for IIT JU Alumni Association
-- Initial data for development and testing

-- ============================================================================
-- DEPARTMENTS
-- ============================================================================

INSERT INTO departments (name, code, description) VALUES
('Computer Science and Engineering', 'CSE', 'Department of Computer Science and Engineering'),
('Electrical and Electronic Engineering', 'EEE', 'Department of Electrical and Electronic Engineering'),
('Mechanical Engineering', 'ME', 'Department of Mechanical Engineering'),
('Civil Engineering', 'CE', 'Department of Civil Engineering'),
('Chemical Engineering', 'ChE', 'Department of Chemical Engineering'),
('Industrial and Production Engineering', 'IPE', 'Department of Industrial and Production Engineering'),
('Materials and Metallurgical Engineering', 'MME', 'Department of Materials and Metallurgical Engineering'),
('Petroleum and Mining Engineering', 'PME', 'Department of Petroleum and Mining Engineering'),
('Naval Architecture and Marine Engineering', 'NAME', 'Department of Naval Architecture and Marine Engineering'),
('Biomedical Engineering', 'BME', 'Department of Biomedical Engineering'),
('Environmental, Water Resources and Coastal Engineering', 'EWRCE', 'Department of Environmental, Water Resources and Coastal Engineering'),
('Urban and Regional Planning', 'URP', 'Department of Urban and Regional Planning'),
('Architecture', 'ARCH', 'Department of Architecture'),
('Mathematics', 'MATH', 'Department of Mathematics'),
('Physics', 'PHY', 'Department of Physics'),
('Chemistry', 'CHEM', 'Department of Chemistry'),
('Humanities', 'HUM', 'Department of Humanities');

-- ============================================================================
-- BATCH YEARS
-- ============================================================================

INSERT INTO batch_years (year, session_name) VALUES
(2000, '2000-01'),
(2001, '2001-02'),
(2002, '2002-03'),
(2003, '2003-04'),
(2004, '2004-05'),
(2005, '2005-06'),
(2006, '2006-07'),
(2007, '2007-08'),
(2008, '2008-09'),
(2009, '2009-10'),
(2010, '2010-11'),
(2011, '2011-12'),
(2012, '2012-13'),
(2013, '2013-14'),
(2014, '2014-15'),
(2015, '2015-16'),
(2016, '2016-17'),
(2017, '2017-18'),
(2018, '2018-19'),
(2019, '2019-20'),
(2020, '2020-21'),
(2021, '2021-22'),
(2022, '2022-23'),
(2023, '2023-24'),
(2024, '2024-25');

-- ============================================================================
-- SAMPLE USERS AND PROFILES
-- ============================================================================

-- Admin User
INSERT INTO users (username, email, password_hash, first_name, last_name, role, is_email_verified) VALUES
('admin', 'admin@iitju-alumni.org', '$2a$10$example.hash.for.admin.password', 'System', 'Administrator', 'ADMIN', true);

INSERT INTO user_profiles (user_id, bio, is_profile_public) VALUES
(1, 'System Administrator for IIT JU Alumni Association', true);

-- Sample Alumni Users
INSERT INTO users (username, email, password_hash, first_name, last_name, date_of_birth, phone, is_email_verified) VALUES
('john.doe', 'john.doe@example.com', '$2a$10$example.hash.for.password', 'John', 'Doe', '1995-05-15', '+8801712345678', true),
('jane.smith', 'jane.smith@example.com', '$2a$10$example.hash.for.password', 'Jane', 'Smith', '1994-08-22', '+8801787654321', true),
('ahmed.rahman', 'ahmed.rahman@example.com', '$2a$10$example.hash.for.password', 'Ahmed', 'Rahman', '1996-03-10', '+8801698765432', true),
('fatima.khan', 'fatima.khan@example.com', '$2a$10$example.hash.for.password', 'Fatima', 'Khan', '1995-11-28', '+8801534567890', true),
('michael.johnson', 'michael.johnson@example.com', '$2a$10$example.hash.for.password', 'Michael', 'Johnson', '1993-07-14', '+8801445678901', true);

-- Sample User Profiles
INSERT INTO user_profiles (user_id, department_id, batch_year_id, student_id, profession, company, job_title, bio, location, linkedin_url) VALUES
(2, 1, 20, 'CSE180001', 'Software Engineer', 'Google', 'Senior Software Engineer', 'Passionate software engineer working on distributed systems at Google.', 'Mountain View, CA, USA', 'https://linkedin.com/in/johndoe'),
(3, 2, 19, 'EEE170002', 'Hardware Engineer', 'Intel', 'Principal Hardware Engineer', 'Hardware design specialist with focus on processor architecture.', 'Santa Clara, CA, USA', 'https://linkedin.com/in/janesmith'),
(4, 1, 21, 'CSE190003', 'Full Stack Developer', 'Microsoft', 'Software Development Engineer', 'Full-stack developer building cloud solutions at Microsoft Azure.', 'Redmond, WA, USA', 'https://linkedin.com/in/ahmedrahman'),
(5, 3, 18, 'ME160004', 'Mechanical Engineer', 'Tesla', 'Senior Mechanical Engineer', 'Working on electric vehicle design and manufacturing processes.', 'Fremont, CA, USA', 'https://linkedin.com/in/fatimakhan'),
(6, 1, 17, 'CSE150005', 'Tech Lead', 'Facebook', 'Engineering Manager', 'Leading engineering teams building social media platforms.', 'Menlo Park, CA, USA', 'https://linkedin.com/in/michaeljohnson');

-- ============================================================================
-- EVENT CATEGORIES
-- ============================================================================

INSERT INTO event_categories (name, description, color, icon) VALUES
('Networking', 'Professional networking events for alumni', '#3B82F6', 'network'),
('Reunion', 'Batch reunions and homecoming events', '#EF4444', 'users'),
('Career Development', 'Career guidance and professional development', '#10B981', 'briefcase'),
('Technical Talks', 'Technical presentations and knowledge sharing', '#8B5CF6', 'presentation'),
('Social Events', 'Social gatherings and recreational activities', '#F59E0B', 'heart'),
('Fundraising', 'Fundraising events for university development', '#06B6D4', 'dollar-sign'),
('Sports', 'Sports tournaments and athletic events', '#84CC16', 'trophy'),
('Cultural', 'Cultural programs and artistic events', '#EC4899', 'music');

-- ============================================================================
-- SAMPLE EVENTS
-- ============================================================================

INSERT INTO events (title, description, short_description, category_id, organizer_id, event_type, status, start_date, end_date, venue_name, venue_city, venue_country, max_participants, is_public, banner_image_url, slug) VALUES
('IIT JU Alumni Tech Summit 2025', 'Annual technology summit bringing together alumni from tech industry to share insights and network.', 'Join us for the biggest tech gathering of IIT JU alumni.', 4, 1, 'PHYSICAL', 'PUBLISHED', '2025-03-15 09:00:00', '2025-03-15 18:00:00', 'IIT Jahangirnagar University Auditorium', 'Dhaka', 'Bangladesh', 200, true, '/images/events/tech-summit-2025.jpg', 'iit-ju-alumni-tech-summit-2025'),

('CSE Batch 2018 Reunion', 'Reunion event for Computer Science and Engineering batch of 2018.', 'Reconnect with your CSE 2018 classmates after 7 years!', 2, 2, 'HYBRID', 'PUBLISHED', '2025-04-20 15:00:00', '2025-04-20 22:00:00', 'Dhaka Regency Hotel', 'Dhaka', 'Bangladesh', 100, false, '/images/events/cse-2018-reunion.jpg', 'cse-batch-2018-reunion'),

('Career Guidance Workshop', 'Workshop for recent graduates on career planning and job search strategies.', 'Get expert advice on starting your career in tech.', 3, 3, 'VIRTUAL', 'PUBLISHED', '2025-02-28 19:00:00', '2025-02-28 21:00:00', NULL, NULL, NULL, 500, true, '/images/events/career-workshop.jpg', 'career-guidance-workshop'),

('Annual Sports Tournament', 'Inter-batch sports tournament featuring cricket, football, and badminton.', 'Show your sporting spirit and compete with fellow alumni!', 7, 1, 'PHYSICAL', 'PUBLISHED', '2025-05-10 08:00:00', '2025-05-12 18:00:00', 'IIT JU Sports Complex', 'Dhaka', 'Bangladesh', 300, true, '/images/events/sports-tournament.jpg', 'annual-sports-tournament-2025');

-- ============================================================================
-- SAMPLE EVENT REGISTRATIONS
-- ============================================================================

INSERT INTO event_registrations (event_id, user_id, registration_status, payment_status) VALUES
(1, 2, 'CONFIRMED', 'COMPLETED'),
(1, 3, 'CONFIRMED', 'COMPLETED'),
(1, 4, 'PENDING', 'PENDING'),
(2, 2, 'CONFIRMED', 'COMPLETED'),
(3, 2, 'CONFIRMED', 'COMPLETED'),
(3, 3, 'CONFIRMED', 'COMPLETED'),
(3, 4, 'CONFIRMED', 'COMPLETED'),
(3, 5, 'CONFIRMED', 'COMPLETED'),
(4, 2, 'CONFIRMED', 'COMPLETED'),
(4, 6, 'CONFIRMED', 'COMPLETED');

-- ============================================================================
-- GROUP CATEGORIES
-- ============================================================================

INSERT INTO group_categories (name, description, color, icon, display_order) VALUES
('Department', 'Groups organized by academic departments', '#3B82F6', 'graduation-cap', 1),
('Batch', 'Groups for specific graduation batches', '#EF4444', 'calendar', 2),
('Location', 'Groups based on geographical locations', '#10B981', 'map-pin', 3),
('Industry', 'Groups for specific industries or professions', '#8B5CF6', 'briefcase', 4),
('Interest', 'Groups based on hobbies and interests', '#F59E0B', 'heart', 5),
('Project', 'Groups for collaborative projects', '#06B6D4', 'folder', 6);

-- ============================================================================
-- SAMPLE GROUPS
-- ============================================================================

INSERT INTO groups (name, description, short_description, creator_id, visibility, group_type, max_members, slug) VALUES
('CSE Alumni Network', 'Official group for all Computer Science and Engineering alumni to stay connected and share opportunities.', 'Connect with fellow CSE graduates worldwide.', 2, 'PUBLIC', 'DEPARTMENT', 1000, 'cse-alumni-network'),

('IIT JU Silicon Valley', 'Group for IIT JU alumni working in Silicon Valley tech companies.', 'Bay Area alumni networking and meetups.', 3, 'PUBLIC', 'LOCATION', 200, 'iit-ju-silicon-valley'),

('Batch 2019 CSE', 'Private group for CSE batch 2019 graduates.', 'Stay connected with your CSE 2019 classmates.', 4, 'PRIVATE', 'BATCH', 50, 'batch-2019-cse'),

('Startup Founders', 'Group for alumni who have started their own companies or are interested in entrepreneurship.', 'Connect with fellow entrepreneurs and share experiences.', 5, 'PUBLIC', 'INTEREST', 300, 'startup-founders'),

('Photography Enthusiasts', 'Group for alumni who love photography and want to share their work.', 'Share your photography and learn from others.', 6, 'PUBLIC', 'INTEREST', 150, 'photography-enthusiasts');

-- ============================================================================
-- SAMPLE GROUP MEMBERS
-- ============================================================================

INSERT INTO group_members (group_id, user_id, role, status) VALUES
-- CSE Alumni Network
(1, 2, 'CREATOR', 'ACTIVE'),
(1, 3, 'ADMIN', 'ACTIVE'),
(1, 4, 'MEMBER', 'ACTIVE'),

-- IIT JU Silicon Valley
(2, 3, 'CREATOR', 'ACTIVE'),
(2, 2, 'MEMBER', 'ACTIVE'),
(2, 6, 'MEMBER', 'ACTIVE'),

-- Batch 2019 CSE
(3, 4, 'CREATOR', 'ACTIVE'),

-- Startup Founders
(4, 5, 'CREATOR', 'ACTIVE'),
(4, 2, 'MEMBER', 'ACTIVE'),
(4, 6, 'MEMBER', 'ACTIVE'),

-- Photography Enthusiasts
(5, 6, 'CREATOR', 'ACTIVE'),
(5, 3, 'MEMBER', 'ACTIVE'),
(5, 5, 'MEMBER', 'ACTIVE');

-- ============================================================================
-- SAMPLE USER CONNECTIONS
-- ============================================================================

INSERT INTO user_connections (requester_id, addressee_id, status, connection_type, requested_at, responded_at) VALUES
(2, 3, 'ACCEPTED', 'PROFESSIONAL', '2024-01-15 10:00:00', '2024-01-15 14:30:00'),
(2, 4, 'ACCEPTED', 'PROFESSIONAL', '2024-02-20 09:15:00', '2024-02-20 16:45:00'),
(3, 5, 'ACCEPTED', 'PROFESSIONAL', '2024-03-10 11:30:00', '2024-03-11 08:20:00'),
(4, 6, 'PENDING', 'PROFESSIONAL', '2024-12-01 14:00:00', NULL),
(5, 2, 'ACCEPTED', 'PERSONAL', '2024-11-15 16:30:00', '2024-11-16 09:00:00');

-- ============================================================================
-- NOTIFICATION TEMPLATES
-- ============================================================================

INSERT INTO notification_templates (template_key, name, description, subject_template, body_template, category, supports_email, supports_push, supports_in_app) VALUES
('connection_request', 'Connection Request', 'Notification when someone sends a connection request', 'New Connection Request from {{requester_name}}', '{{requester_name}} wants to connect with you on IIT JU Alumni Network.', 'SOCIAL', true, true, true),

('event_reminder', 'Event Reminder', 'Reminder notification for upcoming events', 'Reminder: {{event_title}} is tomorrow', 'Don''t forget about {{event_title}} starting at {{start_time}} on {{start_date}}.', 'EVENTS', true, true, true),

('group_invitation', 'Group Invitation', 'Notification when invited to join a group', 'You''re invited to join {{group_name}}', '{{inviter_name}} has invited you to join the group "{{group_name}}".', 'SOCIAL', true, true, true),

('message_received', 'New Message', 'Notification for new direct messages', 'New message from {{sender_name}}', 'You have received a new message from {{sender_name}}.', 'MESSAGES', false, true, true),

('event_registration_confirmed', 'Event Registration Confirmed', 'Confirmation of event registration', 'Registration confirmed for {{event_title}}', 'Your registration for {{event_title}} has been confirmed. Event details: {{event_details}}', 'EVENTS', true, false, true);

-- ============================================================================
-- SYSTEM SETTINGS
-- ============================================================================

INSERT INTO system_settings (key, value, description, is_public) VALUES
('site_name', 'IIT JU Alumni Association', 'Name of the alumni association website', true),
('site_description', 'Official alumni network for IIT Jahangirnagar University graduates', 'Description of the website', true),
('contact_email', 'contact@iitju-alumni.org', 'Main contact email address', true),
('max_file_upload_size', '10485760', 'Maximum file upload size in bytes (10MB)', false),
('session_timeout_minutes', '1440', 'Session timeout in minutes (24 hours)', false),
('password_min_length', '8', 'Minimum password length requirement', false),
('enable_email_notifications', 'true', 'Enable email notifications system-wide', false),
('enable_push_notifications', 'true', 'Enable push notifications system-wide', false),
('maintenance_mode', 'false', 'Enable maintenance mode', false),
('registration_open', 'true', 'Allow new user registrations', false);

-- ============================================================================
-- SAMPLE CONVERSATIONS AND MESSAGES
-- ============================================================================

-- Create direct conversations
INSERT INTO conversations (conversation_type, created_by) VALUES
('DIRECT', 2),
('DIRECT', 3);

-- Add conversation participants
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
(1, 2), (1, 3),  -- John and Jane
(2, 3), (2, 4);  -- Jane and Ahmed

-- Sample messages
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(1, 2, 'Hey Jane! How are you doing?'),
(1, 3, 'Hi John! I''m doing great. Just started a new project at Intel.'),
(1, 2, 'That''s awesome! What kind of project?'),
(2, 3, 'Hi Ahmed! Saw your post about the Microsoft job. Congratulations!'),
(2, 4, 'Thanks Jane! Really excited about this opportunity.');

-- ============================================================================
-- SAMPLE NOTIFICATIONS
-- ============================================================================

INSERT INTO notifications (user_id, type, title, message, related_entity_type, related_entity_id, category) VALUES
(2, 'connection_request', 'New Connection Request', 'Ahmed Rahman wants to connect with you.', 'USER', 4, 'SOCIAL'),
(3, 'event_reminder', 'Event Reminder', 'IIT JU Alumni Tech Summit 2025 is tomorrow at 9:00 AM.', 'EVENT', 1, 'EVENTS'),
(4, 'group_invitation', 'Group Invitation', 'You have been invited to join CSE Alumni Network.', 'GROUP', 1, 'SOCIAL'),
(5, 'message_received', 'New Message', 'You have a new message from Michael Johnson.', 'MESSAGE', 5, 'MESSAGES');

-- Create notification preferences for all users
INSERT INTO notification_preferences (user_id) VALUES (2), (3), (4), (5), (6);

-- ============================================================================
-- UPDATE SEQUENCES
-- ============================================================================

-- Update sequences to avoid conflicts with manually inserted IDs
SELECT setval('departments_id_seq', (SELECT MAX(id) FROM departments));
SELECT setval('batch_years_id_seq', (SELECT MAX(id) FROM batch_years));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('user_profiles_id_seq', (SELECT MAX(id) FROM user_profiles));
SELECT setval('event_categories_id_seq', (SELECT MAX(id) FROM event_categories));
SELECT setval('events_id_seq', (SELECT MAX(id) FROM events));
SELECT setval('event_registrations_id_seq', (SELECT MAX(id) FROM event_registrations));
SELECT setval('group_categories_id_seq', (SELECT MAX(id) FROM group_categories));
SELECT setval('groups_id_seq', (SELECT MAX(id) FROM groups));
SELECT setval('group_members_id_seq', (SELECT MAX(id) FROM group_members));
SELECT setval('user_connections_id_seq', (SELECT MAX(id) FROM user_connections));
SELECT setval('notification_templates_id_seq', (SELECT MAX(id) FROM notification_templates));
SELECT setval('system_settings_id_seq', (SELECT MAX(id) FROM system_settings));
SELECT setval('conversations_id_seq', (SELECT MAX(id) FROM conversations));
SELECT setval('conversation_participants_id_seq', (SELECT MAX(id) FROM conversation_participants));
SELECT setval('messages_id_seq', (SELECT MAX(id) FROM messages));
SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications));
SELECT setval('notification_preferences_id_seq', (SELECT MAX(id) FROM notification_preferences));

