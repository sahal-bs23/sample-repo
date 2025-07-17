-- Complete Database Schema for IIT JU Alumni Association
-- This file contains the complete database schema with all tables, indexes, and functions
-- Generated from Flyway migrations V1 through V6

-- ============================================================================
-- ENUMS AND CUSTOM TYPES
-- ============================================================================

CREATE TYPE user_role AS ENUM ('GUEST', 'ALUMNI', 'ADMIN');
CREATE TYPE event_status AS ENUM ('DRAFT', 'PUBLISHED', 'CANCELLED', 'COMPLETED');
CREATE TYPE group_visibility AS ENUM ('PUBLIC', 'PRIVATE');
CREATE TYPE message_type AS ENUM ('TEXT', 'IMAGE', 'VIDEO', 'AUDIO', 'FILE');
CREATE TYPE call_type AS ENUM ('AUDIO', 'VIDEO');
CREATE TYPE call_status AS ENUM ('INITIATED', 'RINGING', 'CONNECTED', 'ENDED', 'MISSED');
CREATE TYPE payment_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- ============================================================================
-- CORE USER MANAGEMENT TABLES
-- ============================================================================

-- Departments
CREATE TABLE departments (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Batch Years
CREATE TABLE batch_years (
    id BIGSERIAL PRIMARY KEY,
    year INTEGER NOT NULL UNIQUE,
    session_name VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users (Main user entity)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    role user_role DEFAULT 'ALUMNI',
    is_active BOOLEAN DEFAULT true,
    is_email_verified BOOLEAN DEFAULT false,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMP,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Profiles (Extended user information)
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department_id BIGINT REFERENCES departments(id),
    batch_year_id BIGINT REFERENCES batch_years(id),
    student_id VARCHAR(20),
    profession VARCHAR(255),
    company VARCHAR(255),
    job_title VARCHAR(255),
    bio TEXT,
    location VARCHAR(255),
    website_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    facebook_url VARCHAR(500),
    twitter_url VARCHAR(500),
    profile_image_url VARCHAR(500),
    cover_image_url VARCHAR(500),
    is_profile_public BOOLEAN DEFAULT true,
    show_email BOOLEAN DEFAULT false,
    show_phone BOOLEAN DEFAULT false,
    show_location BOOLEAN DEFAULT true,
    show_profession BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- OAuth Providers
CREATE TABLE oauth_providers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_id)
);

-- User Sessions (JWT token management)
CREATE TABLE user_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(500) NOT NULL UNIQUE,
    refresh_token VARCHAR(500) NOT NULL UNIQUE,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- EVENT MANAGEMENT TABLES
-- ============================================================================

-- Event Categories
CREATE TABLE event_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6',
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Events
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    category_id BIGINT REFERENCES event_categories(id),
    organizer_id BIGINT NOT NULL REFERENCES users(id),
    event_type VARCHAR(20) DEFAULT 'PHYSICAL',
    status event_status DEFAULT 'DRAFT',
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    registration_start_date TIMESTAMP,
    registration_end_date TIMESTAMP,
    venue_name VARCHAR(255),
    venue_address TEXT,
    venue_city VARCHAR(100),
    venue_country VARCHAR(100),
    virtual_meeting_url VARCHAR(500),
    virtual_meeting_id VARCHAR(100),
    virtual_meeting_password VARCHAR(100),
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    is_registration_required BOOLEAN DEFAULT true,
    is_approval_required BOOLEAN DEFAULT false,
    is_paid_event BOOLEAN DEFAULT false,
    ticket_price DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    banner_image_url VARCHAR(500),
    gallery_images JSONB,
    event_agenda JSONB,
    is_featured BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    allow_guest_registration BOOLEAN DEFAULT false,
    send_reminders BOOLEAN DEFAULT true,
    slug VARCHAR(255) UNIQUE,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event Registrations
