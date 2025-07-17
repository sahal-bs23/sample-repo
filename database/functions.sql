-- Database Functions for IIT JU Alumni Association
-- Helper functions for common operations and business logic

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to generate unique slugs
CREATE OR REPLACE FUNCTION generate_unique_slug(base_text TEXT, table_name TEXT, column_name TEXT DEFAULT 'slug')
RETURNS TEXT AS $$
DECLARE
    slug TEXT;
    counter INTEGER := 0;
    final_slug TEXT;
BEGIN
    -- Create base slug from text
    slug := LOWER(TRIM(REGEXP_REPLACE(base_text, '[^a-zA-Z0-9\s]', '', 'g')));
    slug := REGEXP_REPLACE(slug, '\s+', '-', 'g');
    slug := TRIM(slug, '-');
    
    -- Limit length
    IF LENGTH(slug) > 50 THEN
        slug := SUBSTRING(slug FROM 1 FOR 50);
    END IF;
    
    final_slug := slug;
    
    -- Check for uniqueness and append counter if needed
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I WHERE %I = $1', table_name, column_name) 
        USING final_slug;
        
        IF NOT FOUND THEN
            EXIT;
        END IF;
        
        counter := counter + 1;
        final_slug := slug || '-' || counter;
    END LOOP;
    
    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Function to normalize search queries
