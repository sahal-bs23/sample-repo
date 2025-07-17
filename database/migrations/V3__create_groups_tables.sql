-- V3__create_groups_tables.sql
-- Tables for group management system

-- Create groups table
CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    creator_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Group settings
    visibility group_visibility DEFAULT 'PUBLIC',
    is_active BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    max_members INTEGER,
    current_member_count INTEGER DEFAULT 1, -- Creator is automatically a member
    
    -- Media
    cover_image_url VARCHAR(500),
    avatar_image_url VARCHAR(500),
    
    -- Group metadata
    group_type VARCHAR(50) DEFAULT 'GENERAL', -- 'GENERAL', 'DEPARTMENT', 'BATCH', 'PROFESSIONAL', 'HOBBY'
    tags JSONB, -- Array of tags for categorization
    
    -- SEO and discovery
    slug VARCHAR(255) UNIQUE,
    is_featured BOOLEAN DEFAULT false,
    is_searchable BOOLEAN DEFAULT true,
    
    -- Activity tracking
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create group_members table
CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Membership details
    role VARCHAR(20) DEFAULT 'MEMBER', -- 'CREATOR', 'ADMIN', 'MODERATOR', 'MEMBER'
    status VARCHAR(20) DEFAULT 'ACTIVE', -- 'PENDING', 'ACTIVE', 'SUSPENDED', 'BANNED'
    
    -- Join details
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by BIGINT REFERENCES users(id),
    
    -- Activity tracking
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    
    -- Permissions
    can_post BOOLEAN DEFAULT true,
    can_invite BOOLEAN DEFAULT false,
    can_moderate BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(group_id, user_id)
);

-- Create group_invitations table
CREATE TABLE group_invitations (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    inviter_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitee_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    
    -- Invitation details
    invitee_email VARCHAR(255), -- For inviting non-users
    invitation_token VARCHAR(255) UNIQUE,
    message TEXT,
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED'
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '7 days'),
    responded_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create group_join_requests table (for private groups)
CREATE TABLE group_join_requests (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Request details
    message TEXT,
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    
    -- Response details
    reviewed_by BIGINT REFERENCES users(id),
    reviewed_at TIMESTAMP,
    review_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(group_id, user_id)
);

-- Create group_categories table
CREATE TABLE group_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6',
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create group_category_mappings table (many-to-many)
CREATE TABLE group_category_mappings (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES group_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, category_id)
);