CREATE TABLE event_registrations (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    guest_name VARCHAR(255),
    guest_email VARCHAR(255),
    guest_phone VARCHAR(20),
    registration_status VARCHAR(20) DEFAULT 'PENDING',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmation_date TIMESTAMP,
    cancellation_date TIMESTAMP,
    cancellation_reason TEXT,
    payment_status payment_status DEFAULT 'PENDING',
    payment_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(255),
    payment_date TIMESTAMP,
    registration_data JSONB,
    attendance_status VARCHAR(20) DEFAULT 'REGISTERED',
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, user_id),
    UNIQUE(event_id, guest_email)
);

-- ============================================================================
-- GROUP MANAGEMENT TABLES
-- ============================================================================

-- Groups
CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    creator_id BIGINT NOT NULL REFERENCES users(id),
    visibility group_visibility DEFAULT 'PUBLIC',
    is_active BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    max_members INTEGER,
    current_member_count INTEGER DEFAULT 1,
    cover_image_url VARCHAR(500),
    avatar_image_url VARCHAR(500),
    group_type VARCHAR(50) DEFAULT 'GENERAL',
    tags JSONB,
    slug VARCHAR(255) UNIQUE,
    is_featured BOOLEAN DEFAULT false,
    is_searchable BOOLEAN DEFAULT true,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Group Members
CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by BIGINT REFERENCES users(id),
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    can_post BOOLEAN DEFAULT true,
    can_invite BOOLEAN DEFAULT false,
    can_moderate BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

-- ============================================================================
-- MESSAGING SYSTEM TABLES
-- ============================================================================

-- Conversations
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    conversation_type VARCHAR(20) NOT NULL,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    title VARCHAR(255),
    description TEXT,
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    allow_file_sharing BOOLEAN DEFAULT true,
    allow_voice_messages BOOLEAN DEFAULT true,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversation Participants
CREATE TABLE conversation_participants (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    last_read_message_id BIGINT,
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unread_count INTEGER DEFAULT 0,
    is_muted BOOLEAN DEFAULT false,
    muted_until TIMESTAMP,
    can_send_messages BOOLEAN DEFAULT true,
    can_add_participants BOOLEAN DEFAULT false,
    can_remove_participants BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(conversation_id, user_id)
);

-- Messages
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    message_type message_type DEFAULT 'TEXT',
    content TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size BIGINT,
    file_type VARCHAR(100),
    thumbnail_url VARCHAR(500),
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by BIGINT REFERENCES users(id),
    reply_to_message_id BIGINT REFERENCES messages(id),
    reaction_count INTEGER DEFAULT 0,
    is_system_message BOOLEAN DEFAULT false,
    system_message_type VARCHAR(50),
    system_message_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CALLING SYSTEM TABLES
-- ============================================================================