CREATE OR REPLACE FUNCTION normalize_search_query(query TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN LOWER(TRIM(REGEXP_REPLACE(query, '\s+', ' ', 'g')));
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- USER MANAGEMENT FUNCTIONS
-- ============================================================================

-- Function to create a complete user profile
CREATE OR REPLACE FUNCTION create_user_with_profile(
    p_username VARCHAR(50),
    p_email VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_date_of_birth DATE DEFAULT NULL,
    p_phone VARCHAR(20) DEFAULT NULL,
    p_department_id BIGINT DEFAULT NULL,
    p_batch_year_id BIGINT DEFAULT NULL,
    p_student_id VARCHAR(20) DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    user_id BIGINT;
BEGIN
    -- Insert user
    INSERT INTO users (username, email, password_hash, first_name, last_name, date_of_birth, phone)
    VALUES (p_username, p_email, p_password_hash, p_first_name, p_last_name, p_date_of_birth, p_phone)
    RETURNING id INTO user_id;
    
    -- Insert user profile
    INSERT INTO user_profiles (user_id, department_id, batch_year_id, student_id)
    VALUES (user_id, p_department_id, p_batch_year_id, p_student_id);
    
    -- Create default notification preferences
    INSERT INTO notification_preferences (user_id)
    VALUES (user_id);
    
    RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get user's full profile
CREATE OR REPLACE FUNCTION get_user_full_profile(p_user_id BIGINT)
RETURNS TABLE (
    user_id BIGINT,
    username VARCHAR(50),
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name TEXT,
    date_of_birth DATE,
    phone VARCHAR(20),
    role user_role,
    is_active BOOLEAN,
    department_name VARCHAR(255),
    department_code VARCHAR(10),
    batch_year INTEGER,
    session_name VARCHAR(20),
    student_id VARCHAR(20),
    profession VARCHAR(255),
    company VARCHAR(255),
    job_title VARCHAR(255),
    bio TEXT,
    location VARCHAR(255),
    profile_image_url VARCHAR(500),
    cover_image_url VARCHAR(500),
    is_profile_public BOOLEAN,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.username,
        u.email,
        u.first_name,
        u.last_name,
        (u.first_name || ' ' || u.last_name) AS full_name,
        u.date_of_birth,
        u.phone,
        u.role,
        u.is_active,
        d.name AS department_name,
        d.code AS department_code,
        by.year AS batch_year,
        by.session_name,
        up.student_id,
        up.profession,
        up.company,
        up.job_title,
        up.bio,
        up.location,
        up.profile_image_url,
        up.cover_image_url,
        up.is_profile_public,
        u.created_at
    FROM users u
    LEFT JOIN user_profiles up ON u.id = up.user_id
    LEFT JOIN departments d ON up.department_id = d.id
    LEFT JOIN batch_years by ON up.batch_year_id = by.id
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SEARCH FUNCTIONS
-- ============================================================================

-- Function to search alumni with filters
CREATE OR REPLACE FUNCTION search_alumni(
    p_query TEXT DEFAULT '',
    p_department_id BIGINT DEFAULT NULL,
    p_batch_year_id BIGINT DEFAULT NULL,
    p_location VARCHAR(255) DEFAULT NULL,
    p_profession VARCHAR(255) DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    user_id BIGINT,
    username VARCHAR(50),
    full_name TEXT,
    profession VARCHAR(255),
    company VARCHAR(255),
    location VARCHAR(255),
    department_name VARCHAR(255),
    batch_year INTEGER,
    profile_image_url VARCHAR(500),
    relevance_score REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.username,
        (u.first_name || ' ' || u.last_name) AS full_name,
        up.profession,
        up.company,
        up.location,
        d.name AS department_name,
        by.year AS batch_year,
        up.profile_image_url,
        CASE 
            WHEN p_query = '' THEN 1.0
            ELSE ts_rank(
                to_tsvector('english', u.first_name || ' ' || u.last_name || ' ' || 
                           COALESCE(up.profession, '') || ' ' || COALESCE(up.company, '')),
                plainto_tsquery('english', p_query)
            )
        END AS relevance_score
    FROM users u
    JOIN user_profiles up ON u.id = up.user_id
    LEFT JOIN departments d ON up.department_id = d.id
    LEFT JOIN batch_years by ON up.batch_year_id = by.id
    WHERE u.is_active = true
    AND up.is_profile_public = true
    AND (p_query = '' OR to_tsvector('english', u.first_name || ' ' || u.last_name || ' ' || 
                                    COALESCE(up.profession, '') || ' ' || COALESCE(up.company, ''))
         @@ plainto_tsquery('english', p_query))
    AND (p_department_id IS NULL OR up.department_id = p_department_id)
    AND (p_batch_year_id IS NULL OR up.batch_year_id = p_batch_year_id)
    AND (p_location IS NULL OR up.location ILIKE '%' || p_location || '%')
    AND (p_profession IS NULL OR up.profession ILIKE '%' || p_profession || '%')
    ORDER BY relevance_score DESC, u.first_name, u.last_name
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- EVENT FUNCTIONS
-- ============================================================================

-- Function to register user for event
CREATE OR REPLACE FUNCTION register_for_event(
    p_event_id BIGINT,
    p_user_id BIGINT DEFAULT NULL,
    p_guest_name VARCHAR(255) DEFAULT NULL,
    p_guest_email VARCHAR(255) DEFAULT NULL,
    p_guest_phone VARCHAR(20) DEFAULT NULL,
    p_registration_data JSONB DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    registration_id BIGINT;
    event_max_participants INTEGER;
    current_count INTEGER;
BEGIN
    -- Check event capacity
    SELECT max_participants, current_participants 
    INTO event_max_participants, current_count
    FROM events WHERE id = p_event_id;
    
    IF event_max_participants IS NOT NULL AND current_count >= event_max_participants THEN
        RAISE EXCEPTION 'Event is full. Maximum participants: %', event_max_participants;
    END IF;
    
    -- Insert registration
    INSERT INTO event_registrations (
        event_id, user_id, guest_name, guest_email, guest_phone, registration_data
    )
    VALUES (
        p_event_id, p_user_id, p_guest_name, p_guest_email, p_guest_phone, p_registration_data
    )
    RETURNING id INTO registration_id;
    
    RETURN registration_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get upcoming events
CREATE OR REPLACE FUNCTION get_upcoming_events(
    p_user_id BIGINT DEFAULT NULL,
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    event_id BIGINT,
    title VARCHAR(255),
    short_description VARCHAR(500),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    venue_name VARCHAR(255),
    venue_city VARCHAR(100),
    event_type VARCHAR(20),
    is_paid_event BOOLEAN,
    ticket_price DECIMAL(10,2),
    current_participants INTEGER,
    max_participants INTEGER,
    banner_image_url VARCHAR(500),
    organizer_name TEXT,
    is_registered BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.short_description,
        e.start_date,
        e.end_date,
        e.venue_name,
        e.venue_city,
        e.event_type,
        e.is_paid_event,
        e.ticket_price,
        e.current_participants,
        e.max_participants,
        e.banner_image_url,
        (u.first_name || ' ' || u.last_name) AS organizer_name,
        CASE 
            WHEN p_user_id IS NULL THEN false
            ELSE EXISTS(
                SELECT 1 FROM event_registrations er 
                WHERE er.event_id = e.id AND er.user_id = p_user_id 
                AND er.registration_status = 'CONFIRMED'
            )
        END AS is_registered
    FROM events e
    JOIN users u ON e.organizer_id = u.id
    WHERE e.status = 'PUBLISHED'
    AND e.is_public = true
    AND e.start_date > CURRENT_TIMESTAMP
    ORDER BY e.start_date ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- GROUP FUNCTIONS
-- ============================================================================

-- Function to join a group
CREATE OR REPLACE FUNCTION join_group(
    p_group_id BIGINT,
    p_user_id BIGINT,
    p_message TEXT DEFAULT NULL
)
RETURNS VARCHAR(20) AS $$
DECLARE
    group_visibility group_visibility;
    requires_approval BOOLEAN;
    max_members INTEGER;
    current_count INTEGER;
    member_status VARCHAR(20);
BEGIN
    -- Get group details
    SELECT g.visibility, g.requires_approval, g.max_members, g.current_member_count
    INTO group_visibility, requires_approval, max_members, current_count
    FROM groups g WHERE g.id = p_group_id AND g.is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Group not found or inactive';
    END IF;
    
    -- Check if already a member
    SELECT status INTO member_status
    FROM group_members 
    WHERE group_id = p_group_id AND user_id = p_user_id;
    
    IF FOUND THEN
        RETURN member_status;
    END IF;
    
    -- Check capacity
    IF max_members IS NOT NULL AND current_count >= max_members THEN
        RAISE EXCEPTION 'Group is full. Maximum members: %', max_members;
    END IF;
    
    -- Handle private groups
    IF group_visibility = 'PRIVATE' THEN
        -- Create join request
        INSERT INTO group_join_requests (group_id, user_id, message)
        VALUES (p_group_id, p_user_id, p_message);
        RETURN 'PENDING';
    END IF;
    
    -- Handle public groups
    IF requires_approval THEN
        INSERT INTO group_members (group_id, user_id, status)
        VALUES (p_group_id, p_user_id, 'PENDING');
        RETURN 'PENDING';
    ELSE
        INSERT INTO group_members (group_id, user_id, status)
        VALUES (p_group_id, p_user_id, 'ACTIVE');
        RETURN 'ACTIVE';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MESSAGING FUNCTIONS
-- ============================================================================

-- Function to create or get direct conversation
CREATE OR REPLACE FUNCTION get_or_create_direct_conversation(
    p_user1_id BIGINT,
    p_user2_id BIGINT
)
RETURNS BIGINT AS $$
DECLARE
    conversation_id BIGINT;
BEGIN
    -- Check if conversation already exists
    SELECT c.id INTO conversation_id
    FROM conversations c
    JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
    JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
    WHERE c.conversation_type = 'DIRECT'
    AND cp1.user_id = p_user1_id AND cp1.status = 'ACTIVE'
    AND cp2.user_id = p_user2_id AND cp2.status = 'ACTIVE'
    AND c.is_active = true;
    
    IF FOUND THEN
        RETURN conversation_id;
    END IF;
    
    -- Create new conversation
    INSERT INTO conversations (conversation_type, created_by)
    VALUES ('DIRECT', p_user1_id)
    RETURNING id INTO conversation_id;
    
    -- Add participants
    INSERT INTO conversation_participants (conversation_id, user_id, role)
    VALUES 
        (conversation_id, p_user1_id, 'MEMBER'),
        (conversation_id, p_user2_id, 'MEMBER');
    
    RETURN conversation_id;
END;
$$ LANGUAGE plpgsql;

-- Function to send message
CREATE OR REPLACE FUNCTION send_message(
    p_conversation_id BIGINT,
    p_sender_id BIGINT,
    p_message_type message_type DEFAULT 'TEXT',
    p_content TEXT DEFAULT NULL,
    p_file_url VARCHAR(500) DEFAULT NULL,
    p_file_name VARCHAR(255) DEFAULT NULL,
    p_file_size BIGINT DEFAULT NULL,
    p_file_type VARCHAR(100) DEFAULT NULL,
    p_reply_to_message_id BIGINT DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    message_id BIGINT;
BEGIN
    -- Verify sender is participant
    IF NOT EXISTS(
        SELECT 1 FROM conversation_participants 
        WHERE conversation_id = p_conversation_id 
        AND user_id = p_sender_id 
        AND status = 'ACTIVE'
        AND can_send_messages = true
    ) THEN
        RAISE EXCEPTION 'User is not authorized to send messages in this conversation';
    END IF;
    
    -- Insert message
    INSERT INTO messages (
        conversation_id, sender_id, message_type, content, 
        file_url, file_name, file_size, file_type, reply_to_message_id
    )
    VALUES (
        p_conversation_id, p_sender_id, p_message_type, p_content,
        p_file_url, p_file_name, p_file_size, p_file_type, p_reply_to_message_id
    )
    RETURNING id INTO message_id;
    
    RETURN message_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- NOTIFICATION FUNCTIONS
-- ============================================================================

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id BIGINT,
    p_type VARCHAR(50),
    p_title VARCHAR(255),
    p_message TEXT,
    p_related_entity_type VARCHAR(50) DEFAULT NULL,
    p_related_entity_id BIGINT DEFAULT NULL,
    p_priority VARCHAR(20) DEFAULT 'NORMAL',
    p_category VARCHAR(50) DEFAULT 'GENERAL',
    p_action_url VARCHAR(500) DEFAULT NULL,
    p_action_text VARCHAR(100) DEFAULT NULL,
    p_scheduled_for TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS BIGINT AS $$
DECLARE
    notification_id BIGINT;
BEGIN
    INSERT INTO notifications (
        user_id, type, title, message, related_entity_type, related_entity_id,
        priority, category, action_url, action_text, scheduled_for
    )
    VALUES (
        p_user_id, p_type, p_title, p_message, p_related_entity_type, p_related_entity_id,
        p_priority, p_category, p_action_url, p_action_text, p_scheduled_for
    )
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Function to mark notifications as read
CREATE OR REPLACE FUNCTION mark_notifications_read(
    p_user_id BIGINT,
    p_notification_ids BIGINT[] DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    IF p_notification_ids IS NULL THEN
        -- Mark all unread notifications as read
        UPDATE notifications 
        SET is_read = true, read_at = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id AND is_read = false;
    ELSE
        -- Mark specific notifications as read
        UPDATE notifications 
        SET is_read = true, read_at = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id AND id = ANY(p_notification_ids) AND is_read = false;
    END IF;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ANALYTICS FUNCTIONS
-- ============================================================================

-- Function to get user activity summary
CREATE OR REPLACE FUNCTION get_user_activity_summary(
    p_user_id BIGINT,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_messages INTEGER,
    total_events_attended INTEGER,
    total_groups_joined INTEGER,
    total_connections INTEGER,
    total_calls_made INTEGER,
    last_login TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM messages WHERE sender_id = p_user_id 
         AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days),
        (SELECT COUNT(*)::INTEGER FROM event_registrations WHERE user_id = p_user_id 
         AND attendance_status = 'ATTENDED' 
         AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days),
        (SELECT COUNT(*)::INTEGER FROM group_members WHERE user_id = p_user_id 
         AND status = 'ACTIVE' 
         AND joined_at > CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days),
        (SELECT COUNT(*)::INTEGER FROM user_connections 
         WHERE (requester_id = p_user_id OR addressee_id = p_user_id) 
         AND status = 'ACCEPTED'),
        (SELECT COUNT(*)::INTEGER FROM calls WHERE caller_id = p_user_id 
         AND initiated_at > CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days),
        (SELECT last_login_at FROM users WHERE id = p_user_id);
END;
$$ LANGUAGE plpgsql;

-- Function to get system statistics
CREATE OR REPLACE FUNCTION get_system_statistics()
RETURNS TABLE (
    total_users INTEGER,
    active_users_today INTEGER,
    total_events INTEGER,
    upcoming_events INTEGER,
    total_groups INTEGER,
    active_groups INTEGER,
    total_messages_today INTEGER,
    total_calls_today INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM users WHERE is_active = true),
        (SELECT COUNT(DISTINCT user_id)::INTEGER FROM user_activity_logs 
         WHERE created_at > CURRENT_DATE),
        (SELECT COUNT(*)::INTEGER FROM events),
        (SELECT COUNT(*)::INTEGER FROM events 
         WHERE status = 'PUBLISHED' AND start_date > CURRENT_TIMESTAMP),
        (SELECT COUNT(*)::INTEGER FROM groups WHERE is_active = true),
        (SELECT COUNT(*)::INTEGER FROM groups 
         WHERE is_active = true AND last_activity_at > CURRENT_TIMESTAMP - INTERVAL '7 days'),
        (SELECT COUNT(*)::INTEGER FROM messages WHERE created_at > CURRENT_DATE),
        (SELECT COUNT(*)::INTEGER FROM calls WHERE initiated_at > CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