-- Create group_rules table
CREATE TABLE group_rules (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    rule_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create group_announcements table
CREATE TABLE group_announcements (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Announcement content
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT false,
    
    -- Visibility and targeting
    is_active BOOLEAN DEFAULT true,
    target_roles JSONB, -- Array of roles that can see this announcement
    
    -- Scheduling
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create group_events table (group-specific events)
CREATE TABLE group_events (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    created_by BIGINT NOT NULL REFERENCES users(id),
    is_group_exclusive BOOLEAN DEFAULT false, -- Only group members can register
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, event_id)
);

-- Create group_activity_logs table
CREATE TABLE group_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Activity details
    activity_type VARCHAR(50) NOT NULL, -- 'MEMBER_JOINED', 'MEMBER_LEFT', 'MESSAGE_POSTED', 'ANNOUNCEMENT_CREATED', etc.
    description TEXT,
    metadata JSONB, -- Additional activity data
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_groups_creator_id ON groups(creator_id);
CREATE INDEX idx_groups_visibility ON groups(visibility);
CREATE INDEX idx_groups_is_active ON groups(is_active);
CREATE INDEX idx_groups_group_type ON groups(group_type);
CREATE INDEX idx_groups_is_featured ON groups(is_featured);
CREATE INDEX idx_groups_slug ON groups(slug);
CREATE INDEX idx_groups_last_activity_at ON groups(last_activity_at);
CREATE INDEX idx_groups_created_at ON groups(created_at);

CREATE INDEX idx_group_members_group_id ON group_members(group_id);
CREATE INDEX idx_group_members_user_id ON group_members(user_id);
CREATE INDEX idx_group_members_role ON group_members(role);
CREATE INDEX idx_group_members_status ON group_members(status);
CREATE INDEX idx_group_members_joined_at ON group_members(joined_at);

CREATE INDEX idx_group_invitations_group_id ON group_invitations(group_id);
CREATE INDEX idx_group_invitations_inviter_id ON group_invitations(inviter_id);
CREATE INDEX idx_group_invitations_invitee_id ON group_invitations(invitee_id);
CREATE INDEX idx_group_invitations_status ON group_invitations(status);
CREATE INDEX idx_group_invitations_expires_at ON group_invitations(expires_at);

CREATE INDEX idx_group_join_requests_group_id ON group_join_requests(group_id);
CREATE INDEX idx_group_join_requests_user_id ON group_join_requests(user_id);
CREATE INDEX idx_group_join_requests_status ON group_join_requests(status);

CREATE INDEX idx_group_category_mappings_group_id ON group_category_mappings(group_id);
CREATE INDEX idx_group_category_mappings_category_id ON group_category_mappings(category_id);

CREATE INDEX idx_group_rules_group_id ON group_rules(group_id);
CREATE INDEX idx_group_announcements_group_id ON group_announcements(group_id);
CREATE INDEX idx_group_announcements_author_id ON group_announcements(author_id);
CREATE INDEX idx_group_announcements_published_at ON group_announcements(published_at);

CREATE INDEX idx_group_events_group_id ON group_events(group_id);
CREATE INDEX idx_group_events_event_id ON group_events(event_id);

CREATE INDEX idx_group_activity_logs_group_id ON group_activity_logs(group_id);
CREATE INDEX idx_group_activity_logs_user_id ON group_activity_logs(user_id);
CREATE INDEX idx_group_activity_logs_activity_type ON group_activity_logs(activity_type);
CREATE INDEX idx_group_activity_logs_created_at ON group_activity_logs(created_at);

-- Create full-text search indexes
CREATE INDEX idx_groups_search ON groups USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_group_announcements_search ON group_announcements USING gin(to_tsvector('english', title || ' ' || content));

-- Create triggers for updating updated_at timestamps
CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_members_updated_at BEFORE UPDATE ON group_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_invitations_updated_at BEFORE UPDATE ON group_invitations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_join_requests_updated_at BEFORE UPDATE ON group_join_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_categories_updated_at BEFORE UPDATE ON group_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_rules_updated_at BEFORE UPDATE ON group_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_announcements_updated_at BEFORE UPDATE ON group_announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update group member count
CREATE OR REPLACE FUNCTION update_group_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'ACTIVE' THEN
            UPDATE groups SET current_member_count = current_member_count + 1 WHERE id = NEW.group_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status != 'ACTIVE' AND NEW.status = 'ACTIVE' THEN
            UPDATE groups SET current_member_count = current_member_count + 1 WHERE id = NEW.group_id;
        ELSIF OLD.status = 'ACTIVE' AND NEW.status != 'ACTIVE' THEN
            UPDATE groups SET current_member_count = current_member_count - 1 WHERE id = NEW.group_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.status = 'ACTIVE' THEN
            UPDATE groups SET current_member_count = current_member_count - 1 WHERE id = OLD.group_id;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for member count updates
CREATE TRIGGER trigger_update_group_member_count
    AFTER INSERT OR UPDATE OR DELETE ON group_members
    FOR EACH ROW EXECUTE FUNCTION update_group_member_count();

-- Create function to update group last activity
CREATE OR REPLACE FUNCTION update_group_last_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE groups SET last_activity_at = CURRENT_TIMESTAMP WHERE id = NEW.group_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updating group last activity
CREATE TRIGGER trigger_update_group_activity_on_member_join
    AFTER INSERT ON group_members
    FOR EACH ROW EXECUTE FUNCTION update_group_last_activity();

CREATE TRIGGER trigger_update_group_activity_on_announcement
    AFTER INSERT ON group_announcements
    FOR EACH ROW EXECUTE FUNCTION update_group_last_activity();