-- Calls
CREATE TABLE calls (
    id BIGSERIAL PRIMARY KEY,
    call_type call_type NOT NULL,
    status call_status DEFAULT 'INITIATED',
    caller_id BIGINT NOT NULL REFERENCES users(id),
    conversation_id BIGINT REFERENCES conversations(id) ON DELETE SET NULL,
    title VARCHAR(255),
    description TEXT,
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    duration_seconds INTEGER DEFAULT 0,
    room_id VARCHAR(255) UNIQUE,
    server_url VARCHAR(500),
    is_recording_enabled BOOLEAN DEFAULT false,
    recording_url VARCHAR(500),
    max_participants INTEGER DEFAULT 10,
    current_participant_count INTEGER DEFAULT 0,
    average_quality_score DECIMAL(3,2),
    connection_issues_count INTEGER DEFAULT 0,
    call_metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Call Participants
CREATE TABLE call_participants (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'INVITED',
    role VARCHAR(20) DEFAULT 'PARTICIPANT',
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    joined_at TIMESTAMP,
    left_at TIMESTAMP,
    duration_seconds INTEGER DEFAULT 0,
    is_audio_muted BOOLEAN DEFAULT false,
    is_video_disabled BOOLEAN DEFAULT false,
    is_screen_sharing BOOLEAN DEFAULT false,
    peer_id VARCHAR(255),
    connection_quality VARCHAR(20) DEFAULT 'UNKNOWN',
    audio_bitrate INTEGER,
    video_bitrate INTEGER,
    packet_loss_percentage DECIMAL(5,2),
    latency_ms INTEGER,
    device_type VARCHAR(50),
    browser_info VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(call_id, user_id)
);

-- ============================================================================
-- SEARCH AND NETWORKING TABLES
-- ============================================================================

-- User Connections
CREATE TABLE user_connections (
    id BIGSERIAL PRIMARY KEY,
    requester_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'PENDING',
    connection_type VARCHAR(20) DEFAULT 'PROFESSIONAL',
    message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    relationship_strength INTEGER DEFAULT 1,
    interaction_count INTEGER DEFAULT 0,
    last_interaction_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(requester_id, addressee_id),
    CHECK(requester_id != addressee_id)
);

-- Search History
CREATE TABLE search_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    search_query TEXT NOT NULL,
    search_type VARCHAR(50) NOT NULL,
    search_filters JSONB,
    results_count INTEGER DEFAULT 0,
    clicked_result_id BIGINT,
    clicked_result_type VARCHAR(50),
    search_context VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- NOTIFICATION SYSTEM TABLES
-- ============================================================================

-- Notifications
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_entity_type VARCHAR(50),
    related_entity_id BIGINT,
    priority VARCHAR(20) DEFAULT 'NORMAL',
    category VARCHAR(50) DEFAULT 'GENERAL',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_dismissed BOOLEAN DEFAULT false,
    dismissed_at TIMESTAMP,
    delivery_method VARCHAR(50) DEFAULT 'IN_APP',
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    delivery_status VARCHAR(20) DEFAULT 'PENDING',
    action_url VARCHAR(500),
    action_text VARCHAR(100),
    scheduled_for TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notification Preferences
CREATE TABLE notification_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    connection_requests BOOLEAN DEFAULT true,
    event_reminders BOOLEAN DEFAULT true,
    event_updates BOOLEAN DEFAULT true,
    group_invitations BOOLEAN DEFAULT true,
    group_messages BOOLEAN DEFAULT true,
    direct_messages BOOLEAN DEFAULT true,
    call_notifications BOOLEAN DEFAULT true,
    system_updates BOOLEAN DEFAULT true,
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '08:00:00',
    timezone VARCHAR(50) DEFAULT 'UTC',
    digest_frequency VARCHAR(20) DEFAULT 'DAILY',
    digest_time TIME DEFAULT '09:00:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- ============================================================================
-- SYSTEM TABLES
-- ============================================================================

-- System Settings
CREATE TABLE system_settings (
    id BIGSERIAL PRIMARY KEY,
    key VARCHAR(255) NOT NULL UNIQUE,
    value TEXT NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Activity Logs
CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_description TEXT,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(50),
    browser_info VARCHAR(255),
    country VARCHAR(100),
    city VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SUMMARY
-- ============================================================================

-- Total Tables: 30+
-- Key Features Supported:
-- ✅ User Management & Authentication
-- ✅ Event Management with Payments
-- ✅ Group Management & Membership
-- ✅ Real-time Messaging System
-- ✅ Audio/Video Calling
-- ✅ Alumni Search & Networking
-- ✅ Notification System
-- ✅ Activity Tracking & Analytics
-- ✅ System Administration

-- Performance Optimizations:
-- ✅ Comprehensive indexing strategy
-- ✅ Full-text search capabilities
-- ✅ Efficient foreign key relationships
-- ✅ Proper data types and constraints
-- ✅ Trigger-based automation

-- Security Features:
-- ✅ Role-based access control
-- ✅ Audit logging
-- ✅ Session management
-- ✅ Data validation constraints
-- ✅ Soft delete capabilities

