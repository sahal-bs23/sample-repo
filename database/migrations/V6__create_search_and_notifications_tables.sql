-- V6__create_search_and_notifications_tables.sql
-- Tables for search functionality and notification system

-- Create user_connections table (for alumni networking)
CREATE TABLE user_connections (
    id BIGSERIAL PRIMARY KEY,
    requester_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Connection details
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'ACCEPTED', 'DECLINED', 'BLOCKED'
    connection_type VARCHAR(20) DEFAULT 'PROFESSIONAL', -- 'PROFESSIONAL', 'PERSONAL', 'ACADEMIC'
    
    -- Request details
    message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    
    -- Relationship metadata
    relationship_strength INTEGER DEFAULT 1, -- 1-5 scale
    interaction_count INTEGER DEFAULT 0,
    last_interaction_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(requester_id, addressee_id),
    CHECK(requester_id != addressee_id)
);

-- Create search_history table (for improving search results)
CREATE TABLE search_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    
    -- Search details
    search_query TEXT NOT NULL,
    search_type VARCHAR(50) NOT NULL, -- 'ALUMNI', 'EVENTS', 'GROUPS', 'GLOBAL'
    search_filters JSONB, -- Applied filters
    
    -- Results and interaction
    results_count INTEGER DEFAULT 0,
    clicked_result_id BIGINT, -- ID of the result that was clicked
    clicked_result_type VARCHAR(50), -- Type of clicked result
    
    -- Context
    search_context VARCHAR(100), -- Where the search was performed
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create saved_searches table (for users to save frequent searches)
CREATE TABLE saved_searches (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Search details
    name VARCHAR(255) NOT NULL,
    search_query TEXT,
    search_type VARCHAR(50) NOT NULL,
    search_filters JSONB,
    
    -- Settings
    is_active BOOLEAN DEFAULT true,
    notification_enabled BOOLEAN DEFAULT false, -- Notify when new results match
    last_notification_sent TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notifications table
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Notification content
    type VARCHAR(50) NOT NULL, -- 'CONNECTION_REQUEST', 'EVENT_REMINDER', 'GROUP_INVITATION', etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related entities
    related_entity_type VARCHAR(50), -- 'USER', 'EVENT', 'GROUP', 'MESSAGE', etc.
    related_entity_id BIGINT,
    
    -- Notification metadata
    priority VARCHAR(20) DEFAULT 'NORMAL', -- 'LOW', 'NORMAL', 'HIGH', 'URGENT'
    category VARCHAR(50) DEFAULT 'GENERAL', -- 'SOCIAL', 'EVENTS', 'MESSAGES', 'SYSTEM'
    
    -- Status tracking
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_dismissed BOOLEAN DEFAULT false,
    dismissed_at TIMESTAMP,
    
    -- Delivery tracking
    delivery_method VARCHAR(50) DEFAULT 'IN_APP', -- 'IN_APP', 'EMAIL', 'PUSH', 'SMS'
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    delivery_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'SENT', 'DELIVERED', 'FAILED'
    
    -- Action details
    action_url VARCHAR(500),
    action_text VARCHAR(100),
    
    -- Scheduling
    scheduled_for TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notification_preferences table
CREATE TABLE notification_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- General preferences
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    
    -- Category preferences
    connection_requests BOOLEAN DEFAULT true,
    event_reminders BOOLEAN DEFAULT true,
    event_updates BOOLEAN DEFAULT true,
    group_invitations BOOLEAN DEFAULT true,
    group_messages BOOLEAN DEFAULT true,
    direct_messages BOOLEAN DEFAULT true,
    call_notifications BOOLEAN DEFAULT true,
    system_updates BOOLEAN DEFAULT true,
    
    -- Timing preferences
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '08:00:00',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Frequency preferences
    digest_frequency VARCHAR(20) DEFAULT 'DAILY', -- 'IMMEDIATE', 'HOURLY', 'DAILY', 'WEEKLY', 'NEVER'
    digest_time TIME DEFAULT '09:00:00',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id)
);

