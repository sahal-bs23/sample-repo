-- Initial database setup for IIT JU Alumni Association
-- This script runs when the PostgreSQL container starts for the first time

-- Create database if not exists (handled by Docker environment variables)
-- CREATE DATABASE alumni_db;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Create custom types
CREATE TYPE user_role AS ENUM ('GUEST', 'ALUMNI', 'ADMIN');
CREATE TYPE event_status AS ENUM ('DRAFT', 'PUBLISHED', 'CANCELLED', 'COMPLETED');
CREATE TYPE group_visibility AS ENUM ('PUBLIC', 'PRIVATE');
CREATE TYPE message_type AS ENUM ('TEXT', 'IMAGE', 'VIDEO', 'AUDIO', 'FILE');
CREATE TYPE call_type AS ENUM ('AUDIO', 'VIDEO');
CREATE TYPE call_status AS ENUM ('INITIATED', 'RINGING', 'CONNECTED', 'ENDED', 'MISSED');
CREATE TYPE payment_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS user_id_seq START 1000;
CREATE SEQUENCE IF NOT EXISTS event_id_seq START 1000;
CREATE SEQUENCE IF NOT EXISTS group_id_seq START 1000;

-- Create indexes for better performance (will be created with tables in migrations)
-- These are just placeholders for reference

-- Full-text search configuration
CREATE TEXT SEARCH CONFIGURATION alumni_search (COPY = english);

-- Create a function for updating updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a function for generating unique usernames
CREATE OR REPLACE FUNCTION generate_username(first_name TEXT, last_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_username TEXT;
    final_username TEXT;
    counter INTEGER := 1;
BEGIN
    -- Create base username from first and last name
    base_username := LOWER(REGEXP_REPLACE(first_name || last_name, '[^a-zA-Z0-9]', '', 'g'));
    final_username := base_username;
    
    -- Check if username exists and increment counter if needed
    WHILE EXISTS (SELECT 1 FROM users WHERE username = final_username) LOOP
        final_username := base_username || counter::TEXT;
        counter := counter + 1;
    END LOOP;
    
    RETURN final_username;
END;
$$ LANGUAGE plpgsql;

-- Create a function for search ranking
CREATE OR REPLACE FUNCTION calculate_search_rank(
    search_query TEXT,
    name_field TEXT,
    bio_field TEXT DEFAULT '',
    profession_field TEXT DEFAULT ''
)
RETURNS FLOAT AS $$
BEGIN
    RETURN (
        CASE WHEN name_field ILIKE '%' || search_query || '%' THEN 1.0 ELSE 0.0 END +
        CASE WHEN bio_field ILIKE '%' || search_query || '%' THEN 0.5 ELSE 0.0 END +
        CASE WHEN profession_field ILIKE '%' || search_query || '%' THEN 0.3 ELSE 0.0 END
    );
END;
$$ LANGUAGE plpgsql;

-- Insert initial admin user (password: admin123 - should be changed in production)
-- This will be handled by the application during first startup

-- Create initial departments
INSERT INTO departments (name, code, description) VALUES
('Computer Science and Engineering', 'CSE', 'Department of Computer Science and Engineering'),
('Electrical and Electronic Engineering', 'EEE', 'Department of Electrical and Electronic Engineering'),
('Civil Engineering', 'CE', 'Department of Civil Engineering'),
('Mechanical Engineering', 'ME', 'Department of Mechanical Engineering'),
('Industrial and Production Engineering', 'IPE', 'Department of Industrial and Production Engineering'),
('Chemical Engineering', 'ChE', 'Department of Chemical Engineering'),
('Materials and Metallurgical Engineering', 'MME', 'Department of Materials and Metallurgical Engineering'),
('Petroleum and Mining Engineering', 'PME', 'Department of Petroleum and Mining Engineering'),
('Architecture', 'ARCH', 'Department of Architecture'),
('Urban and Regional Planning', 'URP', 'Department of Urban and Regional Planning')
ON CONFLICT (code) DO NOTHING;

-- Create initial batch years (last 20 years)
DO $$
DECLARE
    current_year INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    start_year INTEGER := current_year - 20;
    year_counter INTEGER;
BEGIN
    FOR year_counter IN start_year..current_year LOOP
        INSERT INTO batch_years (year, session_name) 
        VALUES (year_counter, year_counter || '-' || (year_counter + 1))
        ON CONFLICT (year) DO NOTHING;
    END LOOP;
END $$;

-- Create initial event categories
INSERT INTO event_categories (name, description, color) VALUES
('Academic', 'Academic events and seminars', '#3B82F6'),
('Social', 'Social gatherings and meetups', '#10B981'),
('Professional', 'Career and professional development', '#8B5CF6'),
('Sports', 'Sports and recreational activities', '#F59E0B'),
('Cultural', 'Cultural events and celebrations', '#EF4444'),
('Networking', 'Networking and business events', '#6B7280')
ON CONFLICT (name) DO NOTHING;

-- Create initial system settings
INSERT INTO system_settings (key, value, description) VALUES
('app_name', 'IIT JU Alumni Association', 'Application name'),
('app_version', '1.0.0', 'Application version'),
('max_file_size', '10485760', 'Maximum file upload size in bytes (10MB)'),
('allowed_file_types', 'image/jpeg,image/png,image/gif,video/mp4', 'Allowed file types for upload'),
('email_verification_required', 'true', 'Whether email verification is required for new users'),
('admin_approval_required', 'false', 'Whether admin approval is required for new users'),
('maintenance_mode', 'false', 'Whether the application is in maintenance mode')
ON CONFLICT (key) DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO alumni_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO alumni_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO alumni_user;