-- Create notification_templates table
CREATE TABLE notification_templates (
    id BIGSERIAL PRIMARY KEY,
    
    -- Template identification
    template_key VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Template content
    subject_template TEXT,
    body_template TEXT NOT NULL,
    html_template TEXT,
    
    -- Template metadata
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'NORMAL',
    
    -- Supported delivery methods
    supports_email BOOLEAN DEFAULT true,
    supports_push BOOLEAN DEFAULT true,
    supports_sms BOOLEAN DEFAULT false,
    supports_in_app BOOLEAN DEFAULT true,
    
    -- Template variables (JSON schema)
    variables_schema JSONB,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_activity_logs table (for tracking user engagement)
CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Activity details
    activity_type VARCHAR(50) NOT NULL, -- 'LOGIN', 'LOGOUT', 'PROFILE_UPDATE', 'SEARCH', etc.
    activity_description TEXT,
    
    -- Context
    entity_type VARCHAR(50), -- Related entity type
    entity_id BIGINT, -- Related entity ID
    
    -- Technical details
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(50),
    browser_info VARCHAR(255),
    
    -- Location (if available)
    country VARCHAR(100),
    city VARCHAR(100),
    
    -- Metadata
    metadata JSONB, -- Additional activity data
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create popular_searches table (for trending searches)
CREATE TABLE popular_searches (
    id BIGSERIAL PRIMARY KEY,
    
    -- Search details
    search_query TEXT NOT NULL,
    search_type VARCHAR(50) NOT NULL,
    normalized_query TEXT, -- Normalized version for grouping
    
    -- Statistics
    search_count INTEGER DEFAULT 1,
    unique_users_count INTEGER DEFAULT 1,
    last_searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Time period
    date DATE DEFAULT CURRENT_DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(normalized_query, search_type, date)
);

-- Create user_recommendations table (for personalized recommendations)
CREATE TABLE user_recommendations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Recommendation details
    recommendation_type VARCHAR(50) NOT NULL, -- 'CONNECTION', 'EVENT', 'GROUP', 'CONTENT'
    recommended_entity_type VARCHAR(50) NOT NULL,
    recommended_entity_id BIGINT NOT NULL,
    
    -- Scoring
    relevance_score DECIMAL(5,4) DEFAULT 0.0000, -- 0.0000 to 1.0000
    confidence_score DECIMAL(5,4) DEFAULT 0.0000,
    
    -- Recommendation reason
    reason_code VARCHAR(50), -- 'MUTUAL_CONNECTIONS', 'SIMILAR_INTERESTS', 'SAME_BATCH', etc.
    reason_description TEXT,
    
    -- Status tracking
    is_shown BOOLEAN DEFAULT false,
    shown_at TIMESTAMP,
    is_clicked BOOLEAN DEFAULT false,
    clicked_at TIMESTAMP,
    is_dismissed BOOLEAN DEFAULT false,
    dismissed_at TIMESTAMP,
    
    -- Expiration
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_user_connections_requester_id ON user_connections(requester_id);
CREATE INDEX idx_user_connections_addressee_id ON user_connections(addressee_id);
CREATE INDEX idx_user_connections_status ON user_connections(status);
CREATE INDEX idx_user_connections_requested_at ON user_connections(requested_at);

CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_search_history_search_type ON search_history(search_type);
CREATE INDEX idx_search_history_created_at ON search_history(created_at);
CREATE INDEX idx_search_history_search_query ON search_history USING gin(to_tsvector('english', search_query));

CREATE INDEX idx_saved_searches_user_id ON saved_searches(user_id);
CREATE INDEX idx_saved_searches_search_type ON saved_searches(search_type);
CREATE INDEX idx_saved_searches_is_active ON saved_searches(is_active);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_is_sent ON notifications(is_sent);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_related_entity ON notifications(related_entity_type, related_entity_id);

CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);

CREATE INDEX idx_notification_templates_template_key ON notification_templates(template_key);
CREATE INDEX idx_notification_templates_category ON notification_templates(category);
CREATE INDEX idx_notification_templates_is_active ON notification_templates(is_active);

CREATE INDEX idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX idx_user_activity_logs_activity_type ON user_activity_logs(activity_type);
CREATE INDEX idx_user_activity_logs_created_at ON user_activity_logs(created_at);
CREATE INDEX idx_user_activity_logs_entity ON user_activity_logs(entity_type, entity_id);

CREATE INDEX idx_popular_searches_search_type ON popular_searches(search_type);
CREATE INDEX idx_popular_searches_date ON popular_searches(date);
CREATE INDEX idx_popular_searches_search_count ON popular_searches(search_count);
CREATE INDEX idx_popular_searches_normalized_query ON popular_searches(normalized_query);

CREATE INDEX idx_user_recommendations_user_id ON user_recommendations(user_id);
CREATE INDEX idx_user_recommendations_type ON user_recommendations(recommendation_type);
CREATE INDEX idx_user_recommendations_entity ON user_recommendations(recommended_entity_type, recommended_entity_id);
CREATE INDEX idx_user_recommendations_relevance_score ON user_recommendations(relevance_score);
CREATE INDEX idx_user_recommendations_expires_at ON user_recommendations(expires_at);

-- Create full-text search indexes
CREATE INDEX idx_notifications_search ON notifications USING gin(to_tsvector('english', title || ' ' || message));

-- Create triggers for updating updated_at timestamps
CREATE TRIGGER update_user_connections_updated_at BEFORE UPDATE ON user_connections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_searches_updated_at BEFORE UPDATE ON saved_searches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_templates_updated_at BEFORE UPDATE ON notification_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_popular_searches_updated_at BEFORE UPDATE ON popular_searches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_recommendations_updated_at BEFORE UPDATE ON user_recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update interaction count for connections
CREATE OR REPLACE FUNCTION update_connection_interaction()
RETURNS TRIGGER AS $$
BEGIN
    -- Update interaction count and last interaction time for both users
    UPDATE user_connections 
    SET interaction_count = interaction_count + 1,
        last_interaction_at = CURRENT_TIMESTAMP
    WHERE (requester_id = NEW.sender_id AND addressee_id IN (
        SELECT user_id FROM conversation_participants 
        WHERE conversation_id = NEW.conversation_id AND user_id != NEW.sender_id
    )) OR (addressee_id = NEW.sender_id AND requester_id IN (
        SELECT user_id FROM conversation_participants 
        WHERE conversation_id = NEW.conversation_id AND user_id != NEW.sender_id
    ));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for connection interaction updates
CREATE TRIGGER trigger_update_connection_interaction
    AFTER INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION update_connection_interaction();

-- Create function to track popular searches
CREATE OR REPLACE FUNCTION track_popular_search(query TEXT, search_type VARCHAR(50), user_id BIGINT)
RETURNS void AS $$
DECLARE
    normalized TEXT;
BEGIN
    -- Normalize the query (lowercase, trim)
    normalized := LOWER(TRIM(query));
    
    -- Insert or update popular search
    INSERT INTO popular_searches (search_query, search_type, normalized_query, search_count, unique_users_count, last_searched_at)
    VALUES (query, search_type, normalized, 1, 1, CURRENT_TIMESTAMP)
    ON CONFLICT (normalized_query, search_type, date)
    DO UPDATE SET
        search_count = popular_searches.search_count + 1,
        last_searched_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Create function to clean up old data
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
    -- Clean up old search history (older than 1 year)
    DELETE FROM search_history WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year';
    
    -- Clean up old activity logs (older than 2 years)
    DELETE FROM user_activity_logs WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '2 years';
    
    -- Clean up expired notifications
    DELETE FROM notifications WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Clean up expired recommendations
    DELETE FROM user_recommendations WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Clean up old popular searches (older than 90 days)
    DELETE FROM popular_searches WHERE date < CURRENT_DATE - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Create function to generate user recommendations
CREATE OR REPLACE FUNCTION generate_user_recommendations(target_user_id BIGINT)
RETURNS void AS $$
DECLARE
    user_profile RECORD;
BEGIN
    -- Get user profile information
    SELECT u.*, up.* INTO user_profile
    FROM users u
    JOIN user_profiles up ON u.id = up.user_id
    WHERE u.id = target_user_id;
    
    -- Clear existing recommendations for this user
    DELETE FROM user_recommendations WHERE user_id = target_user_id;
    
    -- Generate connection recommendations based on mutual connections
    INSERT INTO user_recommendations (user_id, recommendation_type, recommended_entity_type, recommended_entity_id, relevance_score, reason_code, reason_description)
    SELECT DISTINCT
        target_user_id,
        'CONNECTION',
        'USER',
        u.id,
        0.8,
        'MUTUAL_CONNECTIONS',
        'You have mutual connections with this person'
    FROM users u
    JOIN user_profiles up ON u.id = up.user_id
    WHERE u.id != target_user_id
    AND u.is_active = true
    AND u.id IN (
        -- Users who are connected to people that target user is connected to
        SELECT DISTINCT 
            CASE 
                WHEN uc1.requester_id = target_user_id THEN uc2.addressee_id
                ELSE uc2.requester_id
            END
        FROM user_connections uc1
        JOIN user_connections uc2 ON (
            (uc1.requester_id = uc2.requester_id OR uc1.requester_id = uc2.addressee_id OR
             uc1.addressee_id = uc2.requester_id OR uc1.addressee_id = uc2.addressee_id)
            AND uc1.id != uc2.id
        )
        WHERE (uc1.requester_id = target_user_id OR uc1.addressee_id = target_user_id)
        AND uc1.status = 'ACCEPTED'
        AND uc2.status = 'ACCEPTED'
    )
    AND u.id NOT IN (
        -- Exclude users already connected
        SELECT CASE WHEN requester_id = target_user_id THEN addressee_id ELSE requester_id END
        FROM user_connections
        WHERE (requester_id = target_user_id OR addressee_id = target_user_id)
        AND status IN ('ACCEPTED', 'PENDING')
    )
    LIMIT 10;
    
    -- Generate recommendations based on same batch and department
    INSERT INTO user_recommendations (user_id, recommendation_type, recommended_entity_type, recommended_entity_id, relevance_score, reason_code, reason_description)
    SELECT DISTINCT
        target_user_id,
        'CONNECTION',
        'USER',
        u.id,
        0.7,
        'SAME_BATCH_DEPARTMENT',
        'Same batch and department'
    FROM users u
    JOIN user_profiles up ON u.id = up.user_id
    WHERE u.id != target_user_id
    AND u.is_active = true
    AND up.batch_year_id = user_profile.batch_year_id
    AND up.department_id = user_profile.department_id
    AND u.id NOT IN (
        SELECT recommended_entity_id FROM user_recommendations 
        WHERE user_id = target_user_id AND recommended_entity_type = 'USER'
    )
    AND u.id NOT IN (
        SELECT CASE WHEN requester_id = target_user_id THEN addressee_id ELSE requester_id END
        FROM user_connections
        WHERE (requester_id = target_user_id OR addressee_id = target_user_id)
        AND status IN ('ACCEPTED', 'PENDING')
    )
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

